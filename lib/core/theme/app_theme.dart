import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'theme_controller.dart';

/// BizFlow's branded Material 3 theme.
///
/// The visual language is built from three ideas:
///  * **Sora** for confident, geometric headlines and numbers.
///  * **Manrope** for calm, highly legible body copy.
///  * A single violet spark (`#5B5BF7`) carried through every surface,
///    with mint and amber reserved for meaning (money / attention).
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
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.brandMintDeep,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE6FBF7),
      onSecondaryContainer: const Color(0xFF064E43),
      tertiary: AppColors.brandAmber,
      onTertiary: const Color(0xFF3B2500),
      tertiaryContainer: const Color(0xFFFFF4DE),
      onTertiaryContainer: const Color(0xFF6B4300),
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFBFBFE),
      surfaceContainer: AppColors.lightSurfaceVariant,
      surfaceContainerHigh: AppColors.lightSurfaceContainer,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHigh,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightDivider,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      shadow: const Color(0x1A0B1020),
    );

    return _base(s, Brightness.light);
  }

  static ThemeData _buildDark() {
    final s = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primaryLight,
      onPrimary: const Color(0xFF0A0721),
      primaryContainer: const Color(0xFF2B246F),
      onPrimaryContainer: const Color(0xFFE4E1FF),
      secondary: AppColors.brandMint,
      onSecondary: const Color(0xFF04372F),
      secondaryContainer: const Color(0xFF0D3B35),
      onSecondaryContainer: const Color(0xFFB9FFF2),
      tertiary: AppColors.brandAmber,
      onTertiary: const Color(0xFF3B2500),
      tertiaryContainer: const Color(0xFF4A3312),
      onTertiaryContainer: const Color(0xFFFFE7BD),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      surfaceContainerLowest: const Color(0xFF080C18),
      surfaceContainerLow: const Color(0xFF0B101D),
      surfaceContainer: AppColors.darkSurfaceVariant,
      surfaceContainerHigh: const Color(0xFF1B233A),
      surfaceContainerHighest: AppColors.darkSurfaceContainer,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkDivider,
      error: const Color(0xFFFF7B8F),
      onError: const Color(0xFF3B0710),
      errorContainer: const Color(0xFF4A1620),
      onErrorContainer: const Color(0xFFFFD9DE),
      shadow: Colors.black,
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
    );

    return _base(s, Brightness.light).copyWith(
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF000000), width: 2),
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
    );

    return _base(s, Brightness.dark).copyWith(
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Colors.white, width: 2),
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
    );

    return _base(s, Brightness.light).copyWith(
      scaffoldBackgroundColor: const Color(0xFFFDF8F0),
      cardTheme: CardThemeData(
        color: const Color(0xFFFDF8F0),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFE8DCC8), width: 1.2),
        ),
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final text = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.lightBackground : AppColors.darkBackground,
      canvasColor: isLight ? AppColors.lightBackground : AppColors.darkBackground,
      fontFamily: AppTextStyles.bodyFont,
      textTheme: text,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _BizFlowPageTransitionsBuilder(),
          TargetPlatform.iOS: _BizFlowPageTransitionsBuilder(),
          TargetPlatform.macOS: _BizFlowPageTransitionsBuilder(),
          TargetPlatform.windows: _BizFlowPageTransitionsBuilder(),
          TargetPlatform.linux: _BizFlowPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _BizFlowPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor:
            isLight ? AppColors.lightBackground : AppColors.darkBackground,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isLight
                ? AppColors.lightBorder
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? Colors.white : const Color(0xFF111728),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.45),
        ),
        labelStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.65),
        ),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
          final focused = states.contains(WidgetState.focused);
          return text.bodySmall!.copyWith(
            color: focused
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.65),
            fontWeight: FontWeight.w600,
          );
        }),
        prefixIconColor: scheme.onSurface.withValues(alpha: 0.55),
        suffixIconColor: scheme.onSurface.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error, width: 1.7),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? AppColors.lightSurfaceVariant
            : Colors.white.withValues(alpha: 0.05),
        selectedColor: scheme.primary.withValues(alpha: 0.14),
        side: BorderSide(
          color: isLight
              ? AppColors.lightBorder
              : Colors.white.withValues(alpha: 0.08),
        ),
        labelStyle: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        secondaryLabelStyle: text.bodySmall,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 74,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          text.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        useIndicator: true,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: scheme.onSurface.withValues(alpha: 0.16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titleTextStyle: text.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight
            ? AppColors.lightTextPrimary
            : const Color(0xFF1B233A),
        contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isLight
                ? AppColors.lightBorder
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        textStyle: text.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightTextPrimary : const Color(0xFFE9ECF7),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: isLight ? Colors.white : const Color(0xFF0B1020),
          fontSize: 12,
          fontFamily: AppTextStyles.bodyFont,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.12),
        circularTrackColor: scheme.primary.withValues(alpha: 0.12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : (isLight ? Colors.white : const Color(0xFF8E99B5)),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outlineVariant,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outline,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: scheme.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.transparent,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outline,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface.withValues(alpha: 0.7),
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          scheme.onSurface.withValues(alpha: 0.18),
        ),
        radius: const Radius.circular(999),
        thickness: const WidgetStatePropertyAll(6),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.25),
        selectionHandleColor: scheme.primary,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        headerBackgroundColor: scheme.primary,
        headerForegroundColor: Colors.white,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        dialHandColor: scheme.primary,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final on = scheme.onSurface;
    final muted = scheme.onSurfaceVariant;

    TextStyle display(double size) => TextStyle(
          fontFamily: AppTextStyles.displayFont,
          fontSize: size,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -1.1,
          color: on,
        );

    TextStyle headline(double size) => TextStyle(
          fontFamily: AppTextStyles.displayFont,
          fontSize: size,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.7,
          color: on,
        );

    TextStyle title(double size, {FontWeight weight = FontWeight.w700}) =>
        TextStyle(
          fontFamily: AppTextStyles.displayFont,
          fontSize: size,
          fontWeight: weight,
          height: 1.3,
          letterSpacing: -0.25,
          color: on,
        );

    TextStyle body(double size, {double height = 1.5}) => TextStyle(
          fontFamily: AppTextStyles.bodyFont,
          fontSize: size,
          fontWeight: FontWeight.w500,
          height: height,
          letterSpacing: 0.05,
          color: on,
        );

    return TextTheme(
      displayLarge: display(52),
      displayMedium: display(42),
      displaySmall: display(34),
      headlineLarge: headline(30),
      headlineMedium: headline(26),
      headlineSmall: headline(22),
      titleLarge: title(19),
      titleMedium: title(15),
      titleSmall: title(13.5, weight: FontWeight.w600),
      bodyLarge: body(15.5, height: 1.55),
      bodyMedium: body(13.5, height: 1.5).copyWith(color: muted),
      bodySmall: body(12, height: 1.45).copyWith(color: muted),
      labelLarge: TextStyle(
        fontFamily: AppTextStyles.bodyFont,
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: on,
      ),
      labelMedium: TextStyle(
        fontFamily: AppTextStyles.bodyFont,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: muted,
      ),
      labelSmall: TextStyle(
        fontFamily: AppTextStyles.bodyFont,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: muted,
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
        return WidgetsBinding
                    .instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? dark
            : light;
    }
  }
}

/// A gentle fade + lift route transition shared by every platform.
class _BizFlowPageTransitionsBuilder extends PageTransitionsBuilder {
  const _BizFlowPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.025),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }
}
