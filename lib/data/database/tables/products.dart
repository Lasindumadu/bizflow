import 'package:drift/drift.dart';

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get sku => text()();

  TextColumn get category => text()();

  RealColumn get purchasePrice => real()();

  RealColumn get sellingPrice => real()();

  RealColumn get stockQuantity => real()();

  RealColumn get lowStockThreshold => real()();

  TextColumn get barcode => text().withDefault(const Constant(''))();

  /// Optional URL / local path to a product photo shown on POS tiles.
  TextColumn get productImageUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
