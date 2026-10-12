import 'package:flutter/material.dart';

class AppColors {
  // ─────────────────────────────────────────────
  // Brand colors - Modern professional blue
  // ─────────────────────────────────────────────

  static const primary = Color(0xFF1E40AF);
  static const primaryDark = Color(0xFF1E3A8A);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryContainer = Color(0xFFDBEAFE);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF1E3A8A);

  // Secondary brand color - Teal for accents
  static const secondary = Color(0xFF0F766E);
  static const secondaryLight = Color(0xFF14B8A6);
  static const secondaryContainer = Color(0xFFCCFBF1);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF134E4A);

  // Tertiary - Amber/Orange for warnings
  static const tertiary = Color(0xFFB45309);
  static const tertiaryLight = Color(0xFFF59E0B);
  static const tertiaryContainer = Color(0xFFFEF3C7);
  static const onTertiary = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFF78350F);

  // ─────────────────────────────────────────────
  // Light theme
  // ─────────────────────────────────────────────

  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F5F9);
  static const lightSurfaceContainer = Color(0xFFE2E8F0);
  static const lightSurfaceContainerHigh = Color(0xFFD1D5DB);

  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF334155);
  static const lightTextTertiary = Color(0xFF64748B);
  static const lightTextDisabled = Color(0xFF94A3B8);
  static const lightTextOnSurface = Color(0xFF0F172A);

  static const lightBorder = Color(0xFFE2E8F0);
  static const lightBorderStrong = Color(0xFFCBD5E1);
  static const lightDivider = Color(0xFFE8EDF3);

  // ─────────────────────────────────────────────
  // Dark theme
  // ─────────────────────────────────────────────

  static const darkBackground = Color(0xFF020617);
  static const darkSurface = Color(0xFF0F172A);
  static const darkSurfaceVariant = Color(0xFF1E293B);
  static const darkSurfaceContainer = Color(0xFF334155);
  static const darkSurfaceContainerHigh = Color(0xFF475569);

  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFE2E8F0);
  static const darkTextTertiary = Color(0xFF94A3B8);
  static const darkTextDisabled = Color(0xFF64748B);
  static const darkTextOnSurface = Color(0xFFF8FAFC);

  static const darkBorder = Color(0xFF334155);
  static const darkBorderStrong = Color(0xFF475569);
  static const darkDivider = Color(0xFF1E293B);

  // ─────────────────────────────────────────────
  // Semantic colors
  // ─────────────────────────────────────────────

  static const success = Color(0xFF059669);
  static const successLight = Color(0xFFD1FAE5);
  static const successDark = Color(0xFF047857);
  static const successContainer = Color(0xFFD1FAE5);
  static const onSuccessContainer = Color(0xFF064E3B);

  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFFB45309);
  static const warningContainer = Color(0xFFFEF3C7);
  static const onWarningContainer = Color(0xFF78350F);

  static const error = Color(0xFFDC2626);
  static const errorLight = Color(0xFFFEE2E2);
  static const errorDark = Color(0xFFB91C1C);
  static const errorContainer = Color(0xFFFEE2E2);
  static const onErrorContainer = Color(0xFF7F1D1D);

  static const info = Color(0xFF0284C7);
  static const infoLight = Color(0xFFE0F2FE);
  static const infoDark = Color(0xFF0369A1);
  static const infoContainer = Color(0xFFE0F2FE);
  static const onInfoContainer = Color(0xFF1E3A5F);

  // ─────────────────────────────────────────────
  // Status colors for business logic
  // ─────────────────────────────────────────────

  static const completed = Color(0xFF059669);
  static const pending = Color(0xFFD97706);
  static const cancelled = Color(0xFFDC2626);
  static const refunded = Color(0xFF7C3AED);
  static const draft = Color(0xFF64748B);

  // ─────────────────────────────────────────────
  // Shadow & elevation colors
  // ─────────────────────────────────────────────

  static const shadowColor = Color(0xFF000000);
  static const scrimColor = Color(0xCC000000);

  // ─────────────────────────────────────────────
  // Backward-compatible aliases
  // ─────────────────────────────────────────────

  static const background = lightBackground;
  static const surface = lightSurface;
  static const textPrimary = lightTextPrimary;
  static const textSecondary = lightTextSecondary;
  static const border = lightBorder;
}