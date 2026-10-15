import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/purchase_order_repository.dart';
import '../../../../data/repositories/supplier_repository.dart';

/// Add/edit purchase order screen.
class PurchaseOrderDetailScreen extends StatefulWidget {
  final PurchaseOrderRecord? po;
  final List<SupplierRecord> suppliers;

  const PurchaseOrderDetailScreen({
    super.key,
    this.po,
    required this.suppliers,
  });

  @override
  State<PurchaseOrderDetailScreen> createState() => _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen> {
  final PurchaseOrderRepository _repository = PurchaseOrderRepository(appDatabase);
  final _formKey = GlobalKey<FormState>();

  final _notesController = TextEditingController();

  SupplierRecord? _selectedSupplier;
  DateTime _expectedDate = DateTime.now().add(const Duration(days: 7));
  final List<_POItemForm> _items = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.po != null) {
      final p = widget.po!;
      _selectedSupplier = widget.suppliers.firstWhere(
        (s) => s.id == p.supplierId,
        orElse: () => widget.suppliers.first,
      );
      _expectedDate = p.expectedDate ?? _expectedDate;
      _notesController.text = p.notes;
      _items.addAll(p.items.map((i) => _POItemForm(
        productId: i.productId,
        productName: i.productName,
        productSku: i.productSku,
        quantity: i.quantityOrdered,
        unitCost: i.unitCost,
      )));
    } else {
      _items.add(_POItemForm());
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addItemRow() {
    setState(() => _items.add(_POItemForm()));
  }

  void _removeItemRow(int index) {
    if (_items.length <= 1) return;
    setState(() => _items.removeAt(index));
  }

  Future<void> _pickExpectedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _expectedDate = picked);
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + (item.quantity * item.unitCost));

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    // Validate all items have product
    for (final item in _items) {
      if (item.productId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All items must have a product selected')),
        );
        return;
      }
      if (item.quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All quantities must be greater than 0')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final lines = _items.map((i) => PurchaseOrderLineInput(
        productId: i.productId,
        productName: i.productName,
        productSku: i.productSku,
        quantity: i.quantity,
        unitCost: i.unitCost,
      )).toList();

      if (widget.po != null) {
        await _repository.updatePurchaseOrder(
          id: widget.po!.id,
          supplierId: _selectedSupplier!.id,
          expectedDate: _expectedDate,
          lines: lines,
          notes: _notesController.text.trim(),
        );
      } else {
        await _repository.createPurchaseOrder(
          supplierId: _selectedSupplier!.id,
          expectedDate: _expectedDate,
          lines: lines,
          notes: _notesController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PO: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.po != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Purchase Order' : 'Create Purchase Order')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            Text('Supplier & Details', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spacingMd),
            DropdownButtonFormField<SupplierRecord>(
              initialValue: _selectedSupplier,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Supplier *',
                prefixIcon: Icon(Icons.local_shipping_outlined),
              ),
              items: widget.suppliers
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSupplier = v),
              validator: (v) => v == null ? 'Select a supplier' : null,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            InkWell(
              onTap: _pickExpectedDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expected Date *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  '${_expectedDate.day.toString().padLeft(2, '0')}/${_expectedDate.month.toString().padLeft(2, '0')}/${_expectedDate.year}',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            Text('Items', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spacingSm),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _POItemRow(
                item: item,
                index: index,
                isLast: index == _items.length - 1,
                onRemove: () => _removeItemRow(index),
                onChanged: () => setState(() {}),
              );
            }),
            if (_items.length < 20)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacingSm),
                child: OutlinedButton.icon(
                  onPressed: _addItemRow,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Item'),
                ),
              ),
            const SizedBox(height: AppDimensions.spacingLg),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: AppTextStyles.bodyLarge),
                    Text(_money(_subtotal), style: AppTextStyles.priceLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            Text('Notes', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Internal Notes',
                hintText: 'Optional notes for this purchase order',
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),

            GradientButton(
              label: _isSaving ? 'Saving…' : (widget.po != null ? 'Save Changes' : 'Create Purchase Order'),
              icon: Icons.save_rounded,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _POItemForm {
  String productId = '';
  String productName = '';
  String productSku = '';
  int quantity = 1;
  double unitCost = 0.0;

  _POItemForm({
    String? productId,
    String? productName,
    String? productSku,
    int? quantity,
    double? unitCost,
  }) {
    if (productId != null) this.productId = productId;
    if (productName != null) this.productName = productName;
    if (productSku != null) this.productSku = productSku;
    if (quantity != null) this.quantity = quantity;
    if (unitCost != null) this.unitCost = unitCost;
  }
}

class _POItemRow extends StatelessWidget {
  final _POItemForm item;
  final int index;
  final bool isLast;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _POItemRow({
    required this.item,
    required this.index,
    required this.isLast,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Item ${index + 1}', style: AppTextStyles.labelMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  )),
                ),
                if (!isLast || item.productId.isNotEmpty)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, color: AppColors.error),
                    tooltip: 'Remove item',
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            // Product search (simplified - in real app would use autocomplete)
            TextFormField(
              initialValue: item.productName.isNotEmpty ? item.productName : null,
              decoration: const InputDecoration(
                labelText: 'Product *',
                hintText: 'Search or enter product name',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              validator: (v) {
                if (item.productId.isEmpty) return 'Select a product';
                return null;
              },
              onSaved: (v) => item.productName = v?.trim() ?? '',
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity > 0 ? item.quantity.toString() : '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Qty *',
                      prefixIcon: Icon(Icons.numbers_outlined),
                    ),
                    validator: (v) {
                      final q = int.tryParse(v ?? '');
                      if (q == null || q <= 0) return 'Required';
                      return null;
                    },
                    onSaved: (v) => item.quantity = int.tryParse(v ?? '') ?? 1,
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitCost > 0 ? item.unitCost.toStringAsFixed(2) : '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Unit Cost *',
                      prefixIcon: Icon(Icons.attach_money_outlined),
                    ),
                    validator: (v) {
                      final c = double.tryParse(v ?? '');
                      if (c == null || c < 0) return 'Required';
                      return null;
                    },
                    onSaved: (v) => item.unitCost = double.tryParse(v ?? '') ?? 0,
                    onChanged: (_) => onChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Row(
              children: [
                Text(
                  'Line Total: ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  '\$${(item.quantity * item.unitCost).toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}