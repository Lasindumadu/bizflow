import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/core/session/session_controller.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/business_settings_repository.dart';
import 'package:bizflow/data/repositories/expense_repository.dart';
import 'package:bizflow/data/repositories/product_repository.dart';
import 'package:bizflow/data/repositories/return_repository.dart';
import 'package:bizflow/data/repositories/sale_repository.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';
import 'package:bizflow/models/sale_item.dart' as model;

void main() {
  late AppDatabase database;
  late StaffAccountRepository staffRepository;
  late BusinessSettingsRepository settingsRepository;
  late SaleRepository saleRepository;
  late ReturnRepository returnRepository;
  late ProductRepository productRepository;
  late ExpenseRepository expenseRepository;

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

  Future<void> seedProduct({
    String id = 'product-1',
    int stock = 10,
  }) async {
    await database.into(database.products).insert(
      ProductsCompanion.insert(
        id: id,
        name: 'Test Product',
        sku: 'SKU-$id',
        category: 'General',
        purchasePrice: 5,
        sellingPrice: 10,
        stockQuantity: stock,
        lowStockThreshold: 2,
      ),
    );
  }

  Future<String> seedSale() async {
    const saleId = 'sale-1';
    await database.into(database.sales).insert(
      SalesCompanion.insert(
        id: saleId,
        subtotal: 10,
        total: 10,
        paidAmount: 10,
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    await database.into(database.saleItems).insert(
      SaleItemsCompanion.insert(
        id: 'item-1',
        saleId: saleId,
        productId: 'product-1',
        productName: 'Test Product',
        quantity: 1,
        unitPrice: 10,
        purchasePrice: 5,
        total: 10,
      ),
    );
    return saleId;
  }

  Future<void> completeSale() async {
    await saleRepository.completeSale(
      saleId: 'sale-1',
      subtotal: 10,
      total: 10,
      paidAmount: 10,
      createdAt: DateTime(2026, 1, 1),
      items: [
        const model.SaleItem(
          id: 'item-1',
          saleId: 'sale-1',
          productId: 'product-1',
          productName: 'Test Product',
          quantity: 1,
          unitPrice: 10,
          purchasePrice: 5,
        ),
      ],
    );
  }

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    staffRepository = StaffAccountRepository(database);
    settingsRepository = BusinessSettingsRepository(database);
    saleRepository = SaleRepository(database);
    returnRepository = ReturnRepository(database);
    productRepository = ProductRepository(database);
    expenseRepository = ExpenseRepository(database);
    sessionController.signOut();
  });

  tearDown(() async {
    sessionController.signOut();
    await database.close();
  });

  // MARK: - Attribution

  group('Phase E - Staff attribution on business records', () {
    test('sale records the acting staff member', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      await seedProduct();

      await completeSale();

      final sale = await (database.select(
        database.sales,
      )..where((t) => t.id.equals('sale-1'))).getSingle();
      expect(sale.staffId, owner.id);

      final movement = await (database.select(
        database.stockMovements,
      )..where((t) => t.productId.equals('product-1'))).getSingle();
      expect(movement.staffId, owner.id);
    });

    test('stock adjustment records the acting staff member', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      await seedProduct();

      await productRepository.changeStock(
        productId: 'product-1',
        quantity: 5,
        type: 'restock',
      );

      final movement = await (database.select(
        database.stockMovements,
      )..where((t) => t.productId.equals('product-1'))).getSingle();
      expect(movement.staffId, owner.id);
    });
    test('return and its restock movement record the acting staff member', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      await seedProduct(stock: 5);
      await seedSale();

      await returnRepository.createReturn(
        saleId: 'sale-1',
        lines: const [
          ReturnLine(
            productId: 'product-1',
            productName: 'Test Product',
            quantity: 1,
            unitPrice: 10,
            purchasePrice: 5,
          ),
        ],
        restock: true,
      );

      final record = await (database.select(
        database.saleReturns,
      )..where((t) => t.saleId.equals('sale-1'))).getSingle();
      expect(record.staffId, owner.id);

      final movement = await (database.select(
        database.stockMovements,
      )..where((t) => t.productId.equals('product-1'))).getSingle();
      expect(movement.staffId, owner.id);
    });

    test('sale cancellation restock movement records the acting staff member', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);
      await seedProduct(stock: 5);
      await seedSale();

      await saleRepository.cancelSale('sale-1');

      final movement = await (database.select(
        database.stockMovements,
      )..where((t) => t.productId.equals('product-1'))).getSingle();
      expect(movement.staffId, owner.id);
    });

    test('expense audit records the acting staff member as actor', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      sessionController.signIn(owner);

      await expenseRepository.addExpense(
        id: 'expense-1',
        title: 'Electricity',
        category: 'Utilities',
        amount: 42.5,
        date: DateTime(2026, 1, 1),
      );

      final audit = await (database.select(
        database.auditLogs,
      )..where((t) => t.action.equals('expense.create'))).getSingle();
      expect(audit.actor, 'owner1');
    });

    test('records stay unattributed when login enforcement is disabled', () async {
      // No staff account and no session: legacy single-operator behavior.
      await seedProduct();

      await completeSale();

      final sale = await (database.select(
        database.sales,
      )..where((t) => t.id.equals('sale-1'))).getSingle();
      expect(sale.staffId, isNull);
    });
  });



  // MARK: - Authorization boundaries

  group('Phase E - Authorization boundaries', () {
    test('cashier cannot record an expense', () async {
      final cashier = await createStaff(
        role: StaffRole.cashier,
        username: 'cashier1',
      );
      sessionController.signIn(cashier);

      await expectLater(
        expenseRepository.addExpense(
          title: 'Electricity',
          id: 'expense-1',

          category: 'Utilities',
          amount: 42.5,
          date: DateTime(2026, 1, 1),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('cashier cannot adjust stock', () async {
      final cashier = await createStaff(
        role: StaffRole.cashier,
        username: 'cashier1',
      );
      sessionController.signIn(cashier);
      await seedProduct();

      await expectLater(
        productRepository.changeStock(
          productId: 'product-1',
          quantity: 5,
          type: 'restock',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('cashier can complete a sale', () async {
      final cashier = await createStaff(
        role: StaffRole.cashier,
        username: 'cashier1',
      );
      sessionController.signIn(cashier);
      await seedProduct();

      await completeSale();

      final sale = await (database.select(
        database.sales,
      )..where((t) => t.id.equals('sale-1'))).getSingle();
      expect(sale.staffId, cashier.id);
    });

    test('operations are rejected when login is required but nobody signed in', () async {
      await enableLogin();

      await expectLater(
        expenseRepository.addExpense(
          title: 'Electricity',
          id: 'expense-1',

          category: 'Utilities',
          amount: 42.5,
          date: DateTime(2026, 1, 1),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('a deactivated staff member cannot perform operations', () async {
      final owner = await createStaff(
        role: StaffRole.owner,
        username: 'owner1',
      );
      final cashier = await createStaff(
        role: StaffRole.cashier,
        username: 'cashier1',
      );
      sessionController.signIn(owner);
      await staffRepository.setActive(
        username: cashier.username,
        isActive: false,
        asOwner: true,
      );

      // The stale session must not authorize the operation.
      sessionController.signIn(cashier);

      await expectLater(
        expenseRepository.addExpense(
          id: 'expense-1',
          title: 'Electricity',
          category: 'Utilities',
          amount: 42.5,
          date: DateTime(2026, 1, 1),
        ),
        throwsA(isA<StateError>()),
      );
      expect(sessionController.isAuthenticated, isFalse);
    });
  });
}
