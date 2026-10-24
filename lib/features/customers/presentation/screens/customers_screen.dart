import 'package:flutter/material.dart';

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
                // final query = _searchController.text.trim().toLowerCase();
                final customers = snapshot.data ?? [];
                final filteredCustomers =
                    customers.where((customer) {
                      final query = _searchController.text.trim().toLowerCase();
                      if (query.isEmpty) {
                        return true;
                      }
                      return customer.name.toLowerCase().contains(query) ||
                          customer.phone.toLowerCase().contains(query) ||
                          customer.email.toLowerCase().contains(query);
                    }).toList()..sort(
                      (a, b) => a.name.trim().toLowerCase().compareTo(
                        b.name.trim().toLowerCase(),
                      ),
                    );
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: PageHero(
                        eyebrow: 'Relationships',
                        title: 'Customers & loyalty',
                        subtitle:
                            '${customers.length} people in your directory · '
                            'balances, credit and points in one place.',
                        showIllustration: false,
                        action: FilledButton.icon(
                          onPressed: _openAddCustomer,
                          icon: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 18,
                          ),
                          label: const Text('Add customer'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    _buildSearchField(),
                    Expanded(
                      child: filteredCustomers.isEmpty
                          ? customers.isEmpty
                                ? _buildEmptyState()
                                : _buildNoResultsState()
                          : ListView.separated(
                              padding: const EdgeInsets.all(
                                AppDimensions.screenPadding,
                              ),
                              itemCount: filteredCustomers.length,
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: AppDimensions.spacingMd,
                                );
                              },
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];
                                return _CustomerCard(
                                  customer: customer,
                                  currency: _currency,
                                  onEdit: () {
                                    _openEditCustomer(customer);
                                  },
                                  onDelete: () {
                                    _confirmDeleteCustomer(customer);
                                  },
                                  onCredit: () {
                                    _openCustomerCredit(customer);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppDecor.indigoGradient,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
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

  Widget _buildEmptyState() {
    return Center(
      child: BrandEmptyState(
        title: 'No customers yet',
        message:
            'Add your first customer to track purchases, loyalty points and '
            'outstanding balances.',
        actionLabel: 'Add customer',
        onAction: _openAddCustomer,
        icon: Icons.people_outline_rounded,
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
  final VoidCallback onDelete;
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
    final hasPhone = customer.phone.trim().isNotEmpty;
    final hasEmail = customer.email.trim().isNotEmpty;
    final owes = customer.outstandingBalance > 0;
    final hasPoints = customer.pointsBalance > 0;

    return BrandCard(
      padding: const EdgeInsets.all(14),
      radius: 16,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B6CFF), Color(0xFF5B5BF7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
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
                      color: AppColors.primary,
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
              if (value == 'delete') onDelete();
              if (value == 'credit') onCredit();
            },
            itemBuilder: (context) => const [
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
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline_rounded, size: 18),
                  title: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
