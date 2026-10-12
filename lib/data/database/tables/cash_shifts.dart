import 'package:drift/drift.dart';

/// A cashier shift: opened with a float, closed with a counted amount.
///
/// Expected cash = opening float + cash sales during the shift
///                 + cash-in − cash-out − cash refunds.
class CashShifts extends Table {
  TextColumn get id => text()();

  IntColumn get shiftNumber => integer()();

  /// Cash in the drawer when the shift opened.
  RealColumn get openingFloat => real().withDefault(const Constant(0.0))();

  /// Cash counted by the operator when closing (null while the shift is open).
  RealColumn get closingCount => real().nullable()();

  /// Operator's explanation for any discrepancy.
  TextColumn get discrepancyReason => text().withDefault(const Constant(''))();

  DateTimeColumn get openedAt => dateTime()();

  DateTimeColumn get closedAt => dateTime().nullable()();

  BoolColumn get isOpen => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
