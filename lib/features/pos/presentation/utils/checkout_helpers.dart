import 'package:flutter/material.dart';

/// Checkout helpers: quick cash, discount presets, totals math.
class CheckoutHelpers {
  static List<double> quickCash(double total) {
    final bases = <double>{total, 50, 100, 500, 1000, 5000};
    final rounded = ((total / 50).ceil() * 50).toDouble();
    bases.add(rounded);
    bases.add(rounded + 50);
    final list = bases.where((v) => v >= total).toList()..sort();
    return list.take(4).toList();
  }

  static double discountFor(
      double subtotal, double value, bool isPercent) {
    if (subtotal <= 0 || value <= 0) return 0;
    if (isPercent) {
      final pct = value.clamp(0, 100);
      return (subtotal * pct / 100);
    }
    return value.clamp(0, subtotal);
  }
}

/// Premium summary row.
class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;
  final Color? valueColor;
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.strong = false,
    this.valueColor,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: strong ? 15 : 13,
                  fontWeight:
                      strong ? FontWeight.w800 : FontWeight.w500,
                  color: strong
                      ? scheme.onSurface
                      : scheme.onSurface
                          .withValues(alpha: 0.65))),
        ),
        Text(value,
            style: TextStyle(
                fontSize: strong ? 18 : 14,
                fontWeight: FontWeight.w800,
                color: valueColor ?? scheme.onSurface)),
      ]),
    );
  }
}
