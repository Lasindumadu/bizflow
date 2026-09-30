import 'package:drift/drift.dart';

class SaleItems extends Table {
  TextColumn get id => text()();

  TextColumn get saleId => text()();

  TextColumn get productId => text()();

  TextColumn get productName => text()();

  IntColumn get quantity => integer()();

  RealColumn get unitPrice => real()();

  RealColumn get purchasePrice => real()();

  RealColumn get total => real()();

  @override
  Set<Column> get primaryKey => {id};
}
