import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bizflow/core/session/session_controller.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/product_repository.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';
import 'package:bizflow/models/product.dart';

void main() {
  late AppDatabase database;
  late ProductRepository repository;
  late StaffAccountRepository staffRepository;

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
    repository = ProductRepository(database);
    staffRepository = StaffAccountRepository(database);
    sessionController.signOut();
  });

  tearDown(() async {
    sessionController.signOut();
    await database.close();
  });

  group('ProductRepository barcode handling', () {
    test('saves and retrieves a barcode including leading zeros', () async {
      const product = Product(
        id: 'barcode-test-1',
        name: 'Test Product',
        sku: 'TEST-001',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567890',
      );

      await repository.addProduct(product);

      final savedProduct = await repository.getProductById('barcode-test-1');

      expect(savedProduct, isNotNull);
      expect(savedProduct!.barcode, '001234567890');
    });

    test('updates an existing product barcode', () async {
      const product = Product(
        id: 'barcode-test-2',
        name: 'Test Product',
        sku: 'TEST-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '111222333',
      );

      await repository.addProduct(product);

      const updatedProduct = Product(
        id: 'barcode-test-2',
        name: 'Test Product',
        sku: 'TEST-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '999888777',
      );

      await repository.updateProduct(updatedProduct);

      final savedProduct = await repository.getProductById('barcode-test-2');

      expect(savedProduct, isNotNull);
      expect(savedProduct!.barcode, '999888777');
    });

    test('rejects a barcode already assigned to another product', () async {
      const firstProduct = Product(
        id: 'duplicate-test-1',
        name: 'First Product',
        sku: 'DUP-001',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567890',
      );

      const secondProduct = Product(
        id: 'duplicate-test-2',
        name: 'Second Product',
        sku: 'DUP-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567890',
      );

      await repository.addProduct(firstProduct);

      await expectLater(
        repository.addProduct(secondProduct),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'This barcode is already assigned to another product.',
          ),
        ),
      );
    });

    test('rejects assigning another product barcode during editing', () async {
      const firstProduct = Product(
        id: 'duplicate-edit-1',
        name: 'First Product',
        sku: 'EDIT-001',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '111222333',
      );

      const secondProduct = Product(
        id: 'duplicate-edit-2',
        name: 'Second Product',
        sku: 'EDIT-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '444555666',
      );

      await repository.addProduct(firstProduct);
      await repository.addProduct(secondProduct);

      const updatedSecondProduct = Product(
        id: 'duplicate-edit-2',
        name: 'Second Product',
        sku: 'EDIT-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '111222333',
      );

      await expectLater(
        repository.updateProduct(updatedSecondProduct),
        throwsA(isA<StateError>()),
      );

      final unchangedProduct = await repository.getProductById(
        'duplicate-edit-2',
      );

      expect(unchangedProduct!.barcode, '444555666');
    });

    test('allows a product to retain its own barcode when edited', () async {
      const product = Product(
        id: 'same-barcode-edit',
        name: 'Editable Product',
        sku: 'EDIT-003',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '009988776655',
      );

      await repository.addProduct(product);

      await expectLater(repository.updateProduct(product), completes);

      final savedProduct = await repository.getProductById('same-barcode-edit');

      expect(savedProduct!.barcode, '009988776655');
    });
  });

  group('ProductRepository - authorization', () {
    test('owner can add and update products', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner10');
      sessionController.signIn(owner);

      const product = Product(
        id: 'auth-prod-1',
        name: 'Auth Product',
        sku: 'AUTH-001',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567890',
      );

      await repository.addProduct(product);
      await repository.updateProduct(product);

      final saved = await repository.getProductById('auth-prod-1');
      expect(saved, isNotNull);
      expect(saved!.name, 'Auth Product');
    });

    test('manager can add and update products', () async {
      final manager = await createStaff(role: StaffRole.manager, username: 'mgr10');
      sessionController.signIn(manager);

      const product = Product(
        id: 'auth-prod-2',
        name: 'Manager Product',
        sku: 'AUTH-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567891',
      );

      await repository.addProduct(product);
      await repository.updateProduct(product);

      final saved = await repository.getProductById('auth-prod-2');
      expect(saved, isNotNull);
      expect(saved!.name, 'Manager Product');
    });

    test('cashier cannot add products', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash7');
      sessionController.signIn(cashier);

      const product = Product(
        id: 'auth-prod-3',
        name: 'Cashier Product',
        sku: 'AUTH-003',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567892',
      );

      expect(
        () => repository.addProduct(product),
        throwsA(isA<StateError>()),
      );

      final saved = await repository.getProductById('auth-prod-3');
      expect(saved, isNull);
    });

    test('cashier cannot update products', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash8');
      sessionController.signIn(cashier);

      const product = Product(
        id: 'auth-prod-4',
        name: 'Cashier Product 2',
        sku: 'AUTH-004',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567893',
      );

      expect(
        () => repository.updateProduct(product),
        throwsA(isA<StateError>()),
      );
    });

    test('only owner can delete products', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner11');
      final manager = await createStaff(role: StaffRole.manager, username: 'mgr11');

      sessionController.signIn(owner);
      const product = Product(
        id: 'auth-prod-5',
        name: 'To Delete',
        sku: 'AUTH-005',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567894',
      );
      await repository.addProduct(product);

      sessionController.signOut();
      sessionController.signIn(manager);
      expect(
        () => repository.deleteProduct('auth-prod-5'),
        throwsA(isA<StateError>()),
      );

      sessionController.signOut();
      sessionController.signIn(owner);
      await repository.deleteProduct('auth-prod-5');

      final saved = await repository.getProductById('auth-prod-5');
      expect(saved, isNull);
    });


    test('changeStock remains owner+manager only', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash9');
      sessionController.signIn(cashier);

      expect(
        () => repository.changeStock(
          productId: 'auth-prod-x',
          quantity: 5,
          type: 'STOCK_IN',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('missing session with login required rejects product operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner12');
      sessionController.signIn(owner);
      await staffRepository.setLoginRequired(
        enable: true,
        actingUsername: 'owner12',
        asOwner: true,
      );
      sessionController.signOut();

      const product = Product(
        id: 'auth-prod-6',
        name: 'Should Fail',
        sku: 'AUTH-006',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567895',
      );

      expect(
        () => repository.addProduct(product),
        throwsA(isA<StateError>()),
      );
    });

    test('locked session rejects product operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner13');
      sessionController.signIn(owner);
      sessionController.lock();

      const product = Product(
        id: 'auth-prod-7',
        name: 'Should Fail',
        sku: 'AUTH-007',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567896',
      );

      expect(
        () => repository.addProduct(product),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('locked'),
          ),
        ),
      );
    });

    test('deactivated staff cannot authorize product operations', () async {
      final owner = await createStaff(role: StaffRole.owner, username: 'owner14');
      final manager = await createStaff(role: StaffRole.manager, username: 'mgr14');

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
        const product = Product(
          id: 'auth-prod-8',
          name: 'Should Fail',
          sku: 'AUTH-008',
          category: 'Test',
          purchasePrice: 100,
          sellingPrice: 150,
          stockQuantity: 10,
          lowStockThreshold: 2,
          barcode: '001234567897',
        );
        await repository.addProduct(product);
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<StateError>());
      expect(sessionController.isAuthenticated, isFalse);
    });

    test('failed authorization performs no database mutation', () async {
      final cashier = await createStaff(role: StaffRole.cashier, username: 'cash10');
      sessionController.signIn(cashier);

      const product = Product(
        id: 'auth-prod-9',
        name: 'Should Not Exist',
        sku: 'AUTH-009',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567898',
      );

      try {
        await repository.addProduct(product);
      } catch (_) {
        // Expected — authorization failure.
      }

      final saved = await repository.getProductById('auth-prod-9');
      expect(saved, isNull);
    });
  });
}