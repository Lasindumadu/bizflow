import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/mini_charts.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../data/database/app_database.dart' hide Sale;
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/dashboard_repository.dart';
import '../../../../models/sale.dart';
import '../../../customers/presentation/screens/customers_screen.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../sales/presentation/screens/sale_details_screen.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/empty_sales_card.dart';
import '../widgets/quick_action_card.dart';
import '../../../../core/utils/sale_reference.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPos;

  const DashboardScreen({
    super.key,
    required this.onOpenSettings,
    required this.onOpenPos,
  });

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final DashboardRepository _dashboardRepository = DashboardRepository(
    appDatabase,
  );

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  String _currency = 'USD';
  String _businessName = 'My Business';
  bool _isLoadingSettings = true;

  late final AnimationController _pageAnimationController;
  late final Animation<double> _pageFadeAnimation;
  late final Animation<Offset> _pageSlideAnimation;

  @override
  void initState() {
    super.initState();

    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _pageFadeAnimation = CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOut,
    );

    _pageSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.015), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _pageAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _pageAnimationController.forward();

    _loadBusinessSettings();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinessSettings() async {
    try {
      final settings = await _businessSettingsRepository.getSettings();

      if (!mounted) {
        return;
      }

      setState(() {
        _currency = settings.currency;
        _businessName = settings.businessName;
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
      appBar: AppBar(
        title: const Text('BizFlow'),
        actions: [
          IconButton(
            onPressed: widget.onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoadingSettings
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<DashboardStats>(
                stream: _dashboardRepository.watchStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState();
                  }

                  final stats = snapshot.data;

                  if (stats == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return FadeTransition(
                    opacity: _pageFadeAnimation,
                    child: SlideTransition(
                      position: _pageSlideAnimation,
                      child: _buildContent(context, stats),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context),

              const SizedBox(height: AppDimensions.spacingXl),

              ResponsiveGrid(
                children: [
                  DashboardStatCard(
                    title: "Today's Sales",
                    value: '$_currency ${stats.todaySales.toStringAsFixed(2)}',
                    icon: Icons.payments_rounded,
                    gradient: AppDecor.indigoGradient.colors,
                    onTap: widget.onOpenPos,
                  ),
                  DashboardStatCard(
                    title: "Today's Profit",
                    value: '$_currency ${stats.todayProfit.toStringAsFixed(2)}',
                    icon: Icons.trending_up_rounded,
                    gradient: AppDecor.moneyGradient.colors,
                    trend: stats.todayProfit >= 0 ? 'Profit' : 'Loss',
                    trendUp: stats.todayProfit >= 0,
                  ),
                  DashboardStatCard(
                    title: 'Transactions',
                    value: stats.todayTransactions.toString(),
                    icon: Icons.receipt_long_rounded,
                    gradient: AppDecor.tealGradient.colors,
                  ),
                  DashboardStatCard(
                    title: 'Products',
                    value: stats.totalProducts.toString(),
                    icon: Icons.inventory_2_rounded,
                    gradient: AppDecor.skyGradient.colors,
                  ),
                  DashboardStatCard(
                    title: 'Low Stock',
                    value: stats.lowStockProducts.toString(),
                    icon: Icons.warning_amber_rounded,
                    gradient: AppDecor.amberGradient.colors,
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              QuickActionCard(
                title: 'New Sale',
                subtitle:
                    '$_currency ${stats.todaySales.toStringAsFixed(2)} today • Tap to open POS',
                icon: Icons.point_of_sale_rounded,
                onTap: widget.onOpenPos,
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              _buildQuickActions(context),

              const SizedBox(height: AppDimensions.spacingXl),

              _revenueChartCard(context),

              const SizedBox(height: AppDimensions.spacingXl),

              _lowStockCard(context),

              const SizedBox(height: AppDimensions.spacingXxl),

              _buildSectionHeader(
                context,
                title: 'Recent Sales',
                subtitle: 'Your latest transactions',
              ),

              const SizedBox(height: AppDimensions.spacingMd),

              StreamBuilder<List<Sale>>(
                stream: _dashboardRepository.watchRecentSales(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingXl),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildRecentSalesError();
                  }

                  final sales = snapshot.data ?? [];

                  if (sales.isEmpty) {
                    return const EmptySalesCard();
                  }

                  return Column(
                    children: sales.map((sale) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMd,
                        ),
                        child: _RecentSaleCard(
                          sale: sale,
                          currency: _currency,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    SaleDetailsScreen(saleId: sale.id),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

Widget _buildWelcomeHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppDecor.heroGradient(isDark),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded,
                      color: AppColors.successLight, size: 14),
                  const SizedBox(width: 6),
                  Text('LIVE • OPEN FOR SALE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1)),
                ],
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: widget.onOpenSettings,
              icon: const Icon(Icons.settings_outlined,
                  color: Colors.white),
              tooltip: 'Settings',
            ),
          ]),
          const SizedBox(height: 12),
          Text(_getGreeting(),
              style: TextStyle(
                  color:
                      Colors.white.withValues(alpha: 0.8),
                  fontSize: 14)),
          Text(_businessName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text("Here's your business overview",
              style: TextStyle(
                  color:
                      Colors.white.withValues(alpha: 0.75),
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return SectionHeader(title: title, subtitle: subtitle);
  }

  /// A compact grid of quick navigation actions for common tasks.
  Widget _buildQuickActions(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(
        label: 'POS',
        icon: Icons.point_of_sale_rounded,
        gradient: AppDecor.indigoGradient.colors,
        onTap: widget.onOpenPos,
      ),
      _QuickAction(
        label: 'Products',
        icon: Icons.inventory_2_rounded,
        gradient: AppDecor.skyGradient.colors,
        onTap: () => _push(const ProductsScreen()),
      ),
      _QuickAction(
        label: 'Customers',
        icon: Icons.people_alt_rounded,
        gradient: AppDecor.violetGradient.colors,
        onTap: () => _push(const CustomersScreen()),
      ),
      _QuickAction(
        label: 'Reports',
        icon: Icons.insights_rounded,
        gradient: AppDecor.moneyGradient.colors,
        onTap: () => _push(const ReportsScreen()),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        final spacing = AppDimensions.spacingMd;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: actions.map((a) {
            return SizedBox(
              width: width,
              child: _QuickActionTile(action: a),
            );
          }).toList(),
        );
      },
    );
  }

  void _push(Widget screen) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Widget _revenueChartCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<double>>(
      future: _dashboardRepository.getLast7DaysRevenue(),
      builder: (context, snap) {
        final vals = snap.data ?? List<double>.filled(7, 0);
        const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        final total = vals.fold<double>(0, (a, b) => a + b);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: scheme.outline.withValues(alpha: 0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text('Revenue - last 7 days',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface)),
                      Text(
                          'Total $_currency ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurface
                                  .withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(999),
                  ),
                  child: Text('LIVE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ),
              ]),
              const SizedBox(height: 16),
              MiniBarChart(
                values: vals,
                labels: labels,
                barColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _lowStockCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<ProductRow>>(
      future: _dashboardRepository.getLowStockProducts(),
      builder: (context, snap) {
        final rows = snap.data ?? const <ProductRow>[];

        if (rows.isEmpty && snap.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }

        if (rows.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF059669).withValues(alpha: 0.25),
              ),
            ),
            child: const Row(children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF059669)),
              SizedBox(width: 12),
              Expanded(
                child: Text('All products are well stocked',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669))),
              ),
            ]),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFF59E0B), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Low stock alerts',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('${rows.length} items',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFF59E0B))),
                ),
              ]),
              const SizedBox(height: 14),
              for (final p in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: scheme.onSurface)),
                          Text('SKU ${p.sku}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.55))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (p.stockQuantity == 0
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFF59E0B))
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        p.stockQuantity == 0
                            ? 'OUT'
                            : '${p.stockQuantity} left',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: p.stockQuantity == 0
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFF59E0B)),
                      ),
                    ),
                  ]),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentSalesError() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Text(
          'Unable to load recent sales.',
          style: AppTextStyles.bodySecondary.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
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
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),

            const SizedBox(height: AppDimensions.spacingMd),

            Text(
              'Unable to load dashboard data.',
              style: AppTextStyles.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingSm),

            Text(
              'Something went wrong while loading your dashboard. '
              'Please try again.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            FilledButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSaleCard extends StatelessWidget {
  final Sale sale;
  final String currency;
  final VoidCallback onTap;

  const _RecentSaleCard({
    required this.sale,
    required this.currency,
    required this.onTap,
  });

  String _formatDateTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();

    final day = localDateTime.day.toString().padLeft(2, '0');
    final month = localDateTime.month.toString().padLeft(2, '0');
    final year = localDateTime.year.toString();

    final hour = localDateTime.hour == 0
        ? 12
        : localDateTime.hour > 12
        ? localDateTime.hour - 12
        : localDateTime.hour;

    final minute = localDateTime.minute.toString().padLeft(2, '0');
    final period = localDateTime.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primaryLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SaleReference.format(sale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXs),

                    Text(
                      _formatDateTime(sale.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXs),

                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 15,
                          color: scheme.onSurfaceVariant,
                        ),

                        const SizedBox(width: AppDimensions.spacingXs),

                        Text(
                          sale.paymentMethod.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppDimensions.spacingSm),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currency ${sale.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXs),

                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

/// Data for a single quick-action tile on the dashboard.
class _QuickAction {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}

/// A compact gradient action tile used in the dashboard quick-actions grid.
class _QuickActionTile extends StatefulWidget {
  final _QuickAction action;

  const _QuickActionTile({required this.action});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.action.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 110),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : scheme.outline.withValues(alpha: 0.7),
            ),
            boxShadow: AppDecor.subtleShadow(context),
          ),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.action.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: AppDecor.glow(
                    widget.action.gradient.first,
                    alpha: 0.24,
                  ),
                ),
                child: Icon(
                  widget.action.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.action.label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: scheme.onSurface,
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
