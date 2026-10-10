import 'package:drift/drift.dart';

import '../../models/product.dart';
import '../database/app_database.dart';

class ProductRepository {
  final AppDatabase database;

  ProductRepository(this.database);

  Future<bool> isBarcodeTaken(
    String barcode, {
    String? excludingProductId,
  }) async {
    final normalizedBarcode = barcode.trim();

    if (normalizedBarcode.isEmpty) {
      return false;
    }

    final rows = await database.select(database.products).get();

    return rows.any(
      (row) =>
          row.barcode.trim() == normalizedBarcode &&
          row.id != excludingProductId,
    );
  }

  Future<void> _ensureBarcodeAvailable(
    String barcode, {
    String? excludingProductId,
  }) async {
    if (await isBarcodeTaken(barcode, excludingProductId: excludingProductId)) {
      throw StateError('This barcode is already assigned to another product.');
    }
  }

  Stream<List<Product>> watchProducts() {
    final query = database.select(database.products)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  Future<List<Product>> getProducts() async {
    final query = database.select(database.products)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    final rows = await query.get();

    return rows.map(_toModel).toList();
  }

  Future<Product?> getProductById(String id) async {
    final query = database.select(database.products)
      ..where((table) => table.id.equals(id));

    final row = await query.getSingleOrNull();

    if (row == null) {
      return null;
    }

    return _toModel(row);
  }

  Future<void> addProduct(Product product) async {
    await _ensureBarcodeAvailable(product.barcode);
    await database
        .into(database.products)
        .insert(
          ProductsCompanion.insert(
            id: product.id,
            name: product.name,
            sku: product.sku,
            category: product.category,
            purchasePrice: product.purchasePrice,
            sellingPrice: product.sellingPrice,
            stockQuantity: product.stockQuantity,
            lowStockThreshold: product.lowStockThreshold,
            barcode: Value(product.barcode),
          ),
        );
  }

  Future<void> updateProduct(Product product) async {
    await _ensureBarcodeAvailable(
      product.barcode,
      excludingProductId: product.id,
    );
    await (database.update(
      database.products,
    )..where((table) => table.id.equals(product.id))).write(
      ProductsCompanion(
        name: Value(product.name),
        sku: Value(product.sku),
        category: Value(product.category),
        purchasePrice: Value(product.purchasePrice),
        sellingPrice: Value(product.sellingPrice),
        stockQuantity: Value(product.stockQuantity),
        lowStockThreshold: Value(product.lowStockThreshold),
        barcode: Value(product.barcode),
      ),
    );
  }

  Future<void> changeStock({
    required String productId,
    required int quantity,
    required String type,
    String note = '',
  }) async {
    if (quantity == 0) {
      throw ArgumentError('Stock quantity cannot be zero.');
    }

    await database.transaction(() async {
      final productQuery = database.select(database.products)
        ..where((table) => table.id.equals(productId));

      final productRow = await productQuery.getSingleOrNull();

      if (productRow == null) {
        throw StateError('Product not found.');
      }

      final previousStock = productRow.stockQuantity;
      final newStock = previousStock + quantity;

      if (newStock < 0) {
        throw StateError('Stock cannot be negative.');
      }

      await (database.update(database.products)
            ..where((table) => table.id.equals(productId)))
          .write(ProductsCompanion(stockQuantity: Value(newStock)));

      await database
          .into(database.stockMovements)
          .insert(
            StockMovementsCompanion.insert(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              productId: productId,
              type: type,
              quantity: quantity.abs(),
              previousStock: previousStock,
              newStock: newStock,
              note: Value(note),
              createdAt: DateTime.now(),
            ),
          );
    });
  }

  Future<void> deleteProduct(String id) async {
    await (database.delete(
      database.products,
    )..where((table) => table.id.equals(id))).go();
  }

  Product _toModel(ProductRow row) {
    return Product(
      id: row.id,
      name: row.name,
      sku: row.sku,
      category: row.category,
      purchasePrice: row.purchasePrice,
      sellingPrice: row.sellingPrice,
      stockQuantity: row.stockQuantity,
      lowStockThreshold: row.lowStockThreshold,
      barcode: row.barcode,
    );
  }
}
