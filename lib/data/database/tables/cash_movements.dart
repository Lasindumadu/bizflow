import 'package:drift/drift.dart';

/// A manual cash movement within an open shift (petty cash out, float top-up).
class CashMovements extends Table {
  TextColumn get id => text()();

  TextColumn get shiftId => text()();

  /// 'in' adds cash to the drawer, 'out' removes it.
  TextColumn get direction => text()();

  RealColumn get amount => real()();

  TextColumn get note => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  /// The staff member who recorded this cash movement.
  TextColumn get staffId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
