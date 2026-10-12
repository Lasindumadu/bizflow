import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/sale_repository.dart';

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

  Future<void> insertProduct({required String id, int stock = 10}) async {
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
            lowStockThreshold: 2,
          ),
        );
  }

  Future<void> insertSale({
    required String id,
    String status = 'completed',
    bool withItems = true,
    String productId = 'product-1',
    int quantity = 2,
  }) async {
    await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            id: id,
            subtotal: 200,
            total: 200,
            paidAmount: 200,
            status: Value(status),
            createdAt: saleDate,
          ),
        );

    if (withItems) {
      await database
          .into(database.saleItems)
          .insert(
            SaleItemsCompanion.insert(
              id: 'item-$id',
              saleId: id,
              productId: productId,
              productName: 'Test Product $productId',
              quantity: quantity,
              unitPrice: 100,
              purchasePrice: 50,
              total: quantity * 100.0,
            ),
          );
    }
  }

  group('SaleRepository.cancelSale', () {
    test('cancels a completed sale and restores stock', () async {
      await insertProduct(id: 'product-1', stock: 8);
      await insertSale(id: 'sale-1', productId: 'product-1', quantity: 2);

      await repository.cancelSale('sale-1');

      final sale = await repository.getSaleById('sale-1');
      final productQuery = database.select(database.products)
        ..where((table) => table.id.equals('product-1'));
      final product = await productQuery.getSingle();

      expect(sale!.status, 'cancelled');
      expect(product.stockQuantity, 10);

      final movements = await (database.select(
        database.stockMovements,
      )..where((table) => table.productId.equals('product-1'))).get();

      expect(movements, hasLength(1));
      expect(movements.single.type, 'REFUND');
      expect(movements.single.quantity, 2);
      expect(movements.single.previousStock, 8);
      expect(movements.single.newStock, 10);
    });

    test(
      'combines quantities when a product appears in multiple items',
      () async {
        await insertProduct(id: 'product-1', stock: 5);

        await database
            .into(database.sales)
            .insert(
              SalesCompanion.insert(
                id: 'sale-duplicates',
                subtotal: 300,
                total: 300,
                paidAmount: 300,
                createdAt: saleDate,
              ),
            );

        for (final entry in [('item-a', 2), ('item-b', 3)]) {
          await database
              .into(database.saleItems)
              .insert(
                SaleItemsCompanion.insert(
                  id: entry.$1,
                  saleId: 'sale-duplicates',
                  productId: 'product-1',
                  productName: 'Test Product product-1',
                  quantity: entry.$2,
                  unitPrice: 100,
                  purchasePrice: 50,
                  total: entry.$2 * 100.0,
                ),
              );
        }

        await repository.cancelSale('sale-duplicates');

        final productQuery = database.select(database.products)
          ..where((table) => table.id.equals('product-1'));
        final product = await productQuery.getSingle();

        final movements = await (database.select(
          database.stockMovements,
        )..where((table) => table.productId.equals('product-1'))).get();

        expect(product.stockQuantity, 10);
        expect(movements, hasLength(1));
        expect(movements.single.quantity, 5);
      },
    );

    test(
      'rejects repeated cancellation without restoring stock twice',
      () async {
        await insertProduct(id: 'product-1', stock: 8);
        await insertSale(id: 'sale-repeat', productId: 'product-1');

        await repository.cancelSale('sale-repeat');

        await expectLater(
          repository.cancelSale('sale-repeat'),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              'This sale has already been cancelled.',
            ),
          ),
        );

        final productQuery = database.select(database.products)
          ..where((table) => table.id.equals('product-1'));
        final product = await productQuery.getSingle();

        final movements = await (database.select(
          database.stockMovements,
        )..where((table) => table.productId.equals('product-1'))).get();

        expect(product.stockQuantity, 10);
        expect(movements, hasLength(1));
      },
    );

    test('rejects a sale that is not completed', () async {
      await insertProduct(id: 'product-1', stock: 8);
      await insertSale(
        id: 'sale-pending',
        status: 'pending',
        productId: 'product-1',
      );

      await expectLater(
        repository.cancelSale('sale-pending'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Only completed sales can be cancelled.',
          ),
        ),
      );

      final sale = await repository.getSaleById('sale-pending');
      final productQuery = database.select(database.products)
        ..where((table) => table.id.equals('product-1'));
      final product = await productQuery.getSingle();

      expect(sale!.status, 'pending');
      expect(product.stockQuantity, 8);
    });

    test('rejects cancellation when the sale has no items', () async {
      await insertSale(id: 'sale-empty', withItems: false);

      await expectLater(
        repository.cancelSale('sale-empty'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Cannot cancel a sale with no items.',
          ),
        ),
      );

      final sale = await repository.getSaleById('sale-empty');

      expect(sale!.status, 'completed');
    });

    test('rejects cancellation for a missing sale', () async {
      await expectLater(
        repository.cancelSale('missing-sale'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Sale not found.',
          ),
        ),
      );
    });

    test('keeps the sale history after cancellation', () async {
      await insertProduct(id: 'product-1', stock: 8);
      await insertSale(id: 'sale-history', productId: 'product-1');

      await repository.cancelSale('sale-history');

      final sales = await repository.getSales();

      expect(sales.any((sale) => sale.id == 'sale-history'), isTrue);
      expect(
        sales.singleWhere((sale) => sale.id == 'sale-history').status,
        'cancelled',
      );

      final items = await repository.getSaleItems('sale-history');

      expect(items, hasLength(1));
      expect(items.single.quantity, 2);
    });
  });
}
