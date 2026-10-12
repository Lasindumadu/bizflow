import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

class QuickActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF4F46E5),
              Color(0xFF7C3AED),
              Color(0xFF6366F1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                      AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(widget.icon,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(
                    width: AppDimensions.spacingLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: AppTextStyles.heading2
                              .copyWith(
                                  color: Colors.white)),
                      const SizedBox(
                          height:
                              AppDimensions.spacingXs),
                      Text(widget.subtitle,
                          style: AppTextStyles
                              .bodySecondary
                              .copyWith(
                                  color: Colors.white
                                      .withValues(
                                          alpha: 0.85))),
                    ],
                  ),
                ),
                const SizedBox(
                    width: AppDimensions.spacingSm),
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: Color(0xFF4F46E5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
