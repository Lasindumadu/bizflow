import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/core/session/session_controller.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/business_settings_repository.dart';
import 'package:bizflow/data/repositories/customer_credit_repository.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';

void main() {
  late AppDatabase database;
  late StaffAccountRepository staffRepository;
  late BusinessSettingsRepository settingsRepository;
  late CustomerCreditRepository creditRepository;

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

  Future<void> enableLogin() async {
    await settingsRepository.saveSettings(
      businessName: 'Test Store',
      address: '',
      phone: '',
      email: '',
      currency: 'LKR',
      loginRequired: true,
    );
  }

  Future<void> seedCustomer(String id) async {
    await database.into(database.customers).insert(
      CustomersCompanion.insert(
        id: id,
        name: 'Test Customer',
      ),
    );
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    staffRepository = StaffAccountRepository(database);
    settingsRepository = BusinessSettingsRepository(database);
    creditRepository = CustomerCreditRepository(database);
    sessionController.signOut();
  });

  tearDown(() async {
    sessionController.signOut();
    await database.close();
  });

  group('Customer credit - authorization', () {
    test('login disabled allows operation with null createdBy', () async {
      await seedCustomer('cust-1');
      final account = await creditRepository.ensureCreditAccount('cust-1');

      await creditRepository.recordPayment(
        customerId: 'cust-1',
        amount: 5,
        paymentReference: 'P-1',
        createdBy: 999, // spoofed, must be ignored
      );

      final txns = await creditRepository.getTransactions(account.id);
      expect(txns, hasLength(1));
      expect(txns.first.createdBy, isNull);
    });

    test('locked session cannot record payment', () async {
      await seedCustomer('cust-1');
      await creditRepository.ensureCreditAccount('cust-1');

      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      sessionController.lock();

      await expectLater(
        () => creditRepository.recordPayment(
          customerId: 'cust-1',
          amount: 5,
          paymentReference: 'P-1',
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

    test('unlocking restores ability to operate', () async {
      await seedCustomer('cust-1');
      await creditRepository.ensureCreditAccount('cust-1');

      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      sessionController.lock();
      sessionController.unlock();

      await expectLater(
        creditRepository.recordPayment(
          customerId: 'cust-1',
          amount: 5,
          paymentReference: 'P-2',
        ),
        completes,
      );
    });

    test('no session + login required throws', () async {
      await seedCustomer('cust-1');
      await enableLogin();

      await expectLater(
        () => creditRepository.ensureCreditAccount('cust-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('session resolves createdBy and ignores spoofed value', () async {
      await seedCustomer('cust-1');

      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);

      final account = await creditRepository.ensureCreditAccount('cust-1');

      await creditRepository.recordPayment(
        customerId: 'cust-1',
        amount: 5,
        paymentReference: 'P-3',
        createdBy: 12345, // spoofed
      );

      final txns = await creditRepository.getTransactions(account.id);
      expect(txns, hasLength(1));
      expect(txns.first.createdBy, int.tryParse(owner.id));
    });

    test('deactivated account cannot authorize', () async {
      await seedCustomer('cust-1');

      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      final manager = await createStaff(
        role: StaffRole.manager,
        username: 'manager1',
      );

      // Deactivate the manager account using owner authority.
      sessionController.signIn(owner);
      await staffRepository.setActive(
        username: manager.username,
        isActive: false,
        asOwner: true,
      );

      // Stale session for the now-deactivated manager.
      sessionController.signOut();
      sessionController.signIn(manager);

      Object? caught;
      try {
        await creditRepository.ensureCreditAccount('cust-1');
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<StateError>());
      expect(sessionController.isAuthenticated, isFalse);
    });

    test('addTransaction ignores caller createdBy when session present', () async {
      await seedCustomer('cust-1');

      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);

      final account = await creditRepository.ensureCreditAccount('cust-1');

      await creditRepository.addTransaction(
        accountId: account.id,
        type: 'adjustment',
        amount: 3,
        createdBy: 999,
      );

      final txns = await creditRepository.getTransactions(account.id);
      expect(txns.first.createdBy, int.tryParse(owner.id));
    });
  });
}
