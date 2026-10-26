import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A small soft-squircle quantity adjustment button used in the POS cart tile.
class QuantityButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const QuantityButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 27,
      height: 27,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 27, minHeight: 27),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        color: AppColors.posTint.last,
        hoverColor: AppColors.posTint.last.withValues(alpha: 0.10),
        icon: Icon(icon, size: 15),
      ),
    );
  }
}
