import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
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
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                BrandPageHeader(
                  eyebrow: 'Purchase orders',
                  title: isEditing ? 'Edit purchase order' : 'New purchase order',
                  subtitle:
                      'Pick the supplier, line up the items and mark the expected date.',
                  icon: Icons.shopping_cart_rounded,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          children: [
                            // Supplier & schedule.
                            BrandFormSection(
                              title: 'Supplier & schedule',
                              subtitle:
                                  'Who fulfils the order and when it should arrive.',
                              icon: Icons.local_shipping_outlined,
                              accent: AppColors.stockTint.last,
                              child: Column(
                                children: [
                                  DropdownButtonFormField<SupplierRecord>(
                                    initialValue: _selectedSupplier,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Supplier *',
                                      prefixIcon:
                                          Icon(Icons.local_shipping_outlined),
                                    ),
                                    items: widget.suppliers
                                        .map((s) => DropdownMenuItem(
                                              value: s,
                                              child: Text(s.name),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _selectedSupplier = v),
                                    validator: (v) =>
                                        v == null ? 'Select a supplier' : null,
                                  ),
                                  const SizedBox(height: AppDimensions.spacingMd),
                                  InkWell(
                                    onTap: _pickExpectedDate,
                                    borderRadius:
                                        BorderRadius.circular(AppDimensions.inputRadius),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Expected Date *',
                                        prefixIcon:
                                            Icon(Icons.calendar_today_outlined),
                                      ),
                                      child: Text(
                                        '${_expectedDate.day.toString().padLeft(2, '0')}/${_expectedDate.month.toString().padLeft(2, '0')}/${_expectedDate.year}',
                                        style:
                                            AppTextStyles.bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            _ItemsSection(
                              items: _items,
                              subtotal: _subtotal,
                              onAddItem: _addItemRow,
                              onRemoveItem: _removeItemRow,
                              onChanged: () => setState(() {}),
                            ),
                            const SizedBox(height: 14),
                            BrandFormSection(
                              title: 'Notes',
                              subtitle:
                                  'Anything the supplier should know.',
                              icon: Icons.notes_outlined,
                              accent: AppColors.accent,
                              child: TextFormField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Internal Notes',
                                  hintText:
                                      'Optional notes for this purchase order',
                                  prefixIcon: Icon(Icons.notes_outlined),
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ),
                          ],
                        ).animate(delay: 60.ms).fadeIn(
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            ).moveY(
                              begin: 14,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      ),
                    ),
                  ),
                ),
                // Sticky bar with live order context + primary CTA.
                BrandStickyBar(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Items: ${_items.length}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            Text(
                              'Total: ${_money(_subtotal)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTextStyles.displayFont,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: GradientButton(
                          label: _isSaving
                              ? 'Saving…'
                              : (isEditing ? 'Save Changes' : 'Create PO'),
                          icon: Icons.save_rounded,
                          isLoading: _isSaving,
                          gradient: AppDecor.royalGradient.colors,
                          onPressed: _isSaving ? null : _save,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Line-item editor: gradient-numbered premium rows with POS-style
/// quantity steppers and a mint valuation strip.
class _ItemsSection extends StatelessWidget {
  final List<_POItemForm> items;
  final double subtotal;
  final VoidCallback onAddItem;
  final void Function(int index) onRemoveItem;
  final VoidCallback onChanged;

  const _ItemsSection({
    required this.items,
    required this.subtotal,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BrandFormSection(
      title: 'Items',
      subtitle: 'Products to order, quantities and unit costs.',
      icon: Icons.inventory_2_outlined,
      accent: AppColors.royalMid,
      trailing: items.length < 20
          ? SizedBox(
              height: 34,
              child: SoftButton(
                label: 'Add item',
                icon: Icons.add_rounded,
                expanded: false,
                onPressed: onAddItem,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _POItemRow(
              item: item,
              index: index,
              isLast: index == items.length - 1,
              onRemove: () => onRemoveItem(index),
              onChanged: onChanged,
            );
          }),
          const SizedBox(height: AppDimensions.spacingMd),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.moneyTint.first.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.16
                    : 1,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.brandMintDeep.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.30
                      : 0.25,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.brandMint
                        : AppColors.brandMintDeep,
                  ),
                ),
              ],
            ),
          ),
        ],
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

class _POItemRow extends StatefulWidget {
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
  State<_POItemRow> createState() => _POItemRowState();
}

class _POItemRowState extends State<_POItemRow> {
  late final TextEditingController _quantityController;
  late final TextEditingController _unitCostController;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.item.quantity > 0 ? widget.item.quantity.toString() : '');
    _unitCostController = TextEditingController(
        text: widget.item.unitCost > 0 ? widget.item.unitCost.toStringAsFixed(2) : '');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  void _stepQuantity(int delta) {
    final current = int.tryParse(_quantityController.text) ?? 0;
    final next = (current + delta).clamp(1, 100000);
    _quantityController.text = '$next';
    widget.item.quantity = next;
    setState(() {});
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Gradient number squircle, POS-line style.
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppDecor.royalGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.24),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Item ${widget.index + 1}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
              if (!widget.isLast || widget.item.productId.isNotEmpty)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  tooltip: 'Remove item',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          // Product search (simplified - in real app would use autocomplete)
          TextFormField(
            initialValue:
                widget.item.productName.isNotEmpty ? widget.item.productName : null,
            decoration: const InputDecoration(
              labelText: 'Product *',
              hintText: 'Search or enter product name',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
            validator: (v) {
              if (widget.item.productId.isEmpty) return 'Select a product';
              return null;
            },
            onSaved: (v) => widget.item.productName = v?.trim() ?? '',
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Qty *',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // POS-style stepper: minus · qty · plus.
                    Row(
                      children: [
                        _StepButton(
                          icon: Icons.remove_rounded,
                          onTap: () => _stepQuantity(-1),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTextStyles.displayFont,
                              fontWeight: FontWeight.w800,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: scheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.stockTint.last.withValues(
                                alpha: isDark ? 0.10 : 0.05,
                              ),
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (v) {
                              final q = int.tryParse(v ?? '');
                              if (q == null || q <= 0) return 'Required';
                              return null;
                            },
                            onSaved: (v) =>
                                widget.item.quantity = int.tryParse(v ?? '') ?? 1,
                            onChanged: (v) {
                              widget.item.quantity = int.tryParse(v) ?? 1;
                              widget.onChanged();
                            },
                          ),
                        ),
                        _StepButton(
                          icon: Icons.add_rounded,
                          onTap: () => _stepQuantity(1),
                        ),
                      ],
                    ),
                    if (int.tryParse(_quantityController.text) == null ||
                        (int.tryParse(_quantityController.text) ?? 0) <= 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: scheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: TextFormField(
                  controller: _unitCostController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Unit Cost *',
                    prefixIcon: Icon(Icons.attach_money_outlined),
                  ),
                  style: TextStyle(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: scheme.onSurface,
                  ),
                  validator: (v) {
                    final c = double.tryParse(v ?? '');
                    if (c == null || c < 0) return 'Required';
                    return null;
                  },
                  onSaved: (v) =>
                      widget.item.unitCost = double.tryParse(v ?? '') ?? 0,
                  onChanged: (v) {
                    widget.item.unitCost = double.tryParse(v) ?? 0;
                    widget.onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              Text(
                'Line Total: ',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '\$${(widget.item.quantity * widget.item.unitCost).toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Round +/- stepper button matching the POS cart lines.
class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: scheme.onPrimaryContainer),
      ),
    );
  }
}
