import 'package:drift/drift.dart';

class StockMovements extends Table {
  TextColumn get id => text()();

  TextColumn get productId => text()();

  TextColumn get type => text()();

  RealColumn get quantity => real()();

  RealColumn get previousStock => real()();

  RealColumn get newStock => real()();

  TextColumn get note => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  /// The staff member who recorded this stock movement.
  TextColumn get staffId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
