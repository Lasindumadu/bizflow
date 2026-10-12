import 'package:flutter/material.dart';

class BrandBadge extends StatelessWidget {
  final double size;
  const BrandBadge({super.key, this.size = 44});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(Icons.bolt_rounded,
          color: Colors.white, size: size * 0.55),
    );
  }
}
