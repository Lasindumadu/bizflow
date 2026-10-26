import 'package:flutter/material.dart';

/// Premium BizFlow brand palette.
/// Modern gradient system with sophisticated colors for mobile + web.
/// Designed for light/dark themes with marketplace-ready aesthetics.
class AppColors {
  // ─────────────────────────────────────────────
  // Brand — Modern gradient primary (Indigo/Violet)
  // ─────────────────────────────────────────────

  static const primary = Color(0xFF5B5BF7);
  static const primaryDark = Color(0xFF4141D6);
  static const primaryLight = Color(0xFF7C7CFF);
  static const primarySoft = Color(0xFFEEF0FF);
  static const primaryContainer = Color(0xFFEEF0FF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF211A78);
  static const gradientStart = Color(0xFF7C5CFF); // Iris
  static const gradientEnd = Color(0xFF4F46E5);   // Indigo
  static const gradientDeep = Color(0xFF2E1C86);
  static const gradientVibrant = Color(0xFF5B5BF7);
  static const gradientAccent = Color(0xFFB388FF);
  static const gradientCyan = Color(0xFF22D3EE);
  static const gradientEmerald = Color(0xFF2DD4BF);
  static const gradientSunset = Color(0xFFFF6B8A);

  // ─────────────────────────────────────────────
  // BizFlow brand signature
  // ─────────────────────────────────────────────
  static const brandMint = Color(0xFF2DD4BF);
  static const brandMintDeep = Color(0xFF0E9F8C);
  static const brandAmber = Color(0xFFFFB547);
  static const brandCoral = Color(0xFFFF6B8A);
  static const brandInk = Color(0xFF070A14);
  static const brandInkSoft = Color(0xFF0D1222);

  // Modern UI Glass & Aura Accents
  static const auraPurple = Color(0x338B5CF6);
  static const auraBlue = Color(0x333B82F6);
  static const auraCyan = Color(0x3306B6D4);
  static const auraEmerald = Color(0x3310B981);

  static const accent = Color(0xFF8B5CF6);
  static const accentLight = Color(0xFFB69CFF);
  static const accentSoft = Color(0xFFF3F0FF);

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

  static const lightBackground = Color(0xFFF6F7FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F3FA);
  static const lightSurfaceContainer = Color(0xFFE7EAF3);
  static const lightSurfaceContainerHigh = Color(0xFFD6DBE9);
  static const lightSurfaceContainerHighest = Color(0xFFA6AFC4);

  static const lightTextPrimary = Color(0xFF0B1020);
  static const lightTextSecondary = Color(0xFF49536B);
  static const lightTextTertiary = Color(0xFF6E7891);
  static const lightTextDisabled = Color(0xFFA2AABD);
  static const lightTextOnSurface = Color(0xFF0B1020);

  static const lightBorder = Color(0xFFE6E9F2);
  static const lightBorderStrong = Color(0xFFD2D8E6);
  static const lightDivider = Color(0xFFEFF1F7);

  // ─────────────────────────────────────────────
  // Dark theme — Rich modern dark with depth
  // ─────────────────────────────────────────────

  static const darkBackground = Color(0xFF070A14);
  static const darkSurface = Color(0xFF0E1322);
  static const darkSurfaceVariant = Color(0xFF151C30);
  static const darkSurfaceContainer = Color(0xFF2A3450);
  static const darkSurfaceContainerHigh = Color(0xFF3B4766);
  static const darkSurfaceContainerHighest = Color(0xFF56607C);

  static const darkTextPrimary = Color(0xFFF4F6FF);
  static const darkTextSecondary = Color(0xFFCBD2E4);
  static const darkTextTertiary = Color(0xFF8E99B5);
  static const darkTextDisabled = Color(0xFF5A6480);
  static const darkTextOnSurface = Color(0xFFF4F6FF);

  static const darkBorder = Color(0xFF232C44);
  static const darkBorderStrong = Color(0xFF35405C);
  static const darkDivider = Color(0xFF1A2237);

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

  // ─────────────────────────────────────────────
  // Aurora 2.0 — evolved brand extensions
  // Never renamed, only appended, so every screen
  // can adopt the deeper brand look safely.
  // ─────────────────────────────────────────────

  // Signature "royal" gradient anchors (deeper than primary)
  static const royalStart = Color(0xFF8460FF);
  static const royalMid = Color(0xFF5B5BF7);
  static const royalEnd = Color(0xFF4338CA);

  // Aurora accent trio used for live/glow chrome
  static const auroraTeal = Color(0xFF5EEAD4);
  static const auroraBlue = Color(0xFF60A5FA);
  static const auroraLilac = Color(0xFFC4B5FD);

  // Photo-wash overlay colors (images under gradient glass)
  static const photoInk = Color(0xFF0A0C1E);
  static const photoWash = Color(0xFF191243);

  // Section tint pairs — [soft, deep] — for per-section theming
  static const posTint = [Color(0xFFEEF0FF), Color(0xFF4338CA)];
  static const moneyTint = [Color(0xFFE6FBF7), Color(0xFF0E9F8C)];
  static const stockTint = [Color(0xFFEFF6FF), Color(0xFF2563EB)];
  static const growthTint = [Color(0xFFFFF4DE), Color(0xFFD97706)];
  static const careTint = [Color(0xFFFCE7F3), Color(0xFFBE185D)];

  // Warm contrast helpers used by photo heroes
  static const onPhoto = Color(0xFFFFFFFF);
  static const onPhotoMuted = Color(0xE6FFFFFF); // 90% white
  static const onPhotoSoft = Color(0xB3FFFFFF); // 70% white
}