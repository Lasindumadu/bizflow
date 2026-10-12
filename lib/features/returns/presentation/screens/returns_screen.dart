import 'package:flutter/material.dart';

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
            return const AppEmptyState(
              icon: Icons.assignment_return_outlined,
              title: 'No completed sales',
              message:
                  'Completed sales will appear here so you can process returns '
                  'and refunds.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
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
                                color: Theme.of(context).colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _money(sale.total),
                        style: AppTextStyles.priceSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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
  Map<String, int> _returnable = {};
  final Map<String, int> _selected = {};

  String _refundMethod = 'cash';
  bool _restock = true;
  final TextEditingController _reasonController = TextEditingController();

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
        _returnable = returnable;
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
      final qty = _selected[item.productId] ?? 0;
      total += item.unitPrice * qty;
    }
    return total;
  }

  bool get _hasSelection => _selected.values.any((q) => q > 0);

  Future<void> _submit() async {
    final lines = <ReturnLine>[];
    for (final item in _items) {
      final qty = _selected[item.productId] ?? 0;
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
                        TextField(
                          controller: _reasonController,
                          decoration: const InputDecoration(
                            labelText: 'Reason (optional)',
                            hintText: 'e.g. damaged, wrong item',
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
                            ? _submit
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
    final available = _returnable[item.productId] ?? 0;
    final selected = _selected[item.productId] ?? 0;
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
    required int available,
    required int selected,
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
              _selected[item.productId] = (selected - 1).clamp(0, available);
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
              _selected[item.productId] = (selected + 1).clamp(0, available);
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
