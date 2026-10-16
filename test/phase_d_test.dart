import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/core/session/session_controller.dart';
import 'package:bizflow/core/widgets/startup_gate.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/business_settings_repository.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';

void main() {
  late AppDatabase database;
  late BusinessSettingsRepository settingsRepository;
  late StaffAccountRepository staffRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    settingsRepository = BusinessSettingsRepository(database);
    staffRepository = StaffAccountRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Phase D - Login setting persistence', () {
    test('login is disabled by default', () async {
      final settings = await settingsRepository.getSettings();

      expect(settings.loginRequired, isFalse);
    });

    test('login setting persists when settings are reloaded', () async {
      await settingsRepository.saveSettings(
        businessName: 'Test Store',
        address: '',
        phone: '',
        email: '',
        currency: 'LKR',
        loginRequired: true,
      );

      final reloadedSettings = await BusinessSettingsRepository(database)
          .getSettings();

      expect(reloadedSettings.loginRequired, isTrue);
    });

    test('unrelated settings updates preserve login setting', () async {
      await settingsRepository.saveSettings(
        businessName: 'Test Store',
        address: '',
        phone: '',
        email: '',
        currency: 'LKR',
        loginRequired: true,
      );

      await settingsRepository.saveSettings(
        businessName: 'Updated Store',
        address: '',
        phone: '',
        email: '',
        currency: 'LKR',
        loginRequired: true,
      );

      final settings = await settingsRepository.getSettings();

      expect(settings.businessName, 'Updated Store');
      expect(settings.loginRequired, isTrue);
    });
  });

  group('Phase D - Staff PIN authentication', () {
    test('owner can authenticate with the correct PIN', () async {
      await staffRepository.createAccount(
        role: StaffRole.owner,
        username: 'owner1',
        pin: '1234',
      );

      final result = await staffRepository.verifyPin(
        username: 'owner1',
        pin: '1234',
      );

      expect(result.status, StaffAuthStatus.success);
      expect(result.account != null, isTrue);
      expect(result.account!.role, StaffRole.owner);
    });

    test('manager can authenticate with the correct PIN', () async {
      await staffRepository.createAccount(
        role: StaffRole.manager,
        username: 'manager1',
        pin: '5678',
      );

      final result = await staffRepository.verifyPin(
        username: 'manager1',
        pin: '5678',
      );

      expect(result.status, StaffAuthStatus.success);
      expect(result.account!.role, StaffRole.manager);
    });

    test('cashier can authenticate with the correct PIN', () async {
      await staffRepository.createAccount(
        role: StaffRole.cashier,
        username: 'cashier1',
        pin: '2468',
      );

      final result = await staffRepository.verifyPin(
        username: 'cashier1',
        pin: '2468',
      );

      expect(result.status, StaffAuthStatus.success);
      expect(result.account!.role, StaffRole.cashier);
    });

    test('incorrect PIN is rejected', () async {
      await staffRepository.createAccount(
        role: StaffRole.owner,
        username: 'owner1',
        pin: '1234',
      );

      final result = await staffRepository.verifyPin(
        username: 'owner1',
        pin: '0000',
      );

      expect(result.status, StaffAuthStatus.invalidPin);
    });

    test('deactivated staff cannot authenticate', () async {
      await staffRepository.createAccount(
        role: StaffRole.cashier,
        username: 'cashier1',
        pin: '2468',
      );

      await staffRepository.setActive(
        username: 'cashier1',
        isActive: false,
        asOwner: true,
      );

      final result = await staffRepository.verifyPin(
        username: 'cashier1',
        pin: '2468',
      );

      expect(result.status, StaffAuthStatus.disabled);
    });

    test('repeated incorrect PIN attempts lock the account', () async {
      await staffRepository.createAccount(
        role: StaffRole.owner,
        username: 'owner1',
        pin: '1234',
      );

      for (var attempt = 0; attempt < 5; attempt++) {
        await staffRepository.verifyPin(username: 'owner1', pin: '0000');
      }

      final result = await staffRepository.verifyPin(
        username: 'owner1',
        pin: '1234',
      );

      expect(result.status, StaffAuthStatus.locked);
    });
  });

  group('Phase D - Login setting authorization', () {
    test('owner can enable staff login', () async {
      await staffRepository.createAccount(
        role: StaffRole.owner,
        username: 'owner1',
        pin: '1234',
      );

      await staffRepository.setLoginRequired(
        enable: true,
        actingUsername: 'owner1',
        asOwner: true,
      );

      final settings = await settingsRepository.getSettings();

      expect(settings.loginRequired, isTrue);
    });

    test('owner can disable staff login', () async {
      await staffRepository.createAccount(
        role: StaffRole.owner,
        username: 'owner1',
        pin: '1234',
      );

      await staffRepository.setLoginRequired(
        enable: true,
        actingUsername: 'owner1',
        asOwner: true,
      );

      await staffRepository.setLoginRequired(
        enable: false,
        actingUsername: 'owner1',
        asOwner: true,
      );

      final settings = await settingsRepository.getSettings();

      expect(settings.loginRequired, isFalse);
    });

    test('non-owner cannot enable staff login', () async {
      await staffRepository.createAccount(
        role: StaffRole.owner,
        username: 'owner1',
        pin: '1234',
      );

      await staffRepository.createAccount(
        role: StaffRole.cashier,
        username: 'cashier1',
        pin: '2468',
      );

      expect(
        () => staffRepository.setLoginRequired(
          enable: true,
          actingUsername: 'cashier1',
          asOwner: true,
        ),
        throwsA(anything),
      );
    });
  });

  group('Phase D - Session lifecycle', () {
    late SessionController session;

    setUp(() {
      session = sessionController;
      session.signOut();
    });

    tearDown(() {
      session.signOut();
    });

    test('sign out leaves no authenticated account', () {
      session.signOut();

      expect(session.isAuthenticated, isFalse);
      expect(session.current, null);
    });

    test('sign out can be called repeatedly', () {
      session.signOut();
      session.signOut();

      expect(session.isAuthenticated, isFalse);
      expect(session.current, null);
    });
  });

  group('Phase D - Startup gate', () {
    testWidgets('shows the application after successful initialization '
        'when login is disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartupGate(
            initializer: () async {},
            loginRequiredLoader: () async => false,
            session: sessionController,
            child: const Scaffold(body: Text('BizFlow test shell')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('BizFlow test shell'), findsOneWidget);
    });

    testWidgets('shows a recoverable error when initialization fails', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StartupGate(
            initializer: () async {
              throw Exception('Test initialization failure');
            },
            loginRequiredLoader: () async => false,
            session: sessionController,
            child: const Scaffold(body: Text('BizFlow test shell')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("BizFlow couldn't start"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('loads the login setting before showing the shell', (
      tester,
    ) async {
      var loginSettingLoaded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StartupGate(
            initializer: () async {},
            loginRequiredLoader: () async {
              loginSettingLoaded = true;
              return false;
            },
            session: sessionController,
            child: const Scaffold(body: Text('BizFlow test shell')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loginSettingLoaded, isTrue);
      expect(find.text('BizFlow test shell'), findsOneWidget);
    });
  });
}
