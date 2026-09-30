import 'package:drift/drift.dart';

class StockMovements extends Table {
  TextColumn get id => text()();

  TextColumn get productId => text()();

  TextColumn get type => text()();

  IntColumn get quantity => integer()();

  IntColumn get previousStock => integer()();

  IntColumn get newStock => integer()();

  TextColumn get note => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
