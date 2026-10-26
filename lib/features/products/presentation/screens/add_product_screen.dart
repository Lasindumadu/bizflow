import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../models/product.dart';
import '../../../../data/repositories/product_repository.dart';

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

  /// Selected product photo (local file path stored in productImageUrl).
  File? _selectedImage;
  String? _imagePath;

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

  /// Whether the acting session can manage products (owner or manager).
  bool get _canManageProducts => canPerform(
        sessionController.current,
        {StaffRole.owner, StaffRole.manager},
      );

  String? _barcodeError;
  bool _isSaving = false;

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

    // Live preview card follows the name, category and price fields.
    _nameController.addListener(_refreshPreview);
    _purchasePriceController.addListener(_refreshPreview);
    _sellingPriceController.addListener(_refreshPreview);
    _stockController.addListener(_refreshPreview);

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

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();

    _nameController.removeListener(_refreshPreview);
    _purchasePriceController.removeListener(_refreshPreview);
    _sellingPriceController.removeListener(_refreshPreview);
    _stockController.removeListener(_refreshPreview);

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

  /// Picks an image from the gallery and stores it in the app documents
  /// directory so the path can be saved to productImageUrl.
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null || !mounted) return;
      await _saveImagePermanently(image);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image from gallery.')),
      );
    }
  }

  /// Takes a photo with the camera and stores it in the app documents
  /// directory so the path can be saved to productImageUrl.
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image == null || !mounted) return;
      await _saveImagePermanently(image);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture photo.')),
      );
    }
  }

  /// Copies the picked image into the app documents directory and returns its
  /// persistent path, or null on failure.
  Future<void> _saveImagePermanently(XFile image) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final saved = await File(image.path).copy('${dir.path}/$fileName');
      if (!mounted) return;
      setState(() {
        _selectedImage = saved;
        _imagePath = saved.path;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save product image.')),
      );
    }
  }

  /// Clears the selected product image.
  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imagePath = null;
    });
  }

  Future<void> _saveProduct() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _barcodeError = null;
    });

    try {
      final barcode = _barcodeController.text.trim();
      final productId = widget.product?.id;

      final barcodeTaken = await ProductRepository(appDatabase)
          .isBarcodeTaken(barcode, excludingProductId: productId);

      if (!mounted) {
        return;
      }

      if (barcodeTaken) {
        setState(() {
          _barcodeError =
              'This barcode is already assigned to another product.';
          _isSaving = false;
        });
        return;
      }

      final product = Product(
        id: productId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        category: _selectedCategory!.trim(),
        purchasePrice: double.parse(_purchasePriceController.text.trim()),
        sellingPrice: double.parse(_sellingPriceController.text.trim()),
        stockQuantity: double.parse(_stockController.text.trim()),
        lowStockThreshold: double.parse(_lowStockController.text.trim()),
        barcode: barcode,
        productImageUrl: _imagePath,
      );

      Navigator.of(context).pop(product);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to validate the barcode. Please try again.'),
        ),
      );

      setState(() {
        _isSaving = false;
      });
    }
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
    required Color accent,
    int delay = 0,
  }) {
    final Widget section = BrandFormSection(
      title: title,
      subtitle: subtitle,
      icon: icon,
      accent: accent,
      child: child,
    );

    // Staggered entrance, 60ms·i per section.
    return section
        .animate(delay: delay.ms)
        .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
        .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildProductPreview(BuildContext context, bool isEditing) {
    final name = _nameController.text.trim();
    final purchase = double.tryParse(_purchasePriceController.text.trim()) ?? 0;
    final selling = double.tryParse(_sellingPriceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final profit = selling - purchase;
    final margin = selling > 0 ? (profit / selling) * 100 : 0.0;
    final healthy = profit > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppDecor.royalGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Untitled product' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _selectedCategory == null || _selectedCategory!.isEmpty
                          ? 'No category selected'
                          : _selectedCategory!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  isEditing ? 'EDITING' : 'NEW ITEM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELLING PRICE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$_currency ${selling.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BrandPill(
                    label:
                        '${margin.toStringAsFixed(0)}% margin',
                    color: healthy ? AppColors.brandMint : AppColors.brandCoral,
                    icon: healthy
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${stock < 0 ? 0 : stock} in stock',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : AppColors.lightBorder;

    // Rounded 14 field with the royal focus ring; a soft royal glow rides
    // along via the tinted suffix when a section calls for it.
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      prefixText: prefixText,
      prefixStyle: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.65)
          : colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.royalMid,
          width: 1.7,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.7),
      ),
    );
  }

  /// Inline validation state — a mint checkmark while the field is valid.
  Widget _fieldCheck({
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.isEmpty || validator(value.text) != null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.check_circle_rounded,
            size: 18,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppColors.brandMint
                    : AppColors.brandMintDeep,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_canManageProducts) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Product')),
        body: const Center(
          child: Text('Adding products is restricted to the owner and managers.'),
        ),
      );
    }

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
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BrandPageHeader(
                eyebrow: 'Inventory',
                title: isEditing ? 'Edit product' : 'Add product',
                subtitle: isEditing
                    ? 'Update pricing, stock and identification details.'
                    : 'Create a catalogue item with pricing and stock levels.',
                icon: Icons.inventory_2_rounded,
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildProductPreview(context, isEditing)
                                    .animate()
                                    .fadeIn(
                                      duration: 380.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .moveY(
                                      begin: 14,
                                      end: 0,
                                      curve: Curves.easeOutCubic,
                                    ),

                                const SizedBox(height: 16),

                        _buildSectionCard(
                          context: context,
                          title: 'Product Information',
                          subtitle:
                              'Basic details used to identify your product.',
                          icon: Icons.inventory_2_outlined,
                          accent: AppColors.royalMid,
                          delay: 60,
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
                                  suffixIcon: _fieldCheck(
                                    controller: _nameController,
                                    validator: _requiredValidator,
                                  ),
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
                                  suffixIcon: _fieldCheck(
                                    controller: _skuController,
                                    validator: _requiredValidator,
                                  ),
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
                          accent: AppColors.brandMintDeep,
                          delay: 120,
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
                                  suffixIcon: _fieldCheck(
                                    controller: _purchasePriceController,
                                    validator: _numberValidator,
                                  ),
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
                                  suffixIcon: _fieldCheck(
                                    controller: _sellingPriceController,
                                    validator: _numberValidator,
                                  ),
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
                          accent: AppColors.stockTint[1],
                          delay: 180,
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
                                  suffixIcon: _fieldCheck(
                                    controller: _stockController,
                                    validator: _integerValidator,
                                  ),
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
                                  suffixIcon: _fieldCheck(
                                    controller: _lowStockController,
                                    validator: _integerValidator,
                                  ),
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
                          accent: AppColors.growthTint[1],
                          delay: 240,
                          child: TextFormField(
                            controller: _barcodeController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) {
                              if (_barcodeError != null) {
                                setState(() {
                                  _barcodeError = null;
                                });
                              }
                            },
                            decoration:
                                _inputDecoration(
                                  context: context,
                                  label: 'Barcode',
                                  hint: 'e.g. 4791234567890',
                                  icon: Icons.qr_code_2,
                                ).copyWith(
                                  errorText: _barcodeError,
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

                        const SizedBox(height: AppDimensions.spacingLg),

                        _buildSectionCard(
                          context: context,
                          title: 'Product Image',
                          subtitle:
                              'Optional. Add a photo that will appear on POS tiles.',
                          icon: Icons.image_outlined,
                          accent: AppColors.posTint.last,
                          delay: 300,
                          child: Column(
                            children: [
                              if (_selectedImage != null) ...[
                                BrandCard(
                                  padding: const EdgeInsets.all(16),
                                  radius: 16,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                _selectedImage!,
                                                width: double.infinity,
                                                height: 160,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip: 'Retake / Replace',
                                                icon: const Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 20),
                                                onPressed: _takePhoto,
                                              ),
                                              IconButton(
                                                tooltip: 'Remove image',
                                                icon: const Icon(
                                                    Icons.close_rounded,
                                                    size: 20,
                                                    color: AppColors.error),
                                                onPressed: _clearImage,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    height: AppDimensions.spacingMd),
                              ] else ...[
                                BrandCard(
                                  padding: const EdgeInsets.all(16),
                                  radius: 16,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 48,
                                        color:
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                      const SizedBox(
                                          height: AppDimensions.spacingSm),
                                      Text(
                                        'No image selected',
                                        style: TextStyle(
                                          fontFamily:
                                              AppTextStyles.displayFont,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: AppDimensions.spacingXs),
                                      Text(
                                        'Take a photo or choose from gallery to add a product photo.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: AppDimensions.spacingMd),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                    height: AppDimensions.spacingMd),
                              ],

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _takePhoto,
                                      icon: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 18),
                                      label: const Text('Take Photo'),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: AppDimensions.spacingSm),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _pickFromGallery,
                                      icon: const Icon(
                                          Icons.photo_library_outlined,
                                          size: 18),
                                      label: const Text(
                                          'Choose from Gallery'),
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
                    ),
                  ),
                ),
              ),
              BrandStickyBar(
                child: Builder(
                  builder: (context) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final name = _nameController.text.trim();
                    final selling =
                        double.tryParse(_sellingPriceController.text.trim());

                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.royalMid.withValues(alpha: 0.16)
                                  : AppColors.posTint[0],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.royalMid.withValues(
                                  alpha: isDark ? 0.35 : 0.28,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isEditing
                                      ? 'EDITING PRODUCT'
                                      : 'NEW PRODUCT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: isDark
                                        ? AppColors.royalStart
                                        : AppColors.royalEnd,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${name.isEmpty ? 'Untitled product' : name}'
                                  ' · $_currency '
                                  '${selling?.toStringAsFixed(2) ?? '—'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.displayFont,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Primary save CTA — royal gradient + glow,
                        // unchanged validation/loading logic.
                        GradientButton(
                          label: isEditing ? 'Save changes' : 'Save product',
                          icon: isEditing
                              ? Icons.check_rounded
                              : Icons.add_circle_outline_rounded,
                          gradient: AppDecor.royalGradient.colors,
                          expanded: false,
                          isLoading: _isSaving,
                          onPressed:
                              _isLoadingSettings || _isSaving
                                  ? null
                                  : _saveProduct,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
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
