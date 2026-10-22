import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/core/session/session_authorization.dart';
import 'package:bizflow/core/session/session_controller.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/business_settings_repository.dart';
import 'package:bizflow/data/repositories/expense_repository.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';
import 'package:bizflow/data/services/backup_service.dart';
import 'package:bizflow/features/pos/presentation/utils/parked_sales.dart';

void main() {
  late AppDatabase database;
  late StaffAccountRepository staffRepository;
  late BusinessSettingsRepository settingsRepository;
  late ExpenseRepository expenseRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    staffRepository = StaffAccountRepository(database);
    settingsRepository = BusinessSettingsRepository(database);
    expenseRepository = ExpenseRepository(database);
    sessionController.signOut();
  });

  tearDown(() async {
    sessionController.signOut();
    await database.close();
  });

  Future<StaffAccountSummary> createStaff({
    required StaffRole role,
    required String username,
    String pin = '1234',
  }) async {
    final created = await staffRepository.createAccount(
      role: role,
      username: username,
      pin: pin,
      displayName: username,
    );
    return created.account;
  }

  Future<void> saveSettings({int? inactivityTimeoutMinutes}) async {
    await settingsRepository.saveSettings(
      businessName: 'Test Store',
      address: '',
      phone: '',
      email: '',
      currency: 'LKR',
      inactivityTimeoutMinutes: inactivityTimeoutMinutes,
    );
  }

  group('Phase F - Session lock state', () {
    test('a fresh session is signed out', () {
      expect(sessionController.lockState, SessionLockState.signedOut);
      expect(sessionController.isLocked, isFalse);
      expect(sessionController.isAuthenticated, isFalse);
    });

    test('signing in produces an unlocked session', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);

      expect(sessionController.lockState, SessionLockState.unlocked);
      expect(sessionController.isAuthenticated, isTrue);
      expect(sessionController.isLocked, isFalse);
    });

    test('locking an authenticated session requires a PIN to unlock', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);

      sessionController.lock();

      expect(sessionController.lockState, SessionLockState.locked);
      expect(sessionController.isLocked, isTrue);
      // The identity is preserved: unlocking re-authenticates the SAME
      // account rather than starting a new session.
      expect(sessionController.current, isNotNull);
      expect(sessionController.current!.username, 'owner1');
    });

    test('locking is a no-op when signed out', () {
      sessionController.lock();

      expect(sessionController.lockState, SessionLockState.signedOut);
      expect(sessionController.isLocked, isFalse);
    });

    test('locking twice does not change the state', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);

      sessionController.lock();
      sessionController.lock();

      expect(sessionController.lockState, SessionLockState.locked);
    });

    test('unlocking restores the unlocked state', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      sessionController.unlock();

      expect(sessionController.lockState, SessionLockState.unlocked);
      expect(sessionController.isLocked, isFalse);
    });

    test('signing out clears the identity and the lock state', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      sessionController.signOut();

      expect(sessionController.current, isNull);
      expect(sessionController.lockState, SessionLockState.signedOut);
      expect(sessionController.lastActivity, isNull);
    });

    test('the PIN is the only way to unlock — activity does not', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      // A stray tap / keypress must NOT clear the lock. This is the whole
      // point of the inactivity lock: it must not be escapable by touching
      // the screen.
      sessionController.resetActivity();

      expect(sessionController.isLocked, isTrue);
      expect(sessionController.lockState, SessionLockState.locked);
    });

    test('activity updates the timestamp without unlocking', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      final before = sessionController.lastActivity;

      await Future<void>.delayed(const Duration(milliseconds: 5));
      sessionController.resetActivity();

      expect(sessionController.lastActivity!.isAfter(before!), isTrue);
      expect(sessionController.isLocked, isFalse);
    });

    test(
      'resetActivitySilently updates the timestamp without notifying',
      () async {
        final owner = await createStaff(
          role: StaffRole.owner,
          username: 'owner1',
        );
        sessionController.signIn(owner);
        final before = sessionController.lastActivity;

        var notified = 0;
        void listener() => notified++;
        sessionController.addListener(listener);

        await Future<void>.delayed(const Duration(milliseconds: 5));
        sessionController.resetActivitySilently();

        expect(sessionController.lastActivity!.isAfter(before!), isTrue);
        expect(notified, 0);

        sessionController.removeListener(listener);
      },
    );

    test('activity is ignored when signed out', () {
      sessionController.resetActivity();

      expect(sessionController.lastActivity, isNull);
    });
  });

  group('Phase F - Locked sessions cannot authorize operations', () {
    test('a locked session cannot record an expense', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      expect(
        () => expenseRepository.addExpense(
          id: 'expense-locked',
          title: 'Locked attempt',
          category: 'General',
          amount: 10,
          date: DateTime(2026, 1, 1),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('locked'),
          ),
        ),
      );
    });

    test('unlocking restores the ability to operate', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      sessionController.lock();
      sessionController.unlock();

      await expectLater(
        expenseRepository.addExpense(
          id: 'expense-unlocked',
          title: 'Unlocked attempt',
          category: 'General',
          amount: 10,
          date: DateTime(2026, 1, 1),
        ),
        completes,
      );
    });

    test('resolveActor throws for a locked session', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      expect(
        () => resolveActor(database),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('locked'),
          ),
        ),
      );
    });

    test('requireOwner throws for a locked session', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      expect(
        () => requireOwner(database, 'do something'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Phase F - Inactivity timeout configuration', () {
    test('the timeout is disabled by default', () async {
      final settings = await settingsRepository.getSettings();

      expect(settings.inactivityTimeoutMinutes, 0);
    });

    test('the timeout persists when reloaded', () async {
      await saveSettings(inactivityTimeoutMinutes: 15);

      final settings = await settingsRepository.getSettings();

      expect(settings.inactivityTimeoutMinutes, 15);
    });

    test('an unrelated settings save preserves the timeout', () async {
      await saveSettings(inactivityTimeoutMinutes: 30);
      await saveSettings();

      final settings = await settingsRepository.getSettings();

      expect(settings.inactivityTimeoutMinutes, 30);
    });

    test('a negative timeout is rejected', () async {
      expect(
        () => saveSettings(inactivityTimeoutMinutes: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('the owner can change the timeout', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);

      await saveSettings(inactivityTimeoutMinutes: 5);

      final settings = await settingsRepository.getSettings();
      expect(settings.inactivityTimeoutMinutes, 5);
    });

    test('a manager cannot change the timeout', () async {
      final manager = await createStaff(
        role: StaffRole.manager,
        username: 'manager1',
      );
      sessionController.signIn(manager);

      await expectLater(
        saveSettings(inactivityTimeoutMinutes: 5),
        throwsA(isA<StateError>()),
      );

      final settings = await settingsRepository.getSettings();
      expect(settings.inactivityTimeoutMinutes, 0);
    });

    test('a cashier cannot change the timeout', () async {
      final cashier = await createStaff(
        role: StaffRole.cashier,
        username: 'cashier1',
      );
      sessionController.signIn(cashier);

      await expectLater(
        saveSettings(inactivityTimeoutMinutes: 5),
        throwsA(isA<StateError>()),
      );

      final settings = await settingsRepository.getSettings();
      expect(settings.inactivityTimeoutMinutes, 0);
    });

    test('an owner timeout change is audited', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);

      await saveSettings(inactivityTimeoutMinutes: 15);

      final entries = await database.select(database.auditLogs).get();
      final timeoutAudit = entries.where(
        (e) => e.action == 'settings.inactivity_timeout_change',
      );
      expect(timeoutAudit, isNotEmpty);
      expect(timeoutAudit.first.actor, 'owner1');
    });
  });

  group('Phase F - PIN unlock and owner recovery', () {
    test('the correct PIN verifies and unlocks the session', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
        pin: '1234',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      final result = await staffRepository.verifyPin(
        username: 'owner1',
        pin: '1234',
      );

      expect(result.status, StaffAuthStatus.success);
      expect(result.account!.id, owner.id);

      sessionController.unlock();
      expect(sessionController.isLocked, isFalse);
      expect(sessionController.current!.id, owner.id);
    });

    test('a wrong PIN does not unlock the session', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
        pin: '1234',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      final result = await staffRepository.verifyPin(
        username: 'owner1',
        pin: '9999',
      );

      expect(result.status, StaffAuthStatus.invalidPin);
      expect(sessionController.isLocked, isTrue);
    });

    test('a deactivated account cannot unlock the session', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
        pin: '1234',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      // Deactivate the owner directly, bypassing the owner-only repository
      // gate (the acting session is the owner being deactivated).
      await database
          .update(database.staffAccounts)
          .write(const StaffAccountsCompanion(isActive: Value(false)));

      final result = await staffRepository.verifyPin(
        username: 'owner1',
        pin: '1234',
      );

      expect(result.status, StaffAuthStatus.disabled);
      expect(sessionController.isLocked, isTrue);
    });

    test(
      'owner recovery rotates the recovery code and sets a new PIN',
      () async {
        final created = await staffRepository.createAccount(
          role: StaffRole.owner,
          username: 'owner1',
          pin: '1234',
        );
        final originalRecoveryCode = created.recoveryCode!;

        final recovered = await staffRepository.recoverOwnerPin(
          recoveryCode: originalRecoveryCode,
          newPin: '5678',
        );

        expect(recovered.account.username, 'owner1');
        expect(
          recovered.newRecoveryCode,
          isNot(originalRecoveryCode),
          reason: 'the recovery code is rotated on every recovery',
        );

        // The new PIN works...
        final result = await staffRepository.verifyPin(
          username: 'owner1',
          pin: '5678',
        );
        expect(result.status, StaffAuthStatus.success);

        // ...and the old recovery code no longer does.
        expect(
          () => staffRepository.recoverOwnerPin(
            recoveryCode: originalRecoveryCode,
            newPin: '4321',
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('login readiness reports the missing owner', () async {
      final readiness = await staffRepository.checkLoginReadiness();

      expect(readiness.ready, isFalse);
      expect(readiness.message, contains('No owner account exists'));
    });

    test('login readiness is satisfied by a complete owner account', () async {
      await createStaff(role: StaffRole.owner, username: 'owner1');

      final readiness = await staffRepository.checkLoginReadiness();

      expect(readiness.ready, isTrue);
    });

    test('login readiness fails when the owner has no recovery code', () async {
      await database
          .into(database.staffAccounts)
          .insert(
            StaffAccountsCompanion.insert(
              id: 'staff-1',
              username: 'owner1',
              role: StaffRole.owner.name,
              pinVerifier: 'not-a-real-verifier',
              recoveryCodeVerifier: const Value(null),
              pinChangedAt: DateTime(2026, 1, 1),
              createdAt: DateTime(2026, 1, 1),
            ),
          );

      final readiness = await staffRepository.checkLoginReadiness();

      expect(readiness.ready, isFalse);
      expect(readiness.message, contains('recovery code'));
    });
  });

  group('Phase F - Backup compatibility', () {
    test('the backup carries the inactivity timeout', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      await saveSettings(inactivityTimeoutMinutes: 15);

      final json = await BackupService(database).createBackupJson();
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      final settings = (data['businessSettings'] as List).first as Map;

      expect(settings['inactivityTimeoutMinutes'], 15);
    });

    test('a backup without the timeout field still restores', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      // Make sure a business-settings row exists so it lands in the payload.
      await saveSettings();

      final json = await BackupService(database).createBackupJson();
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      final settings = (data['businessSettings'] as List).first as Map;
      // Simulate a pre-v15 backup that never carried the field.
      settings.remove('inactivityTimeoutMinutes');

      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(decoded)));

      await expectLater(
        BackupService(database).restoreBackup(bytes),
        completes,
      );

      final restored = await settingsRepository.getSettings();
      expect(restored.inactivityTimeoutMinutes, 0);
    });

    test('the backup round-trips the inactivity timeout', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      await saveSettings(inactivityTimeoutMinutes: 30);

      final json = await BackupService(database).createBackupJson();
      final bytes = Uint8List.fromList(utf8.encode(json));

      await BackupService(database).restoreBackup(bytes);

      final restored = await settingsRepository.getSettings();
      expect(restored.inactivityTimeoutMinutes, 30);
    });
  });

  group('Phase F - POS cart preservation across a lock', () {
    tearDown(() {
      // The parked-sale store is a process-wide singleton; reset it so each
      // test starts from a clean slate.
      while (parkedSalesStore.sales.isNotEmpty) {
        parkedSalesStore.recall(0);
      }
    });

    test('a cart is parked once and restored once', () {
      final sale = ParkedSale(
        label: 'Hold 10:00 • 2 items',
        parkedAt: DateTime(2026, 1, 1),
        items: [
          ParkedItem(
            productId: 'product-1',
            name: 'Test Product',
            price: 10,
            cost: 5,
            qty: 2,
          ),
        ],
      );

      parkedSalesStore.park(sale);
      expect(parkedSalesStore.sales, hasLength(1));

      // The sale is removed from the store when it is recalled, so a second
      // recall can never duplicate the customer's items.
      final recalled = parkedSalesStore.recall(0);
      expect(recalled, isNotNull);
      expect(parkedSalesStore.sales, isEmpty);

      final secondRecall = parkedSalesStore.recall(0);
      expect(secondRecall, isNull);
    });

    test('parking preserves the cart contents', () {
      parkedSalesStore.park(
        ParkedSale(
          label: 'Hold 10:00 • 1 items',
          parkedAt: DateTime(2026, 1, 1),
          items: [
            ParkedItem(
              productId: 'product-1',
              name: 'Test Product',
              price: 10,
              cost: 5,
              qty: 3,
            ),
          ],
        ),
      );

      final recalled = parkedSalesStore.recall(0)!;

      expect(recalled.items, hasLength(1));
      expect(recalled.items.single.productId, 'product-1');
      expect(recalled.items.single.qty, 3);
      expect(recalled.items.single.price, 10);
      // The subtotal is what the customer was about to pay.
      expect(recalled.subtotal, 30);
    });

    test('a locked session does not clear the parked sale', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);

      parkedSalesStore.park(
        ParkedSale(
          label: 'Hold 10:00 • 1 items',
          parkedAt: DateTime(2026, 1, 1),
          items: [
            ParkedItem(
              productId: 'product-1',
              name: 'Test Product',
              price: 10,
              cost: 5,
              qty: 1,
            ),
          ],
        ),
      );

      sessionController.lock();

      // Locking parks the cart; the parked sale survives until it is
      // explicitly recalled on unlock.
      expect(parkedSalesStore.sales, hasLength(1));
    });
  });
}
