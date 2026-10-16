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
  int get schemaVersion => 13;

  static const int currentSchemaVersion = 13;

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
          await m.addColumn(
            businessSettings,
            businessSettings.loginRequired,
          );
        }
      },
    );
  }
}
