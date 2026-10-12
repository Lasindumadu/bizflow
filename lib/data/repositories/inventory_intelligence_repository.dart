import '../database/app_database.dart';

/// A product suggested for reorder, with the reasoning behind it.
class ReorderSuggestion {
  final String productId;
  final String name;
  final String sku;
  final int currentStock;
  final int lowStockThreshold;
  final int soldLast30Days;
  final double averageDailySales;
  final int suggestedReorderQuantity;

  const ReorderSuggestion({
    required this.productId,
    required this.name,
    required this.sku,
    required this.currentStock,
    required this.lowStockThreshold,
    required this.soldLast30Days,
    required this.averageDailySales,
    required this.suggestedReorderQuantity,
  });

  bool get isOutOfStock => currentStock <= 0;

  /// Rough days of cover left at the current run-rate.
  int get daysOfCover {
    if (averageDailySales <= 0) return 999;
    return (currentStock / averageDailySales).floor();
  }
}

/// A product that has not sold in the analysis window.
class DeadStockItem {
  final String productId;
  final String name;
  final String sku;
  final int stockQuantity;
  final double stockValue;
  final DateTime? lastSoldAt;

  const DeadStockItem({
    required this.productId,
    required this.name,
    required this.sku,
    required this.stockQuantity,
    required this.stockValue,
    required this.lastSoldAt,
  });
}

/// Inventory intelligence derived from products + completed sales history.
///
/// Everything here is computed on demand from existing tables — no schema
/// changes required.
class InventoryIntelligenceRepository {
  final AppDatabase database;

  InventoryIntelligenceRepository(this.database);

  /// Products that should be reordered soon, ranked by urgency.
  ///
  /// A product qualifies when it is at/below its low-stock threshold, OR its
  /// projected days-of-cover within [windowDays] falls below [coverDays].
  /// The suggested reorder quantity tops the product back up to roughly
  /// [targetCoverDays] of demand (minimum of the low-stock threshold).
  Future<List<ReorderSuggestion>> getReorderSuggestions({
    int windowDays = 30,
    int coverDays = 14,
    int targetCoverDays = 45,
  }) async {
    final products = await database.select(database.products).get();
    final salesByProduct = await _getSoldQuantities(windowDays);

    final result = <ReorderSuggestion>[];

    for (final product in products) {
      final sold = salesByProduct[product.id] ?? 0;
      final avgDaily = sold / windowDays;

      final belowThreshold = product.stockQuantity <= product.lowStockThreshold;
      final daysCover = avgDaily <= 0
          ? 999.0
          : product.stockQuantity / avgDaily;
      final runningLow = avgDaily > 0 && daysCover <= coverDays;

      if (!belowThreshold && !runningLow) continue;

      final targetStock = (avgDaily * targetCoverDays).ceil();
      final rawReorder = targetStock - product.stockQuantity;
      final suggested = rawReorder < product.lowStockThreshold
          ? product.lowStockThreshold
          : rawReorder;

      result.add(
        ReorderSuggestion(
          productId: product.id,
          name: product.name,
          sku: product.sku,
          currentStock: product.stockQuantity,
          lowStockThreshold: product.lowStockThreshold,
          soldLast30Days: sold,
          averageDailySales: avgDaily,
          suggestedReorderQuantity: suggested < 1 ? 1 : suggested,
        ),
      );
    }

    // Most urgent first: out of stock, then fewest days of cover.
    result.sort((a, b) {
      if (a.isOutOfStock != b.isOutOfStock) return a.isOutOfStock ? -1 : 1;
      return a.daysOfCover.compareTo(b.daysOfCover);
    });

    return result;
  }

  /// Products with positive stock that have not sold in [windowDays].
  Future<List<DeadStockItem>> getDeadStock({int windowDays = 60}) async {
    final products = await database.select(database.products).get();
    final soldByProduct = await _getSoldQuantities(windowDays);
    final lastSold = await _getLastSoldDates();

    final result = <DeadStockItem>[];

    for (final product in products) {
      final sold = soldByProduct[product.id] ?? 0;
      if (sold > 0 || product.stockQuantity <= 0) continue;

      result.add(
        DeadStockItem(
          productId: product.id,
          name: product.name,
          sku: product.sku,
          stockQuantity: product.stockQuantity,
          stockValue: product.purchasePrice * product.stockQuantity,
          lastSoldAt: lastSold[product.id],
        ),
      );
    }

    // Tie the most capital up first.
    result.sort((a, b) => b.stockValue.compareTo(a.stockValue));
    return result;
  }

  /// Total value of stock on hand, at both cost and retail.
  Future<StockValuation> getStockValuation() async {
    final products = await database.select(database.products).get();

    double costValue = 0;
    double retailValue = 0;
    int units = 0;

    for (final p in products) {
      costValue += p.purchasePrice * p.stockQuantity;
      retailValue += p.sellingPrice * p.stockQuantity;
      units += p.stockQuantity;
    }

    return StockValuation(
      productCount: products.length,
      totalUnits: units,
      costValue: costValue,
      retailValue: retailValue,
      potentialProfit: retailValue - costValue,
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  /// Quantity sold per product over the last [windowDays] (completed sales).
  Future<Map<String, int>> _getSoldQuantities(int windowDays) async {
    final since = DateTime.now().subtract(Duration(days: windowDays));

    final sales = await (database.select(
      database.sales,
    )..where((t) => t.status.equals('completed'))).get();

    final recentSaleIds = sales
        .where((s) => s.createdAt.isAfter(since))
        .map((s) => s.id)
        .toSet();

    if (recentSaleIds.isEmpty) return {};

    final items = await (database.select(
      database.saleItems,
    )..where((t) => t.saleId.isIn(recentSaleIds))).get();

    final map = <String, int>{};
    for (final item in items) {
      map[item.productId] = (map[item.productId] ?? 0) + item.quantity;
    }
    return map;
  }

  /// Most recent completed-sale date per product.
  Future<Map<String, DateTime>> _getLastSoldDates() async {
    final sales = await (database.select(
      database.sales,
    )..where((t) => t.status.equals('completed'))).get();

    if (sales.isEmpty) return {};
    final saleDate = {for (final s in sales) s.id: s.createdAt};

    final items = await database.select(database.saleItems).get();

    final map = <String, DateTime>{};
    for (final item in items) {
      final date = saleDate[item.saleId];
      if (date == null) continue;
      final existing = map[item.productId];
      if (existing == null || date.isAfter(existing)) {
        map[item.productId] = date;
      }
    }
    return map;
  }
}

/// Aggregate valuation of the current inventory.
class StockValuation {
  final int productCount;
  final int totalUnits;
  final double costValue;
  final double retailValue;
  final double potentialProfit;

  const StockValuation({
    required this.productCount,
    required this.totalUnits,
    required this.costValue,
    required this.retailValue,
    required this.potentialProfit,
  });
}
