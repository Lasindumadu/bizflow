import 'package:flutter/material.dart';

class AppColors {
  // ─────────────────────────────────────────────
  // Brand colors
  // ─────────────────────────────────────────────

  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryLight = Color(0xFF3B82F6);

  // ─────────────────────────────────────────────
  // Light theme
  // ─────────────────────────────────────────────

  static const lightBackground = Color(0xFFF6F8FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F5F9);

  // Light theme
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightTextTertiary = Color(0xFF64748B);

  static const lightBorder = Color(0xFFE2E8F0);
  static const lightDivider = Color(0xFFE8EDF3);

  // ─────────────────────────────────────────────
  // Dark theme
  // ─────────────────────────────────────────────

  static const darkBackground = Color(0xFF0B1120);
  static const darkSurface = Color(0xFF111827);
  static const darkSurfaceVariant = Color(0xFF1E293B);

  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFCBD5E1);
  static const darkTextTertiary = Color(0xFF94A3B8);

  static const darkBorder = Color(0xFF273449);
  static const darkDivider = Color(0xFF1F2A3D);

  // ─────────────────────────────────────────────
  // Semantic colors
  // ─────────────────────────────────────────────

  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFDCFCE7);

  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFEF3C7);

  static const error = Color(0xFFDC2626);
  static const errorLight = Color(0xFFFEE2E2);

  static const info = Color(0xFF0284C7);
  static const infoLight = Color(0xFFE0F2FE);

  // ─────────────────────────────────────────────
  // Backward-compatible aliases
  // ─────────────────────────────────────────────

  // These are kept temporarily so existing screens
  // continue to compile while we migrate them to
  // theme-aware colors.

  static const background = lightBackground;
  static const surface = lightSurface;
  static const textPrimary = lightTextPrimary;
  static const textSecondary = lightTextSecondary;
  static const border = lightBorder;
}
