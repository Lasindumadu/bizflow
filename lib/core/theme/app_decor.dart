import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared premium gradients, shadows and decorations.
class AppDecor {
  // Modern vibrant gradients
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient primaryGradientVertical = const LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient primaryGradientDiagonal = const LinearGradient(
    colors: [AppColors.gradientStart, AppColors.accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient heroGradient(bool isDark) {
    return LinearGradient(
      colors: isDark
          ? const [Color(0xFF312E81), Color(0xFF4C1D95), Color(0xFF0F172A)]
          : const [AppColors.gradientStart, AppColors.gradientEnd, AppColors.gradientDeep],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient heroGradientAlt(bool isDark) {
    return LinearGradient(
      colors: isDark
          ? const [Color(0xFF1E3A8A), Color(0xFF312E81), Color(0xFF0B1026)]
          : const [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFF4F46E5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient moneyGradient = const LinearGradient(
    colors: [AppColors.secondaryLight, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient successGradient = const LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient amberGradient = const LinearGradient(
    colors: [AppColors.tertiaryLight, AppColors.tertiaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient indigoGradient = const LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient violetGradient = const LinearGradient(
    colors: [AppColors.accent, AppColors.gradientAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient roseGradient = const LinearGradient(
    colors: [AppColors.rose, Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient infoGradient = const LinearGradient(
    colors: [AppColors.chartSky, AppColors.chartBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient surfaceGradient(bool isDark) {
    return LinearGradient(
      colors: isDark
          ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
          : [Colors.white, AppColors.lightSurfaceContainer],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Modern shadows
  static List<BoxShadow> softShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : AppColors.shadowColor.withValues(alpha: 0.08),
        blurRadius: 32,
        offset: const Offset(0, 16),
        spreadRadius: -8,
      ),
    ];
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : AppColors.shadowColor.withValues(alpha: 0.06),
        blurRadius: 20,
        offset: const Offset(0, 10),
        spreadRadius: -4,
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: AppColors.shadowColor.withValues(alpha: 0.12),
      blurRadius: 48,
      offset: const Offset(0, 24),
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.25),
        blurRadius: 24,
        offset: const Offset(0, 12),
        spreadRadius: -4,
      ),
    ];
  }

  static BoxDecoration glassCard(bool isDark) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : AppColors.shadowColor.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  static BoxDecoration gradientCard(List<Color> gradient) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowColor.withValues(alpha: 0.15),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }

  static const statGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const moneyGradientLight = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────────
  // Extended modern gradients
  // ─────────────────────────────────────────────

  static LinearGradient warningGradient = const LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient errorGradient = const LinearGradient(
    colors: [Color(0xFFF87171), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient grayGradient = const LinearGradient(
    colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient tealGradient = const LinearGradient(
    colors: [AppColors.cyanLight, AppColors.cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient skyGradient = const LinearGradient(
    colors: [AppColors.skyLight, AppColors.sky],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient pinkGradient = const LinearGradient(
    colors: [AppColors.pinkLight, AppColors.pink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient limeGradient = const LinearGradient(
    colors: [AppColors.limeLight, AppColors.lime],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient orangeGradient = const LinearGradient(
    colors: [AppColors.orangeLight, AppColors.orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns a gradient for a semantic tone name. Handy for
  /// data-driven lists (categories, products, KPIs).
  static LinearGradient toneGradient(int seed) {
    final preset =
        AppColors.chartGradients[seed.abs() % AppColors.chartGradients.length];
    return LinearGradient(
      colors: preset,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ─────────────────────────────────────────────
  // Modern shadow variants
  // ─────────────────────────────────────────────

  /// Small, tight shadow for chips and small surfaces.
  static List<BoxShadow> subtleShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : AppColors.shadowColor.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Layered shadow that reads as "lifted off the page" — ideal for
  /// hero cards and dialogs.
  static List<BoxShadow> layeredShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.45)
            : AppColors.shadowColor.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.30)
            : AppColors.shadowColor.withValues(alpha: 0.04),
        blurRadius: 32,
        offset: const Offset(0, 20),
        spreadRadius: -8,
      ),
    ];
  }

  /// Coloured "glow" used behind gradient buttons and accent tiles.
  static List<BoxShadow> glow(Color color, {double alpha = 0.32}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: alpha),
        blurRadius: 22,
        offset: const Offset(0, 10),
        spreadRadius: -6,
      ),
    ];
  }

  // ─────────────────────────────────────────────
  // Decorations
  // ─────────────────────────────────────────────

  /// A hairline "ring" border used for focus/hover states.
  static BoxDecoration ring({
    required Color color,
    double radius = 16,
    double width = 1.5,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color, width: width),
    );
  }

  /// Elevated surface that adapts to light/dark automatically.
  static BoxDecoration surface(BuildContext context, {double radius = 24}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.lightBorder,
      ),
      boxShadow: layeredShadow(context),
    );
  }
}
