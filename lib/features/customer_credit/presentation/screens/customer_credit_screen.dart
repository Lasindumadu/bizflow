import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
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

            if (filtered.isEmpty) {
              return AppEmptyState(
                icon: Icons.credit_card_outlined,
                title: accounts.isEmpty ? 'No credit accounts' : 'No matching accounts',
                message: accounts.isEmpty
                    ? 'Enable credit for customers to track accounts receivable.'
                    : 'Try changing the filter.',
                actionLabel: accounts.isEmpty ? 'Manage Customers' : null,
                onAction: null,
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final account = filtered[index];
                return _AccountTile(
                  account: account,
                  onTap: () => _openDetail(account),
                  onDeactivate: account.isActive ? () => _confirmDeactivate(account) : null,
                ).animate(delay: Duration(milliseconds: 100 + 50 * index))
                  .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
                  .slideX(begin: 0.1, end: 0);
              },
            );
          },
        ),
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOverLimit = account.isOverLimit;
    final hasBalance = account.currentBalance > 0;

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
                IconTile(
                  icon: isOverLimit
                      ? Icons.warning_amber_rounded
                      : (hasBalance ? Icons.credit_card_rounded : Icons.credit_card_outlined),
                  gradient: isOverLimit
                      ? AppDecor.errorGradient.colors
                      : (hasBalance ? AppDecor.warningGradient.colors : AppDecor.successGradient.colors),
                  size: 48,
                  iconSize: 22,
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
                          if (!account.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.outline.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'INACTIVE',
                                style: AppTextStyles.labelSmall.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Limit: ${_money(account.creditLimit)}  •  Terms: ${account.paymentTerms}',
                        style: AppTextStyles.caption.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(account.currentBalance),
                      style: AppTextStyles.priceSmall.copyWith(
                        color: isOverLimit
                            ? AppColors.error
                            : (hasBalance ? AppColors.warning : AppColors.success),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Available: ${_money(account.availableCredit)}',
                      style: AppTextStyles.caption.copyWith(
                        color: account.availableCredit < 0 ? AppColors.error : scheme.onSurface.withValues(alpha: 0.55),
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