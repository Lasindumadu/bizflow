
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/loyalty_repository.dart';

class _NoopUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 0;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}


class _RawExecutor extends _NoopUser {
  final QueryExecutor _executor;

  _RawExecutor(this._executor);

  QueryExecutor get e => _executor;

  Future<void> open() async {
    await _executor.ensureOpen(this);
  }

  Future<void> run(List<String> statements) async {
    for (final sql in statements) {
      await _executor.runCustom(sql, const []);
    }
  }

  Future<void> setUserVersion(int version) async {
    await _executor.runCustom('PRAGMA user_version = $version', const []);
  }

  Future<void> close() async {
    await _executor.close();
  }
}


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

  
Future<void> prepareRawDb({
  required int version,
  required List<String> statements,
}) async {
  final executor = NativeDatabase(dbFile);
  final raw = _RawExecutor(executor);

  try {
    await raw.open();
    await raw.run(statements);
    await raw.setUserVersion(version);
  } finally {
    await raw.close();
  }
}


  group('schema migration v5 -> v6', () {
    test('backfills points_balance from existing loyalty_points', () async {
      await prepareRawDb(
        version: 5,
        statements: [
          'CREATE TABLE customers ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'name TEXT NOT NULL, '
              "phone TEXT NOT NULL DEFAULT '', "
              "email TEXT NOT NULL DEFAULT '', "
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

  group('schema migration v11 -> v12', () {
    test('creates staffAccounts table when upgrading from v11', () async {
      await prepareRawDb(
        version: 11,
        statements: [
          'CREATE TABLE customers ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'name TEXT NOT NULL, '
              "phone TEXT NOT NULL DEFAULT '', "
              "email TEXT NOT NULL DEFAULT '', "
              "address TEXT NOT NULL DEFAULT '', "
              'outstanding_balance REAL NOT NULL DEFAULT 0.0, '
              'loyalty_points INTEGER NOT NULL DEFAULT 0, '
              "loyalty_tier TEXT NOT NULL DEFAULT 'Bronze', "
              'points_balance INTEGER NOT NULL DEFAULT 0)',
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
          'CREATE TABLE business_settings ('
              'id TEXT NOT NULL PRIMARY KEY, '
              "business_name TEXT NOT NULL DEFAULT 'My Business', "
              "address TEXT NOT NULL DEFAULT '', "
              "phone TEXT NOT NULL DEFAULT '', "
              "email TEXT NOT NULL DEFAULT '', "
              "currency TEXT NOT NULL DEFAULT 'USD', "
              'loyalty_enabled INTEGER NOT NULL DEFAULT 1, '
              'loyalty_earn_rate REAL NOT NULL DEFAULT 1.0, '
              'loyalty_redeem_value REAL NOT NULL DEFAULT 0.01, '
              "receipt_header TEXT NOT NULL DEFAULT 'Thank you for your purchase!', "
              "receipt_footer TEXT NOT NULL DEFAULT '', "
              'receipt_show_phone INTEGER NOT NULL DEFAULT 1, '
              'receipt_show_address INTEGER NOT NULL DEFAULT 1, '
              "receipt_note TEXT NOT NULL DEFAULT '')",
          'CREATE TABLE sale_returns ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'sale_id TEXT, '
              'customer_id TEXT, '
              'refund_amount REAL NOT NULL, '
              "refund_method TEXT NOT NULL DEFAULT 'cash', "
              'restocked INTEGER NOT NULL DEFAULT 1, '
              "reason TEXT NOT NULL DEFAULT '', "
              'created_at INTEGER NOT NULL)',
          'CREATE TABLE sale_return_items ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'return_id TEXT, '
              'sale_id TEXT, '
              'product_id TEXT NOT NULL, '
              'product_name TEXT NOT NULL, '
              'quantity INTEGER NOT NULL, '
              'unit_price REAL NOT NULL, '
              'purchase_price REAL NOT NULL, '
              'total REAL NOT NULL)',
          'CREATE TABLE audit_logs ('
              'id TEXT NOT NULL PRIMARY KEY, '
              "actor TEXT NOT NULL DEFAULT 'Owner', "
              'action TEXT NOT NULL, '
              "summary TEXT NOT NULL DEFAULT '', "
              "entity_type TEXT NOT NULL DEFAULT '', "
              "entity_id TEXT NOT NULL DEFAULT '', "
              "before_json TEXT NOT NULL DEFAULT '', "
              "after_json TEXT NOT NULL DEFAULT '', "
              'created_at INTEGER NOT NULL)',
          'CREATE TABLE cash_shifts ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'shift_number INTEGER NOT NULL, '
              'opening_float REAL NOT NULL DEFAULT 0.0, '
              'closing_count REAL, '
              "discrepancy_reason TEXT NOT NULL DEFAULT '', "
              'opened_at INTEGER NOT NULL, '
              'closed_at INTEGER, '
              'is_open INTEGER NOT NULL DEFAULT 1)',
          'CREATE TABLE cash_movements ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'shift_id TEXT NOT NULL, '
              'direction TEXT NOT NULL, '
              'amount REAL NOT NULL, '
              "note TEXT NOT NULL DEFAULT '', "
              'created_at INTEGER NOT NULL)',
          'CREATE TABLE suppliers ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'name TEXT NOT NULL, '
              "contact_person TEXT NOT NULL DEFAULT '', "
              "phone TEXT NOT NULL DEFAULT '', "
              "email TEXT NOT NULL DEFAULT '', "
              "address TEXT NOT NULL DEFAULT '', "
              "tax_number TEXT NOT NULL DEFAULT '', "
              'payment_terms_days INTEGER NOT NULL DEFAULT 30, '
              "notes TEXT NOT NULL DEFAULT '', "
              'created_at INTEGER NOT NULL, '
              'updated_at INTEGER NOT NULL)',
          'CREATE TABLE purchase_orders ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'supplier_id TEXT NOT NULL, '
              "supplier_reference TEXT NOT NULL DEFAULT '', "
              "status TEXT NOT NULL DEFAULT 'draft', "
              'subtotal REAL NOT NULL DEFAULT 0.0, '
              'tax_amount REAL NOT NULL DEFAULT 0.0, '
              'total REAL NOT NULL DEFAULT 0.0, '
              "notes TEXT NOT NULL DEFAULT '', "
              'created_at INTEGER NOT NULL, '
              'updated_at INTEGER NOT NULL, '
              'expected_date INTEGER, '
              'received_at INTEGER)',
          'CREATE TABLE purchase_order_items ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'purchase_order_id TEXT NOT NULL, '
              'product_id TEXT NOT NULL, '
              'product_name TEXT NOT NULL, '
              "product_sku TEXT NOT NULL DEFAULT '', "
              'quantity_ordered INTEGER NOT NULL, '
              'quantity_received INTEGER NOT NULL DEFAULT 0, '
              'unit_cost REAL NOT NULL, '
              'total REAL NOT NULL, '
              "notes TEXT NOT NULL DEFAULT '')",
          'CREATE TABLE customer_credit_accounts ('
              'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
              'customer_id TEXT NOT NULL, '
              'credit_limit REAL NOT NULL DEFAULT 0.0, '
              'current_balance REAL NOT NULL DEFAULT 0.0, '
              "payment_terms TEXT NOT NULL DEFAULT 'Net 30', "
              'is_active INTEGER NOT NULL DEFAULT 1, '
              'created_at INTEGER NOT NULL, '
              'updated_at INTEGER NOT NULL)',
          'CREATE TABLE customer_credit_transactions ('
              'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
              'account_id INTEGER NOT NULL, '
              'type TEXT NOT NULL, '
              'reference TEXT, '
              'amount REAL NOT NULL, '
              'balance_after REAL NOT NULL, '
              'description TEXT, '
              'created_at INTEGER NOT NULL, '
              'created_by INTEGER)',
        ],
      );

      final app = AppDatabase(NativeDatabase(dbFile));
      addTearDown(app.close);

      final customers = await app.select(app.customers).get();
      expect(customers, isEmpty);

      final staff = await app.select(app.staffAccounts).get();
      expect(staff, isEmpty);
    });
  });

  group('schema migration v5 -> v12', () {
    test('applies every migration from v5 through v12', () async {
      await prepareRawDb(
        version: 5,
        statements: [
          'CREATE TABLE customers ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'name TEXT NOT NULL, '
              "phone TEXT NOT NULL DEFAULT '', "
              "email TEXT NOT NULL DEFAULT '', "
              "address TEXT NOT NULL DEFAULT '', "
              'outstanding_balance REAL NOT NULL DEFAULT 0.0, '
              'loyalty_points INTEGER NOT NULL DEFAULT 0, '
              "loyalty_tier TEXT NOT NULL DEFAULT 'Bronze')",
          "INSERT INTO customers (id, name, loyalty_points, loyalty_tier) "
              "VALUES ('c1', 'Loyal Customer', 3000, 'Gold')",
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

      await app.select(app.customers).get();

      final customer = (await app.select(app.customers).get()).firstWhere(
        (c) => c.id == 'c1',
      );

      expect(customer.pointsBalance, 3000);
      expect(customer.loyaltyPoints, 3000);

      expect(await app.select(app.saleReturns).get(), isEmpty);
      expect(await app.select(app.saleReturnItems).get(), isEmpty);
      expect(await app.select(app.auditLogs).get(), isEmpty);
      expect(await app.select(app.cashShifts).get(), isEmpty);
      expect(await app.select(app.cashMovements).get(), isEmpty);

      expect(await app.select(app.suppliers).get(), isEmpty);
      expect(await app.select(app.purchaseOrders).get(), isEmpty);
      expect(await app.select(app.purchaseOrderItems).get(), isEmpty);

      expect(await app.select(app.customerCreditAccounts).get(), isEmpty);
      expect(
        await app.select(app.customerCreditTransactions).get(),
        isEmpty,
      );

      expect(await app.select(app.staffAccounts).get(), isEmpty);
    });
  });
}
