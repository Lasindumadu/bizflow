import 'package:drift/drift.dart';

/// A purchase order sent to a supplier.
///
/// Status flow: draft → sent → partially_received → received → cancelled
class PurchaseOrders extends Table {
  TextColumn get id => text()();

  /// The supplier this PO is for.
  TextColumn get supplierId => text()();

  /// Optional reference number from the supplier.
  TextColumn get supplierReference => text().withDefault(const Constant(''))();

  /// PO status.
  TextColumn get status =>
      text().withDefault(const Constant('draft'))();

  /// Subtotal before tax.
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();

  /// Tax amount.
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();

  /// Total amount including tax.
  RealColumn get total => real().withDefault(const Constant(0.0))();

  /// Notes for the supplier.
  TextColumn get notes => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  /// Expected delivery date.
  DateTimeColumn get expectedDate => dateTime().nullable()();

  /// Actual received date (when fully received).
  DateTimeColumn get receivedAt => dateTime().nullable()();

  /// The staff member who created this purchase order.
  TextColumn get staffId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}