import 'package:drift/drift.dart';

import '../database/app_database.dart';

class StockMovementRepository {
  final AppDatabase database;

  StockMovementRepository(this.database);

  Stream<List<StockMovement>> watchMovements() {
    final query = database.select(database.stockMovements)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

    return query.watch();
  }

  Future<List<StockMovement>> getMovements() {
    final query = database.select(database.stockMovements)
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

    return query.get();
  }

  Future<List<StockMovement>> getProductMovements(String productId) {
    final query = database.select(database.stockMovements)
      ..where((table) => table.productId.equals(productId))
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

    return query.get();
  }

  Future<void> addMovement({
    required String id,
    required String productId,
    required String type,
    required int quantity,
    required int previousStock,
    required int newStock,
    String note = '',
    required DateTime createdAt,
  }) async {
    await database
        .into(database.stockMovements)
        .insert(
          StockMovementsCompanion.insert(
            id: id,
            productId: productId,
            type: type,
            quantity: quantity,
            previousStock: previousStock,
            newStock: newStock,
            note: Value(note),
            createdAt: createdAt,
          ),
        );
  }
}
