import 'package:flutter/material.dart';

/// Premium BizFlow brand palette.
/// Modern gradient system with sophisticated colors for mobile + web.
/// Designed for light/dark themes with marketplace-ready aesthetics.
class AppColors {
  // ─────────────────────────────────────────────
  // Brand — Modern gradient primary (Indigo/Violet)
  // ─────────────────────────────────────────────

  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF4338CA);
  static const primaryLight = Color(0xFF6366F1);
  static const primarySoft = Color(0xFFEEF2FF);
  static const primaryContainer = Color(0xFFEEF2FF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF312E81);
  static const gradientStart = Color(0xFF6366F1); // Indigo
  static const gradientEnd = Color(0xFF8B5CF6);   // Violet
  static const gradientDeep = Color(0xFF4338CA);
  static const gradientVibrant = Color(0xFF4F46E5);
  static const gradientAccent = Color(0xFFA855F7);
  static const gradientCyan = Color(0xFF06B6D4);
  static const gradientEmerald = Color(0xFF10B981);
  static const gradientSunset = Color(0xFFF43F5E);

  // Modern UI Glass & Aura Accents
  static const auraPurple = Color(0x338B5CF6);
  static const auraBlue = Color(0x333B82F6);
  static const auraCyan = Color(0x3306B6D4);
  static const auraEmerald = Color(0x3310B981);

  static const accent = Color(0xFF7C3AED);
  static const accentLight = Color(0xFFA78BFA);
  static const accentSoft = Color(0xFFF5F3FF);

  // Secondary — Emerald for success/money
  static const secondary = Color(0xFF059669);
  static const secondaryDark = Color(0xFF047857);
  static const secondaryLight = Color(0xFF10B981);
  static const secondaryContainer = Color(0xFFECFDF5);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF064E3B);

  // Tertiary — Amber/Gold for highlights
  static const tertiary = Color(0xFFF59E0B);
  static const tertiaryDark = Color(0xFFD97706);
  static const tertiaryLight = Color(0xFFFBBF24);
  static const tertiaryContainer = Color(0xFFFEF3C7);
  static const onTertiary = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFF92400E);

  // Quaternary — Rose for attention
  static const rose = Color(0xFFF43F5E);
  static const roseLight = Color(0xFFFDA4AF);
  static const roseSoft = Color(0xFFFFF1F2);

  // ─────────────────────────────────────────────
  // Extended Modern Palette
  // ─────────────────────────────────────────────
  
  // Cyan/Teal for info/analytics
  static const cyan = Color(0xFF06B6D4);
  static const cyanLight = Color(0xFF22D3EE);
  static const cyanSoft = Color(0xFFCFFAFE);
  static const cyanDark = Color(0xFF0E7490);
  
  // Orange for warnings/energy
  static const orange = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFB923C);
  static const orangeSoft = Color(0xFFFFEDD5);
  static const orangeDark = Color(0xFFEA580C);
  
  // Pink for special highlights
  static const pink = Color(0xFFEC4899);
  static const pinkLight = Color(0xFFF472B6);
  static const pinkSoft = Color(0xFFFCE7F3);
  static const pinkDark = Color(0xFFBE185D);
  
  // Lime for growth
  static const lime = Color(0xFF84CC16);
  static const limeLight = Color(0xFFA3E635);
  static const limeSoft = Color(0xFFF7FEE7);
  static const limeDark = Color(0xFF65A30D);
  
  // Sky for calm/tech
  static const sky = Color(0xFF0EA5E9);
  static const skyLight = Color(0xFF38BDF8);
  static const skySoft = Color(0xFFE0F2FE);
  static const skyDark = Color(0xFF0284C7);

  // ─────────────────────────────────────────────
  // Light theme — Clean, airy, professional
  // ─────────────────────────────────────────────

  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F5F9);
  static const lightSurfaceContainer = Color(0xFFE2E8F0);
  static const lightSurfaceContainerHigh = Color(0xFFCBD5E1);
  static const lightSurfaceContainerHighest = Color(0xFF94A3B8);

  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF334155);
  static const lightTextTertiary = Color(0xFF64748B);
  static const lightTextDisabled = Color(0xFF94A3B8);
  static const lightTextOnSurface = Color(0xFF0F172A);

  static const lightBorder = Color(0xFFE2E8F0);
  static const lightBorderStrong = Color(0xFFCBD5E1);
  static const lightDivider = Color(0xFFF1F5F9);

  // ─────────────────────────────────────────────
  // Dark theme — Rich modern dark with depth
  // ─────────────────────────────────────────────

  static const darkBackground = Color(0xFF080C1A);
  static const darkSurface = Color(0xFF0F172A);
  static const darkSurfaceVariant = Color(0xFF1E293B);
  static const darkSurfaceContainer = Color(0xFF334155);
  static const darkSurfaceContainerHigh = Color(0xFF475569);
  static const darkSurfaceContainerHighest = Color(0xFF64748B);

  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFE2E8F0);
  static const darkTextTertiary = Color(0xFF94A3B8);
  static const darkTextDisabled = Color(0xFF64748B);
  static const darkTextOnSurface = Color(0xFFF8FAFC);

  static const darkBorder = Color(0xFF334155);
  static const darkBorderStrong = Color(0xFF475569);
  static const darkDivider = Color(0xFF1E2937);

  // ─────────────────────────────────────────────
  // Semantic colors
  // ─────────────────────────────────────────────

  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFF34D399);
  static const successDark = Color(0xFF059669);
  static const successContainer = Color(0xFFECFDF5);
  static const onSuccessContainer = Color(0xFF065F46);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFBBF24);
  static const warningDark = Color(0xFFD97706);
  static const warningContainer = Color(0xFFFFFBEB);
  static const onWarningContainer = Color(0xFF92400E);

  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFF87171);
  static const errorDark = Color(0xFFDC2626);
  static const errorContainer = Color(0xFFFEF2F2);
  static const onErrorContainer = Color(0xFF991B1B);

  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFF60A5FA);
  static const infoDark = Color(0xFF2563EB);
  static const infoContainer = Color(0xFFEFF6FF);
  static const onInfoContainer = Color(0xFF1E40AF);

  // Status colors
  static const completed = Color(0xFF10B981);
  static const pending = Color(0xFFF59E0B);
  static const cancelled = Color(0xFFEF4444);
  static const refunded = Color(0xFF8B5CF6);
  static const draft = Color(0xFF64748B);
  static const processing = Color(0xFF3B82F6);
  static const onHold = Color(0xFF8B5CF6);

  // Charts — modern vibrant palette
  static const chartIndigo = Color(0xFF6366F1);
  static const chartViolet = Color(0xFF8B5CF6);
  static const chartEmerald = Color(0xFF10B981);
  static const chartAmber = Color(0xFFF59E0B);
  static const chartSky = Color(0xFF0EA5E9);
  static const chartRose = Color(0xFFF43F5E);
  static const chartCyan = Color(0xFF06B6D4);
  static const chartPink = Color(0xFFEC4899);
  static const chartOrange = Color(0xFFFB923C);
  static const chartBlue = Color(0xFF3B82F6);
  static const chartLime = Color(0xFF84CC16);
  static const chartTeal = Color(0xFF14B8A6);
  static const chartPurple = Color(0xFFA855F7);
  static const chartRed = Color(0xFFEF4444);
  static const chartGray = Color(0xFF94A3B8);

  // Chart gradient pairs for beautiful visualizations
  static const List<List<Color>> chartGradients = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],  // Indigo → Violet
    [Color(0xFF10B981), Color(0xFF34D399)],  // Emerald → Light Emerald
    [Color(0xFFF59E0B), Color(0xFFFBBF24)],  // Amber → Light Amber
    [Color(0xFF0EA5E9), Color(0xFF38BDF8)],  // Sky → Light Sky
    [Color(0xFFF43F5E), Color(0xFFFB7185)],  // Rose → Light Rose
    [Color(0xFF06B6D4), Color(0xFF22D3EE)],  // Cyan → Light Cyan
    [Color(0xFFEC4899), Color(0xFFF472B6)],  // Pink → Light Pink
    [Color(0xFFFB923C), Color(0xFFFDBA74)],  // Orange → Light Orange
    [Color(0xFF84CC16), Color(0xFFA3E635)],  // Lime → Light Lime
    [Color(0xFF14B8A6), Color(0xFF2DD4BF)],  // Teal → Light Teal
    [Color(0xFFA855F7), Color(0xFFC084FC)],  // Purple → Light Purple
    [Color(0xFFEF4444), Color(0xFFF87171)],  // Red → Light Red
  ];

  // Shadows
  static const shadowColor = Color(0xFF0F172A);
  static const scrimColor = Color(0xCC0F172A);
  static const shadowColorLight = Color(0xFF1E293B);
  static const shadowColorDark = Color(0xFF000000);

  // Glassmorphism
  static const glassLight = Color(0x80FFFFFF);
  static const glassDark = Color(0x40FFFFFF);
  static const glassBorderLight = Color(0x33FFFFFF);
  static const glassBorderDark = Color(0x1FFFFFFF);

  // Backward-compatible aliases
  static const background = lightBackground;
  static const surface = lightSurface;
  static const textPrimary = lightTextPrimary;
  static const textSecondary = lightTextSecondary;
  static const border = lightBorder;
}