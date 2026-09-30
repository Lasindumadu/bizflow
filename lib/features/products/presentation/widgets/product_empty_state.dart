import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = isSearchResult ? 'No products found' : 'No products yet';

    final description = isSearchResult
        ? 'Try a different product name or SKU.'
        : 'Add your first product to start managing your inventory.';

    final icon = isSearchResult
        ? Icons.search_off_rounded
        : Icons.inventory_2_outlined;

    return SizedBox(
      width: double.infinity,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXl,
            vertical: AppDimensions.spacingXxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: colorScheme.primary),
              ),

              const SizedBox(height: AppDimensions.spacingLg),

              Text(
                title,
                style: AppTextStyles.heading2.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.spacingSm),

              Text(
                description,
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              if (!isSearchResult && onAddProduct != null) ...[
                const SizedBox(height: AppDimensions.spacingLg),
                FilledButton.icon(
                  onPressed: onAddProduct,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Product'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
