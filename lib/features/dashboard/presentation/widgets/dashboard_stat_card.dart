import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';

/// Aurora 2.0 stat tile — gradient squircle, tabular value, one-time
/// entrance (fade + slide, 400ms) and a desktop hover lift.
class DashboardStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color>? gradient;
  final String? trend;
  final bool trendUp;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.gradient,
    this.trend,
    this.trendUp = true,
    this.onTap,
  });

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = widget.gradient ?? AppDecor.royalGradient.colors;

    final card = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _hovered
                ? colors.last.withValues(alpha: isDark ? 0.50 : 0.42)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.lightBorder),
            width: 1.2,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: (isDark ? Colors.black : AppColors.brandInk)
                        .withValues(alpha: isDark ? 0.42 : 0.10),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                    spreadRadius: -8,
                  ),
                  AppDecor.glow(colors.last, alpha: 0.12).first,
                ]
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : colors.first.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colors.last.withValues(
                          alpha: isDark ? 0.34 : 0.26,
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                        spreadRadius: -3,
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
                const Spacer(),
                if (widget.trend != null)
                  TrendPill(value: widget.trend!, up: widget.trendUp),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.statTitle.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              widget.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.statValue.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.onTap == null
            ? card
            : InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(22),
                child: card,
              ),
      ),
    );
  }
}
