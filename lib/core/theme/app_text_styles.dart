import 'package:flutter/material.dart';

class AppTextStyles {
  // ─────────────────────────────────────────────
  // Display styles (largest)
  // ─────────────────────────────────────────────

  static const displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static const displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.16,
    letterSpacing: 0,
  );

  static const displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
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
    letterSpacing: 0,
  );

  static const headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: 0,
  );

  static const headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
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
    letterSpacing: 0,
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
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const statTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
  );

  static const priceLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const priceMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.25,
  );

  static const priceSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
  );

  static const monetary = TextStyle(
    fontFamily: 'Roboto Mono',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
  );

  static const code = TextStyle(
    fontFamily: 'Roboto Mono',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );

  static const overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 1.5,
  );
}