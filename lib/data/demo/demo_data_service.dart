import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

class DemoDataService {
  final AppDatabase _database;

  DemoDataService([AppDatabase? database])
    : _database = database ?? appDatabase;

  static const _demoPrefix = 'demo_';

  Future<void> loadDemoData() async {
    await _clearDemoData();

    await _insertBusinessSettings();
    await _insertCategories();
    await _insertCustomers();
    await _insertProducts();
    await _insertSales();
    await _insertExpenses();
    await _insertStockMovements();
  }

  Future<void> clearDemoData() async {
    await _database.transaction(() async {
      await _clearDemoData();
    });
  }

  Future<void> _clearDemoData() async {
    await (_database.delete(
      _database.stockMovements,
    )..where((table) => table.id.like('$_demoPrefix%'))).go();

    await (_database.delete(
      _database.saleItems,
    )..where((table) => table.id.like('$_demoPrefix%'))).go();

    await (_database.delete(
      _database.sales,
    )..where((table) => table.id.like('$_demoPrefix%'))).go();

    await (_database.delete(
      _database.expenses,
    )..where((table) => table.id.like('$_demoPrefix%'))).go();

    await (_database.delete(
      _database.products,
    )..where((table) => table.id.like('$_demoPrefix%'))).go();

    await (_database.delete(
      _database.customers,
    )..where((table) => table.id.like('$_demoPrefix%'))).go();

    await (_database.delete(
      _database.categories,
    )..where((table) => table.id.like('$_demoPrefix%'))).go();

    await (_database.delete(
      _database.businessSettings,
    )..where((table) => table.id.like('$_demoPrefix%'))).go();
  }

  Future<void> _insertBusinessSettings() async {
    await _database
        .into(_database.businessSettings)
        .insertOnConflictUpdate(
          const BusinessSettingsCompanion(
            id: Value('default'),
            businessName: Value('BizFlow Demo Store'),
            address: Value('123 Main Street, Colombo'),
            phone: Value('+94 71 234 5678'),
            email: Value('demo@bizflow.app'),
            currency: Value('LKR'),
          ),
        );
  }

  Future<void> _insertCategories() async {
    final categories = [
      ('electronics', 'Electronics'),
      ('groceries', 'Groceries'),
      ('beverages', 'Beverages'),
      ('household', 'Household'),
      ('personal_care', 'Personal Care'),
      ('stationery', 'Stationery'),
    ];

    for (final category in categories) {
      await _database
          .into(_database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: '$_demoPrefix${category.$1}',
              name: category.$2,
            ),
          );
    }
  }

  Future<void> _insertCustomers() async {
    final customers = [
      (
        id: 'customer_001',
        name: 'Kasun Perera',
        phone: '+94 77 123 4567',
        email: 'kasun@example.com',
        address: 'Colombo',
        balance: 0.0,
      ),
      (
        id: 'customer_002',
        name: 'Nimali Fernando',
        phone: '+94 76 234 5678',
        email: 'nimali@example.com',
        address: 'Negombo',
        balance: 2500.0,
      ),
      (
        id: 'customer_003',
        name: 'Ravindu Silva',
        phone: '+94 75 345 6789',
        email: 'ravindu@example.com',
        address: 'Wattala',
        balance: 0.0,
      ),
      (
        id: 'customer_004',
        name: 'Amaya Stores',
        phone: '+94 72 456 7890',
        email: 'amaya@example.com',
        address: 'Ja-Ela',
        balance: 12500.0,
      ),
    ];

    for (final customer in customers) {
      await _database
          .into(_database.customers)
          .insert(
            CustomersCompanion.insert(
              id: '$_demoPrefix${customer.id}',
              name: customer.name,
              phone: Value(customer.phone),
              email: Value(customer.email),
              address: Value(customer.address),
              outstandingBalance: Value(customer.balance),
            ),
          );
    }
  }

  Future<void> _insertProducts() async {
    final products = [
      (
        id: 'product_001',
        name: 'Wireless Mouse',
        sku: 'ELEC-001',
        category: 'Electronics',
        purchase: 1800.0,
        selling: 2500.0,
        stock: 25,
        threshold: 5,
        barcode: '890100000001',
      ),
      (
        id: 'product_002',
        name: 'USB-C Cable',
        sku: 'ELEC-002',
        category: 'Electronics',
        purchase: 750.0,
        selling: 1200.0,
        stock: 8,
        threshold: 10,
        barcode: '890100000002',
      ),
      (
        id: 'product_003',
        name: 'Notebook A5',
        sku: 'STAT-001',
        category: 'Stationery',
        purchase: 180.0,
        selling: 300.0,
        stock: 44,
        threshold: 10,
        barcode: '890100000003',
      ),
      (
        id: 'product_004',
        name: 'Ballpoint Pen',
        sku: 'STAT-002',
        category: 'Stationery',
        purchase: 60.0,
        selling: 100.0,
        stock: 143,
        threshold: 20,
        barcode: '890100000004',
      ),
      (
        id: 'product_005',
        name: 'Mineral Water 1L',
        sku: 'BEV-001',
        category: 'Beverages',
        purchase: 100.0,
        selling: 150.0,
        stock: 5,
        threshold: 10,
        barcode: '890100000005',
      ),
      (
        id: 'product_006',
        name: 'Soft Drink 500ml',
        sku: 'BEV-002',
        category: 'Beverages',
        purchase: 120.0,
        selling: 200.0,
        stock: 38,
        threshold: 12,
        barcode: '890100000006',
      ),
      (
        id: 'product_007',
        name: 'Dishwashing Liquid',
        sku: 'HOME-001',
        category: 'Household',
        purchase: 450.0,
        selling: 650.0,
        stock: 21,
        threshold: 5,
        barcode: '890100000007',
      ),
      (
        id: 'product_008',
        name: 'Laundry Powder 1kg',
        sku: 'HOME-002',
        category: 'Household',
        purchase: 780.0,
        selling: 1050.0,
        stock: 6,
        threshold: 8,
        barcode: '890100000008',
      ),
      (
        id: 'product_009',
        name: 'Shampoo 400ml',
        sku: 'CARE-001',
        category: 'Personal Care',
        purchase: 650.0,
        selling: 900.0,
        stock: 17,
        threshold: 5,
        barcode: '890100000009',
      ),
      (
        id: 'product_010',
        name: 'Toothpaste 120g',
        sku: 'CARE-002',
        category: 'Personal Care',
        purchase: 320.0,
        selling: 450.0,
        stock: 25,
        threshold: 6,
        barcode: '890100000010',
      ),
    ];

    for (final product in products) {
      await _database
          .into(_database.products)
          .insert(
            ProductsCompanion.insert(
              id: '$_demoPrefix${product.id}',
              name: product.name,
              sku: product.sku,
              category: product.category,
              purchasePrice: product.purchase,
              sellingPrice: product.selling,
              stockQuantity: product.stock,
              lowStockThreshold: product.threshold,
              barcode: Value(product.barcode),
            ),
          );
    }
  }

  Future<void> _insertSales() async {
    final now = DateTime.now();

    final sales = [
      (
        id: 'sale_001',
        customerId: 'customer_001',
        daysAgo: 0,
        hour: 9,
        minute: 15,
        paymentMethod: 'cash',
        discount: 0.0,
        paidAmount: 7500.0,
        items: [
          ('product_001', 'Wireless Mouse', 2),
          ('product_002', 'USB-C Cable', 2),
        ],
      ),
      (
        id: 'sale_002',
        customerId: null,
        daysAgo: 0,
        hour: 10,
        minute: 40,
        paymentMethod: 'card',
        discount: 150.0,
        paidAmount: 2200.0,
        items: [
          ('product_006', 'Soft Drink 500ml', 2),
          ('product_009', 'Shampoo 400ml', 1),
          ('product_010', 'Toothpaste 120g', 1),
        ],
      ),
      (
        id: 'sale_003',
        customerId: 'customer_003',
        daysAgo: 1,
        hour: 11,
        minute: 5,
        paymentMethod: 'cash',
        discount: 0.0,
        paidAmount: 1500.0,
        items: [
          ('product_003', 'Notebook A5', 2),
          ('product_004', 'Ballpoint Pen', 3),
          ('product_005', 'Mineral Water 1L', 2),
        ],
      ),
      (
        id: 'sale_004',
        customerId: 'customer_002',
        daysAgo: 1,
        hour: 14,
        minute: 20,
        paymentMethod: 'bank_transfer',
        discount: 500.0,
        paidAmount: 5000.0,
        items: [
          ('product_007', 'Dishwashing Liquid', 2),
          ('product_008', 'Laundry Powder 1kg', 3),
          ('product_010', 'Toothpaste 120g', 2),
        ],
      ),
      (
        id: 'sale_005',
        customerId: null,
        daysAgo: 2,
        hour: 9,
        minute: 45,
        paymentMethod: 'cash',
        discount: 0.0,
        paidAmount: 1500.0,
        items: [
          ('product_003', 'Notebook A5', 2),
          ('product_004', 'Ballpoint Pen', 4),
          ('product_006', 'Soft Drink 500ml', 1),
        ],
      ),
      (
        id: 'sale_006',
        customerId: 'customer_004',
        daysAgo: 3,
        hour: 13,
        minute: 10,
        paymentMethod: 'card',
        discount: 300.0,
        paidAmount: 10500.0,
        items: [
          ('product_001', 'Wireless Mouse', 2),
          ('product_002', 'USB-C Cable', 2),
          ('product_007', 'Dishwashing Liquid', 2),
          ('product_009', 'Shampoo 400ml', 2),
        ],
      ),
      (
        id: 'sale_007',
        customerId: 'customer_001',
        daysAgo: 4,
        hour: 16,
        minute: 30,
        paymentMethod: 'cash',
        discount: 0.0,
        paidAmount: 3000.0,
        items: [
          ('product_006', 'Soft Drink 500ml', 4),
          ('product_008', 'Laundry Powder 1kg', 1),
          ('product_010', 'Toothpaste 120g', 2),
        ],
      ),
      (
        id: 'sale_008',
        customerId: null,
        daysAgo: 6,
        hour: 12,
        minute: 15,
        paymentMethod: 'cash',
        discount: 100.0,
        paidAmount: 3500.0,
        items: [
          ('product_001', 'Wireless Mouse', 1),
          ('product_003', 'Notebook A5', 2),
          ('product_005', 'Mineral Water 1L', 3),
        ],
      ),
    ];

    final productPrices = <String, ({double purchase, double selling})>{
      'product_001': (purchase: 1800.0, selling: 2500.0),
      'product_002': (purchase: 750.0, selling: 1200.0),
      'product_003': (purchase: 180.0, selling: 300.0),
      'product_004': (purchase: 60.0, selling: 100.0),
      'product_005': (purchase: 100.0, selling: 150.0),
      'product_006': (purchase: 120.0, selling: 200.0),
      'product_007': (purchase: 450.0, selling: 650.0),
      'product_008': (purchase: 780.0, selling: 1050.0),
      'product_009': (purchase: 650.0, selling: 900.0),
      'product_010': (purchase: 320.0, selling: 450.0),
    };

    for (final sale in sales) {
      final saleId = '$_demoPrefix${sale.id}';

      final createdAt = DateTime(
        now.year,
        now.month,
        now.day,
        sale.hour,
        sale.minute,
      ).subtract(Duration(days: sale.daysAgo));

      double subtotal = 0.0;

      final saleItems = <Map<String, dynamic>>[];

      for (var index = 0; index < sale.items.length; index++) {
        final item = sale.items[index];
        final productId = item.$1;
        final productName = item.$2;
        final quantity = item.$3;

        final prices = productPrices[productId]!;

        final itemTotal = prices.selling * quantity;

        subtotal += itemTotal;

        saleItems.add({
          'id': '${saleId}_item_$index',
          'saleId': saleId,
          'productId': '$_demoPrefix$productId',
          'productName': productName,
          'quantity': quantity,
          'unitPrice': prices.selling,
          'purchasePrice': prices.purchase,
          'total': itemTotal,
        });
      }

      final total = subtotal - sale.discount;

      await _database
          .into(_database.sales)
          .insert(
            SalesCompanion.insert(
              id: saleId,
              customerId: sale.customerId == null
                  ? const Value.absent()
                  : Value('$_demoPrefix${sale.customerId}'),
              subtotal: subtotal,
              discount: Value(sale.discount),
              total: total,
              paidAmount: sale.paidAmount,
              paymentMethod: Value(sale.paymentMethod),
              status: const Value('completed'),
              createdAt: createdAt,
            ),
          );

      for (final saleItem in saleItems) {
        await _database.customStatement(
          '''
    INSERT INTO sale_items (
      id,
      sale_id,
      product_id,
      product_name,
      quantity,
      unit_price,
      purchase_price,
      total
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''',
          [
            saleItem['id'],
            saleItem['saleId'],
            saleItem['productId'],
            saleItem['productName'],
            saleItem['quantity'],
            saleItem['unitPrice'],
            saleItem['purchasePrice'],
            saleItem['total'],
          ],
        );
      }
    }
  }

  Future<void> _insertExpenses() async {
    final now = DateTime.now();

    final expenses = [
      (
        id: 'expense_001',
        title: 'Shop Rent',
        category: 'Rent',
        amount: 45000.0,
        daysAgo: 2,
        note: 'Monthly shop rent',
      ),
      (
        id: 'expense_002',
        title: 'Electricity Bill',
        category: 'Utilities',
        amount: 8500.0,
        daysAgo: 3,
        note: 'Monthly electricity bill',
      ),
      (
        id: 'expense_003',
        title: 'Internet Bill',
        category: 'Utilities',
        amount: 3500.0,
        daysAgo: 4,
        note: 'Monthly internet connection',
      ),
      (
        id: 'expense_004',
        title: 'Packaging Materials',
        category: 'Supplies',
        amount: 4200.0,
        daysAgo: 5,
        note: 'Bags and receipt rolls',
      ),
      (
        id: 'expense_005',
        title: 'Transport',
        category: 'Transport',
        amount: 2800.0,
        daysAgo: 6,
        note: 'Supplier pickup and delivery',
      ),
    ];

    for (final expense in expenses) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
        10,
        0,
      ).subtract(Duration(days: expense.daysAgo));

      await _database
          .into(_database.expenses)
          .insert(
            ExpensesCompanion.insert(
              id: '$_demoPrefix${expense.id}',
              title: expense.title,
              category: expense.category,
              amount: expense.amount,
              date: date,
              note: Value(expense.note),
            ),
          );
    }
  }

  Future<void> _insertStockMovements() async {
    final now = DateTime.now();

    final movements = [
      (
        id: 'movement_001',
        productId: 'product_001',
        type: 'in',
        quantity: 30,
        previousStock: 0,
        newStock: 30,
        daysAgo: 10,
        note: 'Initial stock',
      ),
      (
        id: 'movement_002',
        productId: 'product_001',
        type: 'out',
        quantity: 5,
        previousStock: 30,
        newStock: 25,
        daysAgo: 6,
        note: 'Sales',
      ),
      (
        id: 'movement_003',
        productId: 'product_002',
        type: 'in',
        quantity: 12,
        previousStock: 0,
        newStock: 12,
        daysAgo: 10,
        note: 'Initial stock',
      ),
      (
        id: 'movement_004',
        productId: 'product_002',
        type: 'out',
        quantity: 4,
        previousStock: 12,
        newStock: 8,
        daysAgo: 5,
        note: 'Sales',
      ),
      (
        id: 'movement_005',
        productId: 'product_003',
        type: 'in',
        quantity: 50,
        previousStock: 0,
        newStock: 50,
        daysAgo: 10,
        note: 'Initial stock',
      ),
      (
        id: 'movement_006',
        productId: 'product_003',
        type: 'out',
        quantity: 6,
        previousStock: 50,
        newStock: 44,
        daysAgo: 3,
        note: 'Sales',
      ),
      (
        id: 'movement_007',
        productId: 'product_004',
        type: 'in',
        quantity: 150,
        previousStock: 0,
        newStock: 150,
        daysAgo: 10,
        note: 'Initial stock',
      ),
      (
        id: 'movement_008',
        productId: 'product_004',
        type: 'out',
        quantity: 7,
        previousStock: 150,
        newStock: 143,
        daysAgo: 4,
        note: 'Sales',
      ),
      (
        id: 'movement_009',
        productId: 'product_005',
        type: 'in',
        quantity: 10,
        previousStock: 0,
        newStock: 10,
        daysAgo: 8,
        note: 'Initial stock',
      ),
      (
        id: 'movement_010',
        productId: 'product_005',
        type: 'out',
        quantity: 5,
        previousStock: 10,
        newStock: 5,
        daysAgo: 2,
        note: 'Sales',
      ),
      (
        id: 'movement_011',
        productId: 'product_006',
        type: 'in',
        quantity: 45,
        previousStock: 0,
        newStock: 45,
        daysAgo: 9,
        note: 'Initial stock',
      ),
      (
        id: 'movement_012',
        productId: 'product_006',
        type: 'out',
        quantity: 7,
        previousStock: 45,
        newStock: 38,
        daysAgo: 3,
        note: 'Sales',
      ),
      (
        id: 'movement_013',
        productId: 'product_007',
        type: 'in',
        quantity: 25,
        previousStock: 0,
        newStock: 25,
        daysAgo: 8,
        note: 'Initial stock',
      ),
      (
        id: 'movement_014',
        productId: 'product_007',
        type: 'out',
        quantity: 4,
        previousStock: 25,
        newStock: 21,
        daysAgo: 3,
        note: 'Sales',
      ),
      (
        id: 'movement_015',
        productId: 'product_008',
        type: 'in',
        quantity: 10,
        previousStock: 0,
        newStock: 10,
        daysAgo: 8,
        note: 'Initial stock',
      ),
      (
        id: 'movement_016',
        productId: 'product_008',
        type: 'out',
        quantity: 4,
        previousStock: 10,
        newStock: 6,
        daysAgo: 4,
        note: 'Sales',
      ),
      (
        id: 'movement_017',
        productId: 'product_009',
        type: 'in',
        quantity: 20,
        previousStock: 0,
        newStock: 20,
        daysAgo: 7,
        note: 'Initial stock',
      ),
      (
        id: 'movement_018',
        productId: 'product_009',
        type: 'out',
        quantity: 3,
        previousStock: 20,
        newStock: 17,
        daysAgo: 2,
        note: 'Sales',
      ),
      (
        id: 'movement_019',
        productId: 'product_010',
        type: 'in',
        quantity: 30,
        previousStock: 0,
        newStock: 30,
        daysAgo: 7,
        note: 'Initial stock',
      ),
      (
        id: 'movement_020',
        productId: 'product_010',
        type: 'out',
        quantity: 5,
        previousStock: 30,
        newStock: 25,
        daysAgo: 2,
        note: 'Sales',
      ),
    ];

    for (final movement in movements) {
      final createdAt = DateTime(
        now.year,
        now.month,
        now.day,
        11,
        0,
      ).subtract(Duration(days: movement.daysAgo));

      await _database
          .into(_database.stockMovements)
          .insert(
            StockMovementsCompanion.insert(
              id: '$_demoPrefix${movement.id}',
              productId: '$_demoPrefix${movement.productId}',
              type: movement.type,
              quantity: movement.quantity,
              previousStock: movement.previousStock,
              newStock: movement.newStock,
              note: Value(movement.note),
              createdAt: createdAt,
            ),
          );
    }
  }
}
