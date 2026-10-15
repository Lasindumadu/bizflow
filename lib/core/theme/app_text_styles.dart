import 'package:flutter/material.dart';

class AppTextStyles {
  // ─────────────────────────────────────────────
  // Display styles (largest)
  // ─────────────────────────────────────────────

  static const displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w600,
    height: 1.12,
    letterSpacing: -0.5,
  );

  static const displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    height: 1.16,
    letterSpacing: -0.25,
  );

  static const displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.22,
    letterSpacing: 0,
  );

  // ─────────────────────────────────────────────
  // Headline styles
  // ─────────────────────────────────────────────

  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.29,
    letterSpacing: -0.25,
  );

  static const headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: 0,
  );

  // ─────────────────────────────────────────────
  // Title styles
  // ─────────────────────────────────────────────

  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    letterSpacing: -0.25,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // ─────────────────────────────────────────────
  // Body styles
  // ─────────────────────────────────────────────

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // ─────────────────────────────────────────────
  // Label styles (for buttons, chips, etc.)
  // ─────────────────────────────────────────────

  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.5,
  );

  // ─────────────────────────────────────────────
  // Helper aliases (for backward compatibility)
  // ─────────────────────────────────────────────

  static const heading1 = headlineLarge;
  static const heading2 = headlineSmall;
  static const heading3 = titleLarge;
  static const heading4 = titleMedium;

  static const body = bodyMedium;
  static const bodySecondary = bodySmall;

  static const caption = labelSmall;
  static const captionMedium = labelMedium;

  // ─────────────────────────────────────────────
  // Special purpose styles
  // ─────────────────────────────────────────────

  static const statValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.75,
  );

  static const statTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5,
  );

  static const priceLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const priceMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
  );

  static const priceSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static const monetary = TextStyle(
    fontFamily: 'Roboto Mono',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const code = TextStyle(
    fontFamily: 'Roboto Mono',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 1.5,
  );

  // ─────────────────────────────────────────────
  // Modern numeric / tabular styles
  // ─────────────────────────────────────────────

  static const numericLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.75,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const numericMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const numericSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Big hero price used on POS totals and checkout.
  static const priceHero = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 1.05,
    letterSpacing: -1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Softer variant of [statTitle] for dense KPI rows.
  static const kpiLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.6,
  );

  /// Uppercase micro label used on badges and pills.
  static const badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0.8,
  );

  /// Muted helper line under section headers.
  static const helper = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // ─────────────────────────────────────────────
  // Font scaling helpers
  // ─────────────────────────────────────────────

  /// Scale a text style by the given font scale factor
  static TextStyle scale(TextStyle style, double scale) {
    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * scale,
    );
  }

  /// Scale all text styles in a map by the given factor
  static Map<String, TextStyle> scaleAll(Map<String, TextStyle> styles, double scale) {
    return styles.map((key, style) => MapEntry(key, AppTextStyles.scale(style, scale)));
  }
}