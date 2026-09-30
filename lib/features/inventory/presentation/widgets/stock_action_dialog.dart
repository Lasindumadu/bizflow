import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
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

  int? get _calculatedStock {
    final quantity = int.tryParse(_quantityController.text.trim());

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

    final input = int.parse(_quantityController.text.trim());

    final int stockChange;

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

    return AlertDialog(
      title: Text(_title),
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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: AppDimensions.spacingXs),

              Text(
                'Current stock: ${widget.product.stockQuantity} units',
                style: const TextStyle(color: Colors.grey),
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
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Text('New stock'),
                      const Spacer(),
                      Text(
                        '$calculatedStock units',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
        FilledButton(onPressed: _submit, child: Text(_title)),
      ],
    );
  }
}

class StockActionResult {
  final String type;
  final int quantity;
  final String note;

  const StockActionResult({
    required this.type,
    required this.quantity,
    required this.note,
  });
}
