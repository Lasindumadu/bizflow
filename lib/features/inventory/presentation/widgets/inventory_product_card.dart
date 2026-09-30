import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';

class InventoryProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onStockIn;
  final VoidCallback onStockOut;
  final VoidCallback onAdjustment;
  final VoidCallback onHistory;

  const InventoryProductCard({
    super.key,
    required this.product,
    required this.onStockIn,
    required this.onStockOut,
    required this.onAdjustment,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.stockQuantity == 0;
    final isLowStock = product.isLowStock && !isOutOfStock;

    final Color statusColor;

    if (isOutOfStock) {
      statusColor = AppColors.error;
    } else if (isLowStock) {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.success;
    }

    final String statusText;

    if (isOutOfStock) {
      statusText = 'Out of stock';
    } else if (isLowStock) {
      statusText = 'Low stock';
    } else {
      statusText = 'In stock';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.heading2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text('SKU: ${product.sku}', style: AppTextStyles.caption),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: AppDimensions.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            Row(
              children: [
                const Text('Current Stock', style: AppTextStyles.bodySecondary),
                const Spacer(),
                Text(
                  '${product.stockQuantity}',
                  style: AppTextStyles.statValue,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                const Text('units', style: AppTextStyles.caption),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingSm),

            Text(
              'Low stock threshold: ${product.lowStockThreshold}',
              style: AppTextStyles.caption,
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              children: [
                OutlinedButton.icon(
                  onPressed: onStockIn,
                  icon: const Icon(Icons.add),
                  label: const Text('Stock In'),
                ),
                OutlinedButton.icon(
                  onPressed: onStockOut,
                  icon: const Icon(Icons.remove),
                  label: const Text('Stock Out'),
                ),
                OutlinedButton.icon(
                  onPressed: onAdjustment,
                  icon: const Icon(Icons.tune),
                  label: const Text('Adjust'),
                ),
                TextButton.icon(
                  onPressed: onHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
