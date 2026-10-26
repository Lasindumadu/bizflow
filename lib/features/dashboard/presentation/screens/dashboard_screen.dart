import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/sale_reference.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/mini_charts.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/app_database.dart' hide Sale;
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/dashboard_repository.dart';
import '../../../../models/sale.dart';
import '../../../customers/presentation/screens/customers_screen.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../sales/presentation/screens/sale_details_screen.dart';
import '../../../sales/presentation/screens/sales_screen.dart';

/// The BizFlow command centre.
///
/// The dashboard is intentionally calm: one clear greeting, six honest
/// numbers, a revenue pulse and the latest transactions. Every block is
/// tappable so the screen doubles as a launchpad.
class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPos;
  final ValueChanged<int>? onNavigate;

  /// Hidden while hosted inside [AppShell], which provides the global chrome.
  final bool showAppBar;

  const DashboardScreen({
    super.key,
    required this.onOpenSettings,
    required this.onOpenPos,
    this.onNavigate,
    this.showAppBar = true,
  });

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final DashboardRepository _dashboardRepository = DashboardRepository(
    appDatabase,
  );

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  String _currency = 'USD';
  String _businessName = 'My Business';
  bool _isLoadingSettings = true;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _loadBusinessSettings();
  }

  Future<void> _loadBusinessSettings() async {
    try {
      final settings = await _businessSettingsRepository.getSettings();
      if (!mounted) return;
      setState(() {
        _currency = settings.currency;
        _businessName = settings.businessName;
        _isLoadingSettings = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSettings = false);
    }
  }

  Future<void> refreshBusinessSettings() async {
    await _loadBusinessSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBusinessSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('BizFlow'),
              actions: [
                IconButton(
                  onPressed: widget.onOpenSettings,
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                ),
              ],
            )
          : null,
      body: _isLoadingSettings
          ? const _DashboardSkeleton()
          : StreamBuilder<DashboardStats>(
              stream: _dashboardRepository.watchStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const _DashboardSkeleton();
                }
                if (snapshot.hasError) {
                  return _buildErrorState();
                }
                final stats = snapshot.data;
                if (stats == null) return const _DashboardSkeleton();
                return _buildContent(context, stats);
              },
            ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardStats stats) {
    final scheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        await _loadBusinessSettings();
        setState(() {});
      },
      color: scheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHero(
                image: AppImages.emptyStateIllustrationUndraw,
                eyebrow: 'Live business overview',
                title: '${_greeting()}, $_businessName',
                subtitle: '${todayLabel()} — sales, stock and customers '
                    'at a glance.',
                secondaryAction: _DeltaChip(
                  future: _dashboardRepository.getLast7DaysRevenue(),
                  currency: _currency,
                ),
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HeroAction(
                      label: 'New sale',
                      icon: Icons.bolt_rounded,
                      primary: true,
                      onTap: widget.onOpenPos,
                    ),
                    const SizedBox(width: 10),
                    _HeroAction(
                      label: 'View reports',
                      icon: Icons.insights_rounded,
                      primary: false,
                      onTap: () => _go(7),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 420.ms, curve: Curves.easeOutCubic)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    curve: Curves.easeOutCubic,
                  ),
              const SizedBox(height: 20),
              _kpiGrid(stats),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 920;
                  final main = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _revenueCard(context),
                      const SizedBox(height: 20),
                      SectionHeading(
                        title: 'Recent transactions',
                        subtitle: 'The latest activity across your till',
                        icon: Icons.receipt_long_rounded,
                        trailing: TextButton(
                          onPressed: () => _go(3),
                          child: const Text('View all'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _recentSales(context),
                    ],
                  );
                  final side = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _quickActions(context),
                      const SizedBox(height: 20),
                      _lowStockCard(context, stats),
                    ],
                  );

                  if (!wide) {
                    return Column(
                      children: [
                        main,
                        const SizedBox(height: 24),
                        side,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 7, child: main),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: side),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String todayLabel() {
    final now = DateTime.now();
    return '${_weekdays[now.weekday - 1]}, ${now.day} '
        '${_months[now.month - 1]}';
  }

  void _go(int index) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(index);
      return;
    }
    final Widget? screen = switch (index) {
      1 => const ProductsScreen(),
      3 => const SalesScreen(),
      4 => const CustomersScreen(),
      5 => const InventoryScreen(),
      7 => const ReportsScreen(),
      _ => null,
    };
    if (screen == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  Widget _kpiGrid(DashboardStats stats) {
    final avgSale = stats.todayTransactions == 0
        ? 0.0
        : stats.todaySales / stats.todayTransactions;
    final profitUp = stats.todayProfit >= 0;

    final cards = <_KpiCard>[
      _KpiCard(
        label: "Today's sales",
        valueWidget: _countUpMoney(stats.todaySales),
        icon: Icons.payments_rounded,
        gradient: AppDecor.royalGradient.colors,
        glowColor: AppColors.royalMid,
        helper: '${stats.todayTransactions} transactions',
        badge: 'LIVE',
        onTap: widget.onOpenPos,
      ),
      _KpiCard(
        label: "Today's profit",
        valueWidget: _countUpMoney(stats.todayProfit),
        icon: Icons.trending_up_rounded,
        gradient: AppDecor.moneyGradient.colors,
        glowColor: AppColors.secondary,
        badge: profitUp ? 'UP' : 'DOWN',
        badgeUp: profitUp,
        helper: profitUp ? 'Healthy margin today' : 'Review your costs',
        onTap: () => _go(7),
      ),
      _KpiCard(
        label: 'Avg. basket',
        valueWidget: _countUpMoney(avgSale),
        icon: Icons.shopping_bag_rounded,
        gradient: AppDecor.flowGradient.colors,
        glowColor: AppColors.auroraTeal,
        helper: 'Per completed sale',
        onTap: () => _go(3),
      ),
      _KpiCard(
        label: 'Customers',
        valueWidget: _countUpCount(stats.totalCustomers),
        icon: Icons.people_alt_rounded,
        gradient: AppDecor.roseGradient.colors,
        glowColor: AppColors.rose,
        helper: 'In your directory',
        onTap: () => _go(4),
      ),
      _KpiCard(
        label: 'Products',
        valueWidget: _countUpCount(stats.totalProducts),
        icon: Icons.inventory_2_rounded,
        gradient: AppDecor.skyGradient.colors,
        glowColor: AppColors.sky,
        helper: '${stats.lowStockProducts} need attention',
        onTap: () => _go(1),
      ),
      _KpiCard(
        label: 'Low stock',
        valueWidget: _countUpCount(stats.lowStockProducts),
        icon: Icons.warning_amber_rounded,
        gradient: AppDecor.amberGradient.colors,
        glowColor: AppColors.tertiary,
        helper: stats.lowStockProducts == 0
            ? 'Everything is stocked'
            : 'Reorder soon',
        onTap: () => _go(5),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1080
            ? 3
            : width >= 680
                ? 3
                : width >= 430
                    ? 2
                    : 1;
        const gap = 12.0;
        final cardWidth = (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cards
              .asMap()
              .entries
              .map(
                (entry) => SizedBox(
                  width: cardWidth,
                  child: entry.value
                      .animate(
                        delay: Duration(milliseconds: 60 * entry.key),
                      )
                      .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
                      .moveY(
                        begin: 14,
                        end: 0,
                        curve: Curves.easeOutCubic,
                      ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  /// Count-up money figure — Sora, tabular figures, solid colour.
  Widget _countUpMoney(double value) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: CountUpText(
        value,
        prefix: '$_currency ',
        decimals: 2,
        style: _kpiValueStyle(context),
      ),
    );
  }

  Widget _countUpCount(int value) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: CountUpText(
        value.toDouble(),
        decimals: 0,
        style: _kpiValueStyle(context),
      ),
    );
  }

  TextStyle _kpiValueStyle(BuildContext context) {
    return TextStyle(
      fontFamily: AppTextStyles.displayFont,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.7,
      color: Theme.of(context).colorScheme.onSurface,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  Widget _revenueCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<double>>(
      future: _dashboardRepository.getLast7DaysRevenue(),
      builder: (context, snap) {
        final values = snap.data ?? List<double>.filled(7, 0);
        const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        final total = values.fold<double>(0, (a, b) => a + b);
        final peak = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
        final todayShare =
            total > 0 ? (values.last / total).clamp(0.0, 1.0) : 0.0;

        return BrandCard(
          padding: const EdgeInsets.all(22),
          gradientBorder: true,
          accent: AppColors.royalMid,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Revenue pulse',
                              style: TextStyle(
                                fontFamily: AppTextStyles.displayFont,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandMint
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                '7 DAYS',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.brandMintDeep,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Total $_currency ${_compact(total)}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface.withValues(alpha: 0.52),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppDecor.royalGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.30),
                    ),
                    child: const Icon(
                      Icons.show_chart_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              MiniBarChart(
                values: values,
                labels: labels,
                barColor: AppColors.royalMid,
              ),
              const SizedBox(height: 16),
              // Aurora progress — today's share of the week.
              Row(
                children: [
                  Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 7,
                        color: scheme.onSurface.withValues(alpha: 0.08),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            widthFactor: todayShare,
                            heightFactor: 1,
                            alignment: Alignment.centerLeft,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppDecor.auroraBar,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: AppDecor.glow(
                                  AppColors.auroraTeal,
                                  alpha: 0.45,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$_currency ${_compact(values.last)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.10
                        : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 15,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        peak > 0
                            ? 'Your best day this week brought in '
                                '$_currency ${_compact(peak)}.'
                            : 'Sales will appear here as soon as your first '
                                'sale is completed.',
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.4,
                          color: scheme.onSurface.withValues(alpha: 0.58),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _recentSales(BuildContext context) {
    return StreamBuilder<List<Sale>>(
      stream: _dashboardRepository.watchRecentSales(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SkeletonList(count: 3, itemHeight: 76);
        }
        if (snapshot.hasError) {
          return BrandCard(
            child: Text(
              'Unable to load recent sales.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12.5,
              ),
            ),
          );
        }
        final sales = snapshot.data ?? const <Sale>[];
        if (sales.isEmpty) {
          return BrandCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: BrandEmptyState(
              icon: Icons.receipt_long_rounded,
              image: AppImages.emptyStateIllustrationUndraw,
              title: 'No sales yet',
              message:
                  'Your first completed sale will appear here with its receipt.',
              actionLabel: 'Open the till',
              onAction: widget.onOpenPos,
            ),
          );
        }

        return Column(
          children: sales
              .take(12)
              .toList()
              .asMap()
              .entries
              .map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _RecentSaleCard(
                sale: entry.value,
                currency: _currency,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          SaleDetailsScreen(saleId: entry.value.id),
                    ),
                  );
                },
              )
                  .animate(delay: Duration(milliseconds: 60 * entry.key))
                  .fadeIn(duration: 320.ms, curve: Curves.easeOutCubic)
                  .slideX(
                    begin: 0.03,
                    end: 0,
                    curve: Curves.easeOutCubic,
                  ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        label: 'New sale',
        hint: 'Open the till',
        icon: Icons.bolt_rounded,
        gradient: AppDecor.royalGradient.colors,
        glowColor: AppColors.royalMid,
        photo: AppImages.posPayment,
        primary: true,
        onTap: widget.onOpenPos,
      ),
      _QuickAction(
        label: 'Products',
        hint: 'Catalog & prices',
        icon: Icons.inventory_2_rounded,
        gradient: AppDecor.skyGradient.colors,
        glowColor: AppColors.sky,
        onTap: () => _go(1),
      ),
      _QuickAction(
        label: 'Customers',
        hint: 'Loyalty & credit',
        icon: Icons.people_alt_rounded,
        gradient: AppDecor.roseGradient.colors,
        glowColor: AppColors.rose,
        onTap: () => _go(4),
      ),
      _QuickAction(
        label: 'Reports',
        hint: 'Know your numbers',
        icon: Icons.insights_rounded,
        gradient: AppDecor.moneyGradient.colors,
        glowColor: AppColors.secondary,
        onTap: () => _go(7),
      ),
    ];

    return BrandCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Quick actions',
            subtitle: 'Jump straight into the work',
            icon: Icons.flash_on_rounded,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: actions
                    .asMap()
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: width,
                        child: _QuickActionTile(
                          action: entry.value,
                          delay: 60 * entry.key,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _lowStockCard(BuildContext context, DashboardStats stats) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<ProductRow>>(
      future: _dashboardRepository.getLowStockProducts(),
      builder: (context, snap) {
        final rows = snap.data ?? const <ProductRow>[];
        final isLoading =
            snap.connectionState != ConnectionState.done && rows.isEmpty;

        return BrandCard(
          padding: const EdgeInsets.all(18),
          accent: AppColors.tertiary,
          gradientBorder: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                title: 'Stock watch',
                subtitle: isLoading
                    ? 'Checking your shelves…'
                    : rows.isEmpty
                        ? 'All shelves are healthy'
                        : '${rows.length} item${rows.length == 1 ? '' : 's'} '
                            'need attention',
                icon: Icons.inventory_rounded,
                trailing: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.brandAmber,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (isLoading)
                const SkeletonList(count: 2, itemHeight: 54)
              else if (rows.isEmpty)
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.brandMint.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.brandMintDeep,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nothing is running low. Nice work.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                )
              else ...[
                ...rows.take(4).map(
                      (p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: (p.stockQuantity == 0
                                        ? AppColors.error
                                        : AppColors.tertiary)
                                    .withValues(alpha: 0.11),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                p.stockQuantity == 0
                                    ? Icons.remove_shopping_cart_rounded
                                    : Icons.inventory_2_outlined,
                                size: 15,
                                color: p.stockQuantity == 0
                                    ? AppColors.error
                                    : const Color(0xFF9A6400),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            BrandPill(
                              label: p.stockQuantity == 0
                                  ? 'OUT'
                                  : '${p.stockQuantity}',
                              color: p.stockQuantity == 0
                                  ? AppColors.error
                                  : AppColors.tertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => _go(5),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                    label: const Text('Open inventory'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _compact(double value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value.abs() >= 10000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(2);
  }

  Widget _buildErrorState() {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: scheme.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to load your dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.displayFont,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your data is safe. Try refreshing the view.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dashboard building blocks
// ─────────────────────────────────────────────

/// "Today vs previous 6 days" delta chip for the photo hero.
class _DeltaChip extends StatelessWidget {
  final Future<List<double>> future;
  final String currency;

  const _DeltaChip({required this.future, required this.currency});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<double>>(
      future: future,
      builder: (context, snap) {
        final values = snap.data ?? const <double>[];
        if (values.length < 7) {
          return const SizedBox(height: 1);
        }
        final today = values.last;
        final past = values.sublist(0, 6).fold<double>(
              0,
              (a, b) => a + b,
            ) /
            6;
        final String label;
        final Color accent;
        if (today > 0 && past > 0) {
          final pct = ((today - past) / past * 100).abs();
          final up = today >= past;
          label =
              '${up ? '+' : '-'}${pct.toStringAsFixed(0)}% vs 6-day avg';
          accent = up ? const Color(0xFF5EEAD4) : const Color(0xFFFBBF24);
        } else if (today > 0) {
          label = 'First sale of a new day';
          accent = const Color(0xFF5EEAD4);
        } else {
          label = 'Today is open';
          accent = const Color(0xFFC4B5FD);
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                today > 0 && past > 0 && today >= past
                    ? Icons.trending_up_rounded
                    : Icons.trending_flat_rounded,
                size: 12,
                color: accent,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroAction extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _HeroAction({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  State<_HeroAction> createState() => _HeroActionState();
}

class _HeroActionState extends State<_HeroAction> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: widget.primary ? AppDecor.royalGradient : null,
              color: widget.primary
                  ? null
                  : Colors.white.withValues(alpha: _hovered ? 0.16 : 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: widget.primary ? 0.18 : 0.22,
                ),
              ),
              boxShadow: widget.primary
                  ? AppDecor.glow(AppColors.royalMid, alpha: 0.32)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 16, color: Colors.white),
                const SizedBox(width: 7),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aurora 2.0 KPI tile — MetricCard-inspired, with a count-up hero number.
class _KpiCard extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final IconData icon;
  final List<Color> gradient;
  final Color glowColor;
  final String? helper;
  final String? badge;
  final bool badgeUp;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.label,
    required this.valueWidget,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    this.helper,
    this.badge,
    this.badgeUp = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrandCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      elevated: true,
      accent: glowColor,
      gradientBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // One-time entrance pulse only — no looping motion.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppDecor.glow(glowColor, alpha: 0.28),
                ),
                child: Icon(icon, color: Colors.white, size: 21),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (badgeUp ? AppColors.brandMint : AppColors.brandAmber)
                        .withValues(alpha: isDark ? 0.16 : 0.13),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        badgeUp
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 11,
                        color: badgeUp
                            ? (isDark
                                ? AppColors.brandMint
                                : AppColors.brandMintDeep)
                            : (isDark
                                ? AppColors.brandAmber
                                : const Color(0xFF9A6400)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: badgeUp
                              ? (isDark
                                  ? AppColors.brandMint
                                  : AppColors.brandMintDeep)
                              : (isDark
                                  ? AppColors.brandAmber
                                  : const Color(0xFF9A6400)),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          valueWidget,
          if (helper != null) ...[
            const SizedBox(height: 5),
            Text(
              helper!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Premium transaction row — tinted squircle, tabular money,
/// status pill and a desktop hover lift.
class _RecentSaleCard extends StatefulWidget {
  final Sale sale;
  final String currency;
  final VoidCallback onTap;

  const _RecentSaleCard({
    required this.sale,
    required this.currency,
    required this.onTap,
  });

  @override
  State<_RecentSaleCard> createState() => _RecentSaleCardState();
}

class _RecentSaleCardState extends State<_RecentSaleCard> {
  bool _hovered = false;

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour == 0
        ? 12
        : local.hour > 12
            ? local.hour - 12
            : local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$day/$month · $hour:$minute $period';
  }

  IconData get _paymentIcon {
    final method = sale.paymentMethod.toLowerCase();
    if (method.contains('cash')) return Icons.payments_rounded;
    if (method.contains('card')) return Icons.credit_card_rounded;
    return Icons.phone_android_rounded;
  }

  Color get _paymentColor {
    final method = sale.paymentMethod.toLowerCase();
    if (method.contains('cash')) return AppColors.brandMintDeep;
    if (method.contains('card')) return AppColors.primary;
    return AppColors.tertiary;
  }

  Color get _statusColor {
    return switch (sale.status.toLowerCase()) {
      'completed' => AppColors.brandMintDeep,
      'refunded' || 'onhold' => AppColors.primary,
      'cancelled' => AppColors.error,
      _ => AppColors.tertiary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? scheme.primary.withValues(alpha: 0.35)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppColors.lightBorder),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: (isDark
                            ? Colors.black
                            : AppColors.brandInk)
                        .withValues(alpha: isDark ? 0.40 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                    spreadRadius: -6,
                  ),
                  BoxShadow(
                    color: _paymentColor.withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _paymentColor.withValues(
                        alpha: isDark ? 0.16 : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: _paymentColor.withValues(
                          alpha: isDark ? 0.26 : 0.18,
                        ),
                      ),
                    ),
                    child: Icon(
                      _paymentIcon,
                      color: _paymentColor,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          SaleReference.format(widget.sale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatDateTime(widget.sale.createdAt)} · '
                          '${widget.sale.paymentMethod.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurface.withValues(alpha: 0.48),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.currency} '
                        '${widget.sale.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: scheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BrandPill(
                            label: widget.sale.status.toUpperCase(),
                            color: _statusColor,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 15,
                            color: scheme.onSurface.withValues(alpha: 0.32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Sale get sale => widget.sale;
}

class _QuickAction {
  final String label;
  final String hint;
  final IconData icon;
  final List<Color> gradient;
  final Color glowColor;
  final VoidCallback onTap;
  final String? photo;
  final bool primary;

  const _QuickAction({
    required this.label,
    required this.hint,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
    this.photo,
    this.primary = false,
  });
}

class _QuickActionTile extends StatefulWidget {
  final _QuickAction action;
  final int delay;

  const _QuickActionTile({required this.action, this.delay = 0});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final action = widget.action;

    final body = GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        action.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _hovered
                    ? action.gradient.last.withValues(alpha: 0.45)
                    : scheme.onSurface.withValues(alpha: 0.055),
              ),
              boxShadow: _hovered ? AppDecor.glow(action.glowColor, alpha: 0.22) : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: SizedBox(
                height: 128,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                  // Per-action tint surface, or photo micro-wash for
                  // THE primary action.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: action.photo != null
                            ? null
                            : action.gradient.first.withValues(
                                alpha: isDark ? 0.14 : 0.09,
                              ),
                      ),
                    ),
                  ),
                  if (action.photo != null) ...[
                    Positioned.fill(
                      child: Image.asset(
                        action.photo!,
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.9),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF0A0C1E).withValues(alpha: 0.90),
                              AppColors.photoWash.withValues(alpha: 0.80),
                              action.gradient.last
                                  .withValues(alpha: 0.50),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: action.photo != null
                                ? Colors.white.withValues(alpha: 0.16)
                                : null,
                            gradient: action.photo != null
                                ? null
                                : LinearGradient(
                                    colors: action.gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: action.photo != null
                                ? null
                                : AppDecor.glow(
                                    action.glowColor,
                                    alpha: 0.24,
                                  ),
                          ),
                          child: Icon(
                            action.icon,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          action.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: action.photo != null
                                ? Colors.white
                                : scheme.onSurface,
                          ),
                        ),
                        Text(
                          action.hint,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: action.photo != null
                                ? Colors.white.withValues(alpha: 0.75)
                                : scheme.onSurface.withValues(alpha: 0.42),
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

    if (widget.delay <= 0) return body;
    return body
        .animate(delay: widget.delay.ms)
        .fadeIn(duration: 340.ms, curve: Curves.easeOutCubic);
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: PageBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ShimmerBox(height: 190, radius: 28),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: ShimmerBox(height: 116, radius: 22)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 116, radius: 22)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 116, radius: 22)),
              ],
            ),
            SizedBox(height: 20),
            ShimmerBox(height: 260, radius: 22),
          ],
        ),
      ),
    );
  }
}
