import 'package:drift/drift.dart';

import '../database/app_database.dart';

class SalesReport {
  final double revenue;
  final int transactionCount;
  final double costOfGoodsSold;
  final double grossProfit;

  const SalesReport({
    required this.revenue,
    required this.transactionCount,
    required this.costOfGoodsSold,
    required this.grossProfit,
  });
}

class ExpenseCategoryTotal {
  final String category;
  final double amount;

  const ExpenseCategoryTotal({required this.category, required this.amount});
}

class BestSellingProduct {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  const BestSellingProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });
}

class ReportSummary {
  final SalesReport today;
  final SalesReport thisWeek;
  final SalesReport thisMonth;
  final double totalExpenses;
  final double monthlyExpenses;
  final List<ExpenseCategoryTotal> expenseCategories;
  final List<BestSellingProduct> bestSellingProducts;
  final double stockValue;
  final int lowStockProducts;

  const ReportSummary({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.totalExpenses,
    required this.monthlyExpenses,
    required this.expenseCategories,
    required this.bestSellingProducts,
    required this.stockValue,
    required this.lowStockProducts,
  });

  double get monthlyProfit {
    return thisMonth.grossProfit - monthlyExpenses;
  }
}

class ReportRepository {
  final AppDatabase database;

  ReportRepository(this.database);

  Future<SalesReport> getTodayReport() {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);

    final end = start.add(const Duration(days: 1));

    return _getSalesReport(start: start, end: end);
  }

  Future<SalesReport> getThisWeekReport() {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final daysFromMonday = today.weekday - 1;

    final start = today.subtract(Duration(days: daysFromMonday));

    final end = start.add(const Duration(days: 7));

    return _getSalesReport(start: start, end: end);
  }

  Future<SalesReport> getThisMonthReport() {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, 1);

    final end = DateTime(now.year, now.month + 1, 1);

    return _getSalesReport(start: start, end: end);
  }

  Future<double> getTotalExpenses() async {
    final expenses = await database.select(database.expenses).get();

    return expenses.fold<double>(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  Future<double> getMonthlyExpenses() async {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, 1);

    final end = DateTime(now.year, now.month + 1, 1);

    final query = database.select(database.expenses)
      ..where(
        (table) =>
            table.date.isBiggerOrEqualValue(start) &
            table.date.isSmallerThanValue(end),
      );

    final expenses = await query.get();

    return expenses.fold<double>(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  Future<List<ExpenseCategoryTotal>> getExpenseCategoryTotals() async {
    final expenses = await database.select(database.expenses).get();

    final Map<String, double> totals = {};

    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }

    final result = totals.entries
        .map(
          (entry) =>
              ExpenseCategoryTotal(category: entry.key, amount: entry.value),
        )
        .toList();

    result.sort((a, b) => b.amount.compareTo(a.amount));

    return result;
  }

  Future<List<BestSellingProduct>> getBestSellingProducts({
    int limit = 5,
  }) async {
    final salesQuery = database.select(database.sales)
      ..where((table) => table.status.equals('completed'));

    final sales = await salesQuery.get();

    if (sales.isEmpty) {
      return [];
    }

    final completedSaleIds = sales.map((sale) => sale.id).toSet();

    final itemsQuery = database.select(database.saleItems)
      ..where((table) => table.saleId.isIn(completedSaleIds));

    final items = await itemsQuery.get();

    final Map<String, _ProductSalesData> productData = {};

    for (final item in items) {
      final existing = productData[item.productId];

      if (existing == null) {
        productData[item.productId] = _ProductSalesData(
          productId: item.productId,
          productName: item.productName,
          quantitySold: item.quantity,
          revenue: item.total,
        );
      } else {
        existing.quantitySold += item.quantity;
        existing.revenue += item.total;
      }
    }

    final result = productData.values
        .map(
          (data) => BestSellingProduct(
            productId: data.productId,
            productName: data.productName,
            quantitySold: data.quantitySold,
            revenue: data.revenue,
          ),
        )
        .toList();

    result.sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    return result.take(limit).toList();
  }

  Future<double> getStockValue() async {
    final products = await database.select(database.products).get();

    return products.fold<double>(
      0.0,
      (total, product) =>
          total + (product.purchasePrice * product.stockQuantity),
    );
  }

  Future<int> getLowStockProductCount() async {
    final products = await database.select(database.products).get();

    return products.where((product) {
      return product.stockQuantity <= product.lowStockThreshold;
    }).length;
  }

  Future<ReportSummary> getSummary() async {
    final today = await getTodayReport();

    final thisWeek = await getThisWeekReport();

    final thisMonth = await getThisMonthReport();

    final totalExpenses = await getTotalExpenses();

    final monthlyExpenses = await getMonthlyExpenses();

    final expenseCategories = await getExpenseCategoryTotals();

    final bestSellingProducts = await getBestSellingProducts();

    final stockValue = await getStockValue();

    final lowStockProducts = await getLowStockProductCount();

    return ReportSummary(
      today: today,
      thisWeek: thisWeek,
      thisMonth: thisMonth,
      totalExpenses: totalExpenses,
      monthlyExpenses: monthlyExpenses,
      expenseCategories: expenseCategories,
      bestSellingProducts: bestSellingProducts,
      stockValue: stockValue,
      lowStockProducts: lowStockProducts,
    );
  }

  Future<SalesReport> _getSalesReport({
    required DateTime start,
    required DateTime end,
  }) async {
    final salesQuery = database.select(database.sales)
      ..where(
        (table) =>
            table.createdAt.isBiggerOrEqualValue(start) &
            table.createdAt.isSmallerThanValue(end) &
            table.status.equals('completed'),
      );

    final sales = await salesQuery.get();

    if (sales.isEmpty) {
      return const SalesReport(
        revenue: 0.0,
        transactionCount: 0,
        costOfGoodsSold: 0.0,
        grossProfit: 0.0,
      );
    }

    final saleIds = sales.map((sale) => sale.id).toSet();

    final itemsQuery = database.select(database.saleItems)
      ..where((table) => table.saleId.isIn(saleIds));

    final items = await itemsQuery.get();

    // COGS uses the purchase price stored on each
    // sale item at the time of the sale.
    double costOfGoodsSold = 0.0;

    for (final item in items) {
      costOfGoodsSold += item.purchasePrice * item.quantity;
    }

    // Revenue is the final sale total after discount.
    final revenue = sales.fold<double>(
      0.0,
      (total, sale) => total + sale.total,
    );

    final grossProfit = revenue - costOfGoodsSold;

    return SalesReport(
      revenue: revenue,
      transactionCount: sales.length,
      costOfGoodsSold: costOfGoodsSold,
      grossProfit: grossProfit,
    );
  }
}

class _ProductSalesData {
  final String productId;
  final String productName;
  int quantitySold;
  double revenue;

  _ProductSalesData({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });
}
