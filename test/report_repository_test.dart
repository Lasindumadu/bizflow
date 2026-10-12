import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/report_repository.dart';

void main() {
  late AppDatabase database;
  late ReportRepository repository;

  late DateTime testDate;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ReportRepository(database);
    testDate = DateTime.now();
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertProduct() async {
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: 'product-1',
            name: 'Test Product',
            sku: 'SKU-001',
            category: 'Test',
            purchasePrice: 50,
            sellingPrice: 100,
            stockQuantity: 10,
            lowStockThreshold: 2,
          ),
        );
  }

  Future<void> insertSale({
    required String id,
    required String status,
    required int quantity,
    required double total,
  }) async {
    await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            id: id,
            subtotal: total,
            total: total,
            paidAmount: total,
            status: Value(status),
            createdAt: testDate,
          ),
        );

    await database
        .into(database.saleItems)
        .insert(
          SaleItemsCompanion.insert(
            id: 'item-$id',
            saleId: id,
            productId: 'product-1',
            productName: 'Test Product',
            quantity: quantity,
            unitPrice: 100,
            purchasePrice: 50,
            total: total,
          ),
        );
  }

  group('ReportRepository cancelled-sale filtering', () {
    setUp(() async {
      await insertProduct();

      await insertSale(
        id: 'completed-sale',
        status: 'completed',
        quantity: 2,
        total: 200,
      );

      await insertSale(
        id: 'cancelled-sale',
        status: 'cancelled',
        quantity: 3,
        total: 300,
      );
    });

    test('excludes cancelled sales from monthly report totals', () async {
      final report = await repository.getThisMonthReport();

      expect(report.revenue, 200);
      expect(report.transactionCount, 1);
      expect(report.costOfGoodsSold, 100);
      expect(report.grossProfit, 100);
    });

    test('excludes cancelled sales from best-selling products', () async {
      final products = await repository.getBestSellingProducts();

      expect(products, hasLength(1));
      expect(products.single.productId, 'product-1');
      expect(products.single.quantitySold, 2);
      expect(products.single.revenue, 200);
    });
  });
}
