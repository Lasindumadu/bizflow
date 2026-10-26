import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/customer_credit_repository.dart';

/// Customer credit detail screen.
class CustomerCreditDetailScreen extends StatefulWidget {
  final CustomerCreditRecord account;

  const CustomerCreditDetailScreen({super.key, required this.account});

  @override
  State<CustomerCreditDetailScreen> createState() => _CustomerCreditDetailScreenState();
}

class _CustomerCreditDetailScreenState extends State<CustomerCreditDetailScreen> {
  final CustomerCreditRepository _repository = CustomerCreditRepository(appDatabase);

  late Future<List<CustomerCreditTransactionRecord>> _transactionsFuture;
  bool _isLoadingTransactions = true;

  final _paymentAmountController = TextEditingController();
  final _paymentRefController = TextEditingController();
  final _paymentDescController = TextEditingController();
  final _adjustmentAmountController = TextEditingController();
  final _adjustmentReasonController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoadingTransactions = true);
    try {
      final txns = await _repository.getTransactions(widget.account.id);
      _transactionsFuture = Future.value(txns);
    } finally {
      if (mounted) setState(() => _isLoadingTransactions = false);
    }
  }

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  /// Royal focus ring applied on top of the base theme decoration.
  InputDecoration _royalField(InputDecoration base) {
    return base.copyWith(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.royalMid, width: 1.7),
      ),
    );
  }



  Future<void> _recordPayment() async {
    final amount = double.tryParse(_paymentAmountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid payment amount')),
      );
      return;
    }
    if (amount > widget.account.currentBalance) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Overpayment?'),
          content: Text(
            'Payment amount (\$${amount.toStringAsFixed(2)}) exceeds current balance (\$${widget.account.currentBalance.toStringAsFixed(2)}).\n\n'
            'This will create a credit balance. Continue?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continue')),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
    }

    final ref = _paymentRefController.text.trim();
    if (ref.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a payment reference')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _repository.recordPayment(
        customerId: widget.account.customerId,
        amount: amount,
        paymentReference: ref,
        description: _paymentDescController.text.trim(),
      );
      if (!mounted) return;
      _paymentAmountController.clear();
      _paymentRefController.clear();
      _paymentDescController.clear();
      Navigator.of(context).pop();
      await _loadTransactions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record payment: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _recordAdjustment() async {
    final amount = double.tryParse(_adjustmentAmountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid adjustment amount')),
      );
      return;
    }
    if (_adjustmentReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a reason for the adjustment')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await _repository.recordAdjustment(
        customerId: widget.account.customerId,
        amount: amount,
        reason: _adjustmentReasonController.text.trim(),
      );
      if (!mounted) return;
      _adjustmentAmountController.clear();
      _adjustmentReasonController.clear();
      Navigator.of(context).pop();
      await _loadTransactions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adjustment recorded successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record adjustment: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPaymentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppDimensions.screenPadding,
          right: AppDimensions.screenPadding,
          top: AppDimensions.screenPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record Payment', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _paymentAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _royalField(
                const InputDecoration(
                  labelText: 'Amount *',
                  prefixIcon: Icon(Icons.attach_money_outlined),
                  hintText: 'e.g. 100.00',
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _paymentRefController,
              decoration: const InputDecoration(
                labelText: 'Payment Reference *',
                prefixIcon: Icon(Icons.receipt_outlined),
                hintText: 'e.g. Cash, Card ending 1234, Bank Transfer',
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _paymentDescController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.notes_outlined),
                hintText: 'Optional notes',
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: GradientButton(
                    label: _isProcessing ? 'Processing…' : 'Record Payment',
                    icon: Icons.save_rounded,
                    gradient: AppDecor.royalGradient.colors,
                    isLoading: _isProcessing,
                    onPressed: _isProcessing ? null : _recordPayment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
          ],
        ),
      ),
    );
  }

  void _showAdjustmentDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppDimensions.screenPadding,
          right: AppDimensions.screenPadding,
          top: AppDimensions.screenPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record Adjustment', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _adjustmentAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: _royalField(
                const InputDecoration(
                  labelText: 'Amount * (positive = charge, negative = credit)',
                  prefixIcon: Icon(Icons.tune_outlined),
                  hintText: 'e.g. 50.00 or -25.00',
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _adjustmentReasonController,
              decoration: const InputDecoration(
                labelText: 'Reason *',
                prefixIcon: Icon(Icons.notes_outlined),
                hintText: 'e.g. Write-off, discount, correction',
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: GradientButton(
                    label: _isProcessing ? 'Processing…' : 'Record Adjustment',
                    icon: Icons.save_rounded,
                    gradient: AppDecor.royalGradient.colors,
                    isLoading: _isProcessing,
                    onPressed: _isProcessing ? null : _recordAdjustment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _paymentRefController.dispose();
    _paymentDescController.dispose();
    _adjustmentAmountController.dispose();
    _adjustmentReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOverLimit = widget.account.isOverLimit;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.customerName),
        actions: [
          if (widget.account.isActive)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'deactivate') {
                  // Would need a callback to parent to update
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Use the main screen to deactivate')),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'deactivate', child: Text('Deactivate Credit')),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: CustomScrollView(
          slivers: [
            // Account summary header — photo micro-wash with mint hero.
            SliverToBoxAdapter(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                child: SizedBox(
                  height: 206,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AppImages.shoppingCustomers,
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, 0.3),
                      ),
                      for (final g in AppDecor.photoWash(anchor: 'top'))
                        DecoratedBox(decoration: BoxDecoration(gradient: g)),
                      Padding(
                        padding: const EdgeInsets.all(AppDimensions.screenPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  'Current Balance'.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.auroraTeal,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _money(widget.account.currentBalance),
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.displayFont,
                                      color: isOverLimit
                                          ? AppColors.brandCoral
                                          : AppColors.brandMint,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.9,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Credit Limit',
                                      style: TextStyle(
                                        color: AppColors.onPhotoSoft,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      _money(widget.account.creditLimit),
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.displayFont,
                                        color: AppColors.onPhoto,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Available: ${_money(widget.account.availableCredit)}',
                                      style: TextStyle(
                                        color: widget.account.availableCredit < 0
                                            ? AppColors.brandCoral
                                            : AppColors.onPhotoSoft,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryItem(
                                    label: 'Payment Terms',
                                    value: widget.account.paymentTerms,
                                    icon: Icons.schedule_outlined,
                                  ),
                                ),
                                Expanded(
                                  child: _SummaryItem(
                                    label: 'Status',
                                    value: widget.account.isActive ? 'Active' : 'Inactive',
                                    icon: widget.account.isActive ? Icons.check_circle_outline : Icons.block_outlined,
                                    color: widget.account.isActive ? AppColors.auroraTeal : AppColors.brandCoral,
                                  ),
                                ),
                                Expanded(
                                  child: _SummaryItem(
                                    label: 'Since',
                                    value: _formatDate(widget.account.createdAt).split(' ')[0],
                                    icon: Icons.calendar_today_outlined,
                                  ),
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
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: 'Record Payment',
                        icon: Icons.add_card_outlined,
                        gradient: AppDecor.royalGradient.colors,
                        height: 48,
                        onPressed: _showPaymentDialog,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: SoftButton(
                        label: 'Adjustment',
                        icon: Icons.tune_outlined,
                        color: AppColors.warning,
                        onPressed: _showAdjustmentDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Transactions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding),
                child: Text('Transaction History', style: AppTextStyles.heading3),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: FutureBuilder<List<CustomerCreditTransactionRecord>>(
                  future: _transactionsFuture,
                  builder: (context, snapshot) {
                    if (_isLoadingTransactions) {
                      return const AppLoadingState(message: 'Loading transactions…');
                    }

                    if (snapshot.hasError) {
                      return AppErrorState(message: snapshot.error.toString(), onRetry: _loadTransactions);
                    }

                    final txns = snapshot.data ?? const <CustomerCreditTransactionRecord>[];

                    if (txns.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No transactions yet',
                        message: 'Credit sales, payments, and adjustments will appear here.',
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < txns.length; i++)
                          _TimelineTxnRow(
                            txn: txns[i],
                            isLast: i == txns.length - 1,
                            scheme: scheme,
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ledger row with a timeline rail: gradient status dot + connector line.
class _TimelineTxnRow extends StatelessWidget {
  final CustomerCreditTransactionRecord txn;
  final bool isLast;
  final ColorScheme scheme;

  const _TimelineTxnRow({
    required this.txn,
    required this.isLast,
    required this.scheme,
  });

  String get _typeLabel {
    switch (txn.type) {
      case 'invoice':
        return 'INVOICE';
      case 'payment':
        return 'PAYMENT';
      case 'adjustment':
        return 'ADJUSTMENT';
      case 'credit_note':
        return 'CREDIT NOTE';
      default:
        return txn.type.toUpperCase();
    }
  }

  Color get _typeColor {
    switch (txn.type) {
      case 'invoice':
        return AppColors.royalMid;
      case 'payment':
        return AppColors.brandMint;
      case 'adjustment':
        return AppColors.warning;
      case 'credit_note':
        return AppColors.info;
      default:
        return AppColors.chartGray;
    }
  }

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final isPositive = txn.amount > 0;
    final typeColor = _typeColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeIcon = switch (txn.type) {      'invoice' => Icons.receipt_long_outlined,
      'payment' => Icons.payments_outlined,
      'adjustment' => Icons.tune_outlined,
      'credit_note' => Icons.assignment_return_outlined,
      _ => Icons.help_outline,
    };
    String formatDate(DateTime d) {
      final local = d.toLocal();
      return '${local.day.toString().padLeft(2, '0')}/'
          '${local.month.toString().padLeft(2, '0')}/${local.year} '
          '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        typeColor.withValues(alpha: 0.85),
                        typeColor,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppDecor.glow(typeColor, alpha: 0.4),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Opacity(
                      opacity: isDark ? 0.9 : 0.55,
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          gradient: AppDecor.auroraBar,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
              child: HoverLiftCard(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Row(
                  children: [
                    IconTile(
                      icon: typeIcon,
                      gradient: [
                        typeColor.withValues(alpha: 0.2),
                        typeColor.withValues(alpha: 0.1),
                      ],
                      size: 40,
                      iconSize: 18,
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusBadge(
                                label: _typeLabel,
                                color: typeColor,
                                icon: typeIcon,
                              ),
                              const SizedBox(width: AppDimensions.spacingSm),
                              Expanded(
                                child: Text(
                                  txn.description ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (txn.reference != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              txn.reference!,
                              style: AppTextStyles.caption.copyWith(
                                color: scheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPositive ? '+' : ''}${_money(txn.amount)}',
                          style: AppTextStyles.priceSmall.copyWith(
                            color: isPositive ? AppColors.error : AppColors.brandMint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          formatDate(txn.createdAt),
                          style: AppTextStyles.caption.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: effectiveColor.withValues(alpha: 0.8)),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.caption.copyWith(color: effectiveColor.withValues(alpha: 0.8))),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(color: effectiveColor, fontWeight: FontWeight.w600)),
      ],
    );
  }
}