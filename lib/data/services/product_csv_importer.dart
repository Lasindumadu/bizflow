import 'package:csv/csv.dart';

/// A successfully parsed product row ready to import.
class ParsedProductRow {
  final String name;
  final String sku;
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String barcode;

  const ParsedProductRow({
    required this.name,
    required this.sku,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.barcode,
  });
}

/// A row that failed validation, with the reason.
class CsvRowError {
  final int line; // 1-based line in the source file (excludes the header).
  final String reason;
  final Map<String, String> raw;

  const CsvRowError({
    required this.line,
    required this.reason,
    required this.raw,
  });
}

/// The result of parsing a CSV before it is committed.
class CsvImportPreview {
  final List<ParsedProductRow> validRows;
  final List<CsvRowError> errors;

  /// SKUs/barcodes in the file that already exist in the database.
  final List<String> duplicateSkus;
  final List<String> duplicateBarcodes;

  const CsvImportPreview({
    required this.validRows,
    required this.errors,
    required this.duplicateSkus,
    required this.duplicateBarcodes,
  });

  int get totalRows => validRows.length + errors.length;

  /// Rows that will actually be imported (valid, non-duplicate).
  List<ParsedProductRow> get importableRows => validRows
      .where(
        (r) =>
            !duplicateSkus.contains(r.sku) &&
            (r.barcode.isEmpty || !duplicateBarcodes.contains(r.barcode)),
      )
      .toList();
}

/// Parses product CSV text with tolerant header + number handling.
///
/// Expected columns (case-insensitive, order-independent):
///   name, sku, category, purchase_price, selling_price,
///   stock_quantity, low_stock_threshold, barcode
///
/// Only `name`, `sku`, `purchase_price` and `selling_price` are required.
class ProductCsvImporter {
  static const _requiredColumns = [
    'name',
    'sku',
    'purchase_price',
    'selling_price',
  ];

  /// Parses [csvText] and reports valid rows, errors and duplicates.
  ///
  /// [existingSkus] and [existingBarcodes] are used for duplicate detection.
  static CsvImportPreview parse(
    String csvText, {
    Set<String> existingSkus = const {},
    Set<String> existingBarcodes = const {},
  }) {
    final normalized = csvText.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) {
      return const CsvImportPreview(
        validRows: [],
        errors: [],
        duplicateSkus: [],
        duplicateBarcodes: [],
      );
    }

    final rows = const CsvDecoder().convert(normalized);

    if (rows.isEmpty) {
      return const CsvImportPreview(
        validRows: [],
        errors: [],
        duplicateSkus: [],
        duplicateBarcodes: [],
      );
    }

    final header = rows.first
        .map((c) => c.toString().trim().toLowerCase().replaceAll(' ', '_'))
        .toList();

    final indexOf = <String, int>{};
    for (var i = 0; i < header.length; i++) {
      indexOf[header[i]] = i;
    }

    final missing = _requiredColumns
        .where((c) => !indexOf.containsKey(c))
        .toList();
    if (missing.isNotEmpty) {
      throw FormatException(
        'Missing required column(s): ${missing.join(', ')}. '
        'Expected: ${_requiredColumns.join(', ')}.',
      );
    }

    final valid = <ParsedProductRow>[];
    final errors = <CsvRowError>[];
    final seenSkus = <String>{};
    final seenBarcodes = <String>{};
    final duplicateSkus = <String>{};
    final duplicateBarcodes = <String>{};

    String cell(List<dynamic> row, String column) {
      final idx = indexOf[column];
      if (idx == null || idx >= row.length) return '';
      return row[idx].toString().trim();
    }

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      // Skip wholly empty lines.
      if (row.every((c) => c.toString().trim().isEmpty)) continue;

      final raw = {
        for (final entry in indexOf.entries)
          if (entry.value < row.length)
            entry.key: row[entry.value].toString().trim(),
      };

      void fail(String reason) {
        errors.add(CsvRowError(line: i, reason: reason, raw: raw));
      }

      final name = cell(row, 'name');
      final sku = cell(row, 'sku');
      final category = cell(row, 'category');
      final barcode = cell(row, 'barcode');

      if (name.isEmpty) {
        fail('Product name is required.');
        continue;
      }
      if (sku.isEmpty) {
        fail('SKU is required.');
        continue;
      }

      final purchase = _parseMoney(cell(row, 'purchase_price'));
      if (purchase == null) {
        fail('Purchase price must be a valid number.');
        continue;
      }
      final selling = _parseMoney(cell(row, 'selling_price'));
      if (selling == null) {
        fail('Selling price must be a valid number.');
        continue;
      }

      final stock = _parseInt(cell(row, 'stock_quantity')) ?? 0;
      final threshold = _parseInt(cell(row, 'low_stock_threshold')) ?? 0;

      if (stock < 0) {
        fail('Stock quantity cannot be negative.');
        continue;
      }

      if (!seenSkus.add(sku.toLowerCase())) {
        fail('Duplicate SKU "$sku" within the file.');
        continue;
      }
      if (barcode.isNotEmpty && !seenBarcodes.add(barcode.toLowerCase())) {
        fail('Duplicate barcode "$barcode" within the file.');
        continue;
      }

      if (existingSkus.contains(sku.toLowerCase())) {
        duplicateSkus.add(sku);
      }
      if (barcode.isNotEmpty &&
          existingBarcodes.contains(barcode.toLowerCase())) {
        duplicateBarcodes.add(barcode);
      }

      valid.add(
        ParsedProductRow(
          name: name,
          sku: sku,
          category: category.isEmpty ? 'Uncategorised' : category,
          purchasePrice: purchase,
          sellingPrice: selling,
          stockQuantity: stock,
          lowStockThreshold: threshold,
          barcode: barcode,
        ),
      );
    }

    return CsvImportPreview(
      validRows: valid,
      errors: errors,
      duplicateSkus: duplicateSkus.toList(),
      duplicateBarcodes: duplicateBarcodes.toList(),
    );
  }

  static double? _parseMoney(String raw) {
    if (raw.isEmpty) return null;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned);
  }

  static int? _parseInt(String raw) {
    if (raw.isEmpty) return null;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9\-]'), '');
    return int.tryParse(cleaned);
  }
}
