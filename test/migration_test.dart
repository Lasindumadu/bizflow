import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
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
      expect(await app.select(app.customerCreditTransactions).get(), isEmpty);

      expect(await app.select(app.staffAccounts).get(), isEmpty);
    });
  });

  group('schema migration v13 -> v14', () {
    test('adds the staff attribution columns to existing tables', () async {
      // A v13 database: every table that receives an attribution column
      // already exists, but *without* that column. This is the shape of a
      // real installation upgrading from the Phase D build.
      await prepareRawDb(
        version: 13,
        statements: [
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
          'CREATE TABLE sale_returns ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'sale_id TEXT, '
              'customer_id TEXT, '
              'refund_amount REAL NOT NULL, '
              "refund_method TEXT NOT NULL DEFAULT 'cash', "
              'restocked INTEGER NOT NULL DEFAULT 1, '
              "reason TEXT NOT NULL DEFAULT '', "
              'created_at INTEGER NOT NULL)',
          'CREATE TABLE stock_movements ('
              'id TEXT NOT NULL PRIMARY KEY, '
              'product_id TEXT NOT NULL, '
              'type TEXT NOT NULL, '
              'quantity INTEGER NOT NULL, '
              'previous_stock INTEGER NOT NULL, '
              'new_stock INTEGER NOT NULL, '
              "note TEXT NOT NULL DEFAULT '', "
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
        ],
      );

      final app = AppDatabase(NativeDatabase(dbFile));
      addTearDown(app.close);

      // Reading a table forces the migration to run.
      await app.select(app.sales).get();

      Future<List<String>> columnsOf(String table) async {
        final rows = await app
            .customSelect(
              "SELECT name FROM pragma_table_info('$table')",
              readsFrom: {},
            )
            .get();
        return rows.map((r) => r.read<String>('name')).toList();
      }

      expect(await columnsOf('sales'), contains('staff_id'));
      expect(await columnsOf('sale_returns'), contains('staff_id'));
      expect(await columnsOf('stock_movements'), contains('staff_id'));
      expect(await columnsOf('cash_shifts'), contains('opened_by_id'));
      expect(await columnsOf('cash_shifts'), contains('closed_by_id'));
      expect(await columnsOf('cash_movements'), contains('staff_id'));
      expect(await columnsOf('purchase_orders'), contains('staff_id'));
    });

    test('pre-existing rows survive the upgrade with null attribution', () async {
      await prepareRawDb(
        version: 13,
        statements: [
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
          "INSERT INTO sales (id, customer_id, subtotal, total, paid_amount, "
              "payment_method, status, created_at) VALUES "
              "('s1', 'c1', 10.0, 10.0, 10.0, 'cash', 'completed', 1700000000)",
        ],
      );

      final app = AppDatabase(NativeDatabase(dbFile));
      addTearDown(app.close);

      final sales = await app.select(app.sales).get();
      expect(sales, hasLength(1));
      expect(sales.single.id, 's1');
      expect(
        sales.single.staffId,
        isNull,
        reason: 'legacy rows stay unattributed',
      );
    });
  });

  group('schema migration v14 -> v15', () {
    test(
      'adds the inactivity timeout column with a disabled default',
      () async {
        // A v14 database: `business_settings` exists with every Phase D/E
        // column but WITHOUT the Phase F inactivity timeout.
        await prepareRawDb(
          version: 14,
          statements: [
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
                "receipt_note TEXT NOT NULL DEFAULT '', "
                'login_required INTEGER NOT NULL DEFAULT 0)',
            "INSERT INTO business_settings (id) VALUES ('default')",
          ],
        );

        final app = AppDatabase(NativeDatabase(dbFile));
        addTearDown(app.close);

        // Reading a table forces the migration to run.
        final settings = await app.select(app.businessSettings).get();

        expect(settings, hasLength(1));
        expect(
          settings.single.inactivityTimeoutMinutes,
          0,
          reason: 'the auto-lock is disabled by default after the upgrade',
        );
      },
    );

    test('pre-existing settings rows survive the upgrade', () async {
      await prepareRawDb(
        version: 14,
        statements: [
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
              "receipt_note TEXT NOT NULL DEFAULT '', "
              'login_required INTEGER NOT NULL DEFAULT 0)',
          "INSERT INTO business_settings (id, business_name, currency, "
              "login_required) VALUES ('default', 'Legacy Store', 'LKR', 1)",
        ],
      );

      final app = AppDatabase(NativeDatabase(dbFile));
      addTearDown(app.close);

      final settings = await app.select(app.businessSettings).get();

      expect(settings, hasLength(1));
      expect(settings.single.businessName, 'Legacy Store');
      expect(settings.single.currency, 'LKR');
      expect(
        settings.single.loginRequired,
        isTrue,
        reason: 'the Phase D login flag is preserved by the v15 upgrade',
      );
      expect(settings.single.inactivityTimeoutMinutes, 0);
    });
  });
}
