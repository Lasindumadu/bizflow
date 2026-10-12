import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/return_repository.dart';

void main() {
  late AppDatabase database;
  late ReturnRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ReturnRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertProduct({required String id, int stock = 0}) async {
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: id,
            name: 'Product $id',
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
    required String saleId,
    required int quantity,
    String status = 'completed',
  }) async {
    await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            id: saleId,
            subtotal: quantity * 100.0,
            total: quantity * 100.0,
            paidAmount: quantity * 100.0,
            status: Value(status),
            createdAt: DateTime.now(),
          ),
        );
    await database
        .into(database.saleItems)
        .insert(
          SaleItemsCompanion.insert(
            id: 'item-$saleId',
            saleId: saleId,
            productId: 'p1',
            productName: 'Product p1',
            quantity: quantity,
            unitPrice: 100,
            purchasePrice: 50,
            total: quantity * 100.0,
          ),
        );
  }

  ReturnLine line(int qty) => ReturnLine(
    productId: 'p1',
    productName: 'Product p1',
    quantity: qty,
    unitPrice: 100,
    purchasePrice: 50,
  );

  group('createReturn', () {
    test('records a full refund and restocks by default', () async {
      await insertProduct(id: 'p1', stock: 0);
      await insertSale(saleId: 's1', quantity: 3);

      final result = await repository.createReturn(
        saleId: 's1',
        lines: [line(3)],
      );

      expect(result.refundAmount, 300);

      final product = (await database.select(database.products).get()).single;
      expect(product.stockQuantity, 3, reason: 'restocked');

      final movements = await database.select(database.stockMovements).get();
      expect(movements.single.type, 'RETURN');
      expect(movements.single.quantity, 3);
    });

    test(
      'supports partial returns and tracks remaining returnable units',
      () async {
        await insertProduct(id: 'p1', stock: 0);
        await insertSale(saleId: 's1', quantity: 5);

        await repository.createReturn(saleId: 's1', lines: [line(2)]);

        final returnable = await repository.getReturnableQuantities('s1');
        expect(returnable['p1'], 3);

        await repository.createReturn(saleId: 's1', lines: [line(3)]);
        final after = await repository.getReturnableQuantities('s1');
        expect(after['p1'], 0);

        final product = (await database.select(database.products).get()).single;
        expect(product.stockQuantity, 5);
      },
    );

    test('rejects returning more than was sold', () async {
      await insertSale(saleId: 's1', quantity: 2);

      await expectLater(
        repository.createReturn(saleId: 's1', lines: [line(3)]),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects returning more than remains after prior returns', () async {
      await insertSale(saleId: 's1', quantity: 3);
      await repository.createReturn(saleId: 's1', lines: [line(2)]);

      await expectLater(
        repository.createReturn(saleId: 's1', lines: [line(2)]),
        throwsA(isA<StateError>()),
      );
    });

    test('does not restock when restock is false', () async {
      await insertProduct(id: 'p1', stock: 0);
      await insertSale(saleId: 's1', quantity: 2);

      await repository.createReturn(
        saleId: 's1',
        lines: [line(2)],
        restock: false,
      );

      final product = (await database.select(database.products).get()).single;
      expect(product.stockQuantity, 0);
      expect(await database.select(database.stockMovements).get(), isEmpty);
    });

    test('rejects an empty return', () async {
      await insertSale(saleId: 's1', quantity: 1);

      await expectLater(
        repository.createReturn(saleId: 's1', lines: [line(0)]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects a return for a missing sale', () async {
      await expectLater(
        repository.createReturn(saleId: 'missing', lines: [line(1)]),
        throwsA(isA<StateError>()),
      );
    });

    test('never deletes or mutates the original sale', () async {
      await insertProduct(id: 'p1', stock: 0);
      await insertSale(saleId: 's1', quantity: 4);

      await repository.createReturn(saleId: 's1', lines: [line(4)]);

      final sale = (await database.select(database.sales).get()).single;
      expect(sale.status, 'completed', reason: 'original sale untouched');
      expect(sale.total, 400);
      expect(await database.select(database.saleItems).get(), hasLength(1));
    });

    test('writes an audit entry for the refund', () async {
      await insertProduct(id: 'p1', stock: 0);
      await insertSale(saleId: 's1', quantity: 1);

      await repository.createReturn(saleId: 's1', lines: [line(1)]);

      final logs = await database.select(database.auditLogs).get();
      expect(logs, hasLength(1));
      expect(logs.single.action, 'refund.create');
      expect(logs.single.entityId, 's1');
    });
  });

  group('reporting helpers', () {
    test('getTotalRefunded sums all refunds', () async {
      await insertProduct(id: 'p1', stock: 0);
      await insertSale(saleId: 's1', quantity: 3);
      await repository.createReturn(saleId: 's1', lines: [line(1)]);
      await insertSale(saleId: 's2', quantity: 3);
      await repository.createReturn(saleId: 's2', lines: [line(2)]);

      expect(await repository.getTotalRefunded(), 300);
    });

    test('getReturnsForSale lists its returns newest first', () async {
      await insertProduct(id: 'p1', stock: 0);
      await insertSale(saleId: 's1', quantity: 5);
      await repository.createReturn(saleId: 's1', lines: [line(2)]);
      await repository.createReturn(saleId: 's1', lines: [line(1)]);

      final returns = await repository.getReturnsForSale('s1');
      expect(returns, hasLength(2));
      expect(returns.first.items.single.quantity, 1);
    });
  });
}
