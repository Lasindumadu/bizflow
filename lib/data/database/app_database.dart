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
  int get schemaVersion => 16;

  static const int currentSchemaVersion = 16;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },

      onUpgrade: (Migrator m, int from, int to) async {
        // Shared helper: add a column only if the table exists and the column
        // is missing. Used by every migration gate that alters existing tables.
        Future<void> addColumnIfMissing(
          String table,
          String column,
          String ddl,
        ) async {
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
          await m.addColumn(customers, customers.pointsBalance);
          await customStatement(
            'UPDATE customers SET points_balance = loyalty_points',
          );
        }

        if (from < 7) {
          await m.createTable(saleReturns);
          await m.createTable(saleReturnItems);
          await m.createTable(auditLogs);
        }

        if (from < 8) {
          await m.createTable(cashShifts);
          await m.createTable(cashMovements);
        }

        if (from < 9) {
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
          await m.createTable(suppliers);
          await m.createTable(purchaseOrders);
          await m.createTable(purchaseOrderItems);
        }

        if (from < 11) {
          await m.createTable(customerCreditAccounts);
          await m.createTable(customerCreditTransactions);
        }

        if (from < 12) {
          await m.createTable(staffAccounts);
        }

        if (from < 13) {
          await m.addColumn(businessSettings, businessSettings.loginRequired);
        }

        if (from < 14) {
          await addColumnIfMissing('sales', 'staff_id', 'TEXT');
          await addColumnIfMissing('sale_returns', 'staff_id', 'TEXT');
          await addColumnIfMissing('cash_shifts', 'opened_by_id', 'TEXT');
          await addColumnIfMissing('cash_shifts', 'closed_by_id', 'TEXT');
          await addColumnIfMissing('cash_movements', 'staff_id', 'TEXT');
          await addColumnIfMissing('stock_movements', 'staff_id', 'TEXT');
          await addColumnIfMissing('purchase_orders', 'staff_id', 'TEXT');
        }

        if (from < 15) {
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

        if (from < 16) {
          // Phase G: Aurora 2.0 feature extensions.
          await addColumnIfMissing(
            'products', 'product_image_url', 'TEXT',
          );
          await addColumnIfMissing(
            'sale_items', 'expiry_date', 'TEXT',
          );
          await addColumnIfMissing(
            'sale_items', 'batch_number', 'TEXT',
          );
          await addColumnIfMissing(
            'business_settings', 'tax_rate', 'REAL NOT NULL DEFAULT 0',
          );
          await addColumnIfMissing(
            'business_settings', 'tax_inclusive', 'INTEGER NOT NULL DEFAULT 0',
          );
          await addColumnIfMissing(
            'sales', 'tax_amount', 'REAL NOT NULL DEFAULT 0',
          );
          await addColumnIfMissing(
            'sales', 'payment_method_details', 'TEXT',
          );
        }
      },
    );
  }
}
