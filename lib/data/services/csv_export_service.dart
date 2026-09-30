import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

class CsvExportService {
  final AppDatabase _database;

  CsvExportService([AppDatabase? database])
    : _database = database ?? appDatabase;

  Future<String> exportProducts() async {
    final products = await _database.select(_database.products).get();

    final rows = <List<dynamic>>[
      [
        'ID',
        'Name',
        'SKU',
        'Category',
        'Purchase Price',
        'Selling Price',
        'Stock Quantity',
        'Low Stock Threshold',
        'Barcode',
      ],
    ];

    for (final product in products) {
      rows.add([
        product.id,
        product.name,
        product.sku,
        product.category,
        product.purchasePrice,
        product.sellingPrice,
        product.stockQuantity,
        product.lowStockThreshold,
        product.barcode,
      ]);
    }

    final csvData = CsvEncoder().convert(rows);

    final savedPath = await FileSaver.instance.saveFile(
      name: 'bizflow_products',
      bytes: Uint8List.fromList(csvData.codeUnits),
      fileExtension: 'csv',
      mimeType: MimeType.text,
    );

    return savedPath;
  }

  Future<String> exportSales() async {
    final sales = await _database.select(_database.sales).get();

    final rows = <List<dynamic>>[
      [
        'ID',
        'Customer ID',
        'Subtotal',
        'Discount',
        'Total',
        'Paid Amount',
        'Payment Method',
        'Status',
        'Created At',
      ],
    ];

    for (final sale in sales) {
      rows.add([
        sale.id,
        sale.customerId ?? '',
        sale.subtotal,
        sale.discount,
        sale.total,
        sale.paidAmount,
        sale.paymentMethod,
        sale.status,
        sale.createdAt.toIso8601String(),
      ]);
    }

    final csvData = CsvEncoder().convert(rows);

    final savedPath = await FileSaver.instance.saveFile(
      name: 'bizflow_sales',
      bytes: Uint8List.fromList(csvData.codeUnits),
      fileExtension: 'csv',
      mimeType: MimeType.text,
    );

    return savedPath;
  }

  Future<String> exportCustomers() async {
    final customers = await _database.select(_database.customers).get();

    final rows = <List<dynamic>>[
      ['ID', 'Name', 'Phone', 'Email', 'Address', 'Outstanding Balance'],
    ];

    for (final customer in customers) {
      rows.add([
        customer.id,
        customer.name,
        customer.phone,
        customer.email,
        customer.address,
        customer.outstandingBalance,
      ]);
    }

    final csvData = CsvEncoder().convert(rows);

    final savedPath = await FileSaver.instance.saveFile(
      name: 'bizflow_customers',
      bytes: Uint8List.fromList(csvData.codeUnits),
      fileExtension: 'csv',
      mimeType: MimeType.text,
    );

    return savedPath;
  }

  Future<String> exportExpenses() async {
    final expenses = await _database.select(_database.expenses).get();

    final rows = <List<dynamic>>[
      ['ID', 'Title', 'Category', 'Amount', 'Date', 'Note'],
    ];

    for (final expense in expenses) {
      rows.add([
        expense.id,
        expense.title,
        expense.category,
        expense.amount,
        expense.date.toIso8601String(),
        expense.note,
      ]);
    }

    final csvData = CsvEncoder().convert(rows);

    final savedPath = await FileSaver.instance.saveFile(
      name: 'bizflow_expenses',
      bytes: Uint8List.fromList(csvData.codeUnits),
      fileExtension: 'csv',
      mimeType: MimeType.text,
    );

    return savedPath;
  }
}
