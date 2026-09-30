import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/stock_movement_repository.dart';
import '../../../../models/product.dart';
import '../widgets/inventory_product_card.dart';
import '../widgets/stock_action_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
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

    if (query.isEmpty) {
      return _products;
    }

    return _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
    }).toList();
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            const Text(
              'Unable to load inventory.',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            const Text(
              'Something went wrong while loading your inventory. '
              'Please try again.',
              style: AppTextStyles.bodySecondary,
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

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: _hasError
          ? _buildErrorState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manage stock levels and inventory movements.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Wrap(
                    spacing: AppDimensions.spacingMd,
                    runSpacing: AppDimensions.spacingMd,
                    children: [
                      _InventorySummaryCard(
                        title: 'Products',
                        value: '${_products.length}',
                        icon: Icons.inventory_2_outlined,
                      ),
                      _InventorySummaryCard(
                        title: 'Total Units',
                        value: '$_totalUnits',
                        icon: Icons.layers_outlined,
                      ),
                      _InventorySummaryCard(
                        title: 'Low Stock',
                        value: '$_lowStockCount',
                        icon: Icons.warning_amber_outlined,
                      ),
                      _InventorySummaryCard(
                        title: 'Out of Stock',
                        value: '$_outOfStockCount',
                        icon: Icons.remove_shopping_cart_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  Row(
                    children: [
                      const Text('Inventory', style: AppTextStyles.heading2),
                      const Spacer(),
                      Text(
                        '${products.length} items',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
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
                    )
                  else if (products.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingXl),
                        child: Center(child: Text('No products found.')),
                      ),
                    )
                  else
                    ...products.map(
                      (product) => InventoryProductCard(
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
                      ),
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

  const _InventorySummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.caption),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(value, style: AppTextStyles.statValue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
