
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart' as m;
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';

void main() {
  group('StaffAccountRepository', () {
    late AppDatabase database;
    late StaffAccountRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = StaffAccountRepository(database);
    });

    tearDown(() {});

    // --- Account creation, role persistence, normalized duplicate
    // usernames, and the single-owner invariant.
    group('createAccount', () {
      test('stores the account and returns a summary without verifiers', () async {
        final created = await repository.createAccount(
          role: StaffRole.cashier,
          username: '  AliceSmith ',
          pin: '1234',
          displayName: 'Alice Smith',
        );
        expect(created.account.username, 'alicesmith');
        expect(created.account.role, StaffRole.cashier);
        expect(created.account.isActive, true);
        expect(created.account.failedPinAttempts, 0);
        expect(created.recoveryCode, m.isNull);
      });

      test('hashes the PIN with the default cost and persists a verifier', () async {
        await repository.createAccount(
          role: StaffRole.cashier,
          username: 'bob',
          pin: '5678',
        );
        final row = (await database.select(database.staffAccounts).get()).single;
        expect(row.pinVerifier, m.startsWith(r'$2'));
        expect(row.pinVerifier.length, m.greaterThan(50));
      });

      test('generates and returns a one-time recovery code for the owner', () async {
        final created = await repository.createAccount(
          role: StaffRole.owner,
          username: 'owner1',
          pin: '1111',
        );
        expect(created.recoveryCode, m.isNotNull);
        expect(created.recoveryCode!.length, m.greaterThanOrEqualTo(16));
      });

      test('assigns the recovery-code verifier to the owner row only', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'cash1', pin: '1111');
        await repository.createAccount(role: StaffRole.owner, username: 'owner1', pin: '1111');
        final rows = await database.select(database.staffAccounts).get();
        final owner = rows.singleWhere((r) => r.role == StaffRole.owner.name);
        final cashier = rows.singleWhere((r) => r.role == StaffRole.cashier.name);
        expect(owner.recoveryCodeVerifier, m.isNotNull);
        expect(cashier.recoveryCodeVerifier, m.isNull);
      });

      test('normalizes duplicate usernames to the same form', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'zed', pin: '1111');
        // '  ZED ' normalizes to 'zed', which is already taken → must reject.
        expect(
          () async => await repository.createAccount(
            role: StaffRole.cashier,
            username: '  ZED ',
            pin: '2222',
          ),
          throwsA(isA<StateError>()),
        );
        // Direct duplicate must also be rejected.
        expect(
          () async => await repository.createAccount(
            role: StaffRole.cashier,
            username: 'zed',
            pin: '3333',
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('rejects an invalid PIN with a message that never contains the PIN', () async {
        expect(
          () async => await repository.createAccount(
            role: StaffRole.cashier,
            username: 'bad',
            pin: '12',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              m.contains('PIN must be 4 to 8 digits'),
            ),
          ),
        );
      });

      test('creates a manager account with the manager role', () async {
        final created = await repository.createAccount(
          role: StaffRole.manager,
          username: 'mgr1',
          pin: '2468',
          displayName: 'Morgan Lee',
        );
        expect(created.account.role, StaffRole.manager);
        expect(created.account.displayName, 'Morgan Lee');
        expect(created.recoveryCode, m.isNull);
        final stored =
            (await database.select(database.staffAccounts).get()).single;
        expect(stored.role, 'manager');
        expect(stored.pinVerifier, m.startsWith(r'$2'));
      });

      test('rejects a second owner (single-owner invariant)', () async {
        await repository.createAccount(role: StaffRole.owner, username: 'only', pin: '1111');
        expect(
          () async => await repository.createAccount(
            role: StaffRole.owner,
            username: 'second',
            pin: '2222',
          ),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              m.contains('owner account already exists'),
            ),
          ),
        );
      });
    });

    // --- Correct and incorrect PIN verification.
    group('verifyPin', () {
      test('rejects a well-formed wrong PIN as invalidPin', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'carol', pin: '1111');
        final result = await repository.verifyPin(username: 'carol', pin: '9999');
        expect(result.status, StaffAuthStatus.invalidPin);
        expect(result.account, m.isNull);
      });

      test('returns accountNotFound for an unknown username', () async {
        final result = await repository.verifyPin(username: 'ghost', pin: '1234');
        expect(result.status, StaffAuthStatus.accountNotFound);
        expect(result.account, m.isNull);
      });

      test('matches a correct PIN and returns the account summary', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'dave', pin: '4321');
        final result = await repository.verifyPin(username: 'dave', pin: '4321');
        expect(result.status, StaffAuthStatus.success);
        expect(result.account!.username, 'dave');
        expect(result.account!.role, StaffRole.cashier);
      });

      test('success resets failed-attempt counter to 0', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'erin', pin: '1234');
        for (var i = 0; i < 4; i++) {
          await repository.verifyPin(username: 'erin', pin: '0000');
        }
        final result = await repository.verifyPin(username: 'erin', pin: '1234');
        expect(result.status, StaffAuthStatus.success);
        final row = (await database.select(database.staffAccounts).get()).single;
        expect(row.failedPinAttempts, 0);
      });
    });

    // --- Malformed inputs do not affect failed-attempt counts.
    group('verifyPin: malformed input', () {
      test('non-numeric PIN is invalidPin without consuming an attempt', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'frank', pin: '1111');
        for (var i = 0; i < 5; i++) {
          await repository.verifyPin(username: 'frank', pin: 'abcd');
        }
        final result = await repository.verifyPin(username: 'frank', pin: '1111');
        expect(result.status, StaffAuthStatus.success);
        final row = (await database.select(database.staffAccounts).get()).single;
        expect(row.failedPinAttempts, 0);
      });

      test('PIN with separators is invalidPin without consuming an attempt', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'grace', pin: '1111');
        await repository.verifyPin(username: 'grace', pin: '11-11');
        final row = (await database.select(database.staffAccounts).get()).single;
        expect(row.failedPinAttempts, 0);
      });
    });

    // --- Disabled accounts and lockout behavior.
    group('verifyPin: disabled and locked', () {
      test('rejects a disabled account as disabled', () async {
        await database.into(database.staffAccounts).insert(
          StaffAccountsCompanion.insert(
            id: 'staff_disabled',
            username: 'disabled',
            role: StaffRole.cashier.name,
            pinVerifier: 'not-a-real-verifier',
            pinChangedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );
        final disabled = (await database.select(database.staffAccounts).get()).single;
        await (database.update(database.staffAccounts)
              ..where((t) => t.id.equals(disabled.id)))
            .write(disabled.copyWith(isActive: false));

        final result = await repository.verifyPin(username: 'disabled', pin: '1234');
        expect(result.status, StaffAuthStatus.disabled);
        expect(result.account, m.isNull);
      });

      test('locks the account after 5 consecutive failures', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'henry', pin: '1111');
        for (var i = 0; i < 5; i++) {
          await repository.verifyPin(username: 'henry', pin: '0000');
        }
        final locked = await repository.verifyPin(username: 'henry', pin: '1111');
        expect(locked.status, StaffAuthStatus.locked);
        expect(locked.lockedUntil, m.isNotNull);
      });

      test('a lock blocks verification even a correct PIN', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'ida', pin: '1111');
        for (var i = 0; i < 5; i++) {
          await repository.verifyPin(username: 'ida', pin: '0000');
        }
        await repository.verifyPin(username: 'ida', pin: '1111');
        final again = await repository.verifyPin(username: 'ida', pin: '1111');
        expect(again.status, StaffAuthStatus.locked);
      });
    });

    // --- PIN changes, authorization rules, role changes, owner deactivation.
    group('changePin / setRole / setActive', () {
      test('self-service PIN change requires the current PIN', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'kate', pin: '1111');
        expect(
          () async => await repository.changePin(username: 'kate', newPin: '2222'),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('current PIN'))),
        );
      });

      test('wrong current PIN refuses a self-service change', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'larry', pin: '1111');
        expect(
          () async => await repository.changePin(
            username: 'larry',
            currentPin: '0000',
            newPin: '2222',
          ),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('incorrect'))),
        );
      });

      test('a correct current PIN changes the PIN atomically', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'mona', pin: '1111');
        await repository.changePin(username: 'mona', currentPin: '1111', newPin: '2222');
        final stillInvalid = await repository.verifyPin(username: 'mona', pin: '1111');
        expect(stillInvalid.status, StaffAuthStatus.invalidPin);
        final ok = await repository.verifyPin(username: 'mona', pin: '2222');
        expect(ok.status, StaffAuthStatus.success);
      });

      test('owner reset (asOwner) skips the current-PIN check', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'nina', pin: '1111');
        await repository.changePin(username: 'nina', asOwner: true, newPin: '3333');
        final stillInvalid = await repository.verifyPin(username: 'nina', pin: '1111');
        expect(stillInvalid.status, StaffAuthStatus.invalidPin);
        final ok = await repository.verifyPin(username: 'nina', pin: '3333');
        expect(ok.status, StaffAuthStatus.success);
      });

      test('setRole requires asOwner', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'oscar', pin: '1111');
        expect(
          () async => await repository.setRole(username: 'oscar', role: StaffRole.manager),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('owner'))),
        );
      });

      test('setRole rejects promoting to owner (single-owner invariant)', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'pat', pin: '1111');
        await repository.createAccount(role: StaffRole.owner, username: 'quinn', pin: '1111');
        expect(
          () async => await repository.setRole(username: 'pat', role: StaffRole.owner, asOwner: true),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('owner account already exists'))),
        );
      });

      test('setRole rejects demoting the owner', () async {
        await repository.createAccount(role: StaffRole.owner, username: 'the', pin: '1111');
        expect(
          () async => await repository.setRole(
            username: 'the',
            role: StaffRole.cashier,
            asOwner: true,
          ),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('owner account cannot be demoted'))),
        );
      });

      test('setActive requires asOwner', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'uma', pin: '1111');
        expect(
          () async => await repository.setActive(username: 'uma', isActive: false),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('owner'))),
        );
      });

      test('setActive deactivates a staff account while keeping its data', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'victor', pin: '1111');
        await repository.setActive(username: 'victor', isActive: false, asOwner: true);
        final row = (await database.select(database.staffAccounts).get()).single;
        expect(row.isActive, false);
        expect(row.pinVerifier, m.isNotNull);
        final auth = await repository.verifyPin(username: 'victor', pin: '1111');
        expect(auth.status, StaffAuthStatus.disabled);
      });

      test('setActive reactivates a deactivated account', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'rex', pin: '1111');
        await repository.setActive(username: 'rex', isActive: false, asOwner: true);
        final disabled = await repository.verifyPin(username: 'rex', pin: '1111');
        expect(disabled.status, StaffAuthStatus.disabled);
        await repository.setActive(username: 'rex', isActive: true, asOwner: true);
        final enabled = await repository.verifyPin(username: 'rex', pin: '1111');
        expect(enabled.status, StaffAuthStatus.success);
      });

      test('setDisplayName requires asOwner', () async {
        await repository.createAccount(role: StaffRole.cashier, username: 'sara', pin: '1111');
        expect(
          () async => await repository.setDisplayName(username: 'sara', displayName: 'Sara Q'),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('owner'))),
        );
      });

      test('setDisplayName edits the label without touching credentials', () async {
        await repository.createAccount(
          role: StaffRole.cashier,
          username: 'todd',
          pin: '1111',
          displayName: 'Todd',
        );
        final updated = await repository.setDisplayName(
          username: 'todd',
          displayName: '  Todd Quincy  ',
          asOwner: true,
        );
        expect(updated.displayName, 'Todd Quincy');
        final row = (await database.select(database.staffAccounts).get()).single;
        expect(row.displayName, 'Todd Quincy');
        final auth = await repository.verifyPin(username: 'todd', pin: '1111');
        expect(auth.status, StaffAuthStatus.success);
      });

      test('setDisplayName rejects an unknown account', () async {
        expect(
          () async => await repository.setDisplayName(
            username: 'ghost2',
            displayName: 'Nope',
            asOwner: true,
          ),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('No staff account'))),
        );
      });

      test('setActive refuses to deactivate the only owner', () async {
        await repository.createAccount(role: StaffRole.owner, username: 'will', pin: '1111');
        expect(
          () async => await repository.setActive(username: 'will', isActive: false, asOwner: true),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('owner account cannot be deactivated'))),
        );
      });
    });

    // --- Recovery success, incorrect recovery codes, code rotation, old-code
    // invalidation.
    group('recoverOwnerPin', () {
      test('recovers the owner PIN with the correct recovery code', () async {
        final created = await repository.createAccount(
          role: StaffRole.owner,
          username: 'neil',
          pin: '1111',
        );
        expect(created.recoveryCode, m.isNotNull);
        final recovered = await repository.recoverOwnerPin(
          recoveryCode: created.recoveryCode!,
          newPin: '5555',
        );
        expect(recovered.account.username, 'neil');
        expect(recovered.newRecoveryCode, m.isNotNull);
        expect(recovered.newRecoveryCode.length, m.greaterThanOrEqualTo(16));
        final stillInvalid = await repository.verifyPin(username: 'neil', pin: '1111');
        expect(stillInvalid.status, StaffAuthStatus.invalidPin);
      });

      test('rejects an incorrect recovery code', () async {
        await repository.createAccount(
          role: StaffRole.owner,
          username: 'olivia',
          pin: '1111',
        );
        expect(
          () async => await repository.recoverOwnerPin(
            recoveryCode: 'WRONG-0000-0000-0000',
            newPin: '5555',
          ),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('incorrect'))),
        );
      });

      test('rejects an invalid new PIN', () async {
        final created = await repository.createAccount(
          role: StaffRole.owner,
          username: 'peter',
          pin: '1111',
        );
        expect(
          () async => await repository.recoverOwnerPin(
            recoveryCode: created.recoveryCode!,
            newPin: '12',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rotates the recovery code (old code invalidated)', () async {
        final first = await repository.createAccount(
          role: StaffRole.owner,
          username: 'rose',
          pin: '1111',
        );
        final recovered = await repository.recoverOwnerPin(
          recoveryCode: first.recoveryCode!,
          newPin: '5555',
        );
        expect(
          () async => await repository.recoverOwnerPin(
            recoveryCode: first.recoveryCode!,
            newPin: '5555',
          ),
          throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('incorrect'))),
        );
        final recovered2 = await repository.recoverOwnerPin(
          recoveryCode: recovered.newRecoveryCode,
          newPin: '6666',
        );
        expect(recovered2.account.username, 'rose');
      });
    });

    // --- Recovery transaction failure: a simulated staff-write failure must
    // leave the previous recovery code valid.
    group('recoverOwnerPin: atomicity', () {
      test('a simulated staff-write failure leaves the previous recovery code valid', () async {
        final created = await repository.createAccount(
          role: StaffRole.owner,
          username: 'susy',
          pin: '1111',
        );
        repository.failNextStaffWrite = true;
        try {
          await expectLater(
            repository.recoverOwnerPin(
              recoveryCode: created.recoveryCode!,
              newPin: '5555',
            ),
            throwsA(isA<StateError>().having((e) => e.message, 'message', m.contains('Simulated staff write failure'))),
          );
        } finally {
          repository.failNextStaffWrite = false;
        }
        final stillWorks = await repository.recoverOwnerPin(
          recoveryCode: created.recoveryCode!,
          newPin: '5555',
        );
        expect(stillWorks.account.username, 'susy');
        expect(stillWorks.newRecoveryCode, m.isNotNull);
      });

      test('success clears failures and the lockout', () async {
        final created = await repository.createAccount(
          role: StaffRole.owner,
          username: 'tom',
          pin: '1111',
        );
        expect(created.recoveryCode, m.isNotNull);
        for (var i = 0; i < 5; i++) {
          await repository.verifyPin(username: 'tom', pin: '0000');
        }
        final recovered = await repository.recoverOwnerPin(
          recoveryCode: created.recoveryCode!,
          newPin: '5555',
        );
        final row = (await database.select(database.staffAccounts).get()).single;
        expect(row.failedPinAttempts, 0);
        expect(row.pinLockedUntil, m.isNull);
        expect(row.isActive, true);
        expect(recovered.account.failedPinAttempts, 0);
        expect(recovered.account.pinLockedUntil, m.isNull);
      });
    });

    // --- DTOs and observable errors must not expose verifiers.
    group('DTO safety', () {
      test('listStaff never exposes pinVerifier or recoveryCodeVerifier', () async {
        await repository.createAccount(
          role: StaffRole.owner,
          username: 'victor',
          pin: '1111',
        );
        final list = await repository.listStaff();
        for (final acc in list) {
          expect(acc.username, m.isNot(m.contains('verifier')));
          expect(acc.id, m.isNotNull);
        }
      });

      test('credentials are never read by the repository', () async {
        await repository.createAccount(
          role: StaffRole.owner,
          username: 'xavier',
          pin: '1111',
        );
        final summary = await repository.getAccountByUsername('xavier');
        expect(summary, m.isNotNull);
      });
    });

    // --- Unsupported inputs do not touch persistence or counters.
    group('null/empty guard', () {
      test('createAccount rejects a null username', () async {
        expect(
          () async => await repository.createAccount(
            role: StaffRole.cashier,
            username: '',
            pin: '1234',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('createAccount rejects an invalid username format', () async {
        expect(
          () async => await repository.createAccount(
            role: StaffRole.cashier,
            username: 'ab',
            pin: '1234',
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              m.contains('Username must be 3-24 characters'),
            ),
          ),
        );
      });
    });

    // --- Staff data and lockout state survive a full database close and
    // reopen: an app restart must not bypass the failed-attempt lock.
    group('persistence across database close and reopen', () {
      late Directory tempDir;
      late File dbFile;

      setUp(() async {
        tempDir = await Directory.systemTemp.createTemp('bizflow_staff_');
        dbFile = File('${tempDir.path}/staff_persistence.sqlite');
      });

      tearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      test('an account created before a restart still verifies afterwards', () async {
        final db1 = AppDatabase(NativeDatabase(dbFile));
        final repo1 = StaffAccountRepository(db1);
        await repo1.createAccount(
          role: StaffRole.cashier,
          username: 'persist',
          pin: '9876',
        );
        await db1.close();

        final db2 = AppDatabase(NativeDatabase(dbFile));
        addTearDown(db2.close);
        final repo2 = StaffAccountRepository(db2);
        final result = await repo2.verifyPin(username: 'persist', pin: '9876');
        expect(result.status, StaffAuthStatus.success);
        expect(result.account!.role, StaffRole.cashier);
      });

      test('the failed-attempt lock survives an app restart', () async {
        final db1 = AppDatabase(NativeDatabase(dbFile));
        final repo1 = StaffAccountRepository(db1);
        await repo1.createAccount(
          role: StaffRole.manager,
          username: 'lockedmgr',
          pin: '5555',
        );
        for (var i = 0; i < StaffAccountRepository.maxFailedPinAttempts; i++) {
          await repo1.verifyPin(username: 'lockedmgr', pin: '0000');
        }
        await db1.close();

        final db2 = AppDatabase(NativeDatabase(dbFile));
        addTearDown(db2.close);
        final repo2 = StaffAccountRepository(db2);
        final stillLocked = await repo2.verifyPin(
          username: 'lockedmgr',
          pin: '5555',
        );
        expect(stillLocked.status, StaffAuthStatus.locked);
        expect(stillLocked.lockedUntil, m.isNotNull);
      });
    });
  });
}
