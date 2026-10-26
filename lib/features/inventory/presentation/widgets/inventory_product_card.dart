import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../models/product.dart';

/// Premium stock row for the inventory list.
///
/// Presentation only — every callback is provided by the owner screen
/// and is invoked unchanged.
class InventoryProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onStockIn;
  final VoidCallback? onStockOut;
  final VoidCallback? onAdjustment;
  final VoidCallback onHistory;
  final bool canManageStock;

  const InventoryProductCard({
    super.key,
    required this.product,
    this.onStockIn,
    this.onStockOut,
    this.onAdjustment,
    required this.onHistory,
    this.canManageStock = false,
  });

  ({Color soft, Color deep, List<Color> fill}) _stateTone(bool isDark) {
    if (isOutOfStock) {
      return (
        soft: AppColors.errorContainer,
        deep: isDark ? AppColors.errorLight : AppColors.errorDark,
        fill: AppDecor.errorGradient.colors,
      );
    }
    if (isLowStock) {
      return (
        soft: AppColors.warningContainer,
        deep: isDark ? AppColors.warningLight : AppColors.warningDark,
        fill: AppDecor.amberGradient.colors,
      );
    }
    return (
      soft: AppColors.moneyTint.first,
      deep: isDark ? AppColors.brandMint : AppColors.brandMintDeep,
      fill: AppDecor.flowGradient.colors,
    );
  }

  bool get isOutOfStock => product.stockQuantity == 0;
  bool get isLowStock => product.isLowStock && !isOutOfStock;

  String get statusText {
    if (isOutOfStock) return 'Out of stock';
    if (isLowStock) return 'Low stock';
    return 'In stock';
  }

  IconData get statusIcon {
    if (isOutOfStock) return Icons.remove_circle_outline_rounded;
    if (isLowStock) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline_rounded;
  }

  /// Stock level as 0..1 against a soft target of 5× the low-stock
  /// threshold — enough to read "healthy" vs "barely there".
  double get _levelFraction {
    final target = math.max(product.lowStockThreshold * 5, 1);
    return (product.stockQuantity / target).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final tone = _stateTone(isDark);
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    final categoryInitial = product.category.trim().isNotEmpty
        ? product.category.trim()[0].toUpperCase()
        : '•';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: BrandCard(
        padding: const EdgeInsets.all(14),
        radius: 20,
        accent: tone.deep,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient category squircle.
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppDecor.toneGradient(product.category.hashCode),
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppDecor.glow(
                  AppColors.stockTint.last,
                  alpha: isDark ? 0.26 : 0.16,
                ),
              ),
              child: Center(
                child: Text(
                  categoryInitial,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.stockQuantity}',
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'units',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'SKU ${product.sku} · ${product.category}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Stock level mini-bar — mint/amber/red aurora fills.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 6,
                      color: (isDark
                              ? Colors.white
                              : AppColors.brandInk)
                          .withValues(alpha: 0.07),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _levelFraction == 0
                            ? 0.02
                            : _levelFraction,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: tone.fill),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      BrandPill(
                        label: statusText.toUpperCase(),
                        color: tone.deep,
                        icon: statusIcon,
                      ),
                      Text(
                        'threshold ${product.lowStockThreshold}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Movement in/out pills + adjust + history.
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MovementPill(
                        label: 'In',
                        sign: '+',
                        color: isDark
                            ? AppColors.brandMint
                            : AppColors.brandMintDeep,
                        icon: Icons.south_west_rounded,
                        enabled: canManageStock && onStockIn != null,
                        onTap: onStockIn,
                      ),
                      _MovementPill(
                        label: 'Out',
                        sign: '−',
                        color: isDark
                            ? AppColors.roseLight
                            : AppColors.rose,
                        icon: Icons.north_east_rounded,
                        enabled: canManageStock && onStockOut != null,
                        onTap: onStockOut,
                      ),
                      _MovementPill(
                        label: 'Adjust',
                        sign: '',
                        color: AppColors.stockTint.last,
                        icon: Icons.tune_rounded,
                        enabled: canManageStock && onAdjustment != null,
                        onTap: onAdjustment,
                      ),
                      _MovementPill(
                        label: 'History',
                        sign: '',
                        color: scheme.onSurface.withValues(alpha: 0.55),
                        icon: Icons.history_rounded,
                        enabled: true,
                        onTap: onHistory,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact +/- movement pill in the section tint.
class _MovementPill extends StatelessWidget {
  final String label;
  final String sign;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _MovementPill({
    required this.label,
    required this.sign,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, enabled ? -1 : 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: enabled
            ? color.withValues(alpha: isDark ? 0.18 : 0.10)
            : Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: enabled
              ? color.withValues(alpha: isDark ? 0.34 : 0.22)
              : Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sign.isNotEmpty)
            Text(
              sign,
              style: TextStyle(
                fontFamily: AppTextStyles.displayFont,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1,
                color: enabled ? color : null,
              ),
            ),
          if (sign.isEmpty) Icon(icon, size: 13, color: enabled ? color : null),
          if (sign.isEmpty) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: enabled ? color : null,
            ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: content,
        ),
      ),
    );
  }
}
