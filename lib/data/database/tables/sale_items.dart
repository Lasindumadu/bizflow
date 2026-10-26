import 'package:drift/drift.dart';

class SaleItems extends Table {
  TextColumn get id => text()();

  TextColumn get saleId => text()();

  TextColumn get productId => text()();

  TextColumn get productName => text()();

  /// Quantity sold — supports fractional values (weight / litre / piece).
  RealColumn get quantity => real()();

  RealColumn get unitPrice => real()();

  RealColumn get purchasePrice => real()();

  RealColumn get total => real()();

  /// Batch number for traceability (optional).
  TextColumn get batchNumber => text().nullable()();

  /// Expiry date (ISO-8601 string, optional).
  TextColumn get expiryDate => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
