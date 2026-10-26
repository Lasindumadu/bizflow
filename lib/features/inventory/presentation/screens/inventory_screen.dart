import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/stock_movement_repository.dart';
import '../../../../models/product.dart';
import '../widgets/inventory_product_card.dart';
import '../widgets/stock_action_dialog.dart';

class InventoryScreen extends StatefulWidget {
  final bool showAppBar;
  const InventoryScreen({super.key, this.showAppBar = true});

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  final ProductRepository _productRepository = ProductRepository(appDatabase);

  final StockMovementRepository _stockMovementRepository =
      StockMovementRepository(appDatabase);

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _stockSectionKey = GlobalKey();

  StreamSubscription<List<Product>>? _productsSubscription;

  List<Product> _products = [];
  String _searchQuery = '';
  String _stockFilter = 'all'; // all | low | out — list view filter only.
  String _currency = 'USD';
  bool _isLoading = true;
  bool _hasError = false;

  /// Whether the acting session can adjust stock (owner or manager).
  bool get _canManageStock => canPerform(
        sessionController.current,
        {StaffRole.owner, StaffRole.manager},
      );

  @override
  void initState() {
    super.initState();

    _watchProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBusinessSettings();
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> refreshBusinessSettings() async {
    await _loadBusinessSettings();
  }

  Future<void> _loadBusinessSettings() async {
    try {
      final settings = await _businessSettingsRepository.getSettings();

      if (!mounted) {
        return;
      }

      setState(() {
        _currency = settings.currency;
      });
    } catch (_) {
      // Display-only: fall back to the default currency code.
    }
  }

  void _watchProducts() {
    _productsSubscription?.cancel();

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    _productsSubscription = _productRepository.watchProducts().listen(
      (products) {
        if (!mounted) {
          return;
        }

        setState(() {
          _products = products;
          _isLoading = false;
          _hasError = false;
        });
      },
      onError: (_) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      },
    );
  }

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = query.isEmpty
        ? [..._products]
        : _products.where((product) {
            return product.name.toLowerCase().contains(query) ||
                product.sku.toLowerCase().contains(query) ||
                product.category.toLowerCase().contains(query) ||
                product.barcode.trim().toLowerCase().contains(query);
          }).toList();

    final viewFiltered = switch (_stockFilter) {
      'low' => filtered.where((product) => product.isLowStock).toList(),
      'out' =>
        filtered.where((product) => product.stockQuantity == 0).toList(),
      _ => filtered,
    };

    viewFiltered.sort(
      (a, b) =>
          a.name.trim().toLowerCase().compareTo(b.name.trim().toLowerCase()),
    );

    return viewFiltered;
  }

  double get _totalUnits {
    return _products.fold(0.0, (total, product) => total + product.stockQuantity);
  }

  double get _stockValue {
    return _products.fold(
      0,
      (total, product) =>
          total + product.stockQuantity * product.purchasePrice,
    );
  }

  int get _lowStockCount {
    return _products.where((product) {
      return product.isLowStock;
    }).length;
  }

  int get _outOfStockCount {
    return _products.where((product) {
      return product.stockQuantity == 0;
    }).length;
  }

  void _scrollToStock() {
    final target = _stockSectionKey.currentContext;
    if (target == null) return;

    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  Future<void> _performStockAction(
    Product product,
    StockActionType actionType,
  ) async {
    final result = await showDialog<StockActionResult>(
      context: context,
      builder: (context) {
        return StockActionDialog(product: product, actionType: actionType);
      },
    );

    if (result == null || !mounted) {
      return;
    }

    try {
      await _productRepository.changeStock(
        productId: product.id,
        quantity: result.quantity,
        type: result.type,
        note: result.note,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update stock: $error')));
    }
  }

  Future<void> _showHistory(Product product) async {
    final movements = await _stockMovementRepository.getProductMovements(
      product.id,
    );

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.history_rounded, size: 22),
              SizedBox(width: 8),
              Expanded(child: Text('Stock movement')),
            ],
          ),
          content: SizedBox(
            width: 600,
            height: 400,
            child: movements.isEmpty
                ? const Center(child: Text('No stock movements yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      return _MovementTimelineRow(
                        movement: movements[index],
                        isFirst: index == 0,
                        isLast: index == movements.length - 1,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text(
              'Unable to load inventory',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Something went wrong while loading your inventory.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            FilledButton.icon(
              onPressed: _watchProducts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Hero stat row: in-stock value (mint), low stock (amber),
  /// out of stock (error).
  Widget _buildKpiRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45);

    Widget kpi({
      required String label,
      required String value,
      required IconData icon,
      required Color soft,
      required Color deep,
      required List<Color> fill,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? deep.withValues(alpha: 0.22) : soft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: deep.withValues(alpha: isDark ? 0.35 : 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: fill),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(icon, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              CountUpText(
                double.tryParse(value) ?? 0,
                decimals: label == 'In-stock value' ? 2 : 0,
                prefix: label == 'In-stock value' ? '$_currency ' : '',
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isDark
                      ? (label == 'In-stock value'
                          ? AppColors.brandMint
                          : deep)
                      : deep,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kpi(
          label: 'In-stock value',
          value: _stockValue.toStringAsFixed(2),
          icon: Icons.account_balance_wallet_rounded,
          soft: AppColors.moneyTint.first,
          deep: AppColors.brandMintDeep,
          fill: AppDecor.flowGradient.colors,
        ),
        const SizedBox(width: 10),
        kpi(
          label: 'Low stock',
          value: '$_lowStockCount',
          icon: Icons.warning_amber_rounded,
          soft: AppColors.growthTint.first,
          deep: AppColors.warningDark,
          fill: AppDecor.amberGradient.colors,
        ),
        const SizedBox(width: 10),
        kpi(
          label: 'Out of stock',
          value: '$_outOfStockCount',
          icon: Icons.remove_circle_outline_rounded,
          soft: AppColors.errorContainer,
          deep: AppColors.errorDark,
          fill: AppDecor.errorGradient.colors,
        ),
      ],
    ).animate(delay: 80.ms).fadeIn(duration: 380.ms).moveY(
          begin: 14,
          end: 0,
          duration: 380.ms,
          curve: Curves.easeOutCubic,
        );
  }

  /// Royal-selected quick filter chips for the stock view.
  Widget _buildFilterChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget chip(String value, String label, IconData icon) {
      final selected = _stockFilter == value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: selected ? AppDecor.royalGradient : null,
          color: selected ? null : (isDark ? Colors.transparent : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : AppColors.lightBorder),
          ),
          boxShadow: selected
              ? AppDecor.glow(AppColors.royalMid, alpha: 0.28)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _stockFilter = value),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: selected
                        ? Colors.white
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                chip('all', 'All stock', Icons.inventory_2_outlined),
                const SizedBox(width: 8),
                chip('low', 'Low stock', Icons.warning_amber_rounded),
                const SizedBox(width: 8),
                chip('out', 'Out of stock', Icons.remove_circle_outline_rounded),
              ],
            ),
          ),
        ),
      ],
    ).animate(delay: 160.ms).fadeIn(duration: 380.ms).moveY(
          begin: 14,
          end: 0,
          duration: 380.ms,
          curve: Curves.easeOutCubic,
        );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Inventory'))
          : null,
      body: _hasError
          ? _buildErrorState().animate().fadeIn(duration: 300.ms).shake()
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHero(
                    eyebrow: 'Stock control',
                    title: 'Inventory',
                    subtitle:
                        '${_products.length} SKUs · $_totalUnits units on hand · '
                        'stock value $_currency ${_stockValue.toStringAsFixed(2)}',
                    showIllustration: false,
                    image: AppImages.warehouse,
                    action: _buildHeroCta(),
                  ).animate().fadeIn(duration: 350.ms).slideY(
                        begin: -0.05,
                        end: 0,
                        duration: 350.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  _buildKpiRow(),
                  const SizedBox(height: AppDimensions.spacingLg),
                  BrandCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    radius: 999,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search by name, SKU, category or barcode…',
                        prefixIcon: Icon(Icons.search_rounded, size: 19),
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ).animate(delay: 160.ms).fadeIn(duration: 380.ms).moveY(
                        begin: 14,
                        end: 0,
                        duration: 380.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  _buildFilterChips(),
                  const SizedBox(height: AppDimensions.spacingXl),
                  KeyedSubtree(
                    key: _stockSectionKey,
                    child: SectionHeading(
                      title: 'Stock on hand',
                      subtitle: '${products.length} items in this view',
                      icon: Icons.warehouse_rounded,
                      trailing: BrandPill(
                        label: '$_totalUnits UNITS',
                        color: AppColors.stockTint.last,
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 380.ms).moveY(
                        begin: 14,
                        end: 0,
                        duration: 380.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingXl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AuroraLoader(size: 44),
                            SizedBox(height: AppDimensions.spacingMd),
                            Text(
                              'Loading inventory...',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms)
                  else if (products.isEmpty)
                    BrandEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products found',
                      message: _searchQuery.isNotEmpty || _stockFilter != 'all'
                          ? 'Try another search or clear the filters.'
                          : 'Add products first to start tracking stock.',
                      image: AppImages.warehouse,
                    ).animate().fadeIn(duration: 400.ms)
                  else
                    ...products.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final product = entry.value;

                        final card = InventoryProductCard(
                          product: product,
                          canManageStock: _canManageStock,
                          onStockIn: _canManageStock
                              ? () {
                                  _performStockAction(
                                    product,
                                    StockActionType.stockIn,
                                  );
                                }
                              : null,
                          onStockOut: _canManageStock
                              ? () {
                                  _performStockAction(
                                    product,
                                    StockActionType.stockOut,
                                  );
                                }
                              : null,
                          onAdjustment: _canManageStock
                              ? () {
                                  _performStockAction(
                                    product,
                                    StockActionType.adjustment,
                                  );
                                }
                              : null,
                          onHistory: () {
                            _showHistory(product);
                          },
                        );

                        // Stagger only the first screenful; rows below
                        // arrive instantly so scrolling never lags.
                        if (index >= 12) return card;

                        return card
                            .animate(
                              delay: Duration(milliseconds: 60 * index + 240),
                            )
                            .fadeIn(
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .moveY(
                              begin: 14,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOutCubic,
                            );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  /// Primary hero CTA — jumps the operator straight to the stock list.
  Widget _buildHeroCta() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppDecor.royalGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.35),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _scrollToStock,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Count stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.layers_rounded,
                size: 15,
                color: AppColors.brandMint,
              ),
              const SizedBox(width: 6),
              Text(
                '$_totalUnits units',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Timeline-style stock movement row with a dot rail tinted by the
/// movement sign: mint for stock in, rose for stock out, gray for
/// adjustments.
class _MovementTimelineRow extends StatelessWidget {
  final StockMovement movement;
  final bool isFirst;
  final bool isLast;

  const _MovementTimelineRow({
    required this.movement,
    required this.isFirst,
    required this.isLast,
  });

  bool get _isIn => movement.type == 'STOCK_IN';
  bool get _isOut => movement.type == 'STOCK_OUT';

  Color _dotColor(bool isDark) {
    if (_isIn) return isDark ? AppColors.brandMint : AppColors.brandMintDeep;
    if (_isOut) return isDark ? AppColors.roseLight : AppColors.rose;
    return AppColors.chartGray;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final dot = _dotColor(isDark);
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dot,
                    boxShadow: AppDecor.glow(dot, alpha: 0.35),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: scheme.onSurface.withValues(alpha: 0.08),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        movement.type.replaceAll('_', ' ').toLowerCase(),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _isOut
                            ? '-${movement.quantity.abs()}'
                            : '+${movement.quantity.abs()}',
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: _isIn
                              ? (isDark
                                  ? AppColors.brandMint
                                  : AppColors.brandMintDeep)
                              : (_isOut
                                  ? (isDark
                                      ? AppColors.roseLight
                                      : AppColors.rose)
                                  : AppColors.chartGray),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${movement.previousStock} → ${movement.newStock} units',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (movement.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      movement.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: muted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
