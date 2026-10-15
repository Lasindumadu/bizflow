import 'package:drift/drift.dart';

/// A single line item on a purchase order.
class PurchaseOrderItems extends Table {
  TextColumn get id => text()();

  TextColumn get purchaseOrderId => text()();

  TextColumn get productId => text()();

  TextColumn get productName => text()();

  TextColumn get productSku => text().withDefault(const Constant(''))();

  /// Quantity ordered.
  IntColumn get quantityOrdered => integer()();

  /// Quantity received so far.
  IntColumn get quantityReceived =>
      integer().withDefault(const Constant(0))();

  /// Unit cost from supplier.
  RealColumn get unitCost => real()();

  /// Line total (quantityOrdered × unitCost).
  RealColumn get total => real()();

  /// Optional notes for this line.
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}