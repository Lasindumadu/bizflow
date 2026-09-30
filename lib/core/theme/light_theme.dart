import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class LightTheme {
  static ThemeData build() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,

          primaryContainer: const Color(0xFFDBEAFE),
          onPrimaryContainer: const Color(0xFF1E3A8A),

          secondary: const Color(0xFF475569),
          onSecondary: Colors.white,

          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,

          surfaceContainerHighest: AppColors.lightSurfaceVariant,

          outline: AppColors.lightBorder,
          outlineVariant: AppColors.lightDivider,

          error: AppColors.error,
          onError: Colors.white,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.lightBackground,

      fontFamily: 'Roboto',

      // ─────────────────────────────────────────
      // Typography
      // ─────────────────────────────────────────
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: AppColors.lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: AppColors.lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: AppColors.lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: AppColors.lightTextSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 13,
          height: 1.35,
          color: AppColors.lightTextSecondary,
        ),
      ),

      // ─────────────────────────────────────────
      // App bar
      // ─────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      // ─────────────────────────────────────────
      // Cards
      // ─────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: AppDimensions.cardElevation,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),

      // ─────────────────────────────────────────
      // Text fields
      // ─────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        hintStyle: const TextStyle(color: AppColors.lightTextTertiary),

        labelStyle: const TextStyle(color: AppColors.lightTextSecondary),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),

      // ─────────────────────────────────────────
      // Primary buttons
      // ─────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppDimensions.buttonHeight),
          backgroundColor: AppColors.primary,
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
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),

      // ─────────────────────────────────────────
      // Text buttons
      // ─────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppDimensions.compactButtonHeight),
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
      ),

      // ─────────────────────────────────────────
      // Bottom navigation
      // ─────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,

        indicatorColor: const Color(0xFFDBEAFE),

        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),

      // ─────────────────────────────────────────
      // Navigation rail
      // ─────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: const Color(0xFFDBEAFE),
        useIndicator: true,
      ),

      // ─────────────────────────────────────────
      // Dividers
      // ─────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // ─────────────────────────────────────────
      // Dialogs
      // ─────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
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
        color: AppColors.lightSurface,
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

          return AppColors.lightTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }

          return AppColors.lightSurfaceVariant;
        }),
      ),
    );
  }
}
