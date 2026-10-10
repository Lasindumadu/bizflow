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

    test('rejects a barcode already assigned to another product', () async {
      const firstProduct = Product(
        id: 'duplicate-test-1',
        name: 'First Product',
        sku: 'DUP-001',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567890',
      );

      const secondProduct = Product(
        id: 'duplicate-test-2',
        name: 'Second Product',
        sku: 'DUP-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '001234567890',
      );

      await repository.addProduct(firstProduct);

      await expectLater(
        repository.addProduct(secondProduct),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'This barcode is already assigned to another product.',
          ),
        ),
      );
    });

    test('rejects assigning another product barcode during editing', () async {
      const firstProduct = Product(
        id: 'duplicate-edit-1',
        name: 'First Product',
        sku: 'EDIT-001',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '111222333',
      );

      const secondProduct = Product(
        id: 'duplicate-edit-2',
        name: 'Second Product',
        sku: 'EDIT-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '444555666',
      );

      await repository.addProduct(firstProduct);
      await repository.addProduct(secondProduct);

      const updatedSecondProduct = Product(
        id: 'duplicate-edit-2',
        name: 'Second Product',
        sku: 'EDIT-002',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '111222333',
      );

      await expectLater(
        repository.updateProduct(updatedSecondProduct),
        throwsA(isA<StateError>()),
      );

      final unchangedProduct = await repository.getProductById(
        'duplicate-edit-2',
      );

      expect(unchangedProduct!.barcode, '444555666');
    });

    test('allows a product to retain its own barcode when edited', () async {
      const product = Product(
        id: 'same-barcode-edit',
        name: 'Editable Product',
        sku: 'EDIT-003',
        category: 'Test',
        purchasePrice: 100,
        sellingPrice: 150,
        stockQuantity: 10,
        lowStockThreshold: 2,
        barcode: '009988776655',
      );

      await repository.addProduct(product);

      await expectLater(repository.updateProduct(product), completes);

      final savedProduct = await repository.getProductById('same-barcode-edit');

      expect(savedProduct!.barcode, '009988776655');
    });
  });
}
