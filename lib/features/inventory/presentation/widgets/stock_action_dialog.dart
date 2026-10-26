import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';

enum StockActionType { stockIn, stockOut, adjustment }

class StockActionDialog extends StatefulWidget {
  final Product product;
  final StockActionType actionType;

  const StockActionDialog({
    super.key,
    required this.product,
    required this.actionType,
  });

  @override
  State<StockActionDialog> createState() => _StockActionDialogState();
}

class _StockActionDialogState extends State<StockActionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.actionType) {
      case StockActionType.stockIn:
        return 'Stock In';
      case StockActionType.stockOut:
        return 'Stock Out';
      case StockActionType.adjustment:
        return 'Adjust Stock';
    }
  }

  String get _movementType {
    switch (widget.actionType) {
      case StockActionType.stockIn:
        return 'STOCK_IN';
      case StockActionType.stockOut:
        return 'STOCK_OUT';
      case StockActionType.adjustment:
        return 'ADJUSTMENT';
    }
  }

  /// Section tint for this movement — stock flows use the blue pair;
  /// the sign decides mint (in) vs rose (out).
  ({Color soft, Color deep, List<Color> fill, IconData icon}) get _tone {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.actionType) {
      case StockActionType.stockIn:
        return (
          soft: AppColors.moneyTint.first,
          deep: isDark ? AppColors.brandMint : AppColors.brandMintDeep,
          fill: AppDecor.flowGradient.colors,
          icon: Icons.south_west_rounded,
        );
      case StockActionType.stockOut:
        return (
          soft: AppColors.roseSoft,
          deep: isDark ? AppColors.roseLight : AppColors.rose,
          fill: AppDecor.roseGradient.colors,
          icon: Icons.north_east_rounded,
        );
      case StockActionType.adjustment:
        return (
          soft: AppColors.stockTint.first,
          deep: AppColors.stockTint.last,
          fill: [AppColors.skyLight, AppColors.stockTint.last],
          icon: Icons.tune_rounded,
        );
    }
  }

  double? get _calculatedStock {
    final quantity = double.tryParse(_quantityController.text.trim());

    if (quantity == null) {
      return null;
    }

    switch (widget.actionType) {
      case StockActionType.stockIn:
        return widget.product.stockQuantity + quantity;
      case StockActionType.stockOut:
        return widget.product.stockQuantity - quantity;
      case StockActionType.adjustment:
        return quantity;
    }
  }

  void _updatePreview() {
    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final input = double.parse(_quantityController.text.trim());

    final double stockChange;

    switch (widget.actionType) {
      case StockActionType.stockIn:
        stockChange = input;
        break;
      case StockActionType.stockOut:
        stockChange = -input;
        break;
      case StockActionType.adjustment:
        stockChange = input - widget.product.stockQuantity;
        break;
    }

    Navigator.of(context).pop(
      StockActionResult(
        type: _movementType,
        quantity: stockChange,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calculatedStock = _calculatedStock;
    final tone = _tone;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: tone.fill),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tone.icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(_title)),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingXs),

              Text(
                'Current stock: ${widget.product.stockQuantity} units',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: Theme.of(context).colorScheme.onSurface
                      .withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              TextFormField(
                controller: _quantityController,
                autofocus: true,
                keyboardType: TextInputType.number,
                onChanged: (_) => _updatePreview(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a quantity';
                  }

                  final quantity = int.tryParse(value.trim());

                  if (quantity == null) {
                    return 'Enter a whole number';
                  }

                  if (quantity < 0) {
                    return 'Cannot be negative';
                  }

                  if (widget.actionType == StockActionType.stockOut &&
                      quantity > widget.product.stockQuantity) {
                    return 'Not enough stock available';
                  }

                  if (widget.actionType == StockActionType.adjustment &&
                      quantity < 0) {
                    return 'Stock cannot be negative';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  labelText: widget.actionType == StockActionType.adjustment
                      ? 'New Stock Quantity'
                      : 'Quantity',
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Optional',
                  border: OutlineInputBorder(),
                ),
              ),

              if (calculatedStock != null) ...[
                const SizedBox(height: AppDimensions.spacingLg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                    color: tone.deep.withValues(alpha: isDark ? 0.16 : 0.08),
                    border: Border.all(color: tone.deep.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Text('New stock'),
                      const Spacer(),
                      Text(
                        '$calculatedStock units',
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: tone.deep,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: Icon(tone.icon, size: 17),
          label: Text(_title),
        ),
      ],
    );
  }
}

class StockActionResult {
  final String type;
  final double quantity;
  final String note;

  const StockActionResult({
    required this.type,
    required this.quantity,
    required this.note,
  });
}
