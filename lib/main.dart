import 'package:flutter/material.dart';

import 'core/services/notification_store.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/startup_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  notificationStore.seedWelcome();
  runApp(const BizFlowApp());
}

class BizFlowApp extends StatelessWidget {
  const BizFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'BizFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.materialThemeMode,
          home: const StartupGate(),
        );
      },
    );
  }
}
