import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/report_repository.dart';

class ReportsScreen extends StatefulWidget {
  final bool showAppBar;
  const ReportsScreen({super.key, this.showAppBar = true});
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

  /// Presentation-only active rail tab — groups of the existing sections.
  int _activeTab = 0;

  static const _railTabs = [
    (label: 'Overview', icon: Icons.dashboard_outlined),
    (label: 'Sales', icon: Icons.storefront_outlined),
    (label: 'Products', icon: Icons.inventory_2_outlined),
    (label: 'Money', icon: Icons.account_balance_wallet_outlined),
    (label: 'Customers', icon: Icons.people_outline_rounded),
  ];

  /// Deep rose tone used for the customer/care section.
  static const _careAccent = Color(0xFFBE185D);

  /// Whether the acting session can view reports (owner or manager).
  bool get _canManageReports => canPerform(sessionController.current, {
    StaffRole.owner,
    StaffRole.manager,
  });

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

  @override
  Widget build(BuildContext context) {
    if (!_canManageReports) {
      return Scaffold(
        appBar: widget.showAppBar ? AppBar(title: const Text('Reports')) : null,
        body: Center(
          child: BrandEmptyState(
            title: 'Owner & managers only',
            message:
                'Reports are restricted to the owner and managers of this '
                'business. Ask an administrator for access.',
            icon: Icons.lock_outline_rounded,
            image: AppImages.teamStaff,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Reports'),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            )
          : null,
      body: _isLoadingSettings
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuroraLoader(size: 44),
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
                  return const Center(child: AuroraLoader(size: 46));
                }

                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                final summary = snapshot.data;

                if (summary == null) {
                  return Center(
                    child: BrandEmptyState(
                      title: 'No report data yet',
                      message:
                          'Once you ring up sales, revenue, profit and '
                          'customer trends will appear here.',
                      icon: Icons.insights_rounded,
                      image: AppImages.analyticsHero,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    children: [
                      PageHero(
                        eyebrow: 'Insight',
                        title: 'Business analytics',
                        subtitle:
                            'Revenue, profit, stock value and customer trends — '
                            'all in one clear report.',
                        image: AppImages.analyticsHero,
                        showIllustration: false,
                        secondaryAction: _GhostAction(
                          icon: Icons.refresh_rounded,
                          label: 'Refresh',
                          onTap: _refresh,
                        ),
                        action: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final days in const [7, 30, 90])
                              Padding(
                                padding: EdgeInsets.only(
                                  left: days == 7 ? 0 : 8,
                                ),
                                child: _PeriodChip(
                                  label: '${days}d',
                                  selected: _rangeDays == days,
                                  onTap: () {
                                    setState(() {
                                      _rangeDays = days;
                                      _comparisonFuture = _reportRepository
                                          .getPeriodComparison(days: days);
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildTabRail(),
                      const SizedBox(height: AppDimensions.spacingLg),
                      ..._buildActiveSections(summary),
                      const SizedBox(height: AppDimensions.spacingLg),
                    ],
                  ),
                );
              },
            ),
    );
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

  // ─────────────────────────────────────────────
  // Tab rail — active treatment mirrors the shell sidebar pill:
  // soft royal-gradient fill, white hairline, aurora notch tick and
  // a glowing teal live dot.
  // ─────────────────────────────────────────────

  Widget _buildTabRail() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < _railTabs.length; i++)
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
              child: _RailTab(
                label: _railTabs[i].label,
                icon: _railTabs[i].icon,
                selected: _activeTab == i,
                onTap: () => setState(() => _activeTab = i),
              ),
            ),
        ],
      ),
    );
  }

  /// Existing sections, grouped behind the rail. Every future and widget
  /// keeps loading exactly as before; only visibility changes per tab.
  List<Widget> _buildActiveSections(ReportSummary summary) {
    switch (_activeTab) {
      case 1:
        return _salesSection(summary);
      case 2:
        return _productsSection();
      case 3:
        return _moneySection();
      case 4:
        return _customersSection();
      default:
        return _overviewSection(summary);
    }
  }

  List<Widget> get _sectionGap => const [
    SizedBox(height: AppDimensions.spacingXl),
  ];

  List<Widget> _overviewSection(ReportSummary summary) => [
    _buildComparisonSection(),
    ..._sectionGap,
    _buildSectionTitle(
      'Business Overview',
      Icons.dashboard_outlined,
      AppColors.primary,
    ),
    const SizedBox(height: AppDimensions.spacingMd),
    _buildOverviewGrid(summary),
  ];

  List<Widget> _salesSection(ReportSummary summary) => [
    _buildSectionTitle(
      'Sales Overview',
      Icons.storefront_outlined,
      AppColors.primary,
    ),
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
  ];

  List<Widget> _productsSection() => [
    _buildSectionTitle(
      'Best-Selling Products',
      Icons.local_fire_department_rounded,
      AppColors.warningDark,
    ),
    const SizedBox(height: AppDimensions.spacingMd),
    _buildBestSellingProducts(),
    ..._sectionGap,
    _buildSectionTitle(
      'Profit by Product',
      Icons.sell_rounded,
      AppColors.brandMintDeep,
    ),
    const SizedBox(height: AppDimensions.spacingMd),
    _buildMarginList(_productMarginFuture),
  ];

  List<Widget> _moneySection() => [
    _buildSectionTitle(
      'Expenses by Category',
      Icons.account_balance_wallet_outlined,
      AppColors.warningDark,
    ),
    const SizedBox(height: AppDimensions.spacingMd),
    _buildExpenseCategories(),
    ..._sectionGap,
    _buildSectionTitle(
      'Payment Methods',
      Icons.credit_card_rounded,
      AppColors.primary,
    ),
    const SizedBox(height: AppDimensions.spacingMd),
    _buildPaymentBreakdown(),
    ..._sectionGap,
    _buildSectionTitle(
      'Profit & Margin by Category',
      Icons.category_rounded,
      AppColors.brandMintDeep,
    ),
    const SizedBox(height: AppDimensions.spacingMd),
    _buildMarginList(_categoryMarginFuture),
  ];

  List<Widget> _customersSection() => [
    _buildSectionTitle(
      'Top Customers',
      Icons.people_outline_rounded,
      _careAccent,
    ),
    const SizedBox(height: AppDimensions.spacingMd),
    _buildCustomerInsights(),
  ];

  Widget _buildSectionTitle(String title, IconData icon, Color accent) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: accent.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.2
                  : 0.12,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: accent),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTextStyles.displayFont,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Sales period cards
  // ─────────────────────────────────────────────

  Widget _buildSalesPeriodCard({
    required String title,
    required SalesReport report,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrandCard(
      padding: const EdgeInsets.all(18),
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppDecor.royalGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.22),
                ),
                child: Icon(icon, color: Colors.white, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.brandMintDeep.withValues(alpha: 0.16)
                      : AppColors.moneyTint.first,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${report.transactionCount} sales',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isDark
                        ? AppColors.brandMint
                        : AppColors.brandMintDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  label: 'Revenue',
                  value: _money(report.revenue),
                ),
              ),
              _metricDivider(),
              Expanded(
                child: _buildMetric(
                  label: 'Transactions',
                  value: report.transactionCount.toString(),
                ),
              ),
              _metricDivider(),
              Expanded(
                child: _buildMetric(
                  label: 'Gross profit',
                  value: _money(report.grossProfit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricDivider() {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
    );
  }

  Widget _buildMetric({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.kpiLabel.copyWith(
            fontSize: 9.5,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTextStyles.numericMedium.copyWith(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Business overview grid (MetricCard with tinted gradients)
  // ─────────────────────────────────────────────

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
            gradient: const [AppColors.tertiaryLight, AppColors.tertiaryDark],
          ),
          _buildOverviewCard(
            icon: Icons.inventory_2_outlined,
            title: 'Stock Value',
            value: _money(summary.stockValue),
            gradient: const [AppColors.skyLight, AppColors.skyDark],
          ),
          _buildOverviewCard(
            icon: Icons.warning_amber_outlined,
            title: 'Low Stock',
            value: summary.lowStockProducts.toString(),
            gradient: const [AppColors.roseLight, AppColors.chartRose],
          ),
          _buildOverviewCard(
            icon: Icons.trending_up_outlined,
            title: 'Monthly Profit',
            value: _money(summary.monthlyProfit),
            gradient: AppDecor.moneyGradientLight.colors,
          ),
          _buildOverviewCard(
            icon: Icons.assignment_return_outlined,
            title: 'Total Refunded',
            value: _money(summary.totalRefunded),
            gradient: AppDecor.violetGradient.colors,
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
    required List<Color> gradient,
  }) {
    return MetricCard(
      compact: true,
      label: title,
      value: value,
      icon: icon,
      gradient: gradient,
    );
  }

  // ─────────────────────────────────────────────
  // Best-selling products — medal rings
  // ─────────────────────────────────────────────

  Widget _buildBestSellingProducts() {
    return FutureBuilder<ReportSummary>(
      future: _summaryFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SkeletonList(count: 3, itemHeight: 60);
        }

        final products = snap.data?.bestSellingProducts ?? const [];
        if (products.isEmpty) {
          return _buildEmptyCard(
            icon: Icons.shopping_bag_outlined,
            message: 'No completed sales yet.',
          );
        }

        final maxQty = products
            .map((p) => p.quantitySold)
            .reduce((a, b) => a > b ? a : b);

        return BrandCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: [
              for (var i = 0; i < products.length; i++)
                _bestSellingRow(
                  rank: i + 1,
                  product: products[i],
                  pct: maxQty == 0 ? 0.0 : products[i].quantitySold / maxQty,
                  animate: i < 8,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _bestSellingRow({
    required int rank,
    required BestSellingProduct product,
    required double pct,
    required bool animate,
  }) {
    final medal = _medalGradient(rank);

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          _medalRing(rank, medal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(medal.first),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.quantitySold} units sold',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _money(product.revenue),
            style: AppTextStyles.numericSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );

    if (!animate) return row;

    return row
        .animate(delay: (60 * (rank - 1)).ms)
        .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
        .moveY(begin: 10, end: 0, curve: Curves.easeOutCubic);
  }

  /// Gold / silver / bronze medal gradient, deeper tones after third place.
  List<Color> _medalGradient(int rank) {
    switch (rank) {
      case 1:
        return const [Color(0xFFFBBF24), Color(0xFFB45309)];
      case 2:
        return const [Color(0xFF94A3B8), Color(0xFF475569)];
      case 3:
        return const [Color(0xFFFB923C), Color(0xFF9A3412)];
      default:
        return const [AppColors.primaryLight, AppColors.royalEnd];
    }
  }

  /// Medal-style gradient ring with the rank number inside.
  Widget _medalRing(int rank, List<Color> colors) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(13),
        boxShadow: AppDecor.glow(colors.first, alpha: 0.28),
      ),
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontFamily: AppTextStyles.displayFont,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: colors.last,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Expenses by category
  // ─────────────────────────────────────────────

  Widget _buildExpenseCategories() {
    return FutureBuilder<ReportSummary>(
      future: _summaryFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SkeletonList(count: 3, itemHeight: 60);
        }

        final categories = snap.data?.expenseCategories ?? const [];
        if (categories.isEmpty) {
          return _buildEmptyCard(
            icon: Icons.receipt_long_outlined,
            message: 'No expenses recorded yet.',
          );
        }

        final maxAmt = categories
            .map((c) => c.amount)
            .reduce((a, b) => a > b ? a : b);

        return BrandCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < categories.length; i++)
                _expenseCategoryRow(categories[i], i + 1, maxAmt),
            ],
          ),
        );
      },
    );
  }

  Widget _expenseCategoryRow(
    ExpenseCategoryTotal cat,
    int seed,
    double maxAmt,
  ) {
    final gradient = AppDecor.toneGradient(cat.category.hashCode.abs());
    final pct = maxAmt <= 0 ? 0.0 : cat.amount / maxAmt;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Tint legend squircle matching the tone gradient.
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cat.category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _money(cat.amount),
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
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
              valueColor: AlwaysStoppedAnimation(gradient.colors.last),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Payment methods — donut + legend chips
  // ─────────────────────────────────────────────

  Widget _buildPaymentBreakdown() {
    return FutureBuilder<List<PaymentMethodTotal>>(
      future: _paymentFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SkeletonList(count: 3, itemHeight: 60);
        }

        final rows = snap.data ?? const [];
        if (rows.isEmpty) {
          return _buildEmptyCard(
            icon: Icons.payments_outlined,
            message: 'No payments recorded yet.',
          );
        }

        final total = rows.fold<double>(0, (s, r) => s + r.amount);
        final slices = rows
            .asMap()
            .entries
            .map(
              (e) => (
                label: _paymentLabel(e.value.method),
                value: e.value.amount,
                color: AppColors
                    .chartGradients[e.key % AppColors.chartGradients.length],
              ),
            )
            .toList();

        return BrandCard(
          padding: const EdgeInsets.all(18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 560;
              final donut = _PaymentDonut(
                slices: slices,
                size: 168,
                centerLabel: 'Total',
                centerValue: _money(total),
              );

              final legend = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < slices.length; i++)
                    _legendChip(
                      label: slices[i].label,
                      amount: slices[i].value,
                      pct: total == 0 ? 0.0 : rows[i].amount / total,
                      count: rows[i].count,
                      colors: slices[i].color,
                      animate: i < 6,
                      index: i,
                    ),
                ],
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    donut,
                    const SizedBox(width: 18),
                    Expanded(child: legend),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(child: donut),
                  const SizedBox(height: 16),
                  legend,
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _legendChip({
    required String label,
    required double amount,
    required double pct,
    required int count,
    required List<Color> colors,
    required bool animate,
    required int index,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chip = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(alpha: isDark ? 0.55 : 0.35),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            '${(pct * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: colors.first,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _money(amount),
            style: TextStyle(
              fontFamily: AppTextStyles.displayFont,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '· $count',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );

    if (!animate) return chip;

    return chip
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
        .moveX(begin: 8, end: 0, curve: Curves.easeOutCubic);
  }

  // ─────────────────────────────────────────────
  // Margin lists
  // ─────────────────────────────────────────────

  Widget _buildMarginList(Future<List<MarginRow>> future) {
    return FutureBuilder<List<MarginRow>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SkeletonList(count: 3, itemHeight: 60);
        }

        final rows = snap.data ?? const [];
        if (rows.isEmpty) {
          return _buildEmptyCard(
            icon: Icons.insights_outlined,
            message: 'No sales recorded yet.',
          );
        }

        final maxProfit = rows
            .map((r) => r.profit.abs())
            .fold<double>(0, (a, b) => a > b ? a : b);

        return BrandCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: rows.map((row) {
              final index = rows.indexOf(row);
              final gradient = AppColors
                  .chartGradients[index % AppColors.chartGradients.length];
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
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                              ),
                              _deltaText(row.profit),
                            ],
                          ),
                          const SizedBox(height: 5),
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
                                '${row.marginPct.toStringAsFixed(0)}% margin'
                                ' • ${row.unitsSold} units',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface
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
        );
      },
    );
  }

  /// Tabular profit value with a triangle delta — mint up, amber down.
  Widget _deltaText(double profit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final up = profit >= 0;
    final color = up
        ? (isDark ? AppColors.brandMint : AppColors.successDark)
        : AppColors.warningDark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          size: 18,
          color: color,
        ),
        Text(
          _money(profit),
          style: TextStyle(
            fontFamily: AppTextStyles.displayFont,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: color,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Comparison card
  // ─────────────────────────────────────────────

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

        return BrandCard(
          padding: const EdgeInsets.all(18),
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconTile(
                    icon: Icons.workspace_premium_rounded,
                    gradient: AppDecor.royalGradient.colors,
                    size: 42,
                    iconSize: 21,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Revenue — last $_rangeDays days',
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _money(data.current.revenue),
                            style: AppTextStyles.numericMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (change != null) _deltaChip(change),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.07),
              ),
              const SizedBox(height: 14),
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

  /// Triangle delta chip — mint up, amber down, grey flat.
  Widget _deltaChip(double change) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final up = change >= 0;
    final neutral = change.abs() < 0.05;
    final color = neutral
        ? AppColors.chartGray
        : up
        ? (isDark ? AppColors.brandMint : AppColors.successDark)
        : AppColors.warningDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            neutral
                ? Icons.remove_rounded
                : (up ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            size: neutral ? 13 : 18,
            color: color,
          ),
          Text(
            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _comparisonMetric(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.kpiLabel.copyWith(
            fontSize: 9.5,
            letterSpacing: 1.1,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTextStyles.numericSmall.copyWith(color: scheme.onSurface),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Top customers
  // ─────────────────────────────────────────────

  Widget _buildCustomerInsights() {
    return FutureBuilder<List<CustomerInsight>>(
      future: _customerFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const SkeletonList(count: 3, itemHeight: 60);
        }

        final rows = snap.data ?? const [];
        if (rows.isEmpty) {
          return _buildEmptyCard(
            icon: Icons.people_outline_rounded,
            message:
                'No customer purchases yet. Attach a customer at checkout '
                'to see insights here.',
          );
        }

        return BrandCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) _customerRow(rows[i], i),
            ],
          ),
        );
      },
    );
  }

  Widget _customerRow(CustomerInsight row, int index) {
    final gradient =
        AppColors.chartGradients[(index + 3) % AppColors.chartGradients.length];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: AppDecor.glow(gradient.first, alpha: 0.24),
            ),
            child: Center(
              child: Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    row.customerName.isEmpty
                        ? '?'
                        : row.customerName[0].toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: gradient.last,
                    ),
                  ),
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
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${row.orderCount} orders',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            _money(row.totalSpent),
            style: TextStyle(
              fontFamily: AppTextStyles.displayFont,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );

    if (index >= 6) return content;

    return content
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
        .moveY(begin: 10, end: 0, curve: Curves.easeOutCubic);
  }

  // ─────────────────────────────────────────────
  // Shared bits
  // ─────────────────────────────────────────────

  Widget _buildEmptyCard({required IconData icon, required String message}) {
    return BrandCard(
      child: BrandEmptyState(
        title: 'Nothing here yet',
        message: message,
        icon: icon,
        image: AppImages.analyticsHero,
      ),
    );
  }

  String _paymentLabel(String method) {
    final m = method.toLowerCase();
    if (m.isEmpty) return 'Cash';
    return m[0].toUpperCase() + m.substring(1);
  }
}

// ─────────────────────────────────────────────
// Local presentation widgets
// ─────────────────────────────────────────────

/// Ghost toolbar action for the photo hero (secondary actions only — the
/// page keeps one gradient primary per view).
class _GhostAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GhostAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_GhostAction> createState() => _GhostActionState();
}

class _GhostActionState extends State<_GhostAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Royal period chip with the signature notch + teal live dot, matching
/// the shell sidebar's active treatment.
class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: AppDecor.royalGradient.colors
                            .map((c) => c.withValues(alpha: 0.26))
                            .toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected
                    ? null
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.09)
                          : Colors.white.withValues(alpha: 0.13)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: selected ? 0.24 : 0.2),
                ),
                boxShadow: selected
                    ? AppDecor.glow(AppColors.primary, alpha: 0.3)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.78),
                      fontSize: 11.5,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 7),
                    Container(
                      width: 5.5,
                      height: 5.5,
                      decoration: BoxDecoration(
                        color: AppColors.auroraTeal,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.auroraTeal.withValues(alpha: 0.8),
                            blurRadius: 7,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Aurora notch tick on the left edge.
        if (selected)
          Positioned(
            left: 0,
            top: 6,
            bottom: 6,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: AppDecor.auroraBar,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.auroraTeal.withValues(alpha: 0.55),
                    blurRadius: 8,
                    spreadRadius: -1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Rail tab chip — a themed-page mirror of the shell sidebar active pill.
class _RailTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RailTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFE3E0F5);
    final activeOutline = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : const Color(0xFFC9C2F7);

    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(13),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: AppDecor.royalGradient.colors
                            .map(
                              (c) => c.withValues(alpha: isDark ? 0.30 : 0.16),
                            )
                            .toList(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected
                    ? (isDark ? Colors.white.withValues(alpha: 0.06) : null)
                    : (isDark ? Colors.transparent : Colors.white),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: selected ? activeOutline : outline),
                boxShadow: selected
                    ? AppDecor.glow(AppColors.primary, alpha: 0.22)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: selected
                        ? (isDark ? Colors.white : AppColors.primaryDark)
                        : Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? (isDark ? Colors.white : AppColors.primaryDark)
                          : Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.6),
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 7),
                    Container(
                      width: 5.5,
                      height: 5.5,
                      decoration: BoxDecoration(
                        color: AppColors.auroraTeal,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.auroraTeal.withValues(alpha: 0.8),
                            blurRadius: 7,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Aurora notch tick.
        if (selected)
          Positioned(
            left: 0,
            top: 8,
            bottom: 8,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: AppDecor.auroraBar,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.auroraTeal.withValues(alpha: 0.55),
                    blurRadius: 8,
                    spreadRadius: -1,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Dependency-free donut chart for payment-method share.
class _PaymentDonut extends StatelessWidget {
  final List<({String label, double value, List<Color> color})> slices;
  final double size;
  final String centerLabel;
  final String centerValue;

  const _PaymentDonut({
    required this.slices,
    required this.size,
    required this.centerLabel,
    required this.centerValue,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(
              slices: slices,
              isDark: scheme.brightness == Brightness.dark,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel.toUpperCase(),
                style: AppTextStyles.kpiLabel.copyWith(
                  fontSize: 9,
                  letterSpacing: 1.1,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  centerValue,
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<({String label, double value, List<Color> color})> slices;
  final bool isDark;

  _DonutPainter({required this.slices, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (a, s) => a + s.value);
    if (total <= 0) return;

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19
      ..strokeCap = StrokeCap.butt;

    final rect = Offset.zero & size;
    final inset = 9.5;

    var start = -math.pi / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19
      ..color = (isDark ? Colors.white : AppColors.shadowColor).withValues(
        alpha: 0.06,
      );

    canvas.drawArc(rect.deflate(inset), 0, 2 * math.pi, false, track);

    for (final slice in slices) {
      final sweep = slice.value / total * 2 * math.pi;
      stroke.shader = SweepGradient(
        colors: slice.color,
        startAngle: start,
        endAngle: start + sweep,
        tileMode: TileMode.repeated,
      ).createShader(rect.deflate(inset));
      canvas.drawArc(rect.deflate(inset), start, sweep, false, stroke);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.isDark != isDark;
}
