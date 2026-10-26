import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/customer_credit_repository.dart';
import 'customer_credit_detail_screen.dart';

/// Customer credit management screen.
class CustomerCreditScreen extends StatefulWidget {
  const CustomerCreditScreen({super.key});

  @override
  State<CustomerCreditScreen> createState() => _CustomerCreditScreenState();
}

class _CustomerCreditScreenState extends State<CustomerCreditScreen> {
  final CustomerCreditRepository _repository = CustomerCreditRepository(appDatabase);

  late Future<List<CustomerCreditRecord>> _accountsFuture;
  String _filter = 'All'; // All, Active, Overdue

  @override
  void initState() {
    super.initState();
    _accountsFuture = _repository.getCreditAccounts();
  }

  Future<void> _refresh() async {
    setState(() => _accountsFuture = _repository.getCreditAccounts());
    await _accountsFuture;
  }

  Future<void> _openDetail(CustomerCreditRecord account) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CustomerCreditDetailScreen(account: account)),
    );
    if (result == true) _refresh();
  }

  Future<void> _confirmDeactivate(CustomerCreditRecord account) async {
    final shouldDeactivate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Credit Account?'),
        content: Text(
          'Deactivate credit for ${account.customerName}?\n\n'
          'They will not be able to make new credit purchases until reactivated.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (shouldDeactivate != true) return;

    try {
      await _repository.updateCreditAccount(accountId: account.id, isActive: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credit account deactivated.')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to deactivate: $e')),
      );
    }
  }

  List<CustomerCreditRecord> _filterAccounts(List<CustomerCreditRecord> accounts) {
    switch (_filter) {
      case 'Active':
        return accounts.where((a) => a.isActive).toList();
      case 'Overdue':
        return accounts.where((a) => a.currentBalance > 0).toList();
      default:
        return accounts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Credit').animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0),
        actions: [
          PopupMenuButton<String>(
            initialValue: _filter,
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'All', child: Text('All Accounts')),
              PopupMenuItem(value: 'Active', child: Text('Active Only')),
              PopupMenuItem(value: 'Overdue', child: Text('With Balance')),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: 0.2, end: 0),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<CustomerCreditRecord>>(
          future: _accountsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingState(message: 'Loading credit accounts…').animate().fadeIn(duration: 300.ms);
            }

            if (snapshot.hasError) {
              return AppErrorState(message: snapshot.error.toString(), onRetry: _refresh)
                  .animate().fadeIn(duration: 300.ms).shake();
            }

            final accounts = snapshot.data ?? const <CustomerCreditRecord>[];
            final filtered = _filterAccounts(accounts);

            if (filtered.isEmpty && accounts.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                children: [
                  AppEmptyState(
                    icon: Icons.credit_card_outlined,
                    title: 'No credit accounts',
                    message:
                        'Enable credit for customers to track accounts receivable.',
                    actionLabel: 'Manage Customers',
                    onAction: null,
                  ).animate().fadeIn(duration: 400.ms),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CreditHeaderBand(accounts: accounts)
                      .animate()
                      .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
                      .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic);
                }

                final itemIndex = index - 1;
                if (itemIndex >= filtered.length) {
                  return const SizedBox.shrink();
                }

                if (filtered.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spacingSm),
                    child: AppEmptyState(
                      icon: Icons.filter_alt_off_rounded,
                      title: 'No matching accounts',
                      message: 'Try changing the filter.',
                    ).animate().fadeIn(duration: 400.ms),
                  );
                }

                final account = filtered[itemIndex];
                final tile = _AccountTile(
                  account: account,
                  onTap: () => _openDetail(account),
                  onDeactivate: account.isActive ? () => _confirmDeactivate(account) : null,
                );
                if (itemIndex >= 12) {
                  return tile;
                }
                return tile
                    .animate(delay: (90 + 50 * itemIndex).ms)
                    .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
                    .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic);
              },
            );
          },
        ),
      ),
    );
  }
}

/// Photo micro-wash band: mint outstanding hero + royal/red context chips.
class _CreditHeaderBand extends StatelessWidget {
  final List<CustomerCreditRecord> accounts;

  const _CreditHeaderBand({required this.accounts});

  @override
  Widget build(BuildContext context) {
    final outstanding = accounts.fold<double>(
      0,
      (sum, a) => sum + a.currentBalance,
    );
    final overLimitCount = accounts.where((a) => a.isOverLimit).length;
    final owesCount = accounts.where((a) => a.currentBalance > 0).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AppImages.shoppingCustomers,
                fit: BoxFit.cover,
                alignment: const Alignment(0, 0.35),
              ),
              for (final g in AppDecor.photoWash(anchor: 'left'))
                DecoratedBox(decoration: BoxDecoration(gradient: g)),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 14,
                          color: AppColors.auroraTeal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ACCOUNTS RECEIVABLE'.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.auroraTeal,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${outstanding.toStringAsFixed(2)}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        color: AppColors.onPhoto,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total outstanding credit across all customers',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.onPhotoSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _BandStatChip(
                          label: '$owesCount with balance',
                          color: AppColors.auroraLilac,
                          icon: Icons.credit_card_rounded,
                        ),
                        const SizedBox(width: 8),
                        _BandStatChip(
                          label: '$overLimitCount over limit',
                          color: overLimitCount > 0
                              ? AppColors.brandCoral
                              : AppColors.auroraTeal,
                          icon: Icons.warning_amber_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small glass chip used over the photo wash.
class _BandStatChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _BandStatChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onPhoto,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final CustomerCreditRecord account;
  final VoidCallback onTap;
  final VoidCallback? onDeactivate;

  const _AccountTile({
    required this.account,
    required this.onTap,
    this.onDeactivate,
  });

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  String get _initials {
    final parts = account.customerName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts.first.isNotEmpty && parts.last.isNotEmpty) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    final name = account.customerName.trim();
    return name.isEmpty
        ? '?'
        : name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }

  /// Money semantics stay identical: red when over limit, amber when
  /// there is a balance, mint when settled.
  Color get _amountColor {
    if (account.isOverLimit) return AppColors.error;
    if (account.currentBalance > 0) return AppColors.warning;
    return AppColors.brandMint;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOverLimit = account.isOverLimit;
    final hasBalance = account.currentBalance > 0;
    final statusColor = !account.isActive
        ? AppColors.chartGray
        : isOverLimit
            ? AppColors.error
            : (hasBalance ? AppColors.warning : AppColors.brandMint);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isOverLimit
                        ? AppDecor.errorGradient
                        : AppDecor.royalGradient,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: AppDecor.glow(
                      isOverLimit ? AppColors.error : AppColors.royalMid,
                      alpha: 0.26,
                    ),
                  ),
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              account.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleSmall,
                            ),
                          ),
                          StatusBadge(
                            label: !account.isActive
                                ? 'INACTIVE'
                                : isOverLimit
                                    ? 'OVER LIMIT'
                                    : (hasBalance ? 'OWES' : 'SETTLED'),
                            color: statusColor,
                            icon: !account.isActive
                                ? Icons.pause_rounded
                                : isOverLimit
                                    ? Icons.warning_amber_rounded
                                    : (hasBalance
                                        ? Icons.schedule_rounded
                                        : Icons
                                            .check_circle_outline_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Limit: ${_money(account.creditLimit)}  •  Terms: ${account.paymentTerms}',
                        style: AppTextStyles.caption.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(account.currentBalance),
                      style: AppTextStyles.priceSmall.copyWith(
                        color: _amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Available: ${_money(account.availableCredit)}',
                      style: AppTextStyles.caption.copyWith(
                        color: account.availableCredit < 0
                            ? AppColors.error
                            : scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (onDeactivate != null) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SoftButton(
                    label: 'Deactivate',
                    icon: Icons.block_outlined,
                    color: AppColors.error,
                    onPressed: onDeactivate!,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}