import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/product_empty_state.dart';
import '../widgets/product_search_bar.dart';
import 'add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  final bool showAppBar;
  const ProductsScreen({super.key, this.showAppBar = true});

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

  String _productSaveErrorMessage(Object error, String action) {
    if (error is StateError &&
        error.message ==
            'This barcode is already assigned to another product.') {
      return 'This barcode is already assigned to another product. '
          'Please enter a unique barcode.';
    }

    return 'Failed to $action product. Please try again.';
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_productSaveErrorMessage(error, 'add'))),
      );
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
        SnackBar(content: Text(_productSaveErrorMessage(error, 'update'))),
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

      final message = error is StateError
          ? error.message
          : 'Failed to delete product. Please try again.';

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Whether the acting session can manage products (owner or manager).
  bool get _canManageProducts => canPerform(
        sessionController.current,
        {StaffRole.owner, StaffRole.manager},
      );

  /// Whether the acting session is the owner (product deletion is owner-only).
  bool get _isOwner => canPerform(
        sessionController.current,
        {StaffRole.owner},
      );

  /// Catalog stats derived for display only.
  double get _totalUnits =>
      products.fold<double>(0.0, (sum, p) => sum + p.stockQuantity);
  double get _stockValue =>
      products.fold<double>(0, (sum, p) => sum + p.stockQuantity * p.purchasePrice);
  int get _lowStockCount => products.where((p) => p.isLowStock).length;

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'Unable to load products.',
              style: AppTextStyles.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
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
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Photo-backed hero with a catalog stats eyebrow and the single
  /// "Add product" gradient CTA (same [_addProduct] callback).
  Widget _buildPageHeader(BuildContext context) {
    return PageHero(
      eyebrow: 'Catalog',
      eyebrowIcon: Icons.inventory_2_rounded,
      title: 'Products & pricing',
      subtitle:
          '${products.length} product${products.length == 1 ? '' : 's'} · '
          '$currency ${_stockValue.toStringAsFixed(2)} stock value · '
          '$_totalUnits units on shelf',
      showIllustration: false,
      image: AppImages.retailShelves,
      secondaryAction: _lowStockCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 12,
                    color: AppColors.brandAmber,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$_lowStockCount low on stock',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            )
          : null,
      action: _canManageProducts ? _buildAddCta() : null,
    );
  }

  /// Primary gradient CTA — royal gradient + glow, press-scale 0.97.
  Widget _buildAddCta() {
    return AnimatedPressCta(
      label: 'Add product',
      icon: Icons.add_rounded,
      onTap: _addProduct,
    );
  }

  /// Stock / value KPI row — royal, mint and amber rhythm with count-up
  /// numbers and 60ms·i stagger.
  Widget _buildKpiRow() {
    final cards = <_CatalogKpi>[
      _CatalogKpi(
        label: 'Total products',
        icon: Icons.inventory_2_rounded,
        gradient: AppDecor.royalGradient.colors,
        glowColor: AppColors.royalMid,
        helper: '$_totalUnits units in catalog',
        valueWidget: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: CountUpText(
            products.length.toDouble(),
            decimals: 0,
            style: _kpiValueStyle(context),
          ),
        ),
      ),
      _CatalogKpi(
        label: 'Stock value',
        icon: Icons.payments_rounded,
        gradient: AppDecor.flowGradient.colors,
        glowColor: AppColors.auroraTeal,
        helper: 'At purchase cost',
        valueWidget: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: CountUpText(
            _stockValue,
            prefix: '$currency ',
            decimals: 2,
            style: _kpiValueStyle(context),
          ),
        ),
      ),
      _CatalogKpi(
        label: 'Low stock alert',
        icon: Icons.warning_amber_rounded,
        gradient: AppDecor.amberGradient.colors,
        glowColor: AppColors.tertiary,
        helper: _lowStockCount == 0 ? 'Everything stocked' : 'Reorder soon',
        valueWidget: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: CountUpText(
            _lowStockCount.toDouble(),
            decimals: 0,
            style: _kpiValueStyle(context),
          ),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 3
            : width >= 520
                ? 3
                : width >= 380
                    ? 2
                    : 1;
        const gap = 12.0;
        final cardWidth = (width - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .asMap()
              .entries
              .map(
                (entry) => SizedBox(
                  width: cardWidth,
                  child: entry.value
                      .animate(delay: Duration(milliseconds: 60 * entry.key))
                      .fadeIn(
                        duration: 380.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .moveY(
                        begin: 14,
                        end: 0,
                        duration: 380.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  TextStyle _kpiValueStyle(BuildContext context) {
    return TextStyle(
      fontFamily: AppTextStyles.displayFont,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.7,
      color: Theme.of(context).colorScheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Search + category filter chips — selected chip uses the royal tint.
  Widget _buildSearchFilters(BuildContext context) {
    final categories = _getCategories();

    return BrandCard(
      padding: const EdgeInsets.all(14),
      radius: 20,
      accent: AppColors.royalMid,
      gradientBorder: true,
      child: Column(
        children: [
          ProductSearchBar(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category == selectedCategory;
                final isAll = category == 'All Categories';

                return AnimatedContainer(
                  key: ValueKey('chip-$category'),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.royalMid.withValues(
                            alpha:
                                Theme.of(context).brightness == Brightness.dark
                                    ? 0.22
                                    : 0.12,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? AppColors.royalMid.withValues(alpha: 0.55)
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.10)
                              : AppColors.lightBorder),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAll) ...[
                              Icon(
                                Icons.grid_view_rounded,
                                size: 14,
                                color: selected
                                    ? AppColors.royalMid
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w600,
                                color: selected
                                    ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.royalStart
                                        : AppColors.royalEnd)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                            if (selected && !isAll) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: AppColors.royalMid,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSectionHeader(BuildContext context, int itemCount) {
    return SectionHeading(
      title: selectedCategory == 'All Categories'
          ? 'All products'
          : selectedCategory,
      subtitle:
          '$itemCount item${itemCount == 1 ? '' : 's'} in this view',
      icon: Icons.grid_view_rounded,
      trailing: BrandPill(
        label: '$itemCount',
        color: AppColors.royalMid,
      ),
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
            boxShadow: AppDecor.cardShadow(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  gradient: AppDecor.royalGradient,
                  shape: BoxShape.circle,
                ),
                child: const AuroraLoader(size: 44, onDarkSurface: true),
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
          onAddProduct: _canManageProducts ? _addProduct : null,
          isSearchResult:
              searchQuery.trim().isNotEmpty ||
              selectedCategory != 'All Categories',
        ),
      );
    }

    return Column(
      key: const ValueKey('products-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in filteredProducts.asMap().entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
            // Stagger only the first screenful; the rest arrive instantly.
            child: entry.key < 12
                ? ProductCard(
                        product: entry.value,
                        currency: currency,
                        onEdit: () => _editProduct(entry.value),
                        onDelete: _isOwner ? () => _deleteProduct(entry.value) : null,
                      )
                      .animate(delay: Duration(milliseconds: 30 * entry.key))
                      .fadeIn(duration: 360.ms, curve: Curves.easeOutCubic)
                      .moveY(
                        begin: 14,
                        end: 0,
                        duration: 360.ms,
                        curve: Curves.easeOutCubic,
                      )
                : ProductCard(
                    product: entry.value,
                    currency: currency,
                    onEdit: () => _editProduct(entry.value),
                    onDelete:
                        _isOwner ? () => _deleteProduct(entry.value) : null,
                  ),
          ),
      ],
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
      appBar: widget.showAppBar ? AppBar(title: const Text('Products')) : null,
      body: hasError
          ? _buildErrorState().animate().fadeIn(duration: 300.ms).shake()
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
                            _buildPageHeader(context)
                                .animate(
                                  delay: 0.ms,
                                )
                                .fadeIn(
                                  duration: 400.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .moveY(
                                  begin: 14,
                                  end: 0,
                                  duration: 400.ms,
                                  curve: Curves.easeOutCubic,
                                ),

                            const SizedBox(height: AppDimensions.spacingLg),

                            // KPI row (products / stock value / low stock).
                            _buildKpiRow()
                                .animate(delay: 60.ms)
                                .fadeIn(
                                  duration: 380.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .moveY(
                                  begin: 14,
                                  end: 0,
                                  duration: 380.ms,
                                  curve: Curves.easeOutCubic,
                                ),

                            const SizedBox(height: AppDimensions.spacingLg),

                            _buildSearchFilters(context)
                                .animate(delay: 120.ms)
                                .fadeIn(
                                  duration: 380.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .moveY(
                                  begin: 14,
                                  end: 0,
                                  duration: 380.ms,
                                  curve: Curves.easeOutCubic,
                                ),

                            const SizedBox(height: AppDimensions.spacingXl),

                            _buildProductSectionHeader(
                              context,
                              filteredProducts.length,
                            ).animate(delay: 180.ms).fadeIn(
                                  duration: 340.ms,
                                  curve: Curves.easeOutCubic,
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

class _CatalogKpi extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final IconData icon;
  final List<Color> gradient;
  final Color glowColor;
  final String? helper;

  const _CatalogKpi({
    required this.label,
    required this.valueWidget,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BrandCard(
      padding: const EdgeInsets.all(18),
      elevated: true,
      accent: glowColor,
      gradientBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppDecor.glow(glowColor, alpha: 0.28),
                ),
                child: Icon(icon, color: Colors.white, size: 21),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          valueWidget,
          if (helper != null) ...[
            const SizedBox(height: 5),
            Text(
              helper!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The single primary gradient CTA — royal gradient, glow and a soft
/// press-scale of 0.97.
class AnimatedPressCta extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const AnimatedPressCta({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<AnimatedPressCta> createState() => _AnimatedPressCtaState();
}

class _AnimatedPressCtaState extends State<AnimatedPressCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppDecor.royalGradient,
            borderRadius: BorderRadius.circular(13),
            boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.35),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(13),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 18),
                    const SizedBox(width: 7),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
