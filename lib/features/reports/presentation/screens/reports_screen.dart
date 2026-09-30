import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/report_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportRepository _reportRepository = ReportRepository(appDatabase);

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  late Future<ReportSummary> _summaryFuture;

  String _currency = 'USD';
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();

    _summaryFuture = _reportRepository.getSummary();
    _loadBusinessSettings();
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
    });

    await _summaryFuture;
  }

  String _money(double value) {
    return '$_currency ${value.toStringAsFixed(2)}';
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
            icon: const Icon(Icons.refresh),
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.screenPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          const Text(
                            'Unable to load reports.',
                            style: AppTextStyles.heading2,
                          ),
                          const SizedBox(height: AppDimensions.spacingSm),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: AppDimensions.spacingLg),
                          FilledButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
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
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
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

    return Card(
      child: Column(
        children: products.map((product) {
          return ListTile(
            leading: CircleAvatar(child: Text(product.quantitySold.toString())),
            title: Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('${product.quantitySold} units sold'),
            trailing: Text(
              _money(product.revenue),
              style: const TextStyle(fontWeight: FontWeight.bold),
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

    return Card(
      child: Column(
        children: categories.map((category) {
          return ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(category.category),
            trailing: Text(
              _money(category.amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyCard({required IconData icon, required String message}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
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
}
