import 'package:drift/drift.dart';

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get sku => text()();

  TextColumn get category => text()();

  RealColumn get purchasePrice => real()();

  RealColumn get sellingPrice => real()();

  IntColumn get stockQuantity => integer()();

  IntColumn get lowStockThreshold => integer()();

  TextColumn get barcode => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
