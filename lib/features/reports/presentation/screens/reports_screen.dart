import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/report_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => ReportsScreenState();
}

class ReportsScreenState extends State<ReportsScreen> {
  final ReportRepository _reportRepository = ReportRepository(appDatabase);

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  late Future<ReportSummary> _summaryFuture;
  late Future<List<PaymentMethodTotal>> _paymentFuture;
  late Future<List<CustomerInsight>> _customerFuture;
  late Future<List<MarginRow>> _productMarginFuture;
  late Future<List<MarginRow>> _categoryMarginFuture;
  late Future<({PeriodComparison current, PeriodComparison previous})>
  _comparisonFuture;

  int _rangeDays = 7;

  String _currency = 'USD';
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();

    _summaryFuture = _reportRepository.getSummary();
    _paymentFuture = _reportRepository.getPaymentMethodBreakdown();
    _customerFuture = _reportRepository.getCustomerInsights();
    _productMarginFuture = _reportRepository.getMarginByProduct();
    _categoryMarginFuture = _reportRepository.getMarginByCategory();
    _comparisonFuture = _reportRepository.getPeriodComparison(days: _rangeDays);
    _loadBusinessSettings();
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
        _isLoadingSettings = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingSettings = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadBusinessSettings();

    setState(() {
      _summaryFuture = _reportRepository.getSummary();
      _paymentFuture = _reportRepository.getPaymentMethodBreakdown();
      _customerFuture = _reportRepository.getCustomerInsights();
      _productMarginFuture = _reportRepository.getMarginByProduct();
      _categoryMarginFuture = _reportRepository.getMarginByCategory();
      _comparisonFuture = _reportRepository.getPeriodComparison(
        days: _rangeDays,
      );
    });

    await _summaryFuture;
  }

  String _money(double value) {
    return '$_currency ${value.toStringAsFixed(2)}';
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

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
                color: colorScheme.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text(
              'Unable to load reports',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Something went wrong while loading your reports.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoadingSettings
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Loading reports...',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            )
          : FutureBuilder<ReportSummary>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                final summary = snapshot.data;

                if (summary == null) {
                  return const Center(child: Text('No report data available.'));
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    children: [
                      _buildRangeSelector(),
                      const SizedBox(height: AppDimensions.spacingLg),
                      _buildComparisonSection(),
                      const SizedBox(height: AppDimensions.spacingXl),
                      _buildSectionTitle('Sales Overview'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildSalesPeriodCard(
                        title: 'Today',
                        report: summary.today,
                        icon: Icons.today_outlined,
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildSalesPeriodCard(
                        title: 'This Week',
                        report: summary.thisWeek,
                        icon: Icons.date_range_outlined,
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildSalesPeriodCard(
                        title: 'This Month',
                        report: summary.thisMonth,
                        icon: Icons.calendar_month_outlined,
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),
                      _buildSectionTitle('Business Overview'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildOverviewGrid(summary),
                      const SizedBox(height: AppDimensions.spacingXl),
                      _buildSectionTitle('Best-Selling Products'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildBestSellingProducts(summary.bestSellingProducts),
                      const SizedBox(height: AppDimensions.spacingXl),
                      _buildSectionTitle('Expenses by Category'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildExpenseCategories(summary.expenseCategories),
                      const SizedBox(height: AppDimensions.spacingXl),
                      _buildSectionTitle('Payment Methods'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildPaymentBreakdown(),
                      const SizedBox(height: AppDimensions.spacingXl),
                      _buildSectionTitle('Profit & Margin by Category'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildMarginList(_categoryMarginFuture),
                      const SizedBox(height: AppDimensions.spacingXl),
                      _buildSectionTitle('Profit by Product'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildMarginList(_productMarginFuture),
                      const SizedBox(height: AppDimensions.spacingXl),
                      _buildSectionTitle('Top Customers'),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _buildCustomerInsights(),
                      const SizedBox(height: AppDimensions.spacingLg),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading2);
  }

  Widget _buildSalesPeriodCard({
    required String title,
    required SalesReport report,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                  ),
                  child: Icon(icon, color: AppColors.primaryDark),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Text(title, style: AppTextStyles.heading2),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    label: 'Sales',
                    value: _money(report.revenue),
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    label: 'Transactions',
                    value: report.transactionCount.toString(),
                  ),
                ),
                Expanded(
                  child: _buildMetric(
                    label: 'Gross Profit',
                    value: _money(report.grossProfit),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(value, style: AppTextStyles.statValue),
      ],
    );
  }

  Widget _buildOverviewGrid(ReportSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 900
            ? 4
            : width >= 500
            ? 2
            : 1;

        final spacing = AppDimensions.spacingMd;

        final cardWidth = columns == 1
            ? width
            : (width - spacing * (columns - 1)) / columns;

        final cards = [
          _buildOverviewCard(
            icon: Icons.receipt_long_outlined,
            title: 'Total Expenses',
            value: _money(summary.totalExpenses),
          ),
          _buildOverviewCard(
            icon: Icons.inventory_2_outlined,
            title: 'Stock Value',
            value: _money(summary.stockValue),
          ),
          _buildOverviewCard(
            icon: Icons.warning_amber_outlined,
            title: 'Low Stock',
            value: summary.lowStockProducts.toString(),
          ),
          _buildOverviewCard(
            icon: Icons.trending_up_outlined,
            title: 'Monthly Profit',
            value: _money(summary.monthlyProfit),
          ),
          _buildOverviewCard(
            icon: Icons.assignment_return_outlined,
            title: 'Total Refunded',
            value: _money(summary.totalRefunded),
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards.map((card) {
            return SizedBox(width: cardWidth, child: card);
          }).toList(),
        );
      },
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.lightBorder,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryLight),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.statValue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellingProducts(List<BestSellingProduct> products) {
    if (products.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.shopping_bag_outlined,
        message: 'No completed sales yet.',
      );
    }

    final maxQty = products
        .map((p) => p.quantitySold)
        .reduce((a, b) => a > b ? a : b);
    return Card(
      child: Column(
        children: products.asMap().entries.map((entry) {
          final i = entry.key;
          final product = entry.value;
          final pct = maxQty == 0 ? 0.0 : product.quantitySold / maxQty;
          final medalColors = [
            [AppColors.tertiary, AppColors.tertiaryDark],
            [AppColors.primary, AppColors.primaryDark],
            [AppColors.secondary, AppColors.secondaryDark],
          ];
          final medal = medalColors[i % medalColors.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: medal),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(medal.first),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.quantitySold} units sold',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(_money(product.revenue), style: AppTextStyles.priceSmall),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpenseCategories(List<ExpenseCategoryTotal> categories) {
    if (categories.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.receipt_long_outlined,
        message: 'No expenses recorded yet.',
      );
    }

    final maxAmt = categories
        .map((c) => c.amount)
        .reduce((a, b) => a > b ? a : b);
    const palette = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.info,
      AppColors.chartPink,
      AppColors.accent,
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: categories.asMap().entries.map((entry) {
            final color = palette[entry.key % palette.length];
            final cat = entry.value;
            final pct = maxAmt == 0 ? 0.0 : cat.amount / maxAmt;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat.category,
                          style: AppTextStyles.titleSmall,
                        ),
                      ),
                      Text(_money(cat.amount), style: AppTextStyles.priceSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRangeSelector() {
    const options = [7, 30, 90];
    return Row(
      children: [
        Text('Compare range', style: AppTextStyles.titleSmall),
        const Spacer(),
        Wrap(
          spacing: 8,
          children: options.map((days) {
            final selected = _rangeDays == days;
            return FilterPill(
              label: '${days}d',
              selected: selected,
              onTap: () {
                setState(() {
                  _rangeDays = days;
                  _comparisonFuture = _reportRepository.getPeriodComparison(
                    days: days,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildComparisonSection() {
    return FutureBuilder<
      ({PeriodComparison current, PeriodComparison previous})
    >(
      future: _comparisonFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SkeletonList(count: 1, itemHeight: 90);
        }

        final data = snap.data;
        if (data == null) return const SizedBox.shrink();

        final change = data.current.revenueChangeVs(data.previous);

        return HoverLiftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revenue — last $_rangeDays days',
                          style: AppTextStyles.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _money(data.current.revenue),
                          style: AppTextStyles.priceMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (change != null)
                    TrendPill(
                      value:
                          '${change >= 0 ? '+' : ''}'
                          '${change.toStringAsFixed(1)}%',
                      up: change >= 0,
                      neutral: change.abs() < 0.05,
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _comparisonMetric(
                      'Profit',
                      _money(data.current.profit),
                    ),
                  ),
                  Expanded(
                    child: _comparisonMetric(
                      'Transactions',
                      data.current.transactions.toString(),
                    ),
                  ),
                  Expanded(
                    child: _comparisonMetric(
                      'Prev. revenue',
                      _money(data.previous.revenue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _comparisonMetric(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 3),
        Text(value, style: AppTextStyles.numericSmall),
      ],
    );
  }

  Widget _buildMarginList(Future<List<MarginRow>> future) {
    return FutureBuilder<List<MarginRow>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SkeletonList(count: 3, itemHeight: 60);
        }

        final rows = snap.data ?? const <MarginRow>[];
        if (rows.isEmpty) {
          return _buildEmptyCard(
            icon: Icons.insights_outlined,
            message: 'No sales recorded yet.',
          );
        }

        final scheme = Theme.of(context).colorScheme;
        final maxProfit = rows
            .map((r) => r.profit.abs())
            .fold<double>(0, (a, b) => a > b ? a : b);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              children: rows.asMap().entries.map((entry) {
                final row = entry.value;
                final gradient =
                    AppColors.chartGradients[entry.key %
                        AppColors.chartGradients.length];
                final pct = maxProfit <= 0 ? 0.0 : row.profit.abs() / maxProfit;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      IconTile(
                        icon: Icons.sell_rounded,
                        gradient: gradient,
                        size: 40,
                        iconSize: 19,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    row.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.titleSmall,
                                  ),
                                ),
                                Text(
                                  _money(row.profit),
                                  style: AppTextStyles.priceSmall.copyWith(
                                    color: row.profit >= 0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: pct.clamp(0.0, 1.0),
                                      minHeight: 6,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.08),
                                      valueColor: AlwaysStoppedAnimation(
                                        gradient.first,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${row.marginPct.toStringAsFixed(0)}% margin • '
                                  '${row.unitsSold} units',
                                  style: AppTextStyles.badge.copyWith(
                                    color: scheme.onSurface.withValues(
                                      alpha: 0.55,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard({required IconData icon, required String message}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBreakdown() {
    return FutureBuilder<List<PaymentMethodTotal>>(
      future: _paymentFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SkeletonList(count: 3, itemHeight: 60);
        }

        final rows = snap.data ?? const <PaymentMethodTotal>[];
        if (rows.isEmpty) {
          return _buildEmptyCard(
            icon: Icons.payments_outlined,
            message: 'No payments recorded yet.',
          );
        }

        final total = rows.fold<double>(0, (s, r) => s + r.amount);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              children: rows.asMap().entries.map((entry) {
                final row = entry.value;
                final pct = total == 0 ? 0.0 : row.amount / total;
                final gradient =
                    AppColors.chartGradients[entry.key %
                        AppColors.chartGradients.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      IconTile(
                        icon: _paymentIcon(row.method),
                        gradient: gradient,
                        size: 40,
                        iconSize: 19,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _paymentLabel(row.method),
                                    style: AppTextStyles.titleSmall,
                                  ),
                                ),
                                Text(
                                  _money(row.amount),
                                  style: AppTextStyles.priceSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: pct.clamp(0.0, 1.0),
                                      minHeight: 6,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.08),
                                      valueColor: AlwaysStoppedAnimation(
                                        gradient.first,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${(pct * 100).toStringAsFixed(0)}% • '
                                  '${row.count} sales',
                                  style: AppTextStyles.badge.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerInsights() {
    return FutureBuilder<List<CustomerInsight>>(
      future: _customerFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SkeletonList(count: 3, itemHeight: 60);
        }

        final rows = snap.data ?? const <CustomerInsight>[];
        if (rows.isEmpty) {
          return _buildEmptyCard(
            icon: Icons.people_outline_rounded,
            message:
                'No customer purchases yet. Attach a customer at checkout '
                'to see insights here.',
          );
        }

        return Card(
          child: Column(
            children: rows.asMap().entries.map((entry) {
              final row = entry.value;
              final gradient =
                  AppColors.chartGradients[(entry.key + 3) %
                      AppColors.chartGradients.length];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradient),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleSmall,
                          ),
                          Text(
                            '${row.orderCount} orders',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _money(row.totalSpent),
                      style: AppTextStyles.priceSmall,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  IconData _paymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'mobile':
      case 'wallet':
        return Icons.phone_iphone_rounded;
      case 'bank':
      case 'transfer':
        return Icons.account_balance_rounded;
      default:
        return Icons.point_of_sale_rounded;
    }
  }

  String _paymentLabel(String method) {
    final m = method.toLowerCase();
    if (m.isEmpty) return 'Cash';
    return m[0].toUpperCase() + m.substring(1);
  }
}
