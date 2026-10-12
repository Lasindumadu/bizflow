import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/report_repository.dart';

void main() {
  late AppDatabase database;
  late ReportRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ReportRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertProduct({
    required String id,
    required String category,
    double cost = 50,
    double price = 100,
  }) async {
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: id,
            name: 'Product $id',
            sku: 'SKU-$id',
            category: category,
            purchasePrice: cost,
            sellingPrice: price,
            stockQuantity: 100,
            lowStockThreshold: 5,
          ),
        );
  }

  Future<void> insertSale({
    required String saleId,
    required String productId,
    required int quantity,
    double unitPrice = 100,
    double purchasePrice = 50,
    DateTime? createdAt,
  }) async {
    final date = createdAt ?? DateTime.now();
    await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            id: saleId,
            subtotal: quantity * unitPrice,
            total: quantity * unitPrice,
            paidAmount: quantity * unitPrice,
            status: const Value('completed'),
            createdAt: date,
          ),
        );
    await database
        .into(database.saleItems)
        .insert(
          SaleItemsCompanion.insert(
            id: 'item-$saleId',
            saleId: saleId,
            productId: productId,
            productName: 'Product $productId',
            quantity: quantity,
            unitPrice: unitPrice,
            purchasePrice: purchasePrice,
            total: quantity * unitPrice,
          ),
        );
  }

  group('getMarginByProduct', () {
    test('aggregates revenue, cost, profit and margin per product', () async {
      await insertProduct(id: 'p1', category: 'A', cost: 50, price: 100);
      await insertSale(saleId: 's1', productId: 'p1', quantity: 4);

      final rows = await repository.getMarginByProduct();

      expect(rows, hasLength(1));
      expect(rows.single.revenue, 400); // 4 × 100
      expect(rows.single.cost, 200); // 4 × 50
      expect(rows.single.profit, 200);
      expect(rows.single.marginPct, closeTo(50, 0.001));
    });

    test('ranks products by profit descending', () async {
      await insertProduct(id: 'low', category: 'A', cost: 90, price: 100);
      await insertProduct(id: 'high', category: 'A', cost: 10, price: 100);
      await insertSale(
        saleId: 's1',
        productId: 'low',
        quantity: 2,
        unitPrice: 100,
        purchasePrice: 90,
      );
      await insertSale(
        saleId: 's2',
        productId: 'high',
        quantity: 2,
        unitPrice: 100,
        purchasePrice: 10,
      );

      final rows = await repository.getMarginByProduct();

      // "high" earns 90 profit per unit vs 10 for "low".
      expect(rows.first.revenue, 200);
      expect(rows.first.profit, 180);
      expect(rows.first.profit, greaterThan(rows.last.profit));
    });
  });

  group('getMarginByCategory', () {
    test('groups profit by product category', () async {
      await insertProduct(id: 'a', category: 'Drinks', cost: 50, price: 100);
      await insertProduct(id: 'b', category: 'Snacks', cost: 20, price: 50);
      await insertSale(
        saleId: 's1',
        productId: 'a',
        quantity: 2,
        unitPrice: 100,
        purchasePrice: 50,
      );
      await insertSale(
        saleId: 's2',
        productId: 'b',
        quantity: 3,
        unitPrice: 50,
        purchasePrice: 20,
      );

      final rows = await repository.getMarginByCategory();

      final drinks = rows.firstWhere((r) => r.label == 'Drinks');
      expect(drinks.revenue, 200);
      expect(drinks.profit, 100);

      final snacks = rows.firstWhere((r) => r.label == 'Snacks');
      expect(snacks.revenue, 150);
      expect(snacks.profit, 90);
    });
  });

  group('getPeriodComparison', () {
    test('compares revenue against the previous equal-length period', () async {
      final now = DateTime.now();
      // Today: 500 revenue.
      await insertProduct(id: 'p1', category: 'A');
      await insertSale(
        saleId: 'today',
        productId: 'p1',
        quantity: 5,
        createdAt: now,
      );
      // 10 days ago: 200 revenue — inside the PREVIOUS 7-day window only.
      await insertSale(
        saleId: 'past',
        productId: 'p1',
        quantity: 2,
        createdAt: now.subtract(const Duration(days: 10)),
      );

      final comparison = await repository.getPeriodComparison(days: 7);

      expect(comparison.current.revenue, 500);
      expect(comparison.previous.revenue, 200);
      expect(
        comparison.current.revenueChangeVs(comparison.previous),
        closeTo(150, 0.001), // +150%
      );
    });
  });
}
