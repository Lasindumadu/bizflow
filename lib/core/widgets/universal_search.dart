import 'dart:async';

import 'package:flutter/material.dart';

import 'package:drift/drift.dart' hide Column;

import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decor.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../../features/sales/presentation/screens/sale_details_screen.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/products/presentation/screens/add_product_screen.dart';
import '../../models/product.dart';

/// A record type supported by the universal search.
enum SearchCategory { product, customer, sale }

/// One result row of the universal search.
class SearchResult {
  final SearchCategory category;
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onOpen;

  const SearchResult({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onOpen,
  });
}

/// A lightweight in-memory cache that keeps search snappy.
class UniversalSearchService {
  final AppDatabase _db;
  UniversalSearchService(this._db);

  Future<List<ProductRow>> getProducts() => _db.select(_db.products).get();
  Future<List<Customer>> getCustomers() => _db.select(_db.customers).get();
  Future<List<Sale>> getSales() => (_db.select(
    _db.sales,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
}

/// Full-screen blurred command-palette search across Products, Customers and
/// Sales. Opens with the header search button or Ctrl/Cmd+K.
class UniversalSearchOverlay extends StatefulWidget {
  const UniversalSearchOverlay({super.key});

  /// Convenience helper to show the search overlay.
  static Future<void> show(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (_, animation, secondaryAnimation) =>
            const UniversalSearchOverlay(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            ),
      ),
    );
  }

  @override
  State<UniversalSearchOverlay> createState() => _UniversalSearchOverlayState();
}

class _UniversalSearchOverlayState extends State<UniversalSearchOverlay> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<SearchResult> _results = [];
  bool _searched = false;
  int _highlighted = 0;
  Timer? _debounce;
  UniversalSearchService? _service;

  @override
  void initState() {
    super.initState();
    _service = UniversalSearchService(appDatabase);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      _runSearch(value.trim());
    });
  }

  Future<void> _runSearch(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _results = [];
        _searched = false;
        _highlighted = 0;
      });
      return;
    }

    final service = _service;
    if (service == null) return;
    final lower = query.toLowerCase();

    final products = await service.getProducts();
    final customers = await service.getCustomers();
    final sales = await service.getSales();

    final results = <SearchResult>[];

    for (final p in products) {
      if (p.name.toLowerCase().contains(lower) ||
          p.sku.toLowerCase().contains(lower) ||
          p.barcode.contains(query)) {
        results.add(
          SearchResult(
            category: SearchCategory.product,
            title: p.name,
            subtitle: 'SKU $p.sku • ${p.category} • Stock ${p.stockQuantity}',
            icon: Icons.inventory_2_rounded,
            gradient: AppDecor.skyGradient,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddProductScreen(product: _toProduct(p)),
              ),
            ),
          ),
        );
        if (results.length >= 12) break;
      }
    }
    for (final c in customers) {
      if (c.name.toLowerCase().contains(lower) || c.phone.contains(query)) {
        results.add(
          SearchResult(
            category: SearchCategory.customer,
            title: c.name,
            subtitle:
                '${c.phone.isEmpty ? 'No phone' : c.phone} • ${c.loyaltyTier}',
            icon: Icons.person_rounded,
            gradient: AppDecor.violetGradient,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CustomersScreen()),
            ),
          ),
        );
        if (results.length >= 12) break;
      }
    }
    for (final s in sales) {
      if (s.id.contains(query) || (s.status.toLowerCase().contains(lower))) {
        results.add(
          SearchResult(
            category: SearchCategory.sale,
            title: 'Sale ${s.id}',
            subtitle:
                '${s.status} • total ${s.total.toStringAsFixed(2)} • ${s.paymentMethod}',
            icon: Icons.receipt_long_rounded,
            gradient: AppDecor.moneyGradient,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SaleDetailsScreen(saleId: s.id),
              ),
            ),
          ),
        );
        if (results.length >= 12) break;
      }
    }

    if (!mounted) return;
    setState(() {
      _results = results;
      _searched = true;
      _highlighted = 0;
    });
  }

  Product _toProduct(ProductRow row) => Product(
    id: row.id,
    name: row.name,
    sku: row.sku,
    category: row.category,
    purchasePrice: row.purchasePrice,
    sellingPrice: row.sellingPrice,
    stockQuantity: row.stockQuantity,
    lowStockThreshold: row.lowStockThreshold,
    barcode: row.barcode,
  );

  void _openResult(SearchResult r) {
    Navigator.of(context).pop();
    r.onOpen();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () {}, // swallow taps inside the palette
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(top: 80, left: 24, right: 24),
                constraints: const BoxConstraints(maxWidth: 640),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 44,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : AppColors.lightSurfaceVariant,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: scheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _queryController,
                              focusNode: _focusNode,
                              autofocus: true,
                              onChanged: _onQueryChanged,
                              style: AppTextStyles.titleMedium,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Search products, customers, sales…',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _KbdHint(
                            label: 'ESC',
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    Flexible(
                      child: _results.isEmpty
                          ? _buildEmpty(scheme)
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _results.length,
                              itemBuilder: (context, i) {
                                final r = _results[i];
                                return _SearchRow(
                                  result: r,
                                  highlighted: _highlighted == i,
                                  onHover: () =>
                                      setState(() => _highlighted = i),
                                  onOpen: () => _openResult(r),
                                );
                              },
                            ),
                    ),

                    // Footer hints
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : AppColors.lightBorder,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _KbdHint(label: '↑↓'),
                          const SizedBox(width: 6),
                          Text(
                            'Navigate',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _KbdHint(label: '↵'),
                          const SizedBox(width: 6),
                          Text(
                            'Open',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_results.length} result${_results.length == 1 ? '' : 's'}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme scheme) {
    final text = _searched
        ? 'No matches for “${_queryController.text}”'
        : 'Type to search across your entire business';
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _searched ? Icons.search_off_rounded : Icons.travel_explore_rounded,
            size: 44,
            color: scheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final SearchResult result;
  final bool highlighted;
  final VoidCallback onHover;
  final VoidCallback onOpen;

  const _SearchRow({
    required this.result,
    required this.highlighted,
    required this.onHover,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => onHover(),
      child: InkWell(
        onTap: onOpen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          color: highlighted
              ? scheme.primary.withValues(alpha: isDark ? 0.18 : 0.08)
              : Colors.transparent,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: result.gradient,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: AppDecor.glow(
                    result.gradient.colors.first,
                    alpha: 0.25,
                  ),
                ),
                child: Icon(result.icon, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      result.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KbdHint extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _KbdHint({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(7),
            child: _chip(scheme, isDark),
          )
        : _chip(scheme, isDark);
  }

  Widget _chip(ColorScheme scheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.lightBorder,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
