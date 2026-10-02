// ignore_for_file: avoid_print

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/categories.dart';
import 'tables/customers.dart';
import 'tables/expenses.dart';
import 'tables/products.dart';
import 'tables/sale_items.dart';
import 'tables/sales.dart';
import 'tables/stock_movements.dart';
import 'tables/business_settings.dart';

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
                onResult: (result) {
                  print(
                    'BizFlow Drift web storage: '
                    '${result.chosenImplementation}',
                  );
                },
              ),
            ),
      );

  @override
  int get schemaVersion => 4;

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
      },
    );
  }
}
