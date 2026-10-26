import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'brand_ui.dart';
import '../theme/app_decor.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// ─────────────────────────────────────────────────────────────
/// BizFlow modern component library.
///
/// Small, dependency-free, theme-aware building blocks used across
/// the app to keep the UI consistent, animated and marketplace-ready.
/// Everything here reacts to light/dark automatically.
/// ─────────────────────────────────────────────────────────────

/// A gradient-filled primary button with press animation, an optional
/// leading icon and built-in loading state.
class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final List<Color>? gradient;
  final bool isLoading;
  final bool expanded;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.gradient,
    this.isLoading = false,
    this.expanded = true,
    this.height = AppDimensions.buttonHeightLg,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? AppDecor.indigoGradient.colors;
    final enabled = widget.onPressed != null && !widget.isLoading;

    final button = AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: AppDimensions.durationFast,
      curve: Curves.easeOut,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? gradient
                : [
                    gradient.first.withValues(alpha: 0.5),
                    gradient.last.withValues(alpha: 0.5),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled ? AppDecor.glow(gradient.first) : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? widget.onPressed : null,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: AuroraLoader(
                        size: 22,
                        strokeWidth: 2,
                        onDarkSurface: true,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    return Listener(
      onPointerDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: widget.expanded
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );
  }
}

/// A soft, tinted secondary button used for less prominent actions.
class SoftButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? color;
  final bool expanded;

  const SoftButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tone = color ?? scheme.primary;
    final content = Container(
      height: AppDimensions.buttonHeight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: tone),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return expanded
        ? SizedBox(width: double.infinity, child: content)
        : content;
  }
}

/// A frosted, semi-transparent card used for overlays and headers.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final List<Color>? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.spacingLg),
    this.radius = 24,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient != null
            ? LinearGradient(
                colors: gradient!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: gradient == null
            ? (isDark ? AppColors.glassDark : AppColors.glassLight)
            : null,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? AppColors.glassBorderDark
              : AppColors.glassBorderLight,
        ),
      ),
      child: child,
    );
  }
}

/// A surface card that lifts subtly on hover (web/desktop) and press.
class HoverLiftCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final List<Color>? gradient;

  const HoverLiftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimensions.spacingLg),
    this.radius = 22,
    this.borderColor,
    this.gradient,
  });

  @override
  State<HoverLiftCard> createState() => _HoverLiftCardState();
}

class _HoverLiftCardState extends State<HoverLiftCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = AnimatedContainer(
      duration: AppDimensions.durationNormal,
      curve: Curves.easeOut,
      padding: widget.padding,
      transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
      decoration: BoxDecoration(
        gradient: widget.gradient != null
            ? LinearGradient(
                colors: widget.gradient!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: widget.gradient == null ? scheme.surface : null,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color:
              widget.borderColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.lightBorder),
        ),
        boxShadow: _hovered
            ? AppDecor.layeredShadow(context)
            : AppDecor.subtleShadow(context),
      ),
      child: widget.child,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: widget.onTap == null
          ? content
          : InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(widget.radius),
              child: content,
            ),
    );
  }
}

/// Smoothly animates a numeric value, rolling digits up/down.
class AnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final int decimals;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 2,
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Text(
          '$prefix${animated.toStringAsFixed(decimals)}$suffix',
          style: style ?? AppTextStyles.numericMedium,
        );
      },
    );
  }
}

/// A shimmering placeholder block used while content loads.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBox({super.key, this.width, this.height = 16, this.radius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.lightSurfaceContainer;
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              colors: [base, highlight, base],
              stops: [math.max(0.0, t - 0.3), t, math.min(1.0, t + 0.3)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}

/// A composite skeleton list for card-based loading states.
class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const SkeletonList({super.key, this.count = 4, this.itemHeight = 88});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
          child: Row(
            children: [
              const ShimmerBox(width: 52, height: 52, radius: 16),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: double.infinity,
                      height: itemHeight * 0.2,
                    ),
                    const SizedBox(height: 10),
                    const ShimmerBox(width: 140, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Consistent, illustrated empty state with an optional action.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Color>? gradient;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = gradient ?? AppDecor.indigoGradient.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.first.withValues(alpha: 0.18),
                    colors.last.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 38, color: colors.first),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.helper.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              GradientButton(
                label: actionLabel!,
                icon: Icons.add_rounded,
                gradient: colors,
                expanded: false,
                height: AppDimensions.buttonHeight,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Consistent error state with retry.
class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.helper.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.spacingXl),
              SoftButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                expanded: false,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-page loading state with a branded spinner.
class AppLoadingState extends StatelessWidget {
  final String message;

  const AppLoadingState({super.key, this.message = 'Loading…'});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AuroraLoader(size: 46),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            message,
            style: AppTextStyles.helper.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Coloured status pill — orders, stock, payments.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool outlined;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? null : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: outlined
            ? Border.all(color: color.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Text(label, style: AppTextStyles.badge.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Up/down trend pill with an arrow, e.g. "+12.4% vs last week".
class TrendPill extends StatelessWidget {
  final String value;
  final bool up;
  final bool neutral;

  const TrendPill({
    super.key,
    required this.value,
    this.up = true,
    this.neutral = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = neutral
        ? AppColors.chartGray
        : (up ? AppColors.success : AppColors.error);
    final icon = neutral
        ? Icons.remove_rounded
        : (up ? Icons.trending_up_rounded : Icons.trending_down_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(value, style: AppTextStyles.badge.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// A compact rounded icon tile with a gradient fill.
class IconTile extends StatelessWidget {
  final IconData icon;
  final List<Color>? gradient;
  final double size;
  final double iconSize;

  const IconTile({
    super.key,
    required this.icon,
    this.gradient,
    this.size = 46,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? AppDecor.indigoGradient.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: AppDecor.glow(colors.first, alpha: 0.22),
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}

/// A floating pill/chip used for filters with an animated selection.
class FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final int? count;
  final VoidCallback? onTap;

  const FilterPill({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppDimensions.durationNormal,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: selected ? AppDecor.indigoGradient : null,
        color: selected ? null : scheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? Colors.transparent
              : scheme.outline.withValues(alpha: 0.7),
        ),
        boxShadow: selected
            ? AppDecor.glow(AppColors.primary, alpha: 0.2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 15,
                    color: selected ? Colors.white : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected ? Colors.white : scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.25)
                          : scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: AppTextStyles.badge.copyWith(
                        color: selected ? Colors.white : scheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A titled section with a trailing action, used to break up long pages.
class ModernSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const ModernSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.helper.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A decorative aurora blob used as a soft background accent.
class AuroraBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const AuroraBlob({
    super.key,
    required this.color,
    this.size = 220,
    this.opacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
