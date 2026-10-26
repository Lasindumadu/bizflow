import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/customer_credit_repository.dart';
import '../../../../data/repositories/customer_repository.dart';
import '../../../customer_credit/presentation/screens/customer_credit_detail_screen.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  final bool showAppBar;
  const CustomersScreen({super.key, this.showAppBar = true});
  @override
  State<CustomersScreen> createState() => CustomersScreenState();
}

class CustomersScreenState extends State<CustomersScreen> {
  final CustomerRepository _customerRepository = CustomerRepository(
    appDatabase,
  );
  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository();
  final TextEditingController _searchController = TextEditingController();
  late final Stream<List<Customer>> _customersStream;
  String _currency = 'USD';
  bool _isLoadingSettings = true;
  String _customerFilter = _filterAll;

  static const _filterAll = 'All';
  static const _filterOwesOnly = 'Owes credit';
  static const _filterLoyaltyOnly = 'Loyalty members';
  @override
  void initState() {
    super.initState();
    _customersStream = _customerRepository.watchCustomers();
    _loadBusinessSettings();
  }

  void _openAddCustomer() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddCustomerScreen()));
  }

  /// Whether the acting session is the owner (customer deletion is owner-only).
  bool get _isOwner => canPerform(
        sessionController.current,
        {StaffRole.owner},
      );

  Future<void> refreshBusinessSettings() async {
    await _loadBusinessSettings();
  }

  Future<void> _loadBusinessSettings() async {
    final settings = await _businessSettingsRepository.getSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _currency = settings.currency;
      _isLoadingSettings = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditCustomer(Customer customer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(customer: customer),
      ),
    );
  }

  Future<void> _openCustomerCredit(Customer customer) async {
    final creditRepo = CustomerCreditRepository(appDatabase);
    final account = await creditRepo.getCreditAccountByCustomer(customer.id);
    
    if (!mounted) return;
    
    if (account == null) {
      // Ask if they want to create a credit account
      final shouldCreate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Create Credit Account?'),
          content: Text(
            '"${customer.name}" does not have a credit account yet.\n\n'
            'Would you like to create one to track their outstanding balance and payment terms?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
          ],
        ),
      );
      
      if (shouldCreate != true) return;
      
      // Create the account
      final newAccount = await creditRepo.ensureCreditAccount(customer.id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CustomerCreditDetailScreen(account: newAccount),
        ),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CustomerCreditDetailScreen(account: account),
        ),
      );
    }
  }

  Future<void> _confirmDeleteCustomer(Customer customer) async {
    final hasOutstandingBalance = customer.outstandingBalance > 0;
    final colorScheme = Theme.of(context).colorScheme;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Customer?',
            style: AppTextStyles.heading3.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to permanently delete '
                '"${customer.name}"?\n\n'
                'This action cannot be undone.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              if (hasOutstandingBalance) ...[
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'Warning: This customer has an outstanding balance of '
                  '$_currency '
                  '${customer.outstandingBalance.toStringAsFixed(2)}.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onErrorContainer,
              ),
              child: Text('Delete', style: AppTextStyles.labelLarge),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) {
      return;
    }
    try {
      await _customerRepository.deleteCustomer(customer.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete customer: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text(
          'Customers',
          style: AppTextStyles.heading3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppDecor.heroGradient(
              Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacingLg),
            child: FilledButton.icon(
              onPressed: _openAddCustomer,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add Customer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.onPrimary,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.buttonRadius,
                  ),
                ),
              ),
            ),
          ),
        ],
      ) : null,
      body: _isLoadingSettings
          ? _buildLoadingState()
          : StreamBuilder<List<Customer>>(
              stream: _customersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }
                final customers = snapshot.data ?? [];
                final loyaltyMembers =
                    customers.where((c) => c.pointsBalance > 0).length;
                final showLoyaltyOnly = _customerFilter == _filterLoyaltyOnly;
                final showOwesOnly = _customerFilter == _filterOwesOnly;
                final filteredCustomers =
                    customers.where((customer) {
                      final query = _searchController.text.trim().toLowerCase();
                      if (query.isNotEmpty) {
                        final matchesQuery =
                            customer.name.toLowerCase().contains(query) ||
                                customer.phone.toLowerCase().contains(query) ||
                                customer.email.toLowerCase().contains(query);
                        if (!matchesQuery) {
                          return false;
                        }
                      }
                      if (showLoyaltyOnly && customer.pointsBalance <= 0) {
                        return false;
                      }
                      if (showOwesOnly && customer.outstandingBalance <= 0) {
                        return false;
                      }
                      return true;
                    }).toList()..sort(
                      (a, b) => a.name.trim().toLowerCase().compareTo(
                        b.name.trim().toLowerCase(),
                      ),
                    );
                // Slivers instead of a pinned Column: hero, KPI strip,
                // filters and search all scroll away with the content so
                // customer cards reclaim the full screen while scrolling.
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: PageHero(
                          eyebrow: 'Relationships',
                          title: 'Customers & loyalty',
                          subtitle:
                              '${customers.length} customers · '
                              '$loyaltyMembers loyalty members · '
                              'balances, credit and points in one place.',
                          showIllustration: false,
                          image: AppImages.shoppingCustomers,
                          action: _HeroGradientCta(
                            icon: Icons.person_add_alt_1_rounded,
                            label: 'Add customer',
                            onTap: _openAddCustomer,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                            duration: 380.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic),
                    ),
                    SliverToBoxAdapter(child: _buildKpiRow(customers)),
                    SliverToBoxAdapter(child: _buildFilterChips()),
                    SliverToBoxAdapter(child: _buildSearchField()),
                    if (filteredCustomers.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: customers.isEmpty
                              ? _buildEmptyState(
                                  key: const ValueKey('empty'),
                                )
                              : _buildNoResultsState(),
                        ),
                      )
                    else
                      _buildCustomerList(filteredCustomers),
                    // Breathing room under the last card.
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppDimensions.spacingXl),
                    ),
                  ],
                );
              },
            ),
    );
  }

  /// KPI strip: people (care rose), loyalty (amber), money owed (mint).
  Widget _buildKpiRow(List<Customer> customers) {
    final loyaltyMembers = customers.where((c) => c.pointsBalance > 0).length;
    final totalPoints = customers.fold<int>(0, (sum, c) => sum + c.pointsBalance);
    final outstanding = customers.fold<double>(
      0,
      (sum, c) => sum + c.outstandingBalance,
    );

    final cards = [
      MetricCard(
        compact: true,
        label: 'Total customers',
        value: '${customers.length}',
        icon: Icons.groups_2_rounded,
        gradient: const [Color(0xFFFB7185), AppColors.rose],
      ),
      MetricCard(
        compact: true,
        label: 'Loyalty points',
        value: '$totalPoints',
        helper: '$loyaltyMembers members earning',
        icon: Icons.stars_rounded,
        gradient: const [AppColors.tertiaryLight, AppColors.tertiaryDark],
      ),
      MetricCard(
        compact: true,
        label: 'Credit outstanding',
        value: '$_currency ${outstanding.toStringAsFixed(2)}',
        helper: 'owed across all customers',
        icon: Icons.account_balance_wallet_rounded,
        gradient: const [AppColors.brandMint, AppColors.brandMintDeep],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i < cards.length - 1) const SizedBox(width: 12),
          ],
        ],
      )
          .animate(delay: 90.ms)
          .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
          .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic),
    );
  }

  /// Royal-selected quick filters (presentation-only refinement).
  Widget _buildFilterChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chips = [
      (_filterAll, Icons.all_inclusive_rounded),
      (_filterOwesOnly, Icons.account_balance_wallet_rounded),
      (_filterLoyaltyOnly, Icons.stars_rounded),
    ];

    Widget buildChip(String label, IconData icon) {
      final selected = _customerFilter == label;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: selected ? AppDecor.royalGradient : null,
          color: selected
              ? null
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.lightBorder),
          ),
          boxShadow: selected
              ? AppDecor.glow(AppColors.royalMid, alpha: 0.28)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _customerFilter = label),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: selected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final chip in chips) ...[
              buildChip(chip.$1, chip.$2),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  /// First screenful gets the staggered entrance; longer lists skip motion.
  /// Returned as a [SliverList] so it composes inside the page's
  /// [CustomScrollView].
  Widget _buildCustomerList(List<Customer> filteredCustomers) {
    final itemCount = filteredCustomers.length;
    return SliverList.separated(
      key: const ValueKey('list'),
      itemCount: filteredCustomers.length,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: AppDimensions.spacingMd,
        );
      },
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        final tile = _CustomerCard(
          customer: customer,
          currency: _currency,
          onEdit: () {
            _openEditCustomer(customer);
          },
          onDelete: _isOwner
              ? () {
                  _confirmDeleteCustomer(customer);
                }
              : null,
          onCredit: () {
            _openCustomerCredit(customer);
          },
        );
        if (index >= itemCount.clamp(0, 12)) {
          return tile;
        }
        return tile
            .animate(delay: (120 + 60 * index).ms)
            .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
            .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: BrandCard(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: _searchController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Search by name, phone or email…',
            prefixIcon: const Icon(Icons.search_rounded, size: 19),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear_rounded, size: 17),
                  ),
            isDense: true,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXxl),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: AppDecor.cardShadow(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuroraLoader(size: 52),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                'Loading customers',
                style: AppTextStyles.heading2.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Please wait while we load your customers.',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({Key? key}) {
    return Center(
      key: key,
      child: BrandEmptyState(
        title: 'No customers yet',
        message:
            'Add your first customer to track purchases, loyalty points and '
            'outstanding balances.',
        actionLabel: 'Add customer',
        onAction: _openAddCustomer,
        icon: Icons.people_outline_rounded,
        image: AppImages.shoppingCustomers,
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: BrandEmptyState(
        compact: true,
        title: 'No customers found',
        message: 'Try a different name, phone number or email.',
        icon: Icons.search_off_outlined,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'Unable to load customers',
              style: AppTextStyles.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Something went wrong while loading your customers.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            FilledButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onCredit;

  const _CustomerCard({
    required this.customer,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    required this.onCredit,
  });

  String get _initials {
    final parts = customer.name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    final name = customer.name.trim();
    return name.isEmpty ? '?' : name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhone = customer.phone.trim().isNotEmpty;
    final hasEmail = customer.email.trim().isNotEmpty;
    final owes = customer.outstandingBalance > 0;
    final hasPoints = customer.pointsBalance > 0;
    final pointsColor = isDark ? AppColors.rose : AppColors.careTint[1];

    return BrandCard(
      padding: const EdgeInsets.all(14),
      radius: 16,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppDecor.royalGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.royalMid.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    if (owes)
                      BrandPill(
                        label:
                            '$currency ${customer.outstandingBalance.toStringAsFixed(2)}',
                        color: AppColors.error,
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  hasPhone
                      ? customer.phone
                      : hasEmail
                          ? customer.email
                          : 'No contact details yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.46),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    BrandPill(
                      label: customer.loyaltyTier.toUpperCase(),
                      color: AppColors.brandAmber,
                      icon: Icons.workspace_premium_rounded,
                    ),
                    BrandPill(
                      label: hasPoints
                          ? '${customer.pointsBalance} PTS'
                          : 'NO POINTS',
                      color: pointsColor,
                      icon: Icons.stars_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 2),
          PopupMenuButton<String>(
            tooltip: 'Customer actions',
            offset: const Offset(0, 36),
            icon: Icon(
              Icons.more_horiz_rounded,
              size: 19,
              color: scheme.onSurface.withValues(alpha: 0.42),
            ),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete?.call();
              if (value == 'credit') onCredit();
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined, size: 18),
                    title: Text('Edit customer'),
                  ),
                ),
                PopupMenuItem(
                  value: 'credit',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.credit_card_outlined, size: 18),
                    title: Text('Credit account'),
                  ),
                ),
                if (onDelete != null)
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.delete_outline_rounded, size: 18),
                      title: Text('Delete'),
                    ),
                  ),
              ];
              return items;
            },
          ),
        ],
      ),
    );
  }
}

/// Primary gradient CTA used inside the photo hero — royal brand ramp
/// with a glow + press scale, per the Aurora 2.0 button rules.
class _HeroGradientCta extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeroGradientCta({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HeroGradientCta> createState() => _HeroGradientCtaState();
}

class _HeroGradientCtaState extends State<_HeroGradientCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final button = AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppDecor.royalGradient,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.4),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(999),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: button,
    );
  }
}
