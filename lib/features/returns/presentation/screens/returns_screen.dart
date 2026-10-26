import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/return_repository.dart';
import '../../../../data/repositories/sale_repository.dart';
import '../../../../models/sale.dart';
import '../../../../models/sale_item.dart';

/// Sales returns & refunds.
///
/// Lists completed sales, lets the operator pick one, choose quantities to
/// return (bounded by what is still returnable), choose a refund method and
/// whether to restock. Every return is recorded, restocks inventory (optional),
/// and is written to the audit trail.
class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final SaleRepository _saleRepository = SaleRepository(appDatabase);
  final ReturnRepository _returnRepository = ReturnRepository(appDatabase);
  final BusinessSettingsRepository _settingsRepository =
      BusinessSettingsRepository(appDatabase);

  String _currency = 'USD';
  late Future<List<Sale>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _salesFuture = _loadSales();
    _loadCurrency();
  }

  Future<List<Sale>> _loadSales() async {
    final sales = await _saleRepository.getSales();
    return sales.where((s) => s.status == 'completed').toList();
  }

  Future<void> _loadCurrency() async {
    try {
      final settings = await _settingsRepository.getSettings();
      if (!mounted) return;
      setState(() => _currency = settings.currency);
    } catch (_) {}
  }

  String _money(double v) => '$_currency ${v.toStringAsFixed(2)}';

  Future<void> _openReturnFlow(Sale sale) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ReturnSheet(
        sale: sale,
        currency: _currency,
        returnRepository: _returnRepository,
      ),
    );

    if (done == true) {
      setState(() => _salesFuture = _loadSales());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Return recorded successfully.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Returns & Refunds')),
      body: FutureBuilder<List<Sale>>(
        future: _salesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState(message: 'Loading sales…');
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _salesFuture = _loadSales()),
            );
          }

          final sales = snapshot.data ?? const <Sale>[];

          if (sales.isEmpty) {
            return Column(
              children: [
                _ReturnsHeaderBand(),
                Expanded(
                  child: AppEmptyState(
                    icon: Icons.assignment_return_outlined,
                    title: 'No completed sales',
                    message:
                        'Completed sales will appear here so you can process '
                        'returns and refunds.',
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _ReturnsHeaderBand(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    final tile = Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                      child: HoverLiftCard(
                        padding: const EdgeInsets.all(AppDimensions.spacingMd),
                        onTap: () => _openReturnFlow(sale),
                        child: Row(
                          children: [
                            IconTile(
                              icon: Icons.assignment_return_rounded,
                              gradient: AppDecor.roseGradient.colors,
                              size: 44,
                              iconSize: 21,
                            ),
                            const SizedBox(width: AppDimensions.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sale ${sale.id}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.titleSmall,
                                  ),
                                  Text(
                                    _formatDate(sale.createdAt),
                                    style: AppTextStyles.caption.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _money(sale.total),
                                  style: AppTextStyles.priceSmall.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                _refundStatusPill(sale.status),
                              ],
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                    if (index >= 12) {
                      return tile;
                    }
                    return tile
                        .animate(delay: (80 + 55 * index).ms)
                        .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
                        .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Refund status pill mapped through the existing colour semantics:
  /// refunded = violet, processing = info, cancelled = error. Anything
  /// else that could reach the list renders as completed emerald.
  Widget _refundStatusPill(String status) {
    final mapping = {
      'refunded': AppColors.refunded,
      'processing': AppColors.processing,
      'cancelled': AppColors.cancelled,
      'pending': AppColors.pending,
    };
    return StatusBadge(
      label: status.toUpperCase(),
      color: mapping[status] ?? AppColors.completed,
      icon: status == 'refunded'
          ? Icons.assignment_return_rounded
          : status == 'cancelled'
              ? Icons.block_rounded
              : Icons.check_rounded,
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year} '
        '$hour:$minute';
  }
}

/// Gradient header band giving the return-window context.
class _ReturnsHeaderBand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppDecor.royalGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
              ),
              child: const Icon(
                Icons.assignment_return_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'RETURNS & REFUNDS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Return to a completed sale',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Refunds are only allowed while items are still '
                    'returnable for the sale.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
        .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic);
  }
}

/// The bottom sheet where quantities are chosen and the refund is confirmed.
class _ReturnSheet extends StatefulWidget {
  final Sale sale;
  final String currency;
  final ReturnRepository returnRepository;

  const _ReturnSheet({
    required this.sale,
    required this.currency,
    required this.returnRepository,
  });

  @override
  State<_ReturnSheet> createState() => _ReturnSheetState();
}

class _ReturnSheetState extends State<_ReturnSheet> {
  final SaleRepository _saleRepository = SaleRepository(appDatabase);

  bool _loading = true;
  bool _submitting = false;
  String? _error;

  List<SaleItem> _items = [];
  Map<String, double> _returnable = {};
  final Map<String, double> _selected = {};

  String _refundMethod = 'cash';
  bool _restock = true;
  final TextEditingController _reasonController = TextEditingController();

  static const List<String> _reasonPresets = [
    'Damaged',
    'Wrong item',
    'Not as described',
    'Customer changed mind',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final items = await _saleRepository.getSaleItems(widget.sale.id);
      final returnable = await widget.returnRepository.getReturnableQuantities(
        widget.sale.id,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _returnable = returnable.cast<String, double>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  double get _refundTotal {
    double total = 0;
    for (final item in _items) {
      final qty = _selected[item.productId] ?? 0.0;
      total += item.unitPrice * qty;
    }
    return total;
  }

  bool get _hasSelection => _selected.values.any((q) => q > 0);

  Future<void> _submit() async {
    final lines = <ReturnLine>[];
    for (final item in _items) {
      final qty = _selected[item.productId] ?? 0.0;
      if (qty > 0) {
        lines.add(
          ReturnLine(
            productId: item.productId,
            productName: item.productName,
            quantity: qty,
            unitPrice: item.unitPrice,
            purchasePrice: item.purchasePrice,
          ),
        );
      }
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.returnRepository.createReturn(
        saleId: widget.sale.id,
        lines: lines,
        refundMethod: _refundMethod,
        restock: _restock,
        reason: _reasonController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Bad state: ', '');
      });
    }
  }

  /// Confirmation gate before the refund is recorded (per the primary
  /// CTA rules — money-out actions confirm before they commit).
  Future<void> _confirmRefund() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Process refund?'),
        content: Text(
          'Refund ${widget.currency} ${_refundTotal.toStringAsFixed(2)} '
          'for sale ${widget.sale.id}?\n\n'
          'This records the return'
          '${_restock ? ' and restocks the items' : ' without restocking'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandCoral,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Refund'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.screenPadding,
        right: AppDimensions.screenPadding,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            AppDimensions.screenPadding,
      ),
      child: _loading
          ? const SizedBox(
              height: 220,
              child: AppLoadingState(message: 'Loading items…'),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppDecor.roseGradient,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: AppDecor.glow(AppColors.brandCoral, alpha: 0.3),
                      ),
                      child: const Icon(
                        Icons.assignment_return_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Return / Refund',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Sale ${widget.sale.id} • ${widget.currency} '
                            '${widget.sale.total.toStringAsFixed(2)}',
                            style: AppTextStyles.caption.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final item in _items) _itemRow(item),
                        const SizedBox(height: AppDimensions.spacingLg),
                        Text('Refund method', style: AppTextStyles.titleSmall),
                        const SizedBox(height: AppDimensions.spacingSm),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final m in const ['cash', 'card', 'credit'])
                              FilterPill(
                                label: m[0].toUpperCase() + m.substring(1),
                                selected: _refundMethod == m,
                                onTap: () => setState(() => _refundMethod = m),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _restock,
                          onChanged: (v) => setState(() => _restock = v),
                          title: const Text('Return items to stock'),
                          subtitle: const Text(
                            'Turn off for damaged / unsellable goods',
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        Text('Quick reasons', style: AppTextStyles.titleSmall),
                        const SizedBox(height: AppDimensions.spacingSm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final r in _reasonPresets)
                              FilterPill(
                                label: r,
                                icon: Icons.sell_outlined,
                                selected:
                                    _reasonController.text.trim().toLowerCase() ==
                                        r.toLowerCase(),
                                onTap: () {
                                  setState(() {
                                    _reasonController.text = r;
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        TextField(
                          controller: _reasonController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Reason (optional)',
                            hintText: 'e.g. damaged, wrong item',
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.royalMid,
                                width: 1.7,
                              ),
                            ),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: AppDimensions.spacingMd),
                          Text(
                            _error!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Refund total',
                            style: AppTextStyles.caption.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            '${widget.currency} '
                            '${_refundTotal.toStringAsFixed(2)}',
                            style: AppTextStyles.priceMedium.copyWith(
                              color: AppColors.errorDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: GradientButton(
                        label: 'Process Refund',
                        icon: Icons.assignment_return_rounded,
                        gradient: AppDecor.roseGradient.colors,
                        isLoading: _submitting,
                        onPressed: _hasSelection && !_submitting
                            ? _confirmRefund
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _itemRow(SaleItem item) {
    final scheme = Theme.of(context).colorScheme;
    final available = _returnable[item.productId] ?? 0.0;
    final selected = _selected[item.productId] ?? 0.0;
    final allReturned = available <= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall,
                ),
                Text(
                  allReturned
                      ? 'Fully returned'
                      : '$available of ${item.quantity} returnable • '
                            '${widget.currency} ${item.unitPrice.toStringAsFixed(2)} each',
                  style: AppTextStyles.caption.copyWith(
                    color: allReturned
                        ? AppColors.success
                        : scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          if (allReturned)
            const StatusBadge(
              label: 'RETURNED',
              color: AppColors.success,
              icon: Icons.check_rounded,
            )
          else
            _stepper(available: available, selected: selected, item: item),
        ],
      ),
    );
  }

  Widget _stepper({
    required double available,
    required double selected,
    required SaleItem item,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(
            icon: Icons.remove_rounded,
            enabled: selected > 0,
            onTap: () => setState(() {
              _selected[item.productId] = (selected - 1).clamp(0.0, available);
            }),
          ),
          SizedBox(
            width: 32,
            child: Center(
              child: Text('$selected', style: AppTextStyles.numericSmall),
            ),
          ),
          _stepButton(
            icon: Icons.add_rounded,
            enabled: selected < available,
            onTap: () => setState(() {
              _selected[item.productId] = (selected + 1).clamp(0.0, available);
            }),
          ),
        ],
      ),
    );
  }

  Widget _stepButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: enabled ? onTap : null,
        icon: Icon(
          icon,
          size: 18,
          color: enabled
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
