// ignore_for_file: avoid_print

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/cash_movements.dart';
import 'tables/cash_shifts.dart';
import 'tables/categories.dart';
import 'tables/customers.dart';
import 'tables/customer_credit.dart';
import 'tables/expenses.dart';
import 'tables/products.dart';
import 'tables/purchase_order_items.dart';
import 'tables/purchase_orders.dart';
import 'tables/sale_items.dart';
import 'tables/sale_returns.dart';
import 'tables/sale_return_items.dart';
import 'tables/sales.dart';
import 'tables/stock_movements.dart';
import 'tables/audit_logs.dart';
import 'tables/business_settings.dart';
import 'tables/suppliers.dart';
import 'tables/staff_accounts.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Categories,
    Sales,
    SaleItems,
    Customers,
    Expenses,
    StockMovements,
    BusinessSettings,
    SaleReturns,
    SaleReturnItems,
    AuditLogs,
    CashShifts,
    CashMovements,
    Suppliers,
    PurchaseOrders,
    PurchaseOrderItems,
    CustomerCreditAccounts,
    CustomerCreditTransactions,
    StaffAccounts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'bizflow_database',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 15;

  static const int currentSchemaVersion = 15;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },

      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(sales, sales.status);
        }

        if (from < 3) {
          await m.addColumn(saleItems, saleItems.purchasePrice);
        }

        if (from < 4) {
          await m.createTable(businessSettings);
        }

        if (from < 5) {
          // Loyalty programme.
          await m.addColumn(customers, customers.loyaltyPoints);
          await m.addColumn(customers, customers.loyaltyTier);
          await m.addColumn(businessSettings, businessSettings.loyaltyEnabled);
          await m.addColumn(businessSettings, businessSettings.loyaltyEarnRate);
          await m.addColumn(
            businessSettings,
            businessSettings.loyaltyRedeemValue,
          );
        }

        if (from < 6) {
          // Separate spendable balance from lifetime (tier) points so that
          // redeeming points never demotes a customer's tier.
          await m.addColumn(customers, customers.pointsBalance);

          // Existing customers: assume their current points are both the
          // lifetime total and the spendable balance (nothing redeemed yet).
          await customStatement(
            'UPDATE customers SET points_balance = loyalty_points',
          );
        }

        if (from < 7) {
          // Returns/refunds and the audit trail.
          await m.createTable(saleReturns);
          await m.createTable(saleReturnItems);
          await m.createTable(auditLogs);
        }

        if (from < 8) {
          // Cashier shifts and cash movements.
          await m.createTable(cashShifts);
          await m.createTable(cashMovements);
        }

        if (from < 9) {
          // Receipt branding settings.
          await m.addColumn(businessSettings, businessSettings.receiptHeader);
          await m.addColumn(businessSettings, businessSettings.receiptFooter);
          await m.addColumn(
            businessSettings,
            businessSettings.receiptShowPhone,
          );
          await m.addColumn(
            businessSettings,
            businessSettings.receiptShowAddress,
          );
          await m.addColumn(businessSettings, businessSettings.receiptNote);
        }

        if (from < 10) {
          // Suppliers and purchase orders.
          await m.createTable(suppliers);
          await m.createTable(purchaseOrders);
          await m.createTable(purchaseOrderItems);
        }

        if (from < 11) {
          // Customer credit / accounts receivable.
          await m.createTable(customerCreditAccounts);
          await m.createTable(customerCreditTransactions);
        }

        if (from < 12) {
          // Local staff accounts (PIN-based operator identification).
          await m.createTable(staffAccounts);
        }

        if (from < 13) {
          // Phase D: optional startup PIN login. Default false so every
          // existing installation keeps its current no-login behavior.
          await m.addColumn(businessSettings, businessSettings.loginRequired);
        }

        if (from < 14) {
          // Phase E: staff attribution for accountable business operations.
          // All columns are nullable so historical records keep working with
          // null attribution; new records written through the repository
          // layer capture the authenticated staff member.
          //
          // Each addition is guarded by a PRAGMA table_info check because
          // some of these tables are created *within this migration ladder*
          // (sale_returns at v7, cash shifts at v8, purchase orders at v10)
          // from the current table definitions, which already include the
          // attribution columns — a plain ADD COLUMN would crash with
          // "duplicate column name" on upgrades from those older versions.
          Future<void> addColumnIfMissing(
            String table,
            String column,
            String ddl,
          ) async {
            // Skip tables that don't exist yet in this database — they may be
            // created by a later migration gate, or may never have existed
            // (e.g. older databases predating some tables).
            final tableExists = await customSelect(
              "SELECT name FROM sqlite_master "
              "WHERE type = 'table' AND name = '$table'",
            ).get();
            if (tableExists.isEmpty) return;

            final existing = await customSelect(
              "SELECT name FROM pragma_table_info('$table') "
              "WHERE name = '$column'",
            ).get();
            if (existing.isEmpty) {
              await customStatement(
                'ALTER TABLE "$table" ADD COLUMN "$column" $ddl',
              );
            }
          }

          await addColumnIfMissing('sales', 'staff_id', 'TEXT');
          await addColumnIfMissing('sale_returns', 'staff_id', 'TEXT');
          await addColumnIfMissing('cash_shifts', 'opened_by_id', 'TEXT');
          await addColumnIfMissing('cash_shifts', 'closed_by_id', 'TEXT');
          await addColumnIfMissing('cash_movements', 'staff_id', 'TEXT');
          await addColumnIfMissing('stock_movements', 'staff_id', 'TEXT');
          await addColumnIfMissing('purchase_orders', 'staff_id', 'TEXT');
        }

        if (from < 15) {
          // Phase F: inactivity auto-lock timeout (minutes, default 0 = off).
          //
          // Guarded by a table-existence check for the same reason as the v14
          // block: a database may not have a `business_settings` table at all
          // (e.g. a hand-built or partially-created database), and a plain
          // ADD COLUMN would fail with "no such table" and abort the whole
          // migration. The column is also skipped when it already exists.
          final businessSettingsExists = await customSelect(
            "SELECT name FROM sqlite_master "
            "WHERE type = 'table' AND name = 'business_settings'",
          ).get();
          if (businessSettingsExists.isNotEmpty) {
            final existing = await customSelect(
              "SELECT name FROM pragma_table_info('business_settings') "
              "WHERE name = 'inactivity_timeout_minutes'",
            ).get();
            if (existing.isEmpty) {
              await customStatement(
                'ALTER TABLE "business_settings" ADD COLUMN '
                '"inactivity_timeout_minutes" INTEGER NOT NULL DEFAULT 0',
              );
            }
          }
        }
      },
    );
  }
}
