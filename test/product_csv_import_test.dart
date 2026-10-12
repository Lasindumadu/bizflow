import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/services/product_csv_importer.dart';

void main() {
  group('ProductCsvImporter.parse', () {
    test('parses a well-formed CSV', () {
      const csv = '''
name,sku,category,purchase_price,selling_price,stock_quantity,low_stock_threshold,barcode
Rice,RICE-001,Groceries,100,150,20,5,123
Sugar,SUG-001,Groceries,80,120,10,3,
''';

      final preview = ProductCsvImporter.parse(csv);

      expect(preview.errors, isEmpty);
      expect(preview.validRows, hasLength(2));

      final rice = preview.validRows.first;
      expect(rice.name, 'Rice');
      expect(rice.sku, 'RICE-001');
      expect(rice.purchasePrice, 100);
      expect(rice.sellingPrice, 150);
      expect(rice.stockQuantity, 20);
      expect(rice.lowStockThreshold, 5);
      expect(rice.barcode, '123');
    });

    test('is tolerant of column order and header case/spacing', () {
      const csv = '''
SKU,Name, Purchase Price ,Selling Price
ABC-1,Widget,10,20
''';

      final preview = ProductCsvImporter.parse(csv);

      expect(preview.errors, isEmpty);
      expect(preview.validRows.single.name, 'Widget');
      expect(preview.validRows.single.sku, 'ABC-1');
    });

    test('throws when required columns are missing', () {
      const csv = 'name,category\nRice,Groceries\n';

      expect(
        () => ProductCsvImporter.parse(csv),
        throwsA(isA<FormatException>()),
      );
    });

    test('reports rows with missing name or sku as errors', () {
      const csv = '''
name,sku,purchase_price,selling_price
,RICE-1,10,20
Sugar,,10,20
''';

      final preview = ProductCsvImporter.parse(csv);

      expect(preview.validRows, isEmpty);
      expect(preview.errors, hasLength(2));
      expect(preview.errors[0].reason, contains('name'));
      expect(preview.errors[1].reason, contains('SKU'));
    });

    test('rejects non-numeric prices', () {
      const csv = '''
name,sku,purchase_price,selling_price
Rice,RICE-1,abc,20
''';

      final preview = ProductCsvImporter.parse(csv);

      expect(preview.validRows, isEmpty);
      expect(preview.errors.single.reason, contains('Purchase price'));
    });

    test('detects duplicate SKUs within the file', () {
      const csv = '''
name,sku,purchase_price,selling_price
Rice,RICE-1,10,20
Rice 2,RICE-1,10,20
''';

      final preview = ProductCsvImporter.parse(csv);

      expect(preview.validRows, hasLength(1));
      expect(preview.errors.single.reason, contains('Duplicate SKU'));
    });

    test('detects duplicate SKUs and barcodes against existing data', () {
      const csv = '''
name,sku,barcode,purchase_price,selling_price
Rice,RICE-1,999,10,20
Sugar,SUG-1,888,10,20
''';

      final preview = ProductCsvImporter.parse(
        csv,
        existingSkus: {'rice-1'},
        existingBarcodes: {'888'},
      );

      expect(preview.duplicateSkus, contains('RICE-1'));
      expect(preview.duplicateBarcodes, contains('888'));
      // Only rows free of duplicates are importable.
      expect(preview.importableRows, isEmpty);
    });

    test('strips currency symbols and thousands separators', () {
      const csv = '''
name,sku,purchase_price,selling_price
Rice,RICE-1,"1,200.50","LKR 1,500"
''';

      final preview = ProductCsvImporter.parse(csv);

      expect(preview.validRows.single.purchasePrice, 1200.50);
      expect(preview.validRows.single.sellingPrice, 1500);
    });

    test('defaults category when blank', () {
      const csv = '''
name,sku,purchase_price,selling_price
Rice,RICE-1,10,20
''';

      final preview = ProductCsvImporter.parse(csv);

      expect(preview.validRows.single.category, 'Uncategorised');
    });

    test('handles an empty file gracefully', () {
      final preview = ProductCsvImporter.parse('');

      expect(preview.validRows, isEmpty);
      expect(preview.errors, isEmpty);
      expect(preview.totalRows, 0);
    });

    test('skips blank lines', () {
      const csv = '''
name,sku,purchase_price,selling_price
Rice,RICE-1,10,20

Sugar,SUG-1,10,20
''';

      final preview = ProductCsvImporter.parse(csv);

      expect(preview.validRows, hasLength(2));
    });
  });
}
