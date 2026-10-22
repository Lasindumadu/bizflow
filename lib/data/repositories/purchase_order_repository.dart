import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../../core/session/session_authorization.dart';
import 'audit_repository.dart';
import 'product_repository.dart';
import 'stock_movement_repository.dart';

/// One line the caller wants to add to a PO.
class PurchaseOrderLineInput {
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final double unitCost;
  final String notes;

  const PurchaseOrderLineInput({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    required this.unitCost,
    this.notes = '',
  });

  double get total => unitCost * quantity;
}

/// A purchase order item for display.
class PurchaseOrderItemRecord {
  final String id;
  final String purchaseOrderId;
  final String productId;
  final String productName;
  final String productSku;
  final int quantityOrdered;
  final int quantityReceived;
  final double unitCost;
  final double total;
  final String notes;

  const PurchaseOrderItemRecord({
    required this.id,
    required this.purchaseOrderId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitCost,
    required this.total,
    required this.notes,
  });

  int get quantityRemaining => quantityOrdered - quantityReceived;

  static PurchaseOrderItemRecord fromRow(PurchaseOrderItem row) => PurchaseOrderItemRecord(
        id: row.id,
        purchaseOrderId: row.purchaseOrderId,
        productId: row.productId,
        productName: row.productName,
        productSku: row.productSku,
        quantityOrdered: row.quantityOrdered,
        quantityReceived: row.quantityReceived,
        unitCost: row.unitCost,
        total: row.total,
        notes: row.notes,
      );
}

/// A purchase order record for display.
class PurchaseOrderRecord {
  final String id;
  final String supplierId;
  final String supplierReference;
  final String status;
  final double subtotal;
  final double taxAmount;
  final double total;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expectedDate;
  final DateTime? receivedAt;
  final List<PurchaseOrderItemRecord> items;

  const PurchaseOrderRecord({
    required this.id,
    required this.supplierId,
    required this.supplierReference,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.expectedDate,
    this.receivedAt,
    required this.items,
  });

  static PurchaseOrderRecord fromRow(PurchaseOrder row, List<PurchaseOrderItem> items) =>
      PurchaseOrderRecord(
        id: row.id,
        supplierId: row.supplierId,
        supplierReference: row.supplierReference,
        status: row.status,
        subtotal: row.subtotal,
        taxAmount: row.taxAmount,
        total: row.total,
        notes: row.notes,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        expectedDate: row.expectedDate,
        receivedAt: row.receivedAt,
        items: items.map(PurchaseOrderItemRecord.fromRow).toList(),
      );
}

/// Manages purchase orders.
///
/// Status flow: draft → sent → partially_received → received → cancelled
/// When a PO is received (fully or partially), stock is increased and stock movements are recorded.
class PurchaseOrderRepository {
  final AppDatabase database;
  final AuditRepository _audit;
  final ProductRepository _productRepository;
  PurchaseOrderRepository(
    this.database, {
    AuditRepository? audit,
    ProductRepository? productRepository,
    StockMovementRepository? stockMovementRepository,
  }) : _audit = audit ?? AuditRepository(database),
       _productRepository = productRepository ?? ProductRepository(database);

  /// Watches all purchase orders ordered by createdAt desc.
  Stream<List<PurchaseOrderRecord>> watchPurchaseOrders() {
    return (database.select(database.purchaseOrders)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .asyncMap((orders) async {
          final result = <PurchaseOrderRecord>[];
          for (final order in orders) {
            final items = await (database.select(database.purchaseOrderItems)
                  ..where((t) => t.purchaseOrderId.equals(order.id)))
                .get();
            result.add(PurchaseOrderRecord.fromRow(order, items));
          }
          return result;
        });
  }

  /// Gets all purchase orders ordered by createdAt desc.
  Future<List<PurchaseOrderRecord>> getPurchaseOrders() async {
    final orders = await (database.select(database.purchaseOrders)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
    final result = <PurchaseOrderRecord>[];
    for (final order in orders) {
      final items = await (database.select(database.purchaseOrderItems)
            ..where((t) => t.purchaseOrderId.equals(order.id)))
          .get();
      result.add(PurchaseOrderRecord.fromRow(order, items));
    }
    return result;
  }

  /// Gets a purchase order by ID.
  Future<PurchaseOrderRecord?> getPurchaseOrderById(String id) async {
    final order = await (database.select(database.purchaseOrders)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (order == null) return null;

    final items = await (database.select(database.purchaseOrderItems)
          ..where((t) => t.purchaseOrderId.equals(id)))
        .get();
    return PurchaseOrderRecord.fromRow(order, items);
  }

  /// Creates a new purchase order in draft status.
  Future<PurchaseOrderRecord> createPurchaseOrder({
    required String supplierId,
    required List<PurchaseOrderLineInput> lines,
    String supplierReference = '',
    DateTime? expectedDate,
    String notes = '',
  }) async {
    if (lines.isEmpty) {
      throw ArgumentError('A purchase order must have at least one line.');
    }

    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner, StaffRole.manager},
      'create purchase order',
    );

    return database.transaction(() async {
      final id = 'po_${DateTime.now().microsecondsSinceEpoch}';
      final now = DateTime.now();

      final subtotal = lines.fold<double>(0, (s, l) => s + l.total);
      // TODO: Add tax calculation when needed
      const taxAmount = 0.0;
      final total = subtotal + taxAmount;

      await database.into(database.purchaseOrders).insert(
        PurchaseOrdersCompanion.insert(
          id: id,
          supplierId: supplierId,
          staffId: Value(actor.staff?.id),
          supplierReference: Value(supplierReference),
          status: const Value('draft'),
          subtotal: Value(subtotal),
          taxAmount: const Value(taxAmount),
          total: Value(total),
          notes: Value(notes),
          createdAt: now,
          updatedAt: now,
          expectedDate: expectedDate != null ? Value(expectedDate) : const Value.absent(),
        ),
      );

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        await database.into(database.purchaseOrderItems).insert(
          PurchaseOrderItemsCompanion.insert(
            id: '${id}_$i',
            purchaseOrderId: id,
            productId: line.productId,
            productName: line.productName,
            productSku: Value(line.productSku),
            quantityOrdered: line.quantity,
            quantityReceived: const Value(0),
            unitCost: line.unitCost,
            total: line.total,
            notes: Value(line.notes),
          ),
        );
      }

      await _audit.log(
        action: 'purchase_order.create',
        actor: actor.staff?.username ?? 'Owner',
        entityType: 'purchase_order',
        entityId: id,
        summary: 'Created PO $id for supplier $supplierId with ${lines.length} line(s)',
        after: {
          'supplierId': supplierId,
          'lineCount': lines.length,
          'total': total,
          'staffId': actor.staff?.id,
        },
      );

      return getPurchaseOrderById(id) as Future<PurchaseOrderRecord>;
    });
  }

  /// Updates a draft purchase order.
  Future<PurchaseOrderRecord> updatePurchaseOrder({
    required String id,
    required String supplierId,
    required List<PurchaseOrderLineInput> lines,
    String supplierReference = '',
    DateTime? expectedDate,
    String notes = '',
  }) async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner, StaffRole.manager},
      'update purchase order',
    );

    final existing = await getPurchaseOrderById(id);
    if (existing == null) {
      throw StateError('Purchase order not found.');
    }
    if (existing.status != 'draft') {
      throw StateError('Only draft purchase orders can be edited.');
    }

    return database.transaction(() async {
      final now = DateTime.now();

      final subtotal = lines.fold<double>(0, (s, l) => s + l.total);
      const taxAmount = 0.0;
      final total = subtotal + taxAmount;

      await (database.update(database.purchaseOrders)
            ..where((t) => t.id.equals(id)))
          .write(
        PurchaseOrdersCompanion(
          supplierId: Value(supplierId),
          supplierReference: Value(supplierReference),
          subtotal: Value(subtotal),
          taxAmount: const Value(taxAmount),
          total: Value(total),
          notes: Value(notes),
          updatedAt: Value(now),
          expectedDate: expectedDate != null ? Value(expectedDate) : const Value.absent(),
        ),
      );

      // Delete existing items and insert new ones.
      await (database.delete(database.purchaseOrderItems)
            ..where((t) => t.purchaseOrderId.equals(id)))
          .go();

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        await database.into(database.purchaseOrderItems).insert(
          PurchaseOrderItemsCompanion.insert(
            id: '${id}_$i',
            purchaseOrderId: id,
            productId: line.productId,
            productName: line.productName,
            productSku: Value(line.productSku),
            quantityOrdered: line.quantity,
            quantityReceived: const Value(0),
            unitCost: line.unitCost,
            total: line.total,
            notes: Value(line.notes),
          ),
        );
      }

      await _audit.log(
        action: 'purchase_order.update',
        actor: actor.staff?.username ?? 'Owner',
        entityType: 'purchase_order',
        entityId: id,
        summary: 'Updated PO $id',
        after: {
          'supplierId': supplierId,
          'lineCount': lines.length,
          'total': total,
          'staffId': actor.staff?.id,
        },
      );

      return getPurchaseOrderById(id) as Future<PurchaseOrderRecord>;
    });
  }

  /// Sends a draft PO to the supplier (changes status to 'sent').
  Future<PurchaseOrderRecord> sendPurchaseOrder(String id) async {
    return _updateStatus(id, 'sent', 'Sent PO to supplier');
  }

  /// Marks a PO as cancelled.
  Future<PurchaseOrderRecord> cancelPurchaseOrder(String id) async {
    return _updateStatus(id, 'cancelled', 'Cancelled PO');
  }

  /// Receives stock against a purchase order.
  ///
  /// For each line, the received quantity is added to the product's stock,
  /// a RETURN stock movement is recorded (type RECEIPT), and the PO item
  /// is updated. If all lines are fully received, the PO status becomes
  /// 'received', otherwise 'partially_received'.
  Future<PurchaseOrderRecord> receiveStock({
    required String id,
    required Map<String, int> receivedQuantities,
    String notes = '',
  }) async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner, StaffRole.manager},
      'receive stock',
    );

    final existing = await getPurchaseOrderById(id);
    if (existing == null) {
      throw StateError('Purchase order not found.');
    }
    if (existing.status == 'received' || existing.status == 'cancelled') {
      throw StateError('Cannot receive stock for a ${existing.status} PO.');
    }

    return database.transaction(() async {
      final now = DateTime.now();
      bool allFullyReceived = true;

      for (final item in existing.items) {
        final receivedQty = receivedQuantities[item.productId] ?? 0;
        if (receivedQty <= 0) continue;

        final newReceived = item.quantityReceived + receivedQty;
        if (newReceived > item.quantityOrdered) {
          throw StateError(
            'Cannot receive $receivedQty units for "${item.productName}". '
            'Only ${item.quantityRemaining} remaining to receive.',
          );
        }

        // Update the PO item.
        await (database.update(database.purchaseOrderItems)
              ..where((t) => t.id.equals(item.id)))
            .write(
          PurchaseOrderItemsCompanion(quantityReceived: Value(newReceived)),
        );

        // Increase product stock.
        final product = await _productRepository.getProductById(item.productId);
        if (product != null) {
          await _productRepository.changeStock(
            productId: item.productId,
            quantity: receivedQty,
            type: 'RECEIPT',
            note: 'PO receipt $id${notes.isEmpty ? '' : ' — $notes'}',
          );
        } else {
          // Product was deleted; skip stock update but keep PO item.
        }

        if (newReceived < item.quantityOrdered) {
          allFullyReceived = false;
        }
      }

      final newStatus = allFullyReceived ? 'received' : 'partially_received';
      final updatedOrder = await (database.update(database.purchaseOrders)
            ..where((t) => t.id.equals(id)))
          .write(
        PurchaseOrdersCompanion(
          status: Value(newStatus),
          updatedAt: Value(now),
          receivedAt: allFullyReceived ? Value(now) : const Value.absent(),
        ),
      ).then((_) => getPurchaseOrderById(id) as Future<PurchaseOrderRecord>);

      await _audit.log(
        action: 'purchase_order.receive',
        actor: actor.staff?.username ?? 'Owner',
        entityType: 'purchase_order',
        entityId: id,
        summary: 'Received stock for PO $id (status: $newStatus)',
        after: {
          'receivedQuantities': receivedQuantities,
          'newStatus': newStatus,
          'staffId': actor.staff?.id,
        },
      );

      return updatedOrder;
    });
  }

  /// Deletes a draft purchase order.
  Future<void> deletePurchaseOrder(String id) async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner},
      'delete purchase order',
    );

    final existing = await getPurchaseOrderById(id);
    if (existing == null) {
      throw StateError('Purchase order not found.');
    }
    if (existing.status != 'draft') {
      throw StateError('Only draft purchase orders can be deleted.');
    }

    await (database.delete(database.purchaseOrderItems)
          ..where((t) => t.purchaseOrderId.equals(id)))
        .go();

    await (database.delete(database.purchaseOrders)
          ..where((t) => t.id.equals(id)))
        .go();

    await _audit.log(
      action: 'purchase_order.delete',
      actor: actor.staff?.username ?? 'Owner',
      entityType: 'purchase_order',
      entityId: id,
      summary: 'Deleted draft PO $id',
    );
  }

  Future<PurchaseOrderRecord> _updateStatus(String id, String newStatus, String summary) async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner, StaffRole.manager},
      'purchase order status change',
    );

    final existing = await getPurchaseOrderById(id);
    if (existing == null) {
      throw StateError('Purchase order not found.');
    }

    final validTransitions = {
      'draft': ['sent', 'cancelled'],
      'sent': ['partially_received', 'received', 'cancelled'],
      'partially_received': ['received', 'cancelled'],
    };

    final allowed = validTransitions[existing.status];
    if (allowed == null || !allowed.contains(newStatus)) {
      throw StateError('Invalid status transition from ${existing.status} to $newStatus.');
    }

    await (database.update(database.purchaseOrders)
          ..where((t) => t.id.equals(id)))
        .write(
      PurchaseOrdersCompanion(
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
        receivedAt: newStatus == 'received' ? Value(DateTime.now()) : const Value.absent(),
      ),
    );

    await _audit.log(
      action: 'purchase_order.status_change',
      actor: actor.staff?.username ?? 'Owner',
      entityType: 'purchase_order',
      entityId: id,
      summary: summary,
      after: {'newStatus': newStatus, 'staffId': actor.staff?.id},
    );

    return getPurchaseOrderById(id) as Future<PurchaseOrderRecord>;
  }
}