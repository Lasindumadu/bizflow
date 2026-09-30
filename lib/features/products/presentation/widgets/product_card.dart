import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final String currency;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.currency,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final stockColor = widget.product.isLowStock
        ? colorScheme.error
        : colorScheme.primary;

    final stockBackground = widget.product.isLowStock
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;

    return AnimatedScale(
      scale: _isPressed ? 0.995 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTapDown: (_) {
            setState(() {
              _isPressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _isPressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              _isPressed = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Row(
              children: [
                _buildProductIcon(context),

                const SizedBox(width: AppDimensions.spacingLg),

                Expanded(child: _buildProductInfo(context)),

                const SizedBox(width: AppDimensions.spacingMd),

                _buildPriceAndStock(context, stockColor, stockBackground),

                const SizedBox(width: AppDimensions.spacingSm),

                _buildMenu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: 27,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          'SKU: ${widget.product.sku}',
          style: AppTextStyles.caption.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Row(
          children: [
            Icon(
              Icons.category_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            Flexible(
              child: Text(
                widget.product.category,
                style: AppTextStyles.caption.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceAndStock(
    BuildContext context,
    Color stockColor,
    Color stockBackground,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${widget.currency} ${widget.product.sellingPrice.toStringAsFixed(2)}',
          style: AppTextStyles.statValue.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSm,
            vertical: AppDimensions.spacingXs,
          ),
          decoration: BoxDecoration(
            color: stockBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.product.isLowStock
                    ? Icons.warning_amber_rounded
                    : Icons.inventory_2_outlined,
                size: 14,
                color: stockColor,
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Text(
                'Stock: ${widget.product.stockQuantity}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: stockColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopupMenuButton<String>(
      tooltip: 'Product actions',
      icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
      onSelected: (value) {
        if (value == 'edit') {
          widget.onEdit?.call();
        } else if (value == 'delete') {
          widget.onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, color: colorScheme.primary),
            title: const Text('Edit'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: colorScheme.error),
            title: const Text('Delete'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
