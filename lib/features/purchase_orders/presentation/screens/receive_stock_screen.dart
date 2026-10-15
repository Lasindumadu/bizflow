import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/repositories/purchase_order_repository.dart';

/// Receive stock for a purchase order.
class ReceiveStockScreen extends StatefulWidget {
  final PurchaseOrderRecord po;
  final PurchaseOrderRepository repository;

  const ReceiveStockScreen({
    super.key,
    required this.po,
    required this.repository,
  });

  @override
  State<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends State<ReceiveStockScreen> {
  final Map<String, int> _receivedQuantities = {};
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    for (final item in widget.po.items) {
      _receivedQuantities[item.productId] = item.quantityReceived;
    }
  }

  int get _totalItems => widget.po.items.length;
  int get _receivedItems => widget.po.items.where((i) => _receivedQuantities[i.productId]! > 0).length;

  double get _progress => _totalItems > 0 ? _receivedItems / _totalItems : 0.0;

  bool get _fullyReceivedPossible => widget.po.items.every((i) => (_receivedQuantities[i.productId] ?? 0) >= i.quantityOrdered);

  Future<void> _confirmReceive() async {
    final hasFullReceipt = widget.po.items.every((i) => _receivedQuantities[i.productId]! >= i.quantityOrdered);

    if (hasFullReceipt) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mark as Fully Received?'),
          content: const Text(
            'All items have been received in full. Do you want to mark this PO as fully received?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Partial Only')),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Mark Fully Received'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await _processReceipt(fullyReceive: true);
      }
    } else {
      await _processReceipt(fullyReceive: false);
    }
  }

  Future<void> _processReceipt({required bool fullyReceive}) async {
    setState(() => _isProcessing = true);

    try {
      final receivedQuantities = <String, int>{};
      for (final item in widget.po.items) {
        final qty = _receivedQuantities[item.productId] ?? 0;
        if (qty > 0) {
          receivedQuantities[item.productId] = qty;
        }
      }

      if (receivedQuantities.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No quantities entered to receive')),
        );
        return;
      }

      await widget.repository.receiveStock(
        id: widget.po.id,
        receivedQuantities: receivedQuantities,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fullyReceive
              ? 'Stock received and PO marked as fully received.'
              : 'Stock received. PO marked as partially received.'),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to receive stock: $e')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Receive Stock: ${widget.po.id}'),
        actions: [
          if (_receivedItems > 0)
            TextButton.icon(
              onPressed: _isProcessing ? null : _confirmReceive,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(_fullyReceivedPossible ? 'Mark Fully Received' : 'Save Partial'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            decoration: BoxDecoration(
              gradient: AppDecor.primaryGradient,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconTile(
                      icon: Icons.inventory_2_rounded,
                      gradient: [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.1)],
                      size: 56,
                      iconSize: 28,
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receive Stock',
                            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                          ),
                          Text(
                            widget.po.id,
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                        Text(
                          '$_receivedItems of $_totalItems items',
                          style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          // Items list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              itemCount: widget.po.items.length,
              itemBuilder: (context, index) {
                final item = widget.po.items[index];
                final received = _receivedQuantities[item.productId] ?? 0;
                final isFull = received >= item.quantityOrdered;
                final isPartial = received > 0 && !isFull;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                  child: HoverLiftCard(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconTile(
                              icon: isFull
                                  ? Icons.check_circle_rounded
                                  : (isPartial ? Icons.remove_circle_outline : Icons.radio_button_unchecked),
                              gradient: isFull
                                  ? AppDecor.successGradient.colors
                                  : (isPartial ? AppDecor.warningGradient.colors : [AppColors.chartGray, AppColors.chartGray]),
                              size: 40,
                              iconSize: 20,
                            ),
                            const SizedBox(width: AppDimensions.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName, style: AppTextStyles.titleSmall),
                                  if (item.productSku.isNotEmpty)
                                    Text('SKU: ${item.productSku}', style: AppTextStyles.caption.copyWith(
                                      color: scheme.onSurface.withValues(alpha: 0.6),
                                    )),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isFull
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : (isPartial ? AppColors.warning.withValues(alpha: 0.15) : scheme.surfaceContainerHighest),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isFull ? 'FULL' : (isPartial ? 'PARTIAL' : 'PENDING'),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isFull
                                      ? AppColors.success
                                      : (isPartial ? AppColors.warning : scheme.onSurface.withValues(alpha: 0.6)),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        Row(
                          children: [
                            Expanded(
                              child: _QtyField(
                                label: 'Ordered',
                                value: item.quantityOrdered,
                                readOnly: true,
                                color: scheme.outline,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spacingMd),
                            Expanded(
                              child: _QtyField(
                                label: 'Received',
                                value: received,
                                onChanged: (v) {
                                  final qty = int.tryParse(v) ?? 0;
                                  final clamped = qty.clamp(0, item.quantityOrdered * 2); // Allow over-receive up to 2x
                                  setState(() => _receivedQuantities[item.productId] = clamped);
                                },
                                color: isFull ? AppColors.success : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        Row(
                          children: [
                            Text(
                              'Remaining: ${item.quantityOrdered - received}',
                              style: AppTextStyles.caption.copyWith(
                                color: (item.quantityOrdered - received) <= 0
                                    ? AppColors.success
                                    : scheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const Spacer(),
                            if (received < item.quantityOrdered)
                              FilledButton.tonal(
                                onPressed: () => setState(() => _receivedQuantities[item.productId] = item.quantityOrdered),
                                child: const Text('Receive All'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom action bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Row(
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
                      label: _isProcessing ? 'Processing…' : (_fullyReceivedPossible ? 'Mark Fully Received' : 'Save Partial Receipt'),
                      icon: Icons.check_circle_outline,
                      isLoading: _isProcessing,
                      onPressed: _isProcessing ? null : _confirmReceive,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyField extends StatelessWidget {
  final String label;
  final int value;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final Color color;

  const _QtyField({
    required this.label,
    required this.value,
    this.readOnly = false,
    this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value.toString(),
          readOnly: readOnly,
          onChanged: onChanged,
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(
            color: readOnly ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6) : color,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: color.withValues(alpha: 0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}