import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../models/product.dart';

/// Premium product tile: gradient category squircle, tabular price chip,
/// stock-status pill rhythm (mint / amber / red), hover lift with border
/// bloom and a subtle press-scale — all presentation only.
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
  bool _pressed = false;

  List<Color> get _categoryColors {
    final k = widget.product.category.toLowerCase();
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
    return [AppColors.royalMid, AppColors.royalStart];
  }

  IconData get _categoryIcon {
    final k = widget.product.category.toLowerCase();
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

  Widget _buildIconSquircle() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _categoryColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final product = widget.product;
    final low = product.isLowStock;
    final isOut = product.stockQuantity <= 0;

    final card = BrandCard(
      padding: const EdgeInsets.all(14),
      radius: 20,
      accent: _categoryColors.last,
      gradientBorder: true,
      child: Row(
        children: [
          // Product photo or fallback gradient category squircle.
          if (product.productImageUrl != null &&
              product.productImageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(product.productImageUrl!),
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildIconSquircle(),
              ),
            ),
          ] else ...[
            _buildIconSquircle(),
          ],
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Price chip — tabular figures, royal tint.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: Theme.of(context).brightness == Brightness.dark
                              ? 0.16
                              : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(
                            alpha:
                                Theme.of(context).brightness == Brightness.dark
                                    ? 0.30
                                    : 0.18,
                          ),
                        ),
                      ),
                      child: Text(
                        '${widget.currency} ${product.sellingPrice.toStringAsFixed(2)}',
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: scheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Stock pill rhythm: red / amber / mint.
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
              if (value == 'edit') widget.onEdit?.call();
              if (value == 'delete') widget.onDelete?.call();
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.edit_outlined,
                      size: 18, color: scheme.primary),
                  title: const Text('Edit product'),
                ),
              ),
              if (widget.onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline_rounded,
                        size: 18, color: scheme.error),
                    title: const Text('Delete'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    // Tactile press moment — 0.97 scale, 120ms.
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: card,
      ),
    );
  }
}
