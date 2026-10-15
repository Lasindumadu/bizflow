import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system,
  highContrastLight,
  highContrastDark,
  sepia,
}

enum AppFontSize {
  small,
  medium,
  large,
  extraLarge,
}

class ThemeController extends ChangeNotifier {
  static const String _themeModeKey = 'app_theme_mode';
  static const String _fontSizeKey = 'app_font_size';
  static const String _animationsEnabledKey = 'app_animations_enabled';

  AppThemeMode _themeMode = AppThemeMode.system;
  AppFontSize _fontSize = AppFontSize.medium;
  bool _animationsEnabled = true;

  ThemeController();

  AppThemeMode get themeMode => _themeMode;
  AppFontSize get fontSize => _fontSize;
  bool get animationsEnabled => _animationsEnabled;
  bool get isDark {
    switch (_themeMode) {
      case AppThemeMode.dark:
      case AppThemeMode.highContrastDark:
        return true;
      case AppThemeMode.light:
      case AppThemeMode.highContrastLight:
      case AppThemeMode.sepia:
        return false;
      case AppThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }

  double get fontScale {
    switch (_fontSize) {
      case AppFontSize.small:
        return 0.85;
      case AppFontSize.medium:
        return 1.0;
      case AppFontSize.large:
        return 1.15;
      case AppFontSize.extraLarge:
        return 1.3;
    }
  }

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
      case AppThemeMode.highContrastLight:
      case AppThemeMode.sepia:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.highContrastDark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = AppThemeMode.values.byName(prefs.getString(_themeModeKey) ?? 'system');
    _fontSize = AppFontSize.values.byName(prefs.getString(_fontSizeKey) ?? 'medium');
    _animationsEnabled = prefs.getBool(_animationsEnabledKey) ?? true;
    notifyListeners();
  }

  void setThemeMode(AppThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _saveThemeMode();
    notifyListeners();
  }

  void setFontSize(AppFontSize size) {
    if (_fontSize == size) return;
    _fontSize = size;
    _saveFontSize();
    notifyListeners();
  }

  void setAnimationsEnabled(bool enabled) {
    if (_animationsEnabled == enabled) return;
    _animationsEnabled = enabled;
    _saveAnimationsEnabled();
    notifyListeners();
  }

  void toggle() {
    final modes = AppThemeMode.values;
    final currentIndex = modes.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    setThemeMode(modes[nextIndex]);
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeMode.name);
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontSizeKey, _fontSize.name);
  }

  Future<void> _saveAnimationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_animationsEnabledKey, _animationsEnabled);
  }

  String get themeModeLabel {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.highContrastLight:
        return 'High Contrast Light';
      case AppThemeMode.highContrastDark:
        return 'High Contrast Dark';
      case AppThemeMode.sepia:
        return 'Sepia';
    }
  }

  String get fontSizeLabel {
    switch (_fontSize) {
      case AppFontSize.small:
        return 'Small';
      case AppFontSize.medium:
        return 'Medium';
      case AppFontSize.large:
        return 'Large';
      case AppFontSize.extraLarge:
        return 'Extra Large';
    }
  }

  IconData get themeModeIcon {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode_outlined;
      case AppThemeMode.dark:
        return Icons.dark_mode_outlined;
      case AppThemeMode.system:
        return Icons.brightness_auto_outlined;
      case AppThemeMode.highContrastLight:
        return Icons.contrast_outlined;
      case AppThemeMode.highContrastDark:
        return Icons.contrast_outlined;
      case AppThemeMode.sepia:
        return Icons.wb_sunny_outlined;
    }
  }
}

final ThemeController themeController = ThemeController();
