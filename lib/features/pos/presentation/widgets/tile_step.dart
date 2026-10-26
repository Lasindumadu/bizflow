import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A small tappable tile step used for increment/decrement actions in the POS.
class TileStep extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const TileStep({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ink = AppColors.posTint.last;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 27,
          height: 34,
          child: Icon(icon, size: 15, color: ink),
        ),
      ),
    );
  }
}
