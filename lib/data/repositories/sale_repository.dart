import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/session/session_authorization.dart';
import '../../models/sale.dart' as model;
import '../../models/sale_item.dart' as model;
import '../database/app_database.dart' as db;

class SaleRepository {
  final db.AppDatabase database;

  /// Called when a completed sale pushes a product's stock at or below its
  /// low-stock threshold. Receives the product name and remaining stock.
  ///
  /// Invoked *after* the sale has been committed — treat as best-effort.
  final void Function(String productName, int remainingStock)? onLowStock;

  SaleRepository(this.database, {this.onLowStock});

  /// Resolves the acting staff and enforces cashier-or-above authorization.
  Future<ResolvedActor> _authorizeCashier() async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner, StaffRole.manager, StaffRole.cashier},
      'sale operations',
    );
    return actor;
  }

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
    double taxAmount = 0.0,
    String? paymentMethodDetails,
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

    final actor = await _authorizeCashier();

    return database.transaction(() async {
      final Map<String, double> productQuantities = {};

      for (final item in items) {
        if (item.quantity <= 0) {
          throw StateError('Invalid quantity for ${item.productName}.');
        }

        final currentQuantity = productQuantities[item.productId] ?? 0.0;

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
              staffId: Value(actor.staff?.id),
              subtotal: subtotal,
              discount: Value(discount),
              total: total,
              paidAmount: paidAmount,
              paymentMethod: Value(paymentMethod),
              taxAmount: Value(taxAmount),
              paymentMethodDetails:
                  paymentMethodDetails == null
                      ? const Value.absent()
                      : Value(paymentMethodDetails),
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
                batchNumber: Value(item.batchNumber),
                expiryDate: Value(item.expiryDate),
              ),
            );
      }

      // Deduct stock and create stock movement records.
      for (final entry in productQuantities.entries) {
        final productQuery = database.select(database.products)
          ..where((table) => table.id.equals(entry.key));

        final product = await productQuery.getSingle();

        final double previousStock = product.stockQuantity.toDouble();
        final double soldQuantity = entry.value.toDouble();
        final double newStock = previousStock - soldQuantity;

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
                staffId: Value(actor.staff?.id),
                createdAt: createdAt,
              ),
            );

        // Fire a low-stock alert when this sale just crossed the threshold.
        if (onLowStock != null &&
            previousStock > product.lowStockThreshold &&
            newStock <= product.lowStockThreshold) {
          onLowStock!(product.name, newStock.toInt());
        }
      }

      // Audit the completed sale (best-effort — never blocks the sale).
      try {
        await database
            .into(database.auditLogs)
            .insert(
              db.AuditLogsCompanion.insert(
                id: 'aud_${DateTime.now().microsecondsSinceEpoch}',
                action: 'sale.complete',
                actor: Value(actor.staff?.username ?? 'Owner'),
                summary: Value(
                  'Completed sale $saleId for ${total.toStringAsFixed(2)} '
                  'via $paymentMethod',
                ),
                entityType: Value('sale'),
                entityId: Value(saleId),
                afterJson: Value(
                  jsonEncode({
                    'total': total,
                    'paymentMethod': paymentMethod,
                    'staffId': actor.staff?.id,
                  }),
                ),
                createdAt: createdAt,
              ),
            );
      } catch (_) {
        // Auditing must never block a completed sale.
      }

      return model.Sale(
        id: saleId,
        customerId: customerId,
        staffId: actor.staff?.id,
        subtotal: subtotal,
        discount: discount,
        taxAmount: 0.0,
        total: total,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
        paymentMethodDetails: null,
        status: 'completed',
        createdAt: createdAt,
      );
    });
  }

  Future<void> cancelSale(String saleId) async {
    final actor = await _authorizeCashier();

    await database.transaction(() async {
      final saleQuery = database.select(database.sales)
        ..where((table) => table.id.equals(saleId));

      final sale = await saleQuery.getSingleOrNull();

      if (sale == null) {
        throw StateError('Sale not found.');
      }

      // Only completed sales may be cancelled.
      // This prevents duplicate stock restoration and invalid transitions.
      if (sale.status != 'completed') {
        throw StateError(
          sale.status == 'cancelled'
              ? 'This sale has already been cancelled.'
              : 'Only completed sales can be cancelled.',
        );
      }

      final itemQuery = database.select(database.saleItems)
        ..where((table) => table.saleId.equals(saleId));

      final items = await itemQuery.get();

      if (items.isEmpty) {
        throw StateError('Cannot cancel a sale with no items.');
      }

      // Combine quantities in case the same product
      // appears on multiple sale-item rows.
      final Map<String, double> productQuantities = {};

      for (final item in items) {
        final currentQuantity = productQuantities[item.productId] ?? 0.0;

        productQuantities[item.productId] = currentQuantity + item.quantity;
      }

      // Restore stock for products that still exist.
      //
      // Deleted products have no product record to update,
      // so their historical sale items remain unchanged.
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
                quantity: returnedQuantity.toDouble(),
                previousStock: previousStock.toDouble(),
                newStock: newStock.toDouble(),
                note: Value('Cancellation of sale $saleId'),
                staffId: Value(actor.staff?.id),
                createdAt: DateTime.now(),
              ),
            );
      }

      // Keep the sale for history, but mark it cancelled.
      await (database.update(database.sales)
            ..where((table) => table.id.equals(saleId)))
          .write(const db.SalesCompanion(status: Value('cancelled')));

      // Audit the cancellation (best-effort — never blocks the cancel).
      try {
        await database
            .into(database.auditLogs)
            .insert(
              db.AuditLogsCompanion.insert(
                id: 'aud_${DateTime.now().microsecondsSinceEpoch}',
                action: 'sale.cancel',
                actor: Value(actor.staff?.username ?? 'Owner'),
                entityType: const Value('sale'),
                entityId: Value(saleId),
                summary: Value(
                  'Cancelled sale $saleId and restored '
                  '${productQuantities.values.fold<double>(0.0, (a, b) => a + b)} '
                  'unit(s) to stock',
                ),
                afterJson: const Value('{"status":"cancelled"}'),
                createdAt: DateTime.now(),
              ),
            );
      } catch (_) {
        // Auditing must never break cancellation.
      }
    });
  }

  Future<void> deleteSale(String id) async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner},
      'delete sale',
    );

    await database.transaction(() async {
      await (database.delete(
        database.saleItems,
      )..where((table) => table.saleId.equals(id))).go();

      await (database.delete(
        database.sales,
      )..where((table) => table.id.equals(id))).go();

      // Audit the deletion (best-effort).
      try {
        await database
            .into(database.auditLogs)
            .insert(
              db.AuditLogsCompanion.insert(
                id: 'aud_${DateTime.now().microsecondsSinceEpoch}',
                action: 'sale.delete',
                actor: Value(actor.staff?.username ?? 'Owner'),
                summary: Value('Deleted sale $id'),
                entityType: Value('sale'),
                entityId: Value(id),
                createdAt: DateTime.now(),
              ),
            );
      } catch (_) {
        // Auditing must never block deletion.
      }
    });
  }

  model.Sale _toSaleModel(db.Sale row) {
    return model.Sale(
      id: row.id,
      customerId: row.customerId,
      staffId: row.staffId,
      subtotal: row.subtotal,
      discount: row.discount,
      taxAmount: row.taxAmount,
      total: row.total,
      paidAmount: row.paidAmount,
      paymentMethod: row.paymentMethod,
      paymentMethodDetails: row.paymentMethodDetails,
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
      batchNumber: row.batchNumber,
      expiryDate: row.expiryDate,
    );
  }
}
