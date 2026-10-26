import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/repositories/purchase_order_repository.dart';

/// Receive stock for a purchase order.
///
/// Presentation hierarchy: hero with progress + guided steps, then a
/// scan/search-first input, then one row per line item with live
/// received-vs-ordered bars.
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
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  /// Set once (and only once) when every line reaches its ordered
  /// quantity — drives the one-shot full-receive celebration.
  bool _celebrated = false;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    for (final item in widget.po.items) {
      _receivedQuantities[item.productId] = item.quantityReceived;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalItems => widget.po.items.length;
  int get _receivedItems => widget.po.items.where((i) => _receivedQuantities[i.productId]! > 0).length;

  double get _progress => _totalItems > 0 ? _receivedItems / _totalItems : 0.0;

  bool get _fullyReceivedPossible => widget.po.items.every((i) => (_receivedQuantities[i.productId] ?? 0) >= i.quantityOrdered);

  List<PurchaseOrderItemRecord> get _visibleItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return widget.po.items;
    return widget.po.items.where((item) {
      return item.productName.toLowerCase().contains(query) ||
          item.productSku.toLowerCase().contains(query);
    }).toList();
  }

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

  void _setReceived(String productId, int qty) {
    setState(() => _receivedQuantities[productId] = qty);
    if (_fullyReceivedPossible && !_celebrated) {
      setState(() => _celebrated = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHero(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              children: [
                // Scan / search-first input.
                _ScannerSearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                if (_celebrated && _fullyReceivedPossible)
                  const _FullReceiveCelebration(),
                if (_visibleItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No line items match that search.'),
                    ),
                  )
                else
                  ..._visibleItems.map(_buildItemRow),
              ],
            ),
          ),
          // Bottom action bar
          SafeArea(
            top: false,
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
                      gradient: _fullyReceivedPossible
                          ? AppDecor.successGradient.colors
                          : AppDecor.royalGradient.colors,
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

  /// Photo hero: warehouse imagery under the brand wash, headline,
  /// receive-vs-ordered total and the guided step rail with an
  /// auroraBar connector.
  Widget _buildHero() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: SizedBox(
        height: 178,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppDecor.photoHero(
              image: AppImages.warehouse,
              anchor: 'left',
              imageAlignmentY: 0.5,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 12),
                        child: Tooltip(
                          message: 'Back',
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.of(context).maybePop(),
                              borderRadius: BorderRadius.circular(12),
                              child: const SizedBox(
                                width: 38,
                                height: 38,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RECEIVE STOCK',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                color: Colors.white.withValues(alpha: 0.66),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.po.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTextStyles.displayFont,
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$_receivedItems of $_totalItems items received',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.74),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildStepRail(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Guided steps — signals with an auroraBar connector between them.
  Widget _buildStepRail() {
    Widget node(bool active, IconData icon, String label) {
      return Expanded(
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.16),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: active ? 1 : 0.28,
                  ),
                ),
              ),
              child: Icon(
                icon,
                size: 12,
                color: active ? AppColors.royalEnd : Colors.white70,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

    Widget connector(bool filled) {
      return Container(
        height: 2,
        width: 18,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: filled ? null : Colors.white.withValues(alpha: 0.18),
          gradient: filled ? AppDecor.auroraBar : null,
          borderRadius: BorderRadius.circular(999),
        ),
      );
    }

    final step = _progress <= 0
        ? 0
        : _fullyReceivedPossible
            ? 3
            : (_progress >= 0.5 ? 2 : 1);

    return Row(
      children: [
        node(step >= 1, Icons.qr_code_scanner_rounded, 'Scan'),
        connector(step >= 2),
        node(step >= 2, Icons.calculate_rounded, 'Count'),
        connector(step >= 3),
        node(step >= 3, Icons.verified_rounded, 'Confirm'),
      ],
    );
  }

  Widget _buildItemRow(PurchaseOrderItemRecord item) {
    final scheme = Theme.of(context).colorScheme;
    final received = _receivedQuantities[item.productId] ?? 0;
    final isFull = received >= item.quantityOrdered;
    final isPartial = received > 0 && !isFull;

    final tone = isFull
        ? AppColors.success
        : (isPartial ? AppColors.warning : scheme.onSurface.withValues(alpha: 0.4));

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        radius: 18,
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
                      : (isPartial
                          ? AppDecor.warningGradient.colors
                          : AppDecor.grayGradient.colors),
                  size: 40,
                  iconSize: 20,
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (item.productSku.isNotEmpty)
                        Text(
                          'SKU: ${item.productSku}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tone.withValues(
                      alpha: tone == scheme.onSurface.withValues(alpha: 0.4)
                          ? 0.08
                          : 0.13,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: tone.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    isFull ? 'FULL' : (isPartial ? 'PARTIAL' : 'PENDING'),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: tone,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            // Received vs ordered — mint aurora fill on the bar.
            Row(
              children: [
                Text(
                  '$received',
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isFull ? AppColors.success : scheme.onSurface,
                  ),
                ),
                Text(
                  ' / ${item.quantityOrdered} received',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const Spacer(),
                Text(
                  'Remaining: ${item.quantityOrdered - received}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: (item.quantityOrdered - received) <= 0
                        ? AppColors.success
                        : scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 7,
                color: scheme.onSurface.withValues(alpha: 0.07),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (received / item.quantityOrdered)
                      .clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isFull
                          ? AppDecor.flowGradient
                          : const LinearGradient(
                              colors: [AppColors.brandMint, AppColors.brandMintDeep],
                            ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: [
                Expanded(
                  child: _QtyField(
                    label: 'Received',
                    value: received,
                    onChanged: (v) {
                      final qty = int.tryParse(v) ?? 0;
                      final clamped = qty.clamp(0, item.quantityOrdered * 2); // Allow over-receive up to 2x
                      _setReceived(item.productId, clamped);
                    },
                    color: isFull ? AppColors.success : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: _QtyField(
                    label: 'Ordered',
                    value: item.quantityOrdered,
                    readOnly: true,
                    color: scheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            if (received < item.quantityOrdered)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () =>
                      _setReceived(item.productId, item.quantityOrdered),
                  child: const Text('Receive All'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Barcode-first input — scan or type to find a line item.
class _ScannerSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _ScannerSearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_scanner_rounded,
            size: 20,
            color: AppColors.royalMid,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'Scan or search SKU / product…',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 17),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
        ],
      ),
    );
  }
}

/// One-shot celebration shown when every line reaches its ordered
/// quantity — sunset gradient glow with an elastic scale-in.
class _FullReceiveCelebration extends StatelessWidget {
  const _FullReceiveCelebration();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      curve: Curves.elasticOut,
      duration: const Duration(milliseconds: 420),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppDecor.sunsetGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDecor.glow(AppColors.brandCoral, alpha: 0.35),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.celebration_rounded,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Full receipt reached!',
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Every line item has met its ordered quantity. Mark the PO fully received to finish.',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          key: ValueKey('$label-$value'),
          initialValue: value.toString(),
          readOnly: readOnly,
          onChanged: onChanged,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTextStyles.displayFont,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: readOnly
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                : color,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: color.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
