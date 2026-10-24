import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/stock_movement_repository.dart';
import '../../../../models/product.dart';
import '../widgets/inventory_product_card.dart';
import '../widgets/stock_action_dialog.dart';

class InventoryScreen extends StatefulWidget {
  final bool showAppBar;
  const InventoryScreen({super.key, this.showAppBar = true});

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  final ProductRepository _productRepository = ProductRepository(appDatabase);

  final StockMovementRepository _stockMovementRepository =
      StockMovementRepository(appDatabase);

  StreamSubscription<List<Product>>? _productsSubscription;

  List<Product> _products = [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _watchProducts();
  }

  Future<void> refreshBusinessSettings() async {
    // Inventory screen does not depend on business settings
  }

  void _watchProducts() {
    _productsSubscription?.cancel();

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _productsSubscription = _productRepository.watchProducts().listen(
      (products) {
        if (!mounted) {
          return;
        }

        setState(() {
          _products = products;
          _isLoading = false;
          _hasError = false;
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = query.isEmpty
        ? [..._products]
        : _products.where((product) {
            return product.name.toLowerCase().contains(query) ||
                product.sku.toLowerCase().contains(query) ||
                product.category.toLowerCase().contains(query) ||
                product.barcode.trim().toLowerCase().contains(query);
          }).toList();

    filtered.sort(
      (a, b) =>
          a.name.trim().toLowerCase().compareTo(b.name.trim().toLowerCase()),
    );

    return filtered;
  }

  int get _totalUnits {
    return _products.fold(0, (total, product) => total + product.stockQuantity);
  }

  int get _lowStockCount {
    return _products.where((product) {
      return product.isLowStock;
    }).length;
  }

  int get _outOfStockCount {
    return _products.where((product) {
      return product.stockQuantity == 0;
    }).length;
  }

  Future<void> _performStockAction(
    Product product,
    StockActionType actionType,
  ) async {
    final result = await showDialog<StockActionResult>(
      context: context,
      builder: (context) {
        return StockActionDialog(product: product, actionType: actionType);
      },
    );

    if (result == null || !mounted) {
      return;
    }

    try {
      await _productRepository.changeStock(
        productId: product.id,
        quantity: result.quantity,
        type: result.type,
        note: result.note,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update stock: $error')));
    }
  }

  Future<void> _showHistory(Product product) async {
    final movements = await _stockMovementRepository.getProductMovements(
      product.id,
    );

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${product.name} - Stock History'),
          content: SizedBox(
            width: 600,
            height: 400,
            child: movements.isEmpty
                ? const Center(child: Text('No stock movements yet.'))
                : ListView.separated(
                    itemCount: movements.length,
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemBuilder: (context, index) {
                      final movement = movements[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Icon(
                            movement.type == 'STOCK_IN'
                                ? Icons.add
                                : movement.type == 'STOCK_OUT'
                                ? Icons.remove
                                : Icons.tune,
                          ),
                        ),
                        title: Text(movement.type.replaceAll('_', ' ')),
                        subtitle: Text(
                          '${movement.previousStock} → ${movement.newStock}'
                          '${movement.note.isEmpty ? '' : '\n${movement.note}'}',
                        ),
                        trailing: Text(
                          movement.type == 'STOCK_OUT'
                              ? '-${movement.quantity}'
                              : '+${movement.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text(
              'Unable to load inventory',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Something went wrong while loading your inventory.',
              style: AppTextStyles.bodySecondary,
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

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Inventory'))
          : null,
      body: _hasError
          ? _buildErrorState().animate().fadeIn(duration: 300.ms).shake()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHero(
                    eyebrow: 'Stock control',
                    title: 'Inventory',
                    subtitle:
                        '${_products.length} products · $_totalUnits units on hand · '
                        '$_lowStockCount low on stock.',
                    showIllustration: false,
                  ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05, end: 0),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Wrap(
                    spacing: AppDimensions.spacingMd,
                    runSpacing: AppDimensions.spacingMd,
                    children: [
                      _InventorySummaryCard(
                        title: 'Products',
                        value: '${_products.length}',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.primaryDark,
                      ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
                      _InventorySummaryCard(
                        title: 'Total Units',
                        value: '$_totalUnits',
                        icon: Icons.layers_outlined,
                        color: AppColors.accent,
                      ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
                      _InventorySummaryCard(
                        title: 'Low Stock',
                        value: '$_lowStockCount',
                        icon: Icons.warning_amber_outlined,
                        color: AppColors.tertiary,
                      ).animate(delay: 300.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
                      _InventorySummaryCard(
                        title: 'Out of Stock',
                        value: '$_outOfStockCount',
                        icon: Icons.remove_shopping_cart_outlined,
                        color: AppColors.errorDark,
                      ).animate(delay: 400.ms).fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  BrandCard(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search by name, SKU, category or barcode…',
                        prefixIcon: Icon(Icons.search_rounded, size: 19),
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppDimensions.spacingXl),
                  SectionHeading(
                    title: 'Stock on hand',
                    subtitle: '${products.length} items in this view',
                    icon: Icons.warehouse_rounded,
                    trailing: BrandPill(
                      label: '$_totalUnits UNITS',
                      color: AppColors.primary,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 600.ms).slideX(begin: -0.1, end: 0),
                  const SizedBox(height: AppDimensions.spacingMd),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingXl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: AppDimensions.spacingMd),
                            Text(
                              'Loading inventory...',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms)
                  else if (products.isEmpty)
                    const BrandEmptyState(
                      compact: true,
                      icon: Icons.inventory_2_outlined,
                      title: 'No products found',
                      message: 'Try another search or add products first.',
                    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0))
                  else
                    ...products.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final product = entry.value;
                        return InventoryProductCard(
                          product: product,
                          onStockIn: () {
                            _performStockAction(product, StockActionType.stockIn);
                          },
                          onStockOut: () {
                            _performStockAction(
                              product,
                              StockActionType.stockOut,
                            );
                          },
                          onAdjustment: () {
                            _performStockAction(
                              product,
                              StockActionType.adjustment,
                            );
                          },
                          onHistory: () {
                            _showHistory(product);
                          },
                        ).animate(delay: Duration(milliseconds: 700 + 50 * index))
                          .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
                          .slideX(begin: 0.1, end: 0);
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

class _InventorySummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _InventorySummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 196,
      child: MetricCard(
        compact: true,
        label: title,
        value: value,
        icon: icon,
        gradient: [color, color.withValues(alpha: 0.72)],
      ),
    );
  }
}
