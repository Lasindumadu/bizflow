import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/services/backup_service.dart';

void main() {
  late AppDatabase database;
  late BackupService backupService;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    backupService = BackupService(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('BackupService', () {
    test('creates a backup that passes validation', () async {
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(id: 'category-1', name: 'Test Category'),
          );

      final json = await backupService.createBackupJson();
      final bytes = Uint8List.fromList(utf8.encode(json));
      final backup = await backupService.validateBackupJson(bytes);

      expect(backup['application'], 'BizFlow');
      expect(backup['backupFormatVersion'], 1);
      expect(backup['databaseSchemaVersion'], 9);

      final data = backup['data'] as Map<String, dynamic>;
      expect(data['categories'], hasLength(1));
      expect((data['categories'] as List).first['name'], 'Test Category');
    });

    test('rejects invalid JSON without changing existing data', () async {
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'original-category',
              name: 'Original Category',
            ),
          );

      final invalidBytes = Uint8List.fromList(utf8.encode('{invalid json'));

      await expectLater(
        backupService.restoreBackup(invalidBytes),
        throwsA(isA<FormatException>()),
      );

      final categories = await database.select(database.categories).get();

      expect(categories, hasLength(1));
      expect(categories.single.id, 'original-category');
      expect(categories.single.name, 'Original Category');
    });

    test('restores valid backup data', () async {
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'category-1',
              name: 'Restored Category',
            ),
          );

      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-1',
              name: 'Test Product',
              sku: 'TEST-001',
              category: 'Restored Category',
              purchasePrice: 10.0,
              sellingPrice: 15.0,
              stockQuantity: 20,
              lowStockThreshold: 5,
            ),
          );

      final json = await backupService.createBackupJson();
      final bytes = Uint8List.fromList(utf8.encode(json));

      await backupService.resetAllData();

      expect(await database.select(database.categories).get(), isEmpty);
      expect(await database.select(database.products).get(), isEmpty);

      await backupService.restoreBackup(bytes);

      final categories = await database.select(database.categories).get();
      final products = await database.select(database.products).get();

      expect(categories, hasLength(1));
      expect(categories.single.name, 'Restored Category');

      expect(products, hasLength(1));
      expect(products.single.id, 'product-1');
      expect(products.single.stockQuantity, 20);
    });

    test('rolls back all changes when restoration fails', () async {
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'original-category',
              name: 'Original Category',
            ),
          );

      final json = await backupService.createBackupJson();
      final backup = jsonDecode(json) as Map<String, dynamic>;
      final data = backup['data'] as Map<String, dynamic>;

      // Duplicate primary keys should cause a database constraint error
      // during insertion, after restoration has started.
      data['categories'] = [
        {'id': 'duplicate-category', 'name': 'First Category'},
        {'id': 'duplicate-category', 'name': 'Second Category'},
      ];

      final bytes = Uint8List.fromList(utf8.encode(jsonEncode(backup)));

      await expectLater(
        backupService.restoreBackup(bytes),
        throwsA(isA<Exception>()),
      );

      // The transaction must preserve the original database state.
      final categories = await database.select(database.categories).get();

      expect(categories, hasLength(1));
      expect(categories.single.id, 'original-category');
      expect(categories.single.name, 'Original Category');

      expect(await database.select(database.products).get(), isEmpty);
    });

    test('resetAllData removes records from all tables', () async {
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'category-1',
              name: 'Temporary Category',
            ),
          );

      await database
          .into(database.businessSettings)
          .insert(
            BusinessSettingsCompanion.insert(
              id: 'default',
              businessName: const Value('Temporary Business'),
            ),
          );

      await backupService.resetAllData();

      expect(await database.select(database.categories).get(), isEmpty);
      expect(await database.select(database.products).get(), isEmpty);
      expect(await database.select(database.sales).get(), isEmpty);
      expect(await database.select(database.saleItems).get(), isEmpty);
      expect(await database.select(database.customers).get(), isEmpty);
      expect(await database.select(database.expenses).get(), isEmpty);
      expect(await database.select(database.stockMovements).get(), isEmpty);
      expect(await database.select(database.businessSettings).get(), isEmpty);
    });

    test(
      'rejects invalid field types without changing existing data',
      () async {
        await database
            .into(database.categories)
            .insert(
              CategoriesCompanion.insert(
                id: 'original-category',
                name: 'Original Category',
              ),
            );

        final json = await backupService.createBackupJson();
        final backup = jsonDecode(json) as Map<String, dynamic>;
        final data = backup['data'] as Map<String, dynamic>;

        data['products'] = [
          {
            'id': 'bad-product',
            'name': 'Bad Product',
            'sku': 'BAD-001',
            'category': 'Test Category',
            'purchasePrice': 10.0,
            'sellingPrice': 15.0,
            'stockQuantity': '20',
            'lowStockThreshold': 5,
            'barcode': '',
          },
        ];

        final bytes = Uint8List.fromList(utf8.encode(jsonEncode(backup)));

        await expectLater(
          backupService.restoreBackup(bytes),
          throwsA(isA<FormatException>()),
        );

        final categories = await database.select(database.categories).get();
        final products = await database.select(database.products).get();

        expect(categories, hasLength(1));
        expect(categories.single.id, 'original-category');
        expect(categories.single.name, 'Original Category');
        expect(products, isEmpty);
      },
    );

    test('preserves data across all tables in a backup round trip', () async {
      final now = DateTime.utc(2026, 10, 6, 10, 0);

      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(id: 'category-1', name: 'Groceries'),
          );

      await database
          .into(database.products)
          .insert(
            ProductsCompanion.insert(
              id: 'product-1',
              name: 'Rice',
              sku: 'RICE-001',
              category: 'Groceries',
              purchasePrice: 100.0,
              sellingPrice: 150.0,
              stockQuantity: 20,
              lowStockThreshold: 5,
              barcode: const Value('123456789'),
            ),
          );

      await database
          .into(database.customers)
          .insert(
            CustomersCompanion.insert(
              id: 'customer-1',
              name: 'Test Customer',
              phone: const Value('0771234567'),
              email: const Value('customer@example.com'),
              address: const Value('Colombo'),
              outstandingBalance: const Value(25.0),
            ),
          );

      await database
          .into(database.sales)
          .insert(
            SalesCompanion.insert(
              id: 'sale-1',
              customerId: const Value.absent(),
              subtotal: 300.0,
              discount: const Value(10.0),
              total: 290.0,
              paidAmount: 200.0,
              paymentMethod: const Value('cash'),
              status: const Value('completed'),
              createdAt: now,
            ),
          );

      await database
          .into(database.saleItems)
          .insert(
            SaleItemsCompanion.insert(
              id: 'sale-item-1',
              saleId: 'sale-1',
              productId: 'product-1',
              productName: 'Rice',
              quantity: 2,
              unitPrice: 150.0,
              purchasePrice: 100.0,
              total: 300.0,
            ),
          );

      await database
          .into(database.expenses)
          .insert(
            ExpensesCompanion.insert(
              id: 'expense-1',
              title: 'Shop supplies',
              category: 'Supplies',
              amount: 50.0,
              date: now,
              note: const Value('Test expense'),
            ),
          );

      await database
          .into(database.stockMovements)
          .insert(
            StockMovementsCompanion.insert(
              id: 'movement-1',
              productId: 'product-1',
              type: 'sale',
              quantity: 2,
              previousStock: 22,
              newStock: 20,
              note: const Value('Test stock movement'),
              createdAt: now,
            ),
          );

      await database
          .into(database.businessSettings)
          .insert(
            BusinessSettingsCompanion.insert(
              id: 'default',
              businessName: const Value('Round Trip Store'),
              address: const Value('Negombo'),
              phone: const Value('0311234567'),
              email: const Value('store@example.com'),
              currency: const Value('LKR'),
            ),
          );

      final json = await backupService.createBackupJson();
      final bytes = Uint8List.fromList(utf8.encode(json));

      await backupService.resetAllData();
      await backupService.restoreBackup(bytes);

      final categories = await database.select(database.categories).get();
      final products = await database.select(database.products).get();
      final customers = await database.select(database.customers).get();
      final sales = await database.select(database.sales).get();
      final saleItems = await database.select(database.saleItems).get();
      final expenses = await database.select(database.expenses).get();
      final movements = await database.select(database.stockMovements).get();
      final settings = await database.select(database.businessSettings).get();

      expect(categories, hasLength(1));
      expect(categories.single.name, 'Groceries');

      expect(products, hasLength(1));
      expect(products.single.barcode, '123456789');
      expect(products.single.stockQuantity, 20);

      expect(customers, hasLength(1));
      expect(customers.single.outstandingBalance, 25.0);

      expect(sales, hasLength(1));
      expect(sales.single.customerId, null);
      expect(sales.single.discount, 10.0);
      expect(sales.single.createdAt.toUtc(), now);

      expect(saleItems, hasLength(1));
      expect(saleItems.single.purchasePrice, 100.0);

      expect(expenses, hasLength(1));
      expect(expenses.single.note, 'Test expense');
      expect(expenses.single.amount, 50.0);

      expect(movements, hasLength(1));
      expect(movements.single.newStock, 20);
      expect(movements.single.note, 'Test stock movement');

      expect(settings, hasLength(1));
      expect(settings.single.businessName, 'Round Trip Store');
      expect(settings.single.currency, 'LKR');
      expect(settings.single.email, 'store@example.com');
    });
  });
}
