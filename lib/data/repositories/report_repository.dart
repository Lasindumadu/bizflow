import 'package:drift/drift.dart';

import '../../core/session/session_authorization.dart';
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
  final double totalRefunded;

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
    this.totalRefunded = 0.0,
  });

  double get monthlyProfit {
    return thisMonth.grossProfit - monthlyExpenses;
  }

  /// Net revenue after refunds (all-time refunds vs this month's revenue is
  /// not meaningful, so this exposes this month's revenue minus all refunds
  /// only for display of returns impact).
  double get refundImpact => totalRefunded;
}

/// Revenue share for one payment method.
class PaymentMethodTotal {
  final String method;
  final double amount;
  final int count;

  const PaymentMethodTotal({
    required this.method,
    required this.amount,
    required this.count,
  });
}

/// Aggregated insight about a single customer's purchasing.
class CustomerInsight {
  final String customerName;
  final double totalSpent;
  final int orderCount;

  const CustomerInsight({
    required this.customerName,
    required this.totalSpent,
    required this.orderCount,
  });
}

/// Profit + margin for a product or category over a period.
class MarginRow {
  final String label;
  final double revenue;
  final double cost;
  final int unitsSold;

  const MarginRow({
    required this.label,
    required this.revenue,
    required this.cost,
    required this.unitsSold,
  });

  double get profit => revenue - cost;

  double get marginPct => revenue <= 0 ? 0 : (profit / revenue) * 100;
}

/// One period's headline figures, used for side-by-side comparisons.
class PeriodComparison {
  final String label;
  final double revenue;
  final double profit;
  final int transactions;

  const PeriodComparison({
    required this.label,
    required this.revenue,
    required this.profit,
    required this.transactions,
  });

  /// Percentage change in revenue vs [previous], or null when not comparable.
  double? revenueChangeVs(PeriodComparison previous) {
    if (previous.revenue <= 0) return null;
    return ((revenue - previous.revenue) / previous.revenue) * 100;
  }
}

class ReportRepository {
  final AppDatabase database;

  ReportRepository(this.database);

  /// Resolves the acting staff and enforces owner-or-manager authorization
  /// for report access (sensitive financial information).
  ///
  /// Cashiers are POS-only per the documented role matrix; the gate lives
  /// here so direct repository invocation cannot bypass the reports UI.
  Future<ResolvedActor> _authorizeReports() async {
    final actor = await resolveActor(database);
    requireRole(actor.staff, {
      StaffRole.owner,
      StaffRole.manager,
    }, 'view reports');
    return actor;
  }

  Future<SalesReport> getTodayReport() async {
    await _authorizeReports();
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);

    final end = start.add(const Duration(days: 1));

    return _getSalesReport(start: start, end: end);
  }

  Future<SalesReport> getThisWeekReport() async {
    await _authorizeReports();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final daysFromMonday = today.weekday - 1;

    final start = today.subtract(Duration(days: daysFromMonday));

    final end = start.add(const Duration(days: 7));

    return _getSalesReport(start: start, end: end);
  }

  Future<SalesReport> getThisMonthReport() async {
    await _authorizeReports();
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, 1);

    final end = DateTime(now.year, now.month + 1, 1);

    return _getSalesReport(start: start, end: end);
  }

  Future<double> getTotalExpenses() async {
    await _authorizeReports();
    final expenses = await database.select(database.expenses).get();

    return expenses.fold<double>(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  Future<double> getMonthlyExpenses() async {
    await _authorizeReports();
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
    await _authorizeReports();
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
    await _authorizeReports();
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
          quantitySold: item.quantity.toInt(),
          revenue: item.total,
        );
      } else {
        existing.quantitySold += item.quantity.toInt();
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
    await _authorizeReports();
    final products = await database.select(database.products).get();

    return products.fold<double>(
      0.0,
      (total, product) =>
          total + (product.purchasePrice * product.stockQuantity),
    );
  }

  Future<int> getLowStockProductCount() async {
    await _authorizeReports();
    final products = await database.select(database.products).get();

    return products.where((product) {
      return product.stockQuantity <= product.lowStockThreshold;
    }).length;
  }

  /// Revenue split by payment method across all completed sales.
  Future<List<PaymentMethodTotal>> getPaymentMethodBreakdown() async {
    await _authorizeReports();
    final sales = await (database.select(
      database.sales,
    )..where((t) => t.status.equals('completed'))).get();

    final Map<String, PaymentMethodTotal> totals = {};
    for (final sale in sales) {
      final key = sale.paymentMethod.isEmpty ? 'cash' : sale.paymentMethod;
      final existing = totals[key];
      totals[key] = PaymentMethodTotal(
        method: key,
        amount: (existing?.amount ?? 0) + sale.total,
        count: (existing?.count ?? 0) + 1,
      );
    }

    final result = totals.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  /// Top customers by total amount spent (all-time, completed sales).
  Future<List<CustomerInsight>> getCustomerInsights({int limit = 5}) async {
    await _authorizeReports();
    final sales = await (database.select(
      database.sales,
    )..where((t) => t.status.equals('completed'))).get();

    final customers = await database.select(database.customers).get();
    final nameById = {for (final c in customers) c.id: c.name};

    final Map<String, CustomerInsight> totals = {};
    for (final sale in sales) {
      final id = sale.customerId;
      if (id == null) continue;
      final name = nameById[id] ?? 'Walk-in';
      final existing = totals[id];
      totals[id] = CustomerInsight(
        customerName: name,
        totalSpent: (existing?.totalSpent ?? 0) + sale.total,
        orderCount: (existing?.orderCount ?? 0) + 1,
      );
    }

    final result = totals.values.toList()
      ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
    return result.take(limit).toList();
  }

  /// Profit & margin grouped by product, highest profit first.
  Future<List<MarginRow>> getMarginByProduct({int limit = 10}) async {
    await _authorizeReports();
    final rows = await _salesInRange(null, null);
    final grouped = <String, _MarginAccumulator>{};

    for (final entry in rows) {
      final item = entry.item;
      final revenue = item.unitPrice * item.quantity;
      final cost = item.purchasePrice * item.quantity;
      final acc = grouped.putIfAbsent(
        item.productName,
        () => _MarginAccumulator(),
      );
      acc.revenue += revenue;
      acc.cost += cost;
      acc.units += item.quantity.toInt();
    }

    final result =
        grouped.entries
            .map(
              (e) => MarginRow(
                label: e.key,
                revenue: e.value.revenue,
                cost: e.value.cost,
                unitsSold: e.value.units,
              ),
            )
            .toList()
          ..sort((a, b) => b.profit.compareTo(a.profit));

    return result.take(limit).toList();
  }

  /// Profit & margin grouped by category, highest profit first.
  Future<List<MarginRow>> getMarginByCategory() async {
    await _authorizeReports();
    final products = await database.select(database.products).get();
    final categoryByProduct = {
      for (final p in products)
        p.id: p.category.isEmpty ? 'Uncategorised' : p.category,
    };

    final rows = await _salesInRange(null, null);
    final grouped = <String, _MarginAccumulator>{};

    for (final entry in rows) {
      final item = entry.item;
      final category = categoryByProduct[item.productId] ?? 'Uncategorised';
      final acc = grouped.putIfAbsent(category, () => _MarginAccumulator());
      acc.revenue += item.unitPrice * item.quantity;
      acc.cost += item.purchasePrice * item.quantity;
      acc.units += item.quantity.toInt();
    }

    final result =
        grouped.entries
            .map(
              (e) => MarginRow(
                label: e.key,
                revenue: e.value.revenue,
                cost: e.value.cost,
                unitsSold: e.value.units,
              ),
            )
            .toList()
          ..sort((a, b) => b.profit.compareTo(a.profit));

    return result;
  }

  /// This period vs the immediately preceding period of equal length.
  Future<({PeriodComparison current, PeriodComparison previous})>
  getPeriodComparison({required int days, String label = 'This period'}) async {
    await _authorizeReports();
    final now = DateTime.now();
    final currentStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    final previousStart = currentStart.subtract(Duration(days: days));
    final end = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));

    final current = await _periodStats(currentStart, end, label);
    final previous = await _periodStats(
      previousStart,
      currentStart,
      'Previous $days days',
    );

    return (current: current, previous: previous);
  }

  Future<PeriodComparison> _periodStats(
    DateTime start,
    DateTime end,
    String label,
  ) async {
    final report = await _getSalesReport(start: start, end: end);
    return PeriodComparison(
      label: label,
      revenue: report.revenue,
      profit: report.grossProfit,
      transactions: report.transactionCount,
    );
  }

  /// Completed sale rows (sale + item) optionally within a date range.
  Future<List<({Sale sale, SaleItem item})>> _salesInRange(
    DateTime? start,
    DateTime? end,
  ) async {
    final salesQuery = database.select(database.sales)
      ..where((t) => t.status.equals('completed'));

    final sales = await salesQuery.get();
    final filtered = sales.where((s) {
      if (start != null && s.createdAt.isBefore(start)) return false;
      if (end != null && !s.createdAt.isBefore(end)) return false;
      return true;
    }).toList();

    if (filtered.isEmpty) return [];

    final ids = filtered.map((s) => s.id).toSet();
    final items = await (database.select(
      database.saleItems,
    )..where((t) => t.saleId.isIn(ids))).get();

    final saleById = {for (final s in filtered) s.id: s};
    return items
        .where((i) => saleById.containsKey(i.saleId))
        .map((i) => (sale: saleById[i.saleId]!, item: i))
        .toList();
  }

  Future<ReportSummary> getSummary() async {
    await _authorizeReports();

    final today = await getTodayReport();

    final thisWeek = await getThisWeekReport();

    final thisMonth = await getThisMonthReport();

    final totalExpenses = await getTotalExpenses();

    final monthlyExpenses = await getMonthlyExpenses();

    final expenseCategories = await getExpenseCategoryTotals();

    final bestSellingProducts = await getBestSellingProducts();

    final stockValue = await getStockValue();

    final lowStockProducts = await getLowStockProductCount();

    final totalRefunded = await getTotalRefunded();

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
      totalRefunded: totalRefunded,
    );
  }

  /// Total value refunded across all recorded returns.
  Future<double> getTotalRefunded() async {
    await _authorizeReports();
    final rows = await database.select(database.saleReturns).get();
    return rows.fold<double>(0, (s, r) => s + r.refundAmount);
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

/// Mutable accumulator used when grouping margin rows.
class _MarginAccumulator {
  double revenue = 0;
  double cost = 0;
  int units = 0;
}
