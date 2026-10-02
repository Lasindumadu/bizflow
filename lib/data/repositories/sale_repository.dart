import 'package:drift/drift.dart';

import '../../models/sale.dart' as model;
import '../../models/sale_item.dart' as model;
import '../database/app_database.dart' as db;

class SaleRepository {
  final db.AppDatabase database;

  SaleRepository(this.database);

  Stream<List<model.Sale>> watchSales() {
    final query = database.select(database.sales)
      ..orderBy([
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.id),
      ]);

    return query.watch().map((rows) => rows.map(_toSaleModel).toList());
  }

  Future<List<model.Sale>> getSales() async {
    final query = database.select(database.sales)
      ..orderBy([
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.id),
      ]);

    final rows = await query.get();
    return rows.map(_toSaleModel).toList();
  }

  Future<model.Sale?> getSaleById(String id) async {
    final query = database.select(database.sales)
      ..where((table) => table.id.equals(id));

    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toSaleModel(row);
  }

  Future<List<model.SaleItem>> getSaleItems(String saleId) async {
    final query = database.select(database.saleItems)
      ..where((table) => table.saleId.equals(saleId));

    final rows = await query.get();

    return rows.map(_toSaleItemModel).toList();
  }

  Future<model.Sale> completeSale({
    required String saleId,
    String? customerId,
    required double subtotal,
    double discount = 0.0,
    required double total,
    required double paidAmount,
    String paymentMethod = 'cash',
    required DateTime createdAt,
    required List<model.SaleItem> items,
  }) async {
    if (items.isEmpty) {
      throw StateError('Cannot complete a sale with an empty cart.');
    }

    if (subtotal < 0) {
      throw ArgumentError('Subtotal cannot be negative.');
    }

    if (discount < 0) {
      throw ArgumentError('Discount cannot be negative.');
    }

    if (total < 0) {
      throw ArgumentError('Total cannot be negative.');
    }

    if (paidAmount < total) {
      throw StateError('Paid amount is less than the sale total.');
    }

    return database.transaction(() async {
      final Map<String, int> productQuantities = {};

      for (final item in items) {
        if (item.quantity <= 0) {
          throw StateError('Invalid quantity for ${item.productName}.');
        }

        final currentQuantity = productQuantities[item.productId] ?? 0;

        productQuantities[item.productId] = currentQuantity + item.quantity;
      }

      // Re-check the latest stock directly from the database.
      for (final entry in productQuantities.entries) {
        final productQuery = database.select(database.products)
          ..where((table) => table.id.equals(entry.key));

        final product = await productQuery.getSingleOrNull();

        if (product == null) {
          throw StateError('Product not found: ${entry.key}.');
        }

        final requestedQuantity = entry.value;

        if (product.stockQuantity < requestedQuantity) {
          throw StateError(
            'Not enough stock for ${product.name} '
            '(SKU: ${product.sku}). '
            'Available stock: ${product.stockQuantity}.',
          );
        }
      }

      // Create the sale.
      await database
          .into(database.sales)
          .insert(
            db.SalesCompanion.insert(
              id: saleId,
              customerId: Value(customerId),
              subtotal: subtotal,
              discount: Value(discount),
              total: total,
              paidAmount: paidAmount,
              paymentMethod: Value(paymentMethod),
              status: const Value('completed'),
              createdAt: createdAt,
            ),
          );

      // Create all sale items.
      for (final item in items) {
        final productQuery = database.select(database.products)
          ..where((table) => table.id.equals(item.productId));

        final product = await productQuery.getSingleOrNull();

        if (product == null) {
          throw StateError('Product not found: ${item.productId}.');
        }

        await database
            .into(database.saleItems)
            .insert(
              db.SaleItemsCompanion.insert(
                id: item.id,
                saleId: item.saleId,
                productId: item.productId,
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                purchasePrice: product.purchasePrice,
                total: item.total,
              ),
            );
      }

      // Deduct stock and create stock movement records.
      for (final entry in productQuantities.entries) {
        final productQuery = database.select(database.products)
          ..where((table) => table.id.equals(entry.key));

        final product = await productQuery.getSingle();

        final int previousStock = product.stockQuantity;
        final int soldQuantity = entry.value;
        final int newStock = previousStock - soldQuantity;

        await (database.update(database.products)
              ..where((table) => table.id.equals(entry.key)))
            .write(db.ProductsCompanion(stockQuantity: Value(newStock)));

        await database
            .into(database.stockMovements)
            .insert(
              db.StockMovementsCompanion.insert(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                productId: entry.key,
                type: 'SALE',
                quantity: soldQuantity,
                previousStock: previousStock,
                newStock: newStock,
                note: Value('Sale $saleId'),
                createdAt: createdAt,
              ),
            );
      }

      return model.Sale(
        id: saleId,
        customerId: customerId,
        subtotal: subtotal,
        discount: discount,
        total: total,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
        status: 'completed',
        createdAt: createdAt,
      );
    });
  }

  Future<void> cancelSale(String saleId) async {
    await database.transaction(() async {
      final saleQuery = database.select(database.sales)
        ..where((table) => table.id.equals(saleId));

      final sale = await saleQuery.getSingleOrNull();

      if (sale == null) {
        throw StateError('Sale not found.');
      }

      if (sale.status == 'cancelled') {
        throw StateError('This sale has already been cancelled.');
      }

      final itemQuery = database.select(database.saleItems)
        ..where((table) => table.saleId.equals(saleId));

      final items = await itemQuery.get();

      if (items.isEmpty) {
        throw StateError('Cannot cancel a sale with no items.');
      }

      // Combine quantities in case the same product
      // appears on multiple sale-item rows.
      final Map<String, int> productQuantities = {};

      for (final item in items) {
        final currentQuantity = productQuantities[item.productId] ?? 0;

        productQuantities[item.productId] = currentQuantity + item.quantity;
      }

      // Restore stock for products that still exist.
      //
      // A product may have been deleted after the sale was created.
      // In that case, the historical sale item is retained, but there
      // is no product record available to restore stock to.
      for (final entry in productQuantities.entries) {
        final productQuery = database.select(database.products)
          ..where((table) => table.id.equals(entry.key));

        final product = await productQuery.getSingleOrNull();

        if (product == null) {
          continue;
        }

        final previousStock = product.stockQuantity;
        final returnedQuantity = entry.value;
        final newStock = previousStock + returnedQuantity;

        await (database.update(database.products)
              ..where((table) => table.id.equals(entry.key)))
            .write(db.ProductsCompanion(stockQuantity: Value(newStock)));

        await database
            .into(database.stockMovements)
            .insert(
              db.StockMovementsCompanion.insert(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                productId: entry.key,
                type: 'REFUND',
                quantity: returnedQuantity,
                previousStock: previousStock,
                newStock: newStock,
                note: Value('Refund $saleId'),
                createdAt: DateTime.now(),
              ),
            );
      }

      // Keep the sale for history, but mark it cancelled.
      await (database.update(database.sales)
            ..where((table) => table.id.equals(saleId)))
          .write(const db.SalesCompanion(status: Value('cancelled')));
    });
  }

  Future<void> deleteSale(String id) async {
    await database.transaction(() async {
      await (database.delete(
        database.saleItems,
      )..where((table) => table.saleId.equals(id))).go();

      await (database.delete(
        database.sales,
      )..where((table) => table.id.equals(id))).go();
    });
  }

  model.Sale _toSaleModel(db.Sale row) {
    return model.Sale(
      id: row.id,
      customerId: row.customerId,
      subtotal: row.subtotal,
      discount: row.discount,
      total: row.total,
      paidAmount: row.paidAmount,
      paymentMethod: row.paymentMethod,
      status: row.status,
      createdAt: row.createdAt,
    );
  }

  model.SaleItem _toSaleItemModel(db.SaleItem row) {
    return model.SaleItem(
      id: row.id,
      saleId: row.saleId,
      productId: row.productId,
      productName: row.productName,
      quantity: row.quantity,
      unitPrice: row.unitPrice,
      purchasePrice: row.purchasePrice,
    );
  }
}
