import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _lowStockController = TextEditingController();
  final _barcodeController = TextEditingController();

  final CategoryRepository _categoryRepository = CategoryRepository(
    appDatabase,
  );

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  StreamSubscription<List<Category>>? _categoriesSubscription;

  List<Category> _categories = [];
  String? _selectedCategory;

  String _currency = 'USD';
  bool _isLoadingSettings = true;

  late final AnimationController _pageAnimationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.015), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageAnimationController,
            curve: Curves.easeOut,
          ),
        );

    final product = widget.product;

    if (product != null) {
      _nameController.text = product.name;
      _skuController.text = product.sku;
      _purchasePriceController.text = product.purchasePrice.toString();
      _sellingPriceController.text = product.sellingPrice.toString();
      _stockController.text = product.stockQuantity.toString();
      _lowStockController.text = product.lowStockThreshold.toString();
      _barcodeController.text = product.barcode;
      _selectedCategory = product.category;
    }

    _loadBusinessSettings();

    _categoriesSubscription = _categoryRepository.watchCategories().listen((
      categories,
    ) {
      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
      });
    });

    _pageAnimationController.forward();
  }

  Future<void> _loadBusinessSettings() async {
    try {
      final settings = await _businessSettingsRepository.getSettings();

      if (!mounted) {
        return;
      }

      setState(() {
        _currency = settings.currency;
        _isLoadingSettings = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingSettings = false;
      });
    }
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();

    _pageAnimationController.dispose();

    _nameController.dispose();
    _skuController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _lowStockController.dispose();
    _barcodeController.dispose();

    super.dispose();
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();

    final categoryName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g. Beverages',
              prefixIcon: Icon(Icons.category_outlined),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                Navigator.of(context).pop(name);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (categoryName == null || !mounted) {
      return;
    }

    final normalizedName = categoryName.trim();

    final existingCategory = _categories.cast<Category?>().firstWhere(
      (category) =>
          category!.name.trim().toLowerCase() == normalizedName.toLowerCase(),
      orElse: () => null,
    );

    if (existingCategory != null) {
      setState(() {
        _selectedCategory = existingCategory.name;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This category already exists.')),
      );

      return;
    }

    try {
      final id = DateTime.now().microsecondsSinceEpoch.toString();

      await _categoryRepository.addCategory(id: id, name: normalizedName);

      if (!mounted) {
        return;
      }

      setState(() {
        _selectedCategory = normalizedName;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add category: $error')));
    }
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = Product(
      id:
          widget.product?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      category: _selectedCategory!.trim(),
      purchasePrice: double.parse(_purchasePriceController.text.trim()),
      sellingPrice: double.parse(_sellingPriceController.text.trim()),
      stockQuantity: int.parse(_stockController.text.trim()),
      lowStockThreshold: int.parse(_lowStockController.text.trim()),
      barcode: _barcodeController.text.trim(),
    );

    Navigator.of(context).pop(product);
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _categoryValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a category';
    }

    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    final number = double.tryParse(value.trim());

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < 0) {
      return 'Cannot be negative';
    }

    return null;
  }

  String? _integerValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Enter a whole number';
    }

    if (number < 0) {
      return 'Cannot be negative';
    }

    return null;
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 21),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.heading2.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      prefixText: prefixText,
      prefixStyle: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final categoryNames = _categories
        .map<String>((category) => category.name)
        .toList();

    // Keep an existing product category visible when editing an older
    // product whose category has not yet been added to the Categories table.
    if (_selectedCategory != null &&
        _selectedCategory!.isNotEmpty &&
        !categoryNames.contains(_selectedCategory)) {
      categoryNames.insert(0, _selectedCategory!);
    }

    final selectedCategory = categoryNames.contains(_selectedCategory)
        ? _selectedCategory
        : null;

    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing
                              ? 'Update your product details'
                              : 'Add a new product to your inventory',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingXl),

                        _buildSectionCard(
                          context: context,
                          title: 'Product Information',
                          subtitle:
                              'Basic details used to identify your product.',
                          icon: Icons.inventory_2_outlined,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                validator: _requiredValidator,
                                textCapitalization: TextCapitalization.words,
                                decoration: _inputDecoration(
                                  context: context,
                                  label: 'Product Name',
                                  hint: 'e.g. Coffee',
                                  icon: Icons.shopping_bag_outlined,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.spacingMd),

                              TextFormField(
                                controller: _skuController,
                                validator: _requiredValidator,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: _inputDecoration(
                                  context: context,
                                  label: 'SKU',
                                  hint: 'e.g. COF-001',
                                  icon: Icons.tag_outlined,
                                ),
                              ),

                              const SizedBox(height: AppDimensions.spacingMd),

                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isCompact = constraints.maxWidth < 500;

                                  if (isCompact) {
                                    return Column(
                                      children: [
                                        _buildCategoryField(
                                          context,
                                          categoryNames,
                                          selectedCategory,
                                        ),
                                        const SizedBox(
                                          height: AppDimensions.spacingSm,
                                        ),
                                        _buildAddCategoryButton(context),
                                      ],
                                    );
                                  }

                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _buildCategoryField(
                                          context,
                                          categoryNames,
                                          selectedCategory,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: AppDimensions.spacingSm,
                                      ),
                                      _buildAddCategoryButton(context),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        _buildSectionCard(
                          context: context,
                          title: 'Pricing',
                          subtitle: 'Set your purchase and selling prices.',
                          icon: Icons.payments_outlined,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 500;

                              final purchaseField = TextFormField(
                                controller: _purchasePriceController,
                                validator: _numberValidator,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: _inputDecoration(
                                  context: context,
                                  label: 'Purchase Price',
                                  hint: '0.00',
                                  icon: Icons.shopping_cart_outlined,
                                  prefixText: '$_currency ',
                                ),
                              );

                              final sellingField = TextFormField(
                                controller: _sellingPriceController,
                                validator: _numberValidator,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: _inputDecoration(
                                  context: context,
                                  label: 'Selling Price',
                                  hint: '0.00',
                                  icon: Icons.sell_outlined,
                                  prefixText: '$_currency ',
                                ),
                              );

                              if (isCompact) {
                                return Column(
                                  children: [
                                    purchaseField,
                                    const SizedBox(
                                      height: AppDimensions.spacingMd,
                                    ),
                                    sellingField,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: purchaseField),
                                  const SizedBox(
                                    width: AppDimensions.spacingMd,
                                  ),
                                  Expanded(child: sellingField),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        _buildSectionCard(
                          context: context,
                          title: 'Inventory',
                          subtitle:
                              'Set current stock and low-stock warning level.',
                          icon: Icons.warehouse_outlined,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 500;

                              final stockField = TextFormField(
                                controller: _stockController,
                                validator: _integerValidator,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  context: context,
                                  label: 'Stock Quantity',
                                  hint: '0',
                                  icon: Icons.inventory_outlined,
                                ),
                              );

                              final thresholdField = TextFormField(
                                controller: _lowStockController,
                                validator: _integerValidator,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  context: context,
                                  label: 'Low Stock Threshold',
                                  hint: '5',
                                  icon: Icons.warning_amber_outlined,
                                ),
                              );

                              if (isCompact) {
                                return Column(
                                  children: [
                                    stockField,
                                    const SizedBox(
                                      height: AppDimensions.spacingMd,
                                    ),
                                    thresholdField,
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: stockField),
                                  const SizedBox(
                                    width: AppDimensions.spacingMd,
                                  ),
                                  Expanded(child: thresholdField),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        _buildSectionCard(
                          context: context,
                          title: 'Barcode',
                          subtitle: 'Optional. Enter a barcode manually or use a barcode scanner.',
                          icon: Icons.qr_code_2_outlined,
                          child: TextFormField(
                            controller: _barcodeController,
                            keyboardType: TextInputType.number,
                            decoration:
                                _inputDecoration(
                                  context: context,
                                  label: 'Barcode',
                                  hint: 'e.g. 4791234567890',
                                  icon: Icons.qr_code_2,
                                ).copyWith(
                                  helperText: 'You can type the barcode or scan it using a compatible scanner.',
                                  helperStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingXl),

                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeight,
                          child: FilledButton.icon(
                            onPressed: _isLoadingSettings ? null : _saveProduct,
                            icon: Icon(
                              isEditing
                                  ? Icons.save_outlined
                                  : Icons.add_circle_outline,
                            ),
                            label: Text(
                              isEditing ? 'Save Changes' : 'Save Product',
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingXl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryField(
    BuildContext context,
    List<String> categoryNames,
    String? selectedCategory,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DropdownButtonFormField<String>(
      initialValue: selectedCategory,
      isExpanded: true,
      validator: _categoryValidator,

      // Dropdown menu appearance.
      dropdownColor: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      elevation: 8,

      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colorScheme.onSurfaceVariant,
      ),

      decoration:
          _inputDecoration(
            context: context,
            label: 'Category',
            hint: 'Choose a product category',
            icon: Icons.category_outlined,
          ).copyWith(
            helperText: selectedCategory == null
                ? 'Select an existing category'
                : 'Selected category',
            helperStyle: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

      items: categoryNames.map((categoryName) {
        final isSelected = categoryName == selectedCategory;

        return DropdownMenuItem<String>(
          value: categoryName,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
              vertical: AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.12)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    size: 17,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(width: AppDimensions.spacingMd),

                Expanded(
                  child: Text(
                    categoryName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),

                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
              ],
            ),
          ),
        );
      }).toList(),

      selectedItemBuilder: (context) {
        return categoryNames.map((categoryName) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              categoryName,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList();
      },

      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _addCategory,
        icon: const Icon(Icons.add),
        label: const Text('Category'),
      ),
    );
  }
}
