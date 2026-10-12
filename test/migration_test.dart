import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/loyalty_repository.dart';

/// Creates a temporary file-backed database so that a migration can be
/// exercised across two separate connections to the SAME file — exactly what
/// happens when a user upgrades the app with existing data on disk.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('bizflow_migration_');
    dbFile = File('${tempDir.path}/bizflow.sqlite');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// Opens a bare connection and runs [sql] statements (no drift schema).
  Future<void> prepareRawDb({
    required int version,
    required List<String> statements,
  }) async {
    final db = NativeDatabase.createInBackground(dbFile);
    final executor = db;
    // Use a raw drift QueryExecutor wrapper to run statements.
    final raw = _RawExecutor(executor);
    await raw.run(statements);
    await raw.setUserVersion(version);
    await raw.close();
  }

  group('schema migration v5 -> v6', () {
    test('backfills points_balance from existing loyalty_points', () async {
      // Build a v5 database containing a customer with lifetime points but no
      // points_balance column (the v5 shape).
      await prepareRawDb(
        version: 5,
        statements: [
          'CREATE TABLE customers ('
              'id TEXT NOT NULL PRIMARY KEY, '
              "name TEXT NOT NULL, "
              "phone TEXT NOT NULL DEFAULT '', "
              "email TEXT NOT NULL DEFAULT '', "
              "address TEXT NOT NULL DEFAULT '', "
              'outstanding_balance REAL NOT NULL DEFAULT 0.0, '
              'loyalty_points INTEGER NOT NULL DEFAULT 0, '
              "loyalty_tier TEXT NOT NULL DEFAULT 'Bronze')",
          'CREATE TABLE products ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'name TEXT NOT NULL, '
              'sku TEXT NOT NULL, '
              'category TEXT NOT NULL, '
              'purchase_price REAL NOT NULL, '
              'selling_price REAL NOT NULL, '
              'stock_quantity INTEGER NOT NULL, '
              'low_stock_threshold INTEGER NOT NULL, '
              "barcode TEXT NOT NULL DEFAULT '')",
          'CREATE TABLE categories ('
              'id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL)',
          'CREATE TABLE sales ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'customer_id TEXT, '
              'subtotal REAL NOT NULL, '
              'discount REAL NOT NULL DEFAULT 0.0, '
              'total REAL NOT NULL, '
              'paid_amount REAL NOT NULL, '
              "payment_method TEXT NOT NULL DEFAULT 'cash', "
              "status TEXT NOT NULL DEFAULT 'completed', "
              'created_at INTEGER NOT NULL)',
          'CREATE TABLE sale_items ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'sale_id TEXT NOT NULL, '
              'product_id TEXT NOT NULL, '
              'product_name TEXT NOT NULL, '
              'quantity INTEGER NOT NULL, '
              'unit_price REAL NOT NULL, '
              'purchase_price REAL NOT NULL, '
              'total REAL NOT NULL)',
          'CREATE TABLE expenses ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'title TEXT NOT NULL, '
              'category TEXT NOT NULL, '
              'amount REAL NOT NULL, '
              'date INTEGER NOT NULL, '
              "note TEXT NOT NULL DEFAULT '')",
          'CREATE TABLE stock_movements ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'product_id TEXT NOT NULL, '
              'type TEXT NOT NULL, '
              'quantity INTEGER NOT NULL, '
              'previous_stock INTEGER NOT NULL, '
              'new_stock INTEGER NOT NULL, '
              "note TEXT NOT NULL DEFAULT '', "
              'created_at INTEGER NOT NULL)',
          'CREATE TABLE business_settings ('
              'id TEXT NOT NULL PRIMARY KEY, '
              "business_name TEXT NOT NULL DEFAULT 'My Business', "
              "address TEXT NOT NULL DEFAULT '', "
              "phone TEXT NOT NULL DEFAULT '', "
              "email TEXT NOT NULL DEFAULT '', "
              "currency TEXT NOT NULL DEFAULT 'USD', "
              'loyalty_enabled INTEGER NOT NULL DEFAULT 1, '
              'loyalty_earn_rate REAL NOT NULL DEFAULT 1.0, '
              'loyalty_redeem_value REAL NOT NULL DEFAULT 0.01)',
          // A customer with 2500 lifetime points (a "Gold" customer).
          "INSERT INTO customers (id, name, loyalty_points, loyalty_tier) "
              "VALUES ('c1', 'Existing Customer', 2500, 'Gold')",
          "INSERT INTO products (id, name, sku, category, purchase_price, "
              "selling_price, stock_quantity, low_stock_threshold) "
              "VALUES ('p1', 'Widget', 'SKU-1', 'General', 50.0, 100.0, 10, 2)",
          "INSERT INTO business_settings (id, business_name) "
              "VALUES ('default', 'Existing Shop')",
        ],
      );

      // Now open the real AppDatabase over the same file. This triggers
      // onUpgrade from 5 to 6.
      final app = AppDatabase(NativeDatabase(dbFile));
      addTearDown(app.close);

      final customers = await app.select(app.customers).get();
      expect(customers, hasLength(1));

      final customer = customers.single;
      // Lifetime points must be untouched.
      expect(customer.loyaltyPoints, 2500);
      expect(customer.loyaltyTier, 'Gold');
      // Balance must be backfilled from lifetime points.
      expect(customer.pointsBalance, 2500);

      // Existing products and settings survive the migration.
      final products = await app.select(app.products).get();
      expect(products.single.name, 'Widget');

      final settings = await app.select(app.businessSettings).get();
      expect(settings.single.businessName, 'Existing Shop');

      // v7 tables must exist and be empty on a migrated database.
      expect(await app.select(app.saleReturns).get(), isEmpty);
      expect(await app.select(app.saleReturnItems).get(), isEmpty);
      expect(await app.select(app.auditLogs).get(), isEmpty);
    });

    test('a fresh v6 database starts consistent', () async {
      final app = AppDatabase(NativeDatabase(dbFile));
      addTearDown(app.close);

      // Touch the schema so it is created.
      await app.select(app.customers).get();

      await app
          .into(app.customers)
          .insert(CustomersCompanion.insert(id: 'new', name: 'New Customer'));

      final customer = (await app.select(app.customers).get()).single;
      expect(customer.loyaltyPoints, 0);
      expect(customer.pointsBalance, 0);
      expect(customer.loyaltyTier, 'Bronze');
    });

    test('redeeming after migration never demotes the migrated tier', () async {
      await prepareRawDb(
        version: 5,
        statements: [
          'CREATE TABLE customers ('
              'id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, '
              "phone TEXT NOT NULL DEFAULT '', email TEXT NOT NULL DEFAULT '', "
              "address TEXT NOT NULL DEFAULT '', "
              'outstanding_balance REAL NOT NULL DEFAULT 0.0, '
              'loyalty_points INTEGER NOT NULL DEFAULT 0, '
              "loyalty_tier TEXT NOT NULL DEFAULT 'Bronze')",
          "INSERT INTO customers (id, name, loyalty_points, loyalty_tier) "
              "VALUES ('c1', 'Gold Customer', 2500, 'Gold')",
          'CREATE TABLE business_settings ('
              'id TEXT NOT NULL PRIMARY KEY, '
              "business_name TEXT NOT NULL DEFAULT 'My Business', "
              "address TEXT NOT NULL DEFAULT '', "
              "phone TEXT NOT NULL DEFAULT '', "
              "email TEXT NOT NULL DEFAULT '', "
              "currency TEXT NOT NULL DEFAULT 'USD', "
              'loyalty_enabled INTEGER NOT NULL DEFAULT 1, '
              'loyalty_earn_rate REAL NOT NULL DEFAULT 1.0, '
              'loyalty_redeem_value REAL NOT NULL DEFAULT 0.01)',
        ],
      );

      final app = AppDatabase(NativeDatabase(dbFile));
      addTearDown(app.close);

      final repository = LoyaltyRepository(app);
      await repository.redeemPoints('c1', 2000);

      final customer = (await app.select(app.customers).get()).single;
      expect(customer.pointsBalance, 500, reason: 'balance reduced');
      expect(customer.loyaltyPoints, 2500, reason: 'lifetime preserved');
      expect(customer.loyaltyTier, 'Gold', reason: 'tier preserved');
    });
  });
}

/// Minimal raw SQL runner over a drift [QueryExecutor], used only by tests to
/// build an older-schema database before opening the real [AppDatabase].
class _RawExecutor {
  final QueryExecutor executor;
  _RawExecutor(this.executor);

  Future<void> run(List<String> statements) async {
    // A lazy executor (NativeDatabase.createInBackground) must be opened
    // before it can run statements.
    await executor.ensureOpen(_NoopUser());
    for (final sql in statements) {
      await executor.runCustom(sql, const []);
    }
  }

  Future<void> setUserVersion(int version) async {
    await executor.runCustom('PRAGMA user_version = $version', const []);
  }

  Future<void> close() async {
    await executor.close();
  }
}

/// Minimal [QueryExecutorUser] used to open a raw executor in tests.
class _NoopUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 0;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
