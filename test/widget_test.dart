import 'package:flutter_test/flutter_test.dart';
import 'package:bizflow/core/theme/app_theme.dart';
import 'package:bizflow/core/theme/app_colors.dart';

void main() {
  group('BizFlow theme configuration', () {
    test('light theme uses the BizFlow primary brand color', () {
      expect(AppTheme.light.colorScheme.primary, AppColors.primary);
    });

    test('dark theme is configured', () {
      expect(AppTheme.dark.brightness, isNotNull);
    });
  });
}
