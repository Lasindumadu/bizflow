import 'package:flutter/material.dart';

/// Lightweight dependency-free bar chart (no new packages).
class MiniBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;
  final Color avgColor;
  const MiniBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.barColor,
    this.avgColor = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxV = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxV <= 0 ? 1.0 : maxV;
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (i) {
              final h = (values[i] / safeMax).clamp(0.04, 1.0);
              final isPeak = values[i] == maxV && maxV > 0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 118 * h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPeak
                                ? [barColor, barColor.withValues(alpha: 0.6)]
                                : [
                                    barColor.withValues(alpha: 0.95),
                                    barColor.withValues(alpha: 0.45)
                                  ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(labels[i],
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface
                                  .withValues(alpha: 0.55))),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Horizontal progress / distribution row.
class DistRow extends StatelessWidget {
  final String label;
  final String value;
  final double pct;
  final Color color;
  const DistRow(
      {super.key,
      required this.label,
      required this.value,
      required this.pct,
      required this.color});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: scheme.onSurface))),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: scheme.onSurface)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor:
                  scheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
