import 'package:drift/drift.dart';

/// A single line of a [SaleReturns] record.
class SaleReturnItems extends Table {
  TextColumn get id => text()();

  TextColumn get returnId => text()();

  TextColumn get saleId => text()();

  TextColumn get productId => text()();

  TextColumn get productName => text()();

  /// Quantity returned on this line.
  RealColumn get quantity => real()();

  /// Unit price refunded per item.
  RealColumn get unitPrice => real()();

  /// Unit cost, captured so profit impact can be computed at return time.
  RealColumn get purchasePrice => real()();

  /// Line total refunded (quantity × unitPrice).
  RealColumn get total => real()();

  @override
  Set<Column> get primaryKey => {id};
}
