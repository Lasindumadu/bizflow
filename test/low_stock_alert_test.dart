import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/sale_repository.dart';
import 'package:bizflow/models/sale.dart' as model;
import 'package:bizflow/models/sale_item.dart' as sale_models;

void main() {
  late AppDatabase database;
  late SaleRepository repository;

  final saleDate = DateTime(2026, 10, 11, 10);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SaleRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertProduct({
    required String id,
    int stock = 10,
    int threshold = 2,
  }) async {
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: id,
            name: 'Test Product $id',
            sku: 'SKU-$id',
            category: 'Test',
            purchasePrice: 50,
            sellingPrice: 100,
            stockQuantity: stock,
            lowStockThreshold: threshold,
          ),
        );
  }

  sale_models.SaleItem item(String saleId, String productId, int qty) =>
      sale_models.SaleItem(
        id: '${saleId}_0',
        saleId: saleId,
        productId: productId,
        productName: 'Test Product $productId',
        quantity: qty,
        unitPrice: 100,
        purchasePrice: 50,
      );

  Future<model.Sale> completeSingleItemSale({
    required String saleId,
    required String productId,
    required int quantity,
  }) {
    return repository.completeSale(
      saleId: saleId,
      subtotal: 100.0 * quantity,
      total: 100.0 * quantity,
      paidAmount: 100.0 * quantity,
      createdAt: saleDate,
      items: [item(saleId, productId, quantity)],
    );
  }

  Future<int> stockOf(String productId) async {
    final product = await (database.select(database.products)
          ..where((t) => t.id.equals(productId)))
        .getSingle();
    return product.stockQuantity;
  }

  group('low-stock alert callback', () {
    test('fires when a sale pushes stock to the threshold', () async {
      await insertProduct(id: 'p1', stock: 5, threshold: 2);
      final alerts = <String, int>{};

      final repo = SaleRepository(
        database,
        onLowStock: (name, remaining) => alerts[name] = remaining,
      );
      await repo.completeSale(
        saleId: 's1',
        subtotal: 300,
        total: 300,
        paidAmount: 300,
        createdAt: saleDate,
        items: [item('s1', 'p1', 3)],
      );

      expect(alerts, {'Test Product p1': 2});
    });

    test('does not fire while stock stays above the threshold', () async {
      await insertProduct(id: 'p1', stock: 10, threshold: 2);
      var alertCount = 0;

      final repo = SaleRepository(
        database,
        onLowStock: (_, _) => alertCount++,
      );
      await repo.completeSale(
        saleId: 's1',
        subtotal: 200,
        total: 200,
        paidAmount: 200,
        createdAt: saleDate,
        items: [item('s1', 'p1', 2)],
      );

      expect(alertCount, 0);
    });

    test('fires only once — on the crossing, not below it', () async {
      await insertProduct(id: 'p1', stock: 10, threshold: 5);
      var alertCount = 0;

      final repo = SaleRepository(
        database,
        onLowStock: (_, _) => alertCount++,
      );
      Future<void> sell(String saleId, int qty) => repo.completeSale(
            saleId: saleId,
            subtotal: 100.0 * qty,
            total: 100.0 * qty,
            paidAmount: 100.0 * qty,
            createdAt: saleDate,
            items: [item(saleId, 'p1', qty)],
          );

      // First sale crosses 10 -> 4 (<= 5): alert.
      await sell('s1', 6);
      // Second sale goes deeper 4 -> 1: no new alert.
      await sell('s2', 3);

      expect(alertCount, 1);
    });

    test('is not called when no callback is provided', () async {
      await insertProduct(id: 'p1', stock: 3, threshold: 2);

      final sale = await completeSingleItemSale(
        saleId: 's1',
        productId: 'p1',
        quantity: 3,
      );

      expect(sale.status, 'completed');
      expect(await stockOf('p1'), 0);
    });

    test('invariants: sale -> cancel -> stock restored exactly once', () async {
      await insertProduct(id: 'p1', stock: 10, threshold: 2);

      await completeSingleItemSale(
        saleId: 's1',
        productId: 'p1',
        quantity: 4,
      );
      expect(await stockOf('p1'), 6);

      await repository.cancelSale('s1');
      expect(await stockOf('p1'), 10);

      // Cancelling again must not double-restore.
      await expectLater(repository.cancelSale('s1'), throwsStateError);
      expect(await stockOf('p1'), 10);
    });
  });
}
