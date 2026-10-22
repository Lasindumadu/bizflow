import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../../core/session/session_authorization.dart';
import 'audit_repository.dart';

/// One line the caller wants to return.
class ReturnLine {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double purchasePrice;

  const ReturnLine({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.purchasePrice,
  });

  double get total => unitPrice * quantity;
}

/// Summary of an already-recorded return for a sale.
class SaleReturnRecord {
  final String id;
  final String saleId;
  final double refundAmount;
  final String refundMethod;
  final bool restocked;
  final String reason;
  final DateTime createdAt;
  final List<SaleReturnItem> items;

  const SaleReturnRecord({
    required this.id,
    required this.saleId,
    required this.refundAmount,
    required this.refundMethod,
    required this.restocked,
    required this.reason,
    required this.createdAt,
    required this.items,
  });
}

/// Handles returns and refunds against completed sales.
///
/// A return:
///  * validates quantities against the original sale and any prior returns;
///  * refunds money (recorded independently for reporting);
///  * optionally restocks inventory and writes a `RETURN` stock movement;
///  * is written to the audit trail.
///
/// It never deletes or mutates the original sale, so history stays intact.
class ReturnRepository {
  final AppDatabase database;
  final AuditRepository _audit;

  ReturnRepository(this.database, {AuditRepository? audit})
    : _audit = audit ?? AuditRepository(database);

  /// Resolves the acting staff and enforces cashier-or-above authorization
  /// for refund operations.
  Future<ResolvedActor> _authorizeCashier() async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner, StaffRole.manager, StaffRole.cashier},
      'refund / return operations',
    );
    return actor;
  }

  /// For each product on [saleId], how many units remain returnable, taking
  /// previously recorded returns into account.
  Future<Map<String, int>> getReturnableQuantities(String saleId) async {
    final items = await (database.select(
      database.saleItems,
    )..where((t) => t.saleId.equals(saleId))).get();

    final soldByProduct = <String, int>{};
    for (final item in items) {
      soldByProduct[item.productId] =
          (soldByProduct[item.productId] ?? 0) + item.quantity;
    }

    final returnItems = await _returnItemsForSale(saleId);
    final returnedByProduct = <String, int>{};
    for (final item in returnItems) {
      returnedByProduct[item.productId] =
          (returnedByProduct[item.productId] ?? 0) + item.quantity;
    }

    return {
      for (final entry in soldByProduct.entries)
        entry.key: (entry.value - (returnedByProduct[entry.key] ?? 0)).clamp(
          0,
          entry.value,
        ),
    };
  }

  /// Records a return. Throws when the requested quantities are invalid.
  Future<SaleReturnRecord> createReturn({
    required String saleId,
    required List<ReturnLine> lines,
    String refundMethod = 'cash',
    bool restock = true,
    String reason = '',
  }) async {
    final validLines = lines.where((l) => l.quantity > 0).toList();
    if (validLines.isEmpty) {
      throw ArgumentError('A return must include at least one item.');
    }

    final actor = await _authorizeCashier();

    return database.transaction(() async {
      final sale = await (database.select(
        database.sales,
      )..where((t) => t.id.equals(saleId))).getSingleOrNull();

      if (sale == null) {
        throw StateError('Sale not found.');
      }

      // Re-check the latest returnable quantities inside the transaction.
      final returnable = await getReturnableQuantities(saleId);
      final requested = <String, int>{};
      for (final line in validLines) {
        requested[line.productId] =
            (requested[line.productId] ?? 0) + line.quantity;
      }

      for (final entry in requested.entries) {
        final available = returnable[entry.key] ?? 0;
        if (entry.value > available) {
          throw StateError(
            'Cannot return ${entry.value} unit(s); only $available '
            'remain returnable for that item.',
          );
        }
      }

      final returnId = 'ret_${DateTime.now().microsecondsSinceEpoch}';
      final refundAmount = validLines.fold<double>(0, (s, l) => s + l.total);

      await database
          .into(database.saleReturns)
          .insert(
            SaleReturnsCompanion.insert(
              id: returnId,
              saleId: saleId,
              customerId: Value(sale.customerId),
              staffId: Value(actor.staff?.id),
              refundAmount: refundAmount,
              refundMethod: Value(refundMethod),
              restocked: Value(restock),
              reason: Value(reason),
              createdAt: DateTime.now(),
            ),
          );

      for (var i = 0; i < validLines.length; i++) {
        final line = validLines[i];
        await database
            .into(database.saleReturnItems)
            .insert(
              SaleReturnItemsCompanion.insert(
                id: '${returnId}_$i',
                returnId: returnId,
                saleId: saleId,
                productId: line.productId,
                productName: line.productName,
                quantity: line.quantity,
                unitPrice: line.unitPrice,
                purchasePrice: line.purchasePrice,
                total: line.total,
              ),
            );

        if (restock) {
          await _restock(
            productId: line.productId,
            quantity: line.quantity,
            returnId: returnId,
            staffId: actor.staff?.id,
          );
        }
      }

      await _audit.log(
        action: 'refund.create',
        actor: actor.staff?.username ?? 'Owner',
        entityType: 'sale',
        entityId: saleId,
        summary:
            'Refund ${refundAmount.toStringAsFixed(2)} via $refundMethod'
            '${restock ? ' (restocked)' : ' (not restocked)'}',
        after: {
          'returnId': returnId,
          'refundAmount': refundAmount,
          'method': refundMethod,
          'restocked': restock,
          'staffId': actor.staff?.id,
        },
      );

      final items = await (database.select(
        database.saleReturnItems,
      )..where((t) => t.returnId.equals(returnId))).get();

      return SaleReturnRecord(
        id: returnId,
        saleId: saleId,
        refundAmount: refundAmount,
        refundMethod: refundMethod,
        restocked: restock,
        reason: reason,
        createdAt: DateTime.now(),
        items: items,
      );
    });
  }

  /// All returns recorded against a sale.
  Future<List<SaleReturnRecord>> getReturnsForSale(String saleId) async {
    final returns = await (database.select(
      database.saleReturns,
    )..where((t) => t.saleId.equals(saleId))).get();

    final result = <SaleReturnRecord>[];
    for (final r in returns) {
      final items = await (database.select(
        database.saleReturnItems,
      )..where((t) => t.returnId.equals(r.id))).get();
      result.add(
        SaleReturnRecord(
          id: r.id,
          saleId: r.saleId,
          refundAmount: r.refundAmount,
          refundMethod: r.refundMethod,
          restocked: r.restocked,
          reason: r.reason,
          createdAt: r.createdAt,
          items: items,
        ),
      );
    }

    result.sort((a, b) {
      final byDate = b.createdAt.compareTo(a.createdAt);
      if (byDate != 0) return byDate;
      // Tie-break on id, which embeds the creation timestamp, so ordering is
      // deterministic even when two returns share a timestamp.
      return b.id.compareTo(a.id);
    });
    return result;
  }

  /// Total amount refunded across all sales (for reporting).
  Future<double> getTotalRefunded() async {
    final rows = await database.select(database.saleReturns).get();
    return rows.fold<double>(0, (s, r) => s + r.refundAmount);
  }

  Future<void> _restock({
    required String productId,
    required int quantity,
    required String returnId,
    String? staffId,
  }) async {
    final product = await (database.select(
      database.products,
    )..where((t) => t.id.equals(productId))).getSingleOrNull();

    // If the product no longer exists, skip restocking but keep the return.
    if (product == null) return;

    final previousStock = product.stockQuantity;
    final newStock = previousStock + quantity;

    await (database.update(database.products)
          ..where((t) => t.id.equals(productId)))
        .write(ProductsCompanion(stockQuantity: Value(newStock)));

    await database
        .into(database.stockMovements)
        .insert(
          StockMovementsCompanion.insert(
            id: 'mov_${DateTime.now().microsecondsSinceEpoch}_$productId',
            productId: productId,
            type: 'RETURN',
            quantity: quantity,
            previousStock: previousStock,
            newStock: newStock,
            note: Value('Return $returnId'),
            staffId: Value(staffId),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<List<SaleReturnItem>> _returnItemsForSale(String saleId) {
    return (database.select(
      database.saleReturnItems,
    )..where((t) => t.saleId.equals(saleId))).get();
  }
}
