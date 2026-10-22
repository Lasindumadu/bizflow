import 'package:drift/drift.dart';

/// A refund/return against a previously completed sale.
///
/// A return may be full or partial (see [SaleReturnItems.quantity]).
/// The refunded amount is recorded independently of the original sale so that
/// reporting can compute net revenue and returns impact.
class SaleReturns extends Table {
  TextColumn get id => text()();

  /// The sale being returned against.
  TextColumn get saleId => text()();

  /// Optional customer on the original sale.
  TextColumn get customerId => text().nullable()();

  /// Total value refunded for this return.
  RealColumn get refundAmount => real()();

  /// How the money was returned: cash, card, credit, etc.
  TextColumn get refundMethod => text().withDefault(const Constant('cash'))();

  /// Whether restocked items were put back into inventory.
  BoolColumn get restocked => boolean().withDefault(const Constant(true))();

  /// Free-form reason (e.g. "damaged", "wrong item").
  TextColumn get reason => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  /// The authenticated staff member who processed the return. Null for legacy
  /// records and for operations performed while login enforcement is disabled.
  TextColumn get staffId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
