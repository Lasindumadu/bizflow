import 'dart:async';

import 'package:drift/drift.dart';


import '../../models/sale.dart' as model;
import '../database/app_database.dart';

class DashboardStats {
  final double todaySales;
  final double todayProfit;
  final int todayTransactions;
  final int totalProducts;
  final int totalCustomers;
  final int lowStockProducts;

  const DashboardStats({
    required this.todaySales,
    required this.todayProfit,
    required this.todayTransactions,
    required this.totalProducts,
    required this.totalCustomers,
    required this.lowStockProducts,
  });
}

class DashboardRepository {
  final AppDatabase database;

  DashboardRepository(this.database);

  Stream<DashboardStats> watchStats() {
    late StreamController<DashboardStats> controller;

    StreamSubscription<List<Sale>>? salesSubscription;
    StreamSubscription<List<ProductRow>>? productsSubscription;

    Future<void> refresh() async {
      try {
        final stats = await _loadStats();

        if (!controller.isClosed) {
          controller.add(stats);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller = StreamController<DashboardStats>(
      onListen: () {
        salesSubscription = database.select(database.sales).watch().listen((_) {
          refresh();
        });

        productsSubscription = database
            .select(database.products)
            .watch()
            .listen((_) {
              refresh();
            });

        refresh();
      },
      onCancel: () async {
        await salesSubscription?.cancel();
        await productsSubscription?.cancel();
      },
    );

    return controller.stream;
  }

  Stream<List<model.Sale>> watchRecentSales({int limit = 5}) {
    final query = database.select(database.sales)
      ..where((table) => table.status.equals('completed'))
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)])
      ..limit(limit);

    return query.watch().map((rows) => rows.map(_toSaleModel).toList());
  }

  Future<DashboardStats> getStats() {
    return _loadStats();
  }

  /// Last 7 days revenue (oldest -> newest), completed sales only.
  Future<List<double>> getLast7DaysRevenue() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <double>[];
    for (var i = 6; i >= 0; i--) {
      final start = today.subtract(Duration(days: i));
      final end = start.add(const Duration(days: 1));
      final q = database.select(database.sales)
        ..where((t) =>
            t.createdAt.isBiggerOrEqualValue(start) &
            t.createdAt.isSmallerThanValue(end) &
            t.status.equals('completed'));
      final rows = await q.get();
      out.add(rows.fold<double>(0, (s, r) => s + r.total));
    }
    return out;
  }

  /// Low-stock product rows for the dashboard alert card.
  Future<List<ProductRow>> getLowStockProducts({int limit = 5}) async {
    final rows = await database.select(database.products).get();
    final low = rows
        .where((p) => p.stockQuantity <= p.lowStockThreshold)
        .toList()
      ..sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
    return low.take(limit).toList();
  }

  Future<DashboardStats> _loadStats() async {
    final products = await database.select(database.products).get();
    final customers = await database.select(database.customers).get();

    final todaySales = await _getTodaySales();
    final todayProfit = await _getTodayProfit();
    final todayTransactions = await _getTodayTransactions();

    final lowStockProducts = products.where((product) {
      return product.stockQuantity <= product.lowStockThreshold;
    }).length;

    return DashboardStats(
      todaySales: todaySales,
      todayProfit: todayProfit,
      todayTransactions: todayTransactions,
      totalProducts: products.length,
      totalCustomers: customers.length,
      lowStockProducts: lowStockProducts,
    );
  }

  Future<double> _getTodaySales() async {
    final now = DateTime.now();

    final startOfDay = DateTime(now.year, now.month, now.day);

    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = database.select(database.sales)
      ..where(
        (table) =>
            table.createdAt.isBiggerOrEqualValue(startOfDay) &
            table.createdAt.isSmallerThanValue(endOfDay) &
            table.status.equals('completed'),
      );

    final sales = await query.get();

    return sales.fold<double>(0.0, (sum, sale) => sum + sale.total);
  }

  Future<double> _getTodayProfit() async {
    final now = DateTime.now();

    final startOfDay = DateTime(now.year, now.month, now.day);

    final endOfDay = startOfDay.add(const Duration(days: 1));

    final salesQuery = database.select(database.sales)
      ..where(
        (table) =>
            table.createdAt.isBiggerOrEqualValue(startOfDay) &
            table.createdAt.isSmallerThanValue(endOfDay) &
            table.status.equals('completed'),
      );

    final sales = await salesQuery.get();

    if (sales.isEmpty) {
      return 0.0;
    }

    double totalProfit = 0.0;

    for (final sale in sales) {
      final itemsQuery = database.select(database.saleItems)
        ..where((table) => table.saleId.equals(sale.id));

      final items = await itemsQuery.get();

      final saleProfit = items.fold<double>(
        0.0,
        (sum, item) =>
            sum + ((item.unitPrice - item.purchasePrice) * item.quantity),
      );

      totalProfit += saleProfit - sale.discount;
    }

    return totalProfit;
  }

  Future<int> _getTodayTransactions() async {
    final now = DateTime.now();

    final startOfDay = DateTime(now.year, now.month, now.day);

    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = database.select(database.sales)
      ..where(
        (table) =>
            table.createdAt.isBiggerOrEqualValue(startOfDay) &
            table.createdAt.isSmallerThanValue(endOfDay) &
            table.status.equals('completed'),
      );

    final sales = await query.get();

    return sales.length;
  }

  model.Sale _toSaleModel(Sale row) {
    return model.Sale(
      id: row.id,
      customerId: row.customerId,
      subtotal: row.subtotal,
      discount: row.discount,
      taxAmount: row.taxAmount,
      total: row.total,
      paidAmount: row.paidAmount,
      paymentMethod: row.paymentMethod,
      paymentMethodDetails: row.paymentMethodDetails,
      status: row.status,
      createdAt: row.createdAt,
    );
  }
}
