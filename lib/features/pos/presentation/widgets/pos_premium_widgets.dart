import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';

/// Premium cart line with stepper.
class CartLineCard extends StatelessWidget {
  final String name;
  final String sku;
  final int qty;
  final double price;
  final String currency;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;
  const CartLineCard({
    super.key,
    required this.name,
    required this.sku,
    required this.qty,
    required this.price,
    required this.currency,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: s.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: s.outline.withValues(alpha: 0.7)),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppDecor.indigoGradient,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: Text(
                name.isEmpty
                    ? '•'
                    : name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700)),
              Text('SKU: $sku x$qty',
                  style: TextStyle(
                      fontSize: 11,
                      color: s.onSurface
                          .withValues(alpha: 0.55))),
              const SizedBox(height: 6),
              Row(children: [
                _btn(context, Icons.remove_rounded,
                    onDec),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10),
                  child: Text('$qty',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800)),
                ),
                _btn(
                    context, Icons.add_rounded, onInc),
              ]),
            ],
          ),
        ),
        Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
                '$currency ${(price * qty).toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w800)),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
              icon: Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _btn(
      BuildContext c, IconData ic, VoidCallback fn) {
    final s = Theme.of(c).colorScheme;
    return InkWell(
      onTap: fn,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: s.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Icon(ic, size: 18, color: s.primary),
      ),
    );
  }
}

/// Premium selectable product tile for POS.
class PosProductTile extends StatelessWidget {
  final String name;
  final String category;
  final double price;
  final String currency;
  final int stock;
  final bool lowStock;
  final VoidCallback onTap;
  const PosProductTile({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.currency,
    required this.stock,
    required this.lowStock,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final isOutOfStock = stock <= 0;
    return InkWell(
      onTap: isOutOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: s.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOutOfStock
                ? AppColors.lightTextDisabled.withValues(alpha: 0.5)
                : lowStock
                    ? AppColors.error.withValues(alpha: 0.5)
                    : s.outline.withValues(alpha: 0.7),
          ),
          boxShadow: isOutOfStock || lowStock
              ? null
              : [
                  BoxShadow(
                    color: s.primary.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isOutOfStock ? s.onSurface.withValues(alpha: 0.5) : s.onSurface,
              ),
            ),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isOutOfStock ? s.onSurface.withValues(alpha: 0.4) : AppColors.lightTextTertiary,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currency ${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isOutOfStock ? s.onSurface.withValues(alpha: 0.5) : s.primary,
                  ),
                ),
                if (lowStock && !isOutOfStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Low',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                if (isOutOfStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: s.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Out',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: s.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
