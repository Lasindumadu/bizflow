import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_decor.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

/// Brand artwork shipped with BizFlow.
class AppImages {
  static const backdrop = 'assets/images/brand_backdrop.jpg';
  static const hero = 'assets/images/hero_aurora.jpg';
  static const posIllustration = 'assets/images/pos_illustration.png';
}

/// ─────────────────────────────────────────────────────────────
/// BizFlow brand UI kit
///
/// A small, opinionated component set that gives every screen the
/// same rhythm: aurora light, glassy surfaces, Sora headlines and
/// restrained motion.
/// ─────────────────────────────────────────────────────────────

/// The signature BizFlow logo mark — a gradient squircle with a
/// flowing bolt, drawn in vectors so it stays razor sharp at any size.
class BrandMark extends StatelessWidget {
  final double size;
  final bool showShadow;

  const BrandMark({super.key, this.size = 44, this.showShadow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.31),
        gradient: const LinearGradient(
          colors: [Color(0xFF8B6CFF), Color(0xFF5B5BF7), Color(0xFF3F2BD6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.38),
                  blurRadius: size * 0.38,
                  offset: Offset(0, size * 0.16),
                  spreadRadius: -size * 0.08,
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.12,
            top: size * 0.1,
            right: size * 0.12,
            height: size * 0.38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          CustomPaint(
            size: Size.square(size),
            painter: _FlowMarkPainter(),
          ),
        ],
      ),
    );
  }
}

class _FlowMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // A bolt cut with a soft mint "flow" tail.
    final bolt = Path()
      ..moveTo(w * 0.57, h * 0.18)
      ..lineTo(w * 0.30, h * 0.53)
      ..lineTo(w * 0.47, h * 0.53)
      ..lineTo(w * 0.40, h * 0.82)
      ..lineTo(w * 0.71, h * 0.44)
      ..lineTo(w * 0.52, h * 0.44)
      ..close();
    canvas.drawPath(bolt, paint);

    final dot = Paint()
      ..color = const Color(0xFF5EEAD4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.72, h * 0.25), w * 0.055, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ambient aurora background used behind page content.
/// The artwork is intentionally faint: content stays the hero.
class BrandBackdrop extends StatelessWidget {
  final Widget child;
  final bool showArtwork;
  final EdgeInsetsGeometry? padding;

  const BrandBackdrop({
    super.key,
    required this.child,
    this.showArtwork = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final content = padding == null
        ? child
        : Padding(padding: padding!, child: child);

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          ),
        ),
        if (showArtwork)
          Positioned(
            top: -180,
            right: -120,
            child: _GlowOrb(
              size: 520,
              color: AppColors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
            ),
          ),
        if (showArtwork)
          Positioned(
            bottom: -220,
            left: -140,
            child: _GlowOrb(
              size: 480,
              color: AppColors.brandMint.withValues(alpha: isDark ? 0.08 : 0.10),
            ),
          ),
        content,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

/// The branded page hero used at the top of every major screen.
///
/// Uses the shipped aurora artwork with a soft gradient wash so the
/// headline remains perfectly legible in both themes.
class PageHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData eyebrowIcon;
  final Widget? action;
  final Widget? secondaryAction;
  final bool showIllustration;
  final List<Color>? gradient;

  const PageHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.eyebrowIcon = Icons.bolt_rounded,
    this.action,
    this.secondaryAction,
    this.showIllustration = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AppImages.hero,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  opacity: const AlwaysStoppedAnimation(0.9),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0A0C18).withValues(alpha: 0.94),
                        const Color(0xFF141130).withValues(alpha: 0.82),
                        (gradient ?? AppDecor.heroGradient(true).colors).last
                            .withValues(alpha: 0.55),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(wide ? 28 : 22),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.13),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      eyebrowIcon,
                                      color: const Color(0xFF7DF3DF),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      eyebrow.toUpperCase(),
                                      style: const TextStyle(
                                        fontFamily: AppTextStyles.bodyFont,
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ?secondaryAction,
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTextStyles.displayFont,
                              color: Colors.white,
                              fontSize: wide ? 32 : 26,
                              fontWeight: FontWeight.w700,
                              height: 1.12,
                              letterSpacing: -0.9,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.74),
                              fontSize: 13,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (action != null) ...[
                            const SizedBox(height: 18),
                            action!,
                          ],
                        ],
                      ),
                    ),
                    if (showIllustration && wide)
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Image.asset(
                              AppImages.posIllustration,
                              height: 196,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A luminous, hover-reactive surface used for all content cards.
class BrandCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final bool elevated;
  final Color? accent;
  final bool gradientBorder;

  const BrandCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 22,
    this.onTap,
    this.elevated = false,
    this.accent,
    this.gradientBorder = false,
  });

  @override
  State<BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<BrandCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.accent ?? AppColors.primary;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: widget.gradientBorder
              ? accent.withValues(alpha: _hovered ? 0.55 : 0.28)
              : (isDark
                  ? Colors.white.withValues(alpha: _hovered ? 0.12 : 0.07)
                  : AppColors.lightBorder),
        ),
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.brandInk)
                      .withValues(alpha: isDark ? 0.42 : 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                  spreadRadius: -8,
                ),
                if (widget.elevated)
                  BoxShadow(
                    color: accent.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
              ]
            : widget.elevated
                ? [
                    BoxShadow(
                      color: (isDark ? Colors.black : AppColors.brandInk)
                          .withValues(alpha: isDark ? 0.32 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: -6,
                    ),
                  ]
                : null,
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: widget.onTap == null
          ? card
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.radius),
                child: card,
              ),
            ),
    );
  }
}

/// Section heading with the signature short gradient rule.
class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: scheme.primary),
          ),
          const SizedBox(width: 11),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: scheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A vivid metric tile with an optional trend and secondary line.
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? helper;
  final IconData icon;
  final List<Color> gradient;
  final String? badge;
  final bool badgeUp;
  final VoidCallback? onTap;
  final bool compact;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.helper,
    this.badge,
    this.badgeUp = true,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrandCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 15 : 18),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 38 : 44,
                height: compact ? 38 : 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(compact ? 12 : 14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: compact ? 19 : 21,
                ),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (badgeUp ? AppColors.brandMint : AppColors.brandAmber)
                        .withValues(alpha: isDark ? 0.16 : 0.13),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        badgeUp
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 11,
                        color: badgeUp
                            ? (isDark
                                ? AppColors.brandMint
                                : AppColors.brandMintDeep)
                            : (isDark
                                ? AppColors.brandAmber
                                : const Color(0xFF9A6400)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: badgeUp
                              ? (isDark
                                  ? AppColors.brandMint
                                  : AppColors.brandMintDeep)
                              : (isDark
                                  ? AppColors.brandAmber
                                  : const Color(0xFF9A6400)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: compact ? 12 : 15),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontFamily: AppTextStyles.displayFont,
                fontSize: compact ? 20 : 24,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -0.7,
                color: scheme.onSurface,
              ),
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 5),
            Text(
              helper!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact pill used for statuses, categories and filters.
class BrandPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  const BrandPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: filled ? 0.95 : (isDark ? 0.16 : 0.11)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: filled ? 1 : (isDark ? 0.28 : 0.20)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11,
              color: filled ? Colors.white : color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Illustrated empty state with the brand artwork.
class BrandEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final bool compact;

  const BrandEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_rounded,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: compact ? 18 : 30,
            horizontal: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!compact)
                SizedBox(
                  height: 150,
                  child: Image.asset(
                    AppImages.posIllustration,
                    fit: BoxFit.contain,
                  ),
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: scheme.primary, size: 26),
                ),
              if (!compact) const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small icon tile with a tinted background.
class BrandIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const BrandIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.28 : 0.18),
        ),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}

/// A compact search field used in headers and lists.
class BrandSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hint;
  final Widget? trailing;
  final FocusNode? focusNode;
  final VoidCallback? onClear;

  const BrandSearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.trailing,
    this.focusNode,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon: trailing ??
            (controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close_rounded, size: 17),
                    onPressed: onClear,
                  )),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

/// Number that counts up when it first appears.
class CountUpText extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final int decimals;
  final TextStyle? style;

  const CountUpText(
    this.value, {
    super.key,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 2,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        '$prefix${v.toStringAsFixed(decimals)}$suffix',
        style: style,
      ),
    );
  }
}

/// Soft grain overlay adds depth to gradient panels without a texture file.
class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _GrainPainter(), size: Size.infinite),
    );
  }
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 240; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        rnd.nextDouble() * 1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Frosted glass surface for overlays and floating bars.
class FrostedPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;

  const FrostedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
    this.blur = 18,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.darkSurface : Colors.white)
                .withValues(alpha: isDark ? 0.72 : 0.82),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.lightBorder,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Sub-page pattern
///
/// Pushed pages (forms, details, settings) use a compact aurora
/// header instead of a plain AppBar so the brand stays present at
/// every depth of the app.
/// ─────────────────────────────────────────────────────────────

/// Compact branded header with a back affordance, used by sub-pages.
class BrandPageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> actions;
  final bool showBack;
  final VoidCallback? onBack;

  const BrandPageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.icon = Icons.bolt_rounded,
    this.actions = const [],
    this.showBack = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF141033), Color(0xFF31246E), Color(0xFF1B3A6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -70,
              child: _GlowOrb(
                size: 220,
                color: AppColors.brandMint.withValues(alpha: 0.24),
              ),
            ),
            Positioned(
              right: 90,
              bottom: -90,
              child: _GlowOrb(
                size: 200,
                color: AppColors.accent.withValues(alpha: 0.35),
              ),
            ),
            Positioned.fill(child: GrainOverlay()),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 16, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBack)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, right: 12),
                      child: _HeaderIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onTap: onBack ?? () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: 14, color: const Color(0xFF7DF3DF)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                eyebrow.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.bodyFont,
                                  color: Color(0xFF9FE9DE),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            letterSpacing: -0.7,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Row(mainAxisSize: MainAxisSize.min, children: actions),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    );
  }
}

/// A frosted header action used for hero toolbars.
class BrandHeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const BrandHeaderAction({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _HeaderIconButton(icon: icon, tooltip: tooltip, onTap: onTap);
  }
}

/// The standard scrollable body for a sub-page: aurora backdrop,
/// centred content and consistent padding.
class BrandSubPageBody extends StatelessWidget {
  final Widget child;
  final bool scrollable;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const BrandSubPageBody({
    super.key,
    required this.child,
    this.scrollable = true,
    this.maxWidth = 860,
    this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 28),
  });

  @override
  Widget build(BuildContext context) {
    return BrandBackdrop(
      showArtwork: true,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: scrollable
              ? SingleChildScrollView(padding: padding, child: child)
              : Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Grouped form card with a tinted icon, title and helper line.
class BrandFormSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget child;
  final Widget? trailing;

  const BrandFormSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.accent = AppColors.primary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BrandIconBadge(icon: icon, color: accent, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// Tappable action row used in Settings and admin hubs.
class BrandActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;
  final List<Color> gradient;
  final Color? accent;
  final bool destructive;

  const BrandActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLoading = false,
    this.gradient = const [AppColors.primaryLight, AppColors.primary],
    this.accent,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = destructive
        ? AppColors.error
        : (accent ?? gradient.last);
    final muted = onTap == null && !isLoading;

    return Opacity(
      opacity: muted ? 0.55 : 1,
      child: BrandCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        onTap: onTap == null || isLoading ? null : onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: destructive
                      ? [const Color(0xFFFB7185), AppColors.error]
                      : gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: tone.withValues(alpha: isDark ? 0.34 : 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 19),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: destructive ? AppColors.error : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: isDark ? 0.16 : 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: tone,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Frosted action bar pinned to the bottom of a form page.
class BrandStickyBar extends StatelessWidget {
  final Widget child;

  const BrandStickyBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkBackground : AppColors.lightBackground)
            .withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Standard page padding + max width for top-level screens.
class PageBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const PageBody({
    super.key,
    required this.child,
    this.maxWidth = AppDimensions.contentMaxWidth,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 28),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
