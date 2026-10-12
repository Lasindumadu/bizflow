import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/inventory_intelligence_repository.dart';

void main() {
  late AppDatabase database;
  late InventoryIntelligenceRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = InventoryIntelligenceRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertProduct({
    required String id,
    int stock = 10,
    int threshold = 3,
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
            category: 'Test',
            purchasePrice: cost,
            sellingPrice: price,
            stockQuantity: stock,
            lowStockThreshold: threshold,
          ),
        );
  }

  Future<void> insertCompletedSale({
    required String saleId,
    required String productId,
    required int quantity,
    DateTime? createdAt,
  }) async {
    final date = createdAt ?? DateTime.now();
    await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            id: saleId,
            subtotal: quantity * 100.0,
            total: quantity * 100.0,
            paidAmount: quantity * 100.0,
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
            unitPrice: 100,
            purchasePrice: 50,
            total: quantity * 100.0,
          ),
        );
  }

  group('getReorderSuggestions', () {
    test('flags a product at or below its low-stock threshold', () async {
      await insertProduct(id: 'p1', stock: 2, threshold: 3);

      final suggestions = await repository.getReorderSuggestions();

      expect(suggestions, hasLength(1));
      expect(suggestions.single.productId, 'p1');
      expect(
        suggestions.single.suggestedReorderQuantity,
        greaterThanOrEqualTo(3),
      );
    });

    test('ranks out-of-stock products first', () async {
      await insertProduct(id: 'low', stock: 2, threshold: 3);
      await insertProduct(id: 'out', stock: 0, threshold: 3);

      final suggestions = await repository.getReorderSuggestions();

      expect(suggestions.first.productId, 'out');
      expect(suggestions.first.isOutOfStock, isTrue);
    });

    test('ignores well-stocked products with no recent sales', () async {
      await insertProduct(id: 'healthy', stock: 100, threshold: 5);

      final suggestions = await repository.getReorderSuggestions();

      expect(suggestions, isEmpty);
    });

    test('flags fast sellers whose cover is running low', () async {
      // 300 units sold over 30 days = 10/day. Stock 50 → 5 days cover.
      await insertProduct(id: 'fast', stock: 50, threshold: 5);
      for (var i = 0; i < 30; i++) {
        await insertCompletedSale(
          saleId: 's$i',
          productId: 'fast',
          quantity: 10,
        );
      }

      final suggestions = await repository.getReorderSuggestions(coverDays: 14);

      expect(suggestions, hasLength(1));
      expect(suggestions.single.soldLast30Days, 300);
      expect(suggestions.single.daysOfCover, lessThanOrEqualTo(14));
    });
  });

  group('getDeadStock', () {
    test('lists stocked products that have not sold', () async {
      await insertProduct(id: 'idle', stock: 20);

      final dead = await repository.getDeadStock();

      expect(dead, hasLength(1));
      expect(dead.single.productId, 'idle');
      expect(dead.single.stockValue, 20 * 50.0);
    });

    test('excludes products that sold recently', () async {
      await insertProduct(id: 'moving', stock: 20);
      await insertCompletedSale(saleId: 's1', productId: 'moving', quantity: 1);

      final dead = await repository.getDeadStock();

      expect(dead, isEmpty);
    });

    test('excludes zero-stock products', () async {
      await insertProduct(id: 'empty', stock: 0);

      final dead = await repository.getDeadStock();

      expect(dead, isEmpty);
    });
  });

  group('getStockValuation', () {
    test('computes cost, retail and potential profit', () async {
      await insertProduct(id: 'a', stock: 10, cost: 50, price: 100);
      await insertProduct(id: 'b', stock: 5, cost: 20, price: 40);

      final valuation = await repository.getStockValuation();

      expect(valuation.productCount, 2);
      expect(valuation.totalUnits, 15);
      expect(valuation.costValue, 10 * 50 + 5 * 20); // 600
      expect(valuation.retailValue, 10 * 100 + 5 * 40); // 1200
      expect(valuation.potentialProfit, 600);
    });
  });
}
