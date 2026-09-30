import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        double cardWidth;

        if (width < 500) {
          // Phone
          cardWidth = width;
        } else if (width < 900) {
          // Tablet
          cardWidth = (width - 12) / 2;
        } else {
          // Desktop
          cardWidth = (width - 36) / 4;
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children.map((child) {
            return SizedBox(width: cardWidth, child: child);
          }).toList(),
        );
      },
    );
  }
}
