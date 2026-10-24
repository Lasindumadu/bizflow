import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../models/product.dart';

class ProductCard extends StatelessWidget {
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

  List<Color> get _categoryColors {
    final k = product.category.toLowerCase();
    if (k.contains('elect')) {
      return const [Color(0xFF6366F1), Color(0xFF8B5CF6)];
    }
    if (k.contains('groc') || k.contains('food')) {
      return const [Color(0xFF10B981), Color(0xFF2DD4BF)];
    }
    if (k.contains('bev')) {
      return const [Color(0xFF0EA5E9), Color(0xFF22D3EE)];
    }
    if (k.contains('house')) {
      return const [Color(0xFFF59E0B), Color(0xFFFB923C)];
    }
    if (k.contains('care') || k.contains('beaut')) {
      return const [Color(0xFFEC4899), Color(0xFFFB7185)];
    }
    if (k.contains('stat')) {
      return const [Color(0xFF8B5CF6), Color(0xFF6D5DFB)];
    }
    return const [Color(0xFF5B5BF7), Color(0xFF8B5CF6)];
  }

  IconData get _categoryIcon {
    final k = product.category.toLowerCase();
    if (k.contains('elect')) return Icons.devices_rounded;
    if (k.contains('groc') || k.contains('food')) {
      return Icons.shopping_basket_rounded;
    }
    if (k.contains('bev')) return Icons.local_cafe_rounded;
    if (k.contains('house')) return Icons.chair_rounded;
    if (k.contains('care') || k.contains('beaut')) return Icons.spa_rounded;
    if (k.contains('stat')) return Icons.note_alt_rounded;
    return Icons.inventory_2_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final low = product.isLowStock;
    final isOut = product.stockQuantity <= 0;

    return BrandCard(
      padding: const EdgeInsets.all(14),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _categoryColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: _categoryColors.first.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Icon(_categoryIcon, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'SKU ${product.sku} · ${product.category}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.48),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Text(
                      '$currency ${product.sellingPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: scheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    BrandPill(
                      label: isOut
                          ? 'OUT OF STOCK'
                          : low
                              ? 'LOW · ${product.stockQuantity}'
                              : 'STOCK ${product.stockQuantity}',
                      color: isOut
                          ? AppColors.error
                          : low
                              ? AppColors.brandAmber
                              : AppColors.brandMintDeep,
                      icon: isOut
                          ? Icons.remove_circle_outline_rounded
                          : low
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'Product actions',
            offset: const Offset(0, 36),
            icon: Icon(
              Icons.more_horiz_rounded,
              size: 19,
              color: scheme.onSurface.withValues(alpha: 0.42),
            ),
            onSelected: (value) {
              if (value == 'edit') onEdit?.call();
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined, size: 18, color: scheme.primary),
                  title: const Text('Edit product'),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline_rounded, size: 18, color: scheme.error),
                  title: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
