import 'package:flutter/material.dart';

import '../../../../core/widgets/brand_ui.dart';

/// Photo-backed product empty state (retail shelves under a brand wash).
class ProductEmptyState extends StatelessWidget {
  final VoidCallback? onAddProduct;
  final bool isSearchResult;

  const ProductEmptyState({
    super.key,
    this.onAddProduct,
    this.isSearchResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = isSearchResult
        ? Icons.search_off_rounded
        : Icons.inventory_2_outlined;

    return BrandEmptyState(
      image: AppImages.retailShelves,
      icon: icon,
      title: isSearchResult ? 'No products found' : 'No products yet',
      message: isSearchResult
          ? 'Try a different product name or SKU.'
          : 'Add your first product to start managing your inventory.',
      actionLabel:
          !isSearchResult && onAddProduct != null ? 'Add product' : null,
      onAction: onAddProduct,
    );
  }
}
