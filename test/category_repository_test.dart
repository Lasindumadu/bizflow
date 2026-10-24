import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/core/session/session_controller.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/category_repository.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';

void main() {
  late AppDatabase database;
  late StaffAccountRepository staffRepository;
  late CategoryRepository categoryRepository;

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

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    staffRepository = StaffAccountRepository(database);
    categoryRepository = CategoryRepository(database);
    sessionController.signOut();
  });

  tearDown(() async {
    sessionController.signOut();
    await database.close();
  });

  group('Category repository - authorization', () {
    test('owner can add and update categories', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner1');
      sessionController.signIn(owner);

      await categoryRepository.addCategory(id: 'cat-1', name: 'Electronics');
      await categoryRepository.updateCategory(id: 'cat-1', name: 'Electronics & Computers');

      final categories = await categoryRepository.getCategories();
      expect(categories, hasLength(1));
      expect(categories.first.name, 'Electronics & Computers');
    });

    test('manager can add and update categories', () async {
      final manager = await createStaff(role: StaffRole.manager, username: 'mgr1');
      sessionController.signIn(manager);

      await categoryRepository.addCategory(id: 'cat-1', name: 'Groceries');
      await categoryRepository.updateCategory(id: 'cat-1', name: 'Fresh Groceries');

      final categories = await categoryRepository.getCategories();
      expect(categories, hasLength(1));
      expect(categories.first.name, 'Fresh Groceries');
    });

    test('cashier cannot add categories', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash1');
      sessionController.signIn(cashier);

      expect(
        () => categoryRepository.addCategory(id: 'cat-1', name: 'Electronics'),
        throwsA(isA<StateError>()),
      );
    });

    test('cashier cannot update categories', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash2');
      sessionController.signIn(cashier);

      expect(
        () => categoryRepository.updateCategory(id: 'cat-1', name: 'Electronics'),
        throwsA(isA<StateError>()),
      );
    });

    test('only owner can delete a category', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner2');
      final manager = await createStaff(role: StaffRole.manager, username: 'mgr2');

      sessionController.signIn(owner);
      await categoryRepository.addCategory(id: 'cat-1', name: 'Electronics');

      // Manager cannot delete.
      sessionController.signOut();
      sessionController.signIn(manager);
      expect(
        () => categoryRepository.deleteCategory('cat-1'),
        throwsA(isA<StateError>()),
      );

      // Owner can delete.
      sessionController.signOut();
      sessionController.signIn(owner);
      await categoryRepository.deleteCategory('cat-1');

      final categories = await categoryRepository.getCategories();
      expect(categories, isEmpty);
    });

    test('missing session with login required rejects category operations', () async {
      await createStaff(role: StaffRole.owner, username: 'owner3');
      await staffRepository.setLoginRequired(
        enable: true,
        actingUsername: 'owner3',
        asOwner: true,
      );

      sessionController.signOut();

      expect(
        () => categoryRepository.addCategory(id: 'cat-1', name: 'Electronics'),
        throwsA(isA<StateError>()),
      );
    });

    test('locked session rejects category operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner4');
      sessionController.signIn(owner);
      sessionController.lock();

      expect(
        () => categoryRepository.addCategory(id: 'cat-1', name: 'Electronics'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('locked'),
          ),
        ),
      );
    });

    test('deactivated staff cannot authorize category operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner5');
      final manager = await createStaff(role: StaffRole.manager, username: 'mgr5');

      sessionController.signIn(owner);
      await staffRepository.setActive(
        username: manager.username,
        isActive: false,
        asOwner: true,
      );

      sessionController.signOut();
      sessionController.signIn(manager);

      Object? caught;
      try {
        await categoryRepository.addCategory(id: 'cat-1', name: 'Electronics');
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<StateError>());
      expect(sessionController.isAuthenticated, isFalse);
    });

    test('failed authorization performs no database mutation', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash3');
      sessionController.signIn(cashier);

      try {
        await categoryRepository.addCategory(id: 'cat-1', name: 'Electronics');
      } catch (_) {
        // Expected — authorization failure.
      }

      final categories = await categoryRepository.getCategories();
      expect(categories, isEmpty);
    });
  });
}