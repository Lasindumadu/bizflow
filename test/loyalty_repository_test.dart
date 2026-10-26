import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/core/session/session_controller.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/customer_repository.dart';
import 'package:bizflow/data/repositories/loyalty_repository.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';

void main() {
  late AppDatabase database;
  late StaffAccountRepository staffRepository;
  late CustomerRepository customerRepository;
  late LoyaltyRepository loyaltyRepository;

  Future<void> createCustomer({required String id}) async {
    await customerRepository.addCustomer(
      id: id,
      name: 'Test Customer',
      phone: '1234567890',
    );
  }

  Future<dynamic> createStaff({
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
    loyaltyRepository = LoyaltyRepository(database);
    sessionController.signOut();
  });

  tearDown(() async {
    sessionController.signOut();
    await database.close();
  });

  group('Loyalty repository - authorization', () {
    test('owner can earn, redeem, and refresh loyalty points', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'loy-owner');
      sessionController.signIn(owner);
      await createCustomer(id: 'cust-loy-1');

      await loyaltyRepository.earnPoints('cust-loy-1', 100);
      await loyaltyRepository.redeemPoints('cust-loy-1', 30);
      await loyaltyRepository.refreshTiers();

      final customer = await customerRepository.getCustomerById('cust-loy-1');
      expect(customer, isNotNull);
      expect(customer!.pointsBalance, 70);
      expect(customer.loyaltyPoints, 100);
    });

    test('cashier can earn and redeem loyalty points through checkout', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'loy-cash');
      sessionController.signIn(cashier);
      await createCustomer(id: 'cust-loy-2');

      await loyaltyRepository.earnPoints('cust-loy-2', 50);
      await loyaltyRepository.redeemPoints('cust-loy-2', 10);

      final customer = await customerRepository.getCustomerById('cust-loy-2');
      expect(customer!.pointsBalance, 40);
      expect(customer.loyaltyPoints, 50);
    });

    test('manager can earn and redeem loyalty points through checkout', () async {
      final manager = await createStaff(role: StaffRole.manager, username: 'loy-mgr');
      sessionController.signIn(manager);
      await createCustomer(id: 'cust-loy-3');

      await loyaltyRepository.earnPoints('cust-loy-3', 50);

      final customer = await customerRepository.getCustomerById('cust-loy-3');
      expect(customer!.loyaltyPoints, 50);
    });

    test('only owner can adjust loyalty points', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'loy-adj-owner');
      final cashier = await createStaff(role: StaffRole.cashier, username: 'loy-adj-cash');
      await createCustomer(id: 'cust-loy-adj');

      sessionController.signIn(owner);
      await loyaltyRepository.adjustPoints('cust-loy-adj', 100);

      sessionController.signOut();
      sessionController.signIn(cashier);

      expect(
        () => loyaltyRepository.adjustPoints('cust-loy-adj', -50),
        throwsA(isA<StateError>()),
      );
    });

    test('login disabled allows earn and redeem with null staff', () async {
      sessionController.signOut();
      await createCustomer(id: 'cust-loy-legacy');

      await loyaltyRepository.earnPoints('cust-loy-legacy', 40);
      await loyaltyRepository.redeemPoints('cust-loy-legacy', 10);

      final customer = await customerRepository.getCustomerById('cust-loy-legacy');
      expect(customer!.pointsBalance, 30);
      expect(customer.loyaltyPoints, 40);
    });

    test('missing session with login required rejects loyalty operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'loy-req');
      sessionController.signIn(owner);
      await createCustomer(id: 'cust-loy-req');
      await enableLogin('loy-req');
      sessionController.signOut();

      expect(
        () => loyaltyRepository.earnPoints('cust-loy-req', 10),
        throwsA(isA<StateError>()),
      );
      expect(
        () => loyaltyRepository.redeemPoints('cust-loy-req', 10),
        throwsA(isA<StateError>()),
      );
      expect(
        () => loyaltyRepository.adjustPoints('cust-loy-req', 10),
        throwsA(isA<StateError>()),
      );
      expect(
        () => loyaltyRepository.refreshTiers(),
        throwsA(isA<StateError>()),
      );
    });

    test('locked session rejects loyalty operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'loy-lock');
      sessionController.signIn(owner);
      await createCustomer(id: 'cust-loy-lock');
      sessionController.lock();

      expect(
        () => loyaltyRepository.earnPoints('cust-loy-lock', 10),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('locked'),
          ),
        ),
      );
      expect(
        () => loyaltyRepository.adjustPoints('cust-loy-lock', 10),
        throwsA(isA<StateError>()),
      );
    });

    test('deactivated staff cannot authorize loyalty operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'loy-deact-owner');
      final cashier = await createStaff(role: StaffRole.cashier, username: 'loy-deact-cash');
      await createCustomer(id: 'cust-loy-deact');

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
        await loyaltyRepository.earnPoints('cust-loy-deact', 10);
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<StateError>());
      expect(sessionController.isAuthenticated, isFalse);
    });

    test('failed loyalty adjustment performs no mutation', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'loy-nomut');
      sessionController.signIn(cashier);
      await createCustomer(id: 'cust-loy-nomut');

      try {
        await loyaltyRepository.adjustPoints('cust-loy-nomut', 999);
      } catch (_) {
        // Expected — authorization failure.
      }

      final customer = await customerRepository.getCustomerById('cust-loy-nomut');
      expect(customer!.pointsBalance, 0);
      expect(customer.loyaltyPoints, 0);
    });

    test('redeeming more than balance throws without mutating', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'loy-over');
      sessionController.signIn(owner);
      await createCustomer(id: 'cust-loy-over');

      expect(
        () => loyaltyRepository.redeemPoints('cust-loy-over', 5),
        throwsA(isA<StateError>()),
      );

      final customer = await customerRepository.getCustomerById('cust-loy-over');
      expect(customer!.pointsBalance, 0);
    });
  });
}
