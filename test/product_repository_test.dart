import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/product_repository.dart';
import 'package:bizflow/models/product.dart';

void main() {
  late AppDatabase database;
  late ProductRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ProductRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('ProductRepository barcode handling', () {
    test('saves and retrieves a barcode including leading zeros', () async {
      const product = Product(
        id: 'barcode-test-1',
        name: 'Test Product',
        sku: 'TEST-001',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567890',
      );

      await repository.addProduct(product);

      final savedProduct = await repository.getProductById('barcode-test-1');

      expect(savedProduct, isNotNull);
      expect(savedProduct!.barcode, '001234567890');
    });

    test('updates an existing product barcode', () async {
      const product = Product(
        id: 'barcode-test-2',
        name: 'Test Product',
        sku: 'TEST-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '111222333',
      );

      await repository.addProduct(product);

      const updatedProduct = Product(
        id: 'barcode-test-2',
        name: 'Test Product',
        sku: 'TEST-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '999888777',
      );

      await repository.updateProduct(updatedProduct);

      final savedProduct = await repository.getProductById('barcode-test-2');

      expect(savedProduct, isNotNull);
      expect(savedProduct!.barcode, '999888777');
    });
  });
}
