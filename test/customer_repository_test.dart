import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/core/session/session_controller.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/customer_repository.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';

void main() {
  late AppDatabase database;
  late StaffAccountRepository staffRepository;
  late CustomerRepository customerRepository;

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

  Future<void> enableLogin(String actingUsername) async {
    await staffRepository.setLoginRequired(
      enable: true,
      actingUsername: actingUsername,
      asOwner: true,
    );
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    staffRepository = StaffAccountRepository(database);
    customerRepository = CustomerRepository(database);
    sessionController.signOut();
  });

  tearDown(() async {
    sessionController.signOut();
    await database.close();
  });

  group('Customer repository - authorization', () {
    test('any authenticated staff can add and update customers', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash4');
      sessionController.signIn(cashier);

      await customerRepository.addCustomer(
        id: 'cust-1',
        name: 'Test Customer',
        phone: '1234567890',
      );
      await customerRepository.updateCustomer(
        id: 'cust-1',
        name: 'Updated Customer',
        phone: '0987654321',
      );

      final customer = await customerRepository.getCustomerById('cust-1');
      expect(customer, isNotNull);
      expect(customer!.name, 'Updated Customer');
      expect(customer.phone, '0987654321');
    });

    test('login disabled allows add and update customers with null staff', () async {
      sessionController.signOut();

      await customerRepository.addCustomer(
        id: 'cust-2',
        name: 'Legacy Customer',
      );
      await customerRepository.updateCustomer(
        id: 'cust-2',
        name: 'Legacy Updated',
      );

      final customer = await customerRepository.getCustomerById('cust-2');
      expect(customer, isNotNull);
      expect(customer!.name, 'Legacy Updated');
    });

    test('missing session with login required rejects customer operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner6');
      sessionController.signIn(owner);
      await enableLogin('owner6');
      sessionController.signOut();

      expect(
        () => customerRepository.addCustomer(
          id: 'cust-3',
          name: 'Should Fail',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('locked session rejects customer operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner7');
      sessionController.signIn(owner);
      sessionController.lock();

      expect(
        () => customerRepository.addCustomer(
          id: 'cust-4',
          name: 'Should Fail',
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

    test('deactivated staff cannot authorize customer operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner8');
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash5');

      sessionController.signIn(owner);
      await staffRepository.setActive(
        username: cashier.username,
        isActive: false,
        asOwner: true,
      );

      sessionController.signOut();
      sessionController.signIn(cashier);

      Object? caught;
      try {
        await customerRepository.addCustomer(
          id: 'cust-5',
          name: 'Should Fail',
        );
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<StateError>());
      expect(sessionController.isAuthenticated, isFalse);
    });

    test('only owner can delete customers', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner9');
      final manager = await createStaff(role: StaffRole.manager, username: 'mgr9');

      sessionController.signIn(owner);
      await customerRepository.addCustomer(id: 'cust-6', name: 'To Delete');

      sessionController.signOut();
      sessionController.signIn(manager);
      expect(
        () => customerRepository.deleteCustomer('cust-6'),
        throwsA(isA<StateError>()),
      );

      sessionController.signOut();
      sessionController.signIn(owner);
      await customerRepository.deleteCustomer('cust-6');

      final customer = await customerRepository.getCustomerById('cust-6');
      expect(customer, isNull);
    });

    test('failed authorization performs no database mutation', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash6');
      sessionController.signIn(cashier);

      try {
        await customerRepository.deleteCustomer('cust-nonexistent');
      } catch (_) {
        // Expected — authorization failure (owner only).
      }

      final all = await customerRepository.getCustomers();
      expect(all, isEmpty);
    });
  });
}