import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Aurora 2.0 launchpad action — per-action brand tint, optional photo
/// micro-wash for THE primary action, hover lift + press scale.
class QuickActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  /// Deep accent colour of this action (drives the icon tile + glow).
  /// Defaults to the brand royal.
  final Color? accent;

  /// Optional photo (from [AppImages]) rendered under the brand wash.
  final String? photo;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accent,
    this.photo,
  });

  @override
  State<QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<QuickActionCard> {
  bool _isPressed = false;
  bool _hovered = false;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accent ?? AppColors.primary;
    final photo = widget.photo;
    final hasPhoto = photo != null;

    final surface = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: hasPhoto
            ? null
            : accent.withValues(alpha: isDark ? 0.14 : 0.09),
        border: Border.all(
          color: hasPhoto
              ? Colors.white.withValues(alpha: 0.20)
              : accent.withValues(
                  alpha: _hovered ? (isDark ? 0.45 : 0.40) : 0.16,
                ),
        ),
        boxShadow: _hovered && !hasPhoto
            ? AppDecor.glow(accent, alpha: 0.22)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasPhoto) ...[
              Positioned.fill(
                child: Image.asset(
                  photo,
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.9),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.photoInk.withValues(alpha: 0.90),
                        AppColors.photoWash.withValues(alpha: 0.78),
                        accent.withValues(alpha: 0.48),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 20,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    decoration: BoxDecoration(
                      color: hasPhoto
                          ? Colors.white.withValues(alpha: 0.18)
                          : null,
                      gradient: hasPhoto
                          ? null
                          : LinearGradient(
                              colors: [accent, accent.withValues(alpha: 0.72)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: hasPhoto
                          ? null
                          : AppDecor.glow(accent, alpha: 0.26),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            color: hasPhoto
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasPhoto
                                ? Colors.white.withValues(alpha: 0.80)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasPhoto
                          ? Colors.white.withValues(alpha: 0.18)
                          : accent.withValues(alpha: isDark ? 0.18 : 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasPhoto
                            ? Colors.white.withValues(alpha: 0.25)
                            : accent.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: hasPhoto
                          ? Colors.white
                          : accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              borderRadius: BorderRadius.circular(24),
              child: surface,
            ),
          ),
        ),
      ),
    );
  }
}
