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

    final isDark = theme.brightness == Brightness.dark;

    return AnimatedScale(
      scale: _isPressed ? 0.995 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
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
    ));
  }

  Widget _buildProductIcon(BuildContext context) {
    final c = _categoryStyle(widget.product.category);
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: c, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        _categoryIcon(widget.product.category),
        size: 28,
        color: Colors.white,
      ),
    );
  }

  List<Color> _categoryStyle(String category) {
    final k = category.toLowerCase();
    if (k.contains('elect')) {
      return const [Color(0xFF4F46E5), Color(0xFF7C3AED)];
    }
    if (k.contains('groc') || k.contains('food')) {
      return const [Color(0xFF059669), Color(0xFF10B981)];
    }
    if (k.contains('bev')) {
      return const [Color(0xFF0EA5E9), Color(0xFF6366F1)];
    }
    if (k.contains('house')) {
      return const [Color(0xFFF59E0B), Color(0xFFF97316)];
    }
    if (k.contains('care') || k.contains('beaut')) {
      return const [Color(0xFFEC4899), Color(0xFFF43F5E)];
    }
    return const [Color(0xFF6366F1), Color(0xFF0EA5E9)];
  }

  IconData _categoryIcon(String category) {
    final k = category.toLowerCase();
    if (k.contains('elect')) return Icons.devices_rounded;
    if (k.contains('groc') || k.contains('food')) {
      return Icons.shopping_basket_rounded;
    }
    if (k.contains('bev')) return Icons.local_cafe_rounded;
    if (k.contains('house')) return Icons.chair_rounded;
    if (k.contains('care') || k.contains('beaut')) {
      return Icons.spa_rounded;
    }
    if (k.contains('stat')) return Icons.note_alt_rounded;
    return Icons.inventory_2_rounded;
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
