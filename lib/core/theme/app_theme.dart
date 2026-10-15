import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'theme_controller.dart';

class AppTheme {
  static ThemeData get light => _buildLight();
  static ThemeData get dark => _buildDark();
  static ThemeData get highContrastLight => _buildHighContrastLight();
  static ThemeData get highContrastDark => _buildHighContrastDark();
  static ThemeData get sepia => _buildSepia();

  static ThemeData _buildLight() {
    final s = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHigh,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightDivider,
      error: AppColors.error,
    );

    return _base(s, Brightness.light);
  }

  static ThemeData _buildDark() {
    final s = ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.darkTextPrimary,
      primaryContainer: const Color(0xFF312E81),
      onPrimaryContainer: AppColors.primaryContainer,
      secondary: AppColors.secondaryLight,
      tertiary: AppColors.tertiaryLight,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      outline: AppColors.darkBorder,
      error: AppColors.errorLight,
    );

    return _base(s, Brightness.dark);
  }

  static ThemeData _buildHighContrastLight() {
    final s = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      contrastLevel: 1.0,
    ).copyWith(
      primary: const Color(0xFF1A1A2E),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF3F3F5C),
      onPrimaryContainer: Colors.white,
      secondary: const Color(0xFF004D26),
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF000000),
      surfaceContainerHighest: const Color(0xFFE0E0E0),
      outline: const Color(0xFF000000),
      outlineVariant: const Color(0xFF757575),
      error: const Color(0xFFB71C1C),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFEBEE),
      onErrorContainer: const Color(0xFFB71C1C),
    );

    return _base(s, Brightness.light).copyWith(
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF000000), width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF000000), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF000000), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 3),
        ),
      ),
    );
  }

  static ThemeData _buildHighContrastDark() {
    final s = ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      contrastLevel: 1.0,
    ).copyWith(
      primary: const Color(0xFFE8E8FF),
      onPrimary: const Color(0xFF000000),
      primaryContainer: const Color(0xFF4A4AD4),
      onPrimaryContainer: Colors.white,
      secondary: const Color(0xFF81C784),
      onSecondary: const Color(0xFF000000),
      surface: const Color(0xFF000000),
      onSurface: Colors.white,
      surfaceContainerHighest: const Color(0xFF333333),
      outline: Colors.white,
      outlineVariant: const Color(0xFFBDBDBD),
      error: const Color(0xFFFF5252),
      onError: const Color(0xFF000000),
      errorContainer: const Color(0xFFB71C1C),
      onErrorContainer: Colors.white,
    );

    return _base(s, Brightness.dark).copyWith(
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8E8FF), width: 3),
        ),
      ),
    );
  }

  static ThemeData _buildSepia() {
    final s = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B7355),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFF8B7355),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFF5E6D3),
      onPrimaryContainer: const Color(0xFF5D4E37),
      secondary: const Color(0xFF6B8E6B),
      onSecondary: Colors.white,
      tertiary: const Color(0xFFC4A35A),
      onTertiary: Colors.white,
      surface: const Color(0xFFFDF8F0),
      onSurface: const Color(0xFF3D332A),
      surfaceContainerHighest: const Color(0xFFE8DCC8),
      outline: const Color(0xFFC4B59D),
      outlineVariant: const Color(0xFFD4C8B8),
      error: const Color(0xFF8B3A3A),
      onError: Colors.white,
      errorContainer: const Color(0xFFF5E6E6),
      onErrorContainer: const Color(0xFF8B3A3A),
    );

    return _base(s, Brightness.light).copyWith(
      scaffoldBackgroundColor: const Color(0xFFFDF8F0),
      cardTheme: CardThemeData(
        color: const Color(0xFFFDF8F0),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: const Color(0xFFE8DCC8), width: 1.5),
        ),
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme, Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight
          ? const Color(0xFFF8FAFC)
          : const Color(0xFF0F172A),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isLight
                ? const Color(0xFFE2E8F0)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        elevation: 0,
        height: 80,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData getThemeForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return light;
      case AppThemeMode.dark:
        return dark;
      case AppThemeMode.highContrastLight:
        return highContrastLight;
      case AppThemeMode.highContrastDark:
        return highContrastDark;
      case AppThemeMode.sepia:
        return sepia;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
            ? dark
            : light;
    }
  }
}
