import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/product_empty_state.dart';
import '../widgets/product_search_bar.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  ProductsScreenState createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final ProductRepository _productRepository = ProductRepository(appDatabase);

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  StreamSubscription<List<Product>>? _productsSubscription;

  String searchQuery = '';
  String selectedCategory = 'All Categories';

  List<Product> products = [];

  bool isLoading = true;
  bool isLoadingSettings = true;
  bool hasError = false;

  String currency = 'USD';

  late final AnimationController _pageAnimationController;
  late final Animation<double> _pageFadeAnimation;
  late final Animation<Offset> _pageSlideAnimation;

  @override
  void initState() {
    super.initState();

    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _pageFadeAnimation = CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOut,
    );

    _pageSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.015), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pageAnimationController.forward();

    _loadBusinessSettings();
    _watchProducts();
  }

  void _watchProducts() {
    _productsSubscription?.cancel();

    setState(() {
      isLoading = true;
      hasError = false;
    });

    _productsSubscription = _productRepository.watchProducts().listen(
      (items) {
        if (!mounted) {
          return;
        }

        final sortedItems = [...items]
          ..sort(
            (a, b) => a.name.trim().toLowerCase().compareTo(
              b.name.trim().toLowerCase(),
            ),
          );

        setState(() {
          products = sortedItems;
          isLoading = false;
          hasError = false;
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          isLoading = false;
          hasError = true;
        });
      },
    );
  }

  Future<void> _loadBusinessSettings() async {
    try {
      final settings = await _businessSettingsRepository.getSettings();

      if (!mounted) {
        return;
      }

      setState(() {
        currency = settings.currency;
        isLoadingSettings = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingSettings = false;
      });
    }
  }

  Future<void> refreshBusinessSettings() async {
    await _loadBusinessSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBusinessSettings();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _pageAnimationController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final product = await Navigator.of(context).push<Product>(
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );

    if (product == null || !mounted) {
      return;
    }

    try {
      await _productRepository.addProduct(product);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add product: $error')));
    }
  }

  Future<void> _editProduct(Product product) async {
    final updatedProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute(
        builder: (context) => AddProductScreen(product: product),
      ),
    );

    if (updatedProduct == null || !mounted) {
      return;
    }

    try {
      await _productRepository.updateProduct(updatedProduct);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product: $error')),
      );
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product?'),
          content: Text(
            'Are you sure you want to permanently delete '
            '"${product.name}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await _productRepository.deleteProduct(product.id);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $error')),
      );
    }
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = _getCategories();

    return DropdownButtonFormField<String>(
      initialValue: categories.contains(selectedCategory)
          ? selectedCategory
          : 'All Categories',
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
        ),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<String>(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          selectedCategory = value;
        });
      },
      dropdownColor: colorScheme.surface,
    );
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Unable to load products.',
              style: AppTextStyles.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Something went wrong while loading your products. '
              'Please try again.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            FilledButton.icon(
              onPressed: _watchProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products',
          style: AppTextStyles.heading1.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          'Manage your products and inventory.',
          style: AppTextStyles.bodySecondary.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProductSectionHeader(BuildContext context, int itemCount) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Products',
          style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSm,
            vertical: AppDimensions.spacingXs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style: AppTextStyles.caption.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      key: const ValueKey('products-loading'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXxl),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                'Loading products',
                style: AppTextStyles.heading2.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Please wait while we load your inventory.',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getCategories() {
    final categories = products
        .map((product) => product.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return ['All Categories', ...categories];
  }

  Widget _buildProductContent(
    BuildContext context,
    List<Product> filteredProducts,
  ) {
    if (isLoading || isLoadingSettings) {
      return _buildLoadingState(context);
    }

    if (filteredProducts.isEmpty) {
      return SizedBox(
        key: ValueKey(
          searchQuery.trim().isEmpty
              ? 'products-empty'
              : 'products-search-empty',
        ),
        width: double.infinity,
        child: ProductEmptyState(
          onAddProduct: _addProduct,
          isSearchResult:
              searchQuery.trim().isNotEmpty ||
              selectedCategory != 'All Categories',
        ),
      );
    }

    return Column(
      key: const ValueKey('products-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: filteredProducts.map((product) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
          child: ProductCard(
            product: product,
            currency: currency,
            onEdit: () => _editProduct(product),
            onDelete: () => _deleteProduct(product),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      final name = product.name.toLowerCase();
      final sku = product.sku.toLowerCase();
      final query = searchQuery.toLowerCase();

      final matchesSearch = name.contains(query) || sku.contains(query);

      final matchesCategory =
          selectedCategory == 'All Categories' ||
          product.category.trim() == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacingLg),
            child: FilledButton.icon(
              onPressed: _addProduct,
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ),
        ],
      ),
      body: hasError
          ? _buildErrorState()
          : SafeArea(
              child: FadeTransition(
                opacity: _pageFadeAnimation,
                child: SlideTransition(
                  position: _pageSlideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPageHeader(context),

                            const SizedBox(height: AppDimensions.spacingXl),

                            ProductSearchBar(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),

                            const SizedBox(height: AppDimensions.spacingMd),

                            _buildCategoryFilter(context),

                            const SizedBox(height: AppDimensions.spacingXl),

                            _buildProductSectionHeader(
                              context,
                              filteredProducts.length,
                            ),

                            const SizedBox(height: AppDimensions.spacingMd),

                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              reverseDuration: const Duration(
                                milliseconds: 180,
                              ),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ...previousChildren,
                                    ?currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.98, end: 1.0)
                                        .animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildProductContent(
                                context,
                                filteredProducts,
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
    );
  }
}
