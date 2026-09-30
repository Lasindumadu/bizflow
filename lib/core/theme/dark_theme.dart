import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class DarkTheme {
  static ThemeData build() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.primaryLight,
          onPrimary: Colors.white,

          primaryContainer: const Color(0xFF1E3A8A),
          onPrimaryContainer: const Color(0xFFDBEAFE),

          secondary: const Color(0xFF94A3B8),
          onSecondary: const Color(0xFF0F172A),

          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,

          surfaceContainerHighest: AppColors.darkSurfaceVariant,

          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkDivider,

          error: const Color(0xFFF87171),
          onError: const Color(0xFF450A0A),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.darkBackground,

      fontFamily: 'Roboto',

      // ─────────────────────────────────────────
      // Typography
      // ─────────────────────────────────────────
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: AppColors.darkTextSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          height: 1.35,
          color: AppColors.darkTextSecondary,
        ),
      ),

      // ─────────────────────────────────────────
      // App bar
      // ─────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      // ─────────────────────────────────────────
      // Cards
      // ─────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: AppDimensions.cardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),

      // ─────────────────────────────────────────
      // Text fields
      // ─────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        hintStyle: const TextStyle(color: AppColors.darkTextTertiary),

        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: Color(0xFFF87171)),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
        ),
      ),

      // ─────────────────────────────────────────
      // Primary buttons
      // ─────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppDimensions.buttonHeight),
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          elevation: 0,
        ),
      ),

      // ─────────────────────────────────────────
      // Outlined buttons
      // ─────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppDimensions.buttonHeight),
          foregroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),

      // ─────────────────────────────────────────
      // Text buttons
      // ─────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppDimensions.compactButtonHeight),
          foregroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
      ),

      // ─────────────────────────────────────────
      // Bottom navigation
      // ─────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,

        indicatorColor: const Color(0xFF1E3A8A),

        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),

      // ─────────────────────────────────────────
      // Navigation rail
      // ─────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: const Color(0xFF1E3A8A),
        useIndicator: true,
      ),

      // ─────────────────────────────────────────
      // Dividers
      // ─────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // ─────────────────────────────────────────
      // Dialogs
      // ─────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: AppDimensions.dialogElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
      ),

      // ─────────────────────────────────────────
      // Snackbars
      // ─────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),

      // ─────────────────────────────────────────
      // Popup menus
      // ─────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: AppDimensions.menuElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),

      // ─────────────────────────────────────────
      // Switches
      // ─────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }

          return AppColors.darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }

          return AppColors.darkSurfaceVariant;
        }),
      ),
    );
  }
}
