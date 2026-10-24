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
                eyebrow: 'Live business overview',
                title: '${_greeting()}, $_businessName',
                subtitle:
                    'Here is the pulse of your store today — sales, stock and '
                    'customers in one glance.',
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
                  .fadeIn(duration: 520.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic),
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

    final cards = [
      MetricCard(
        label: "Today's sales",
        value: '$_currency ${_compact(stats.todaySales)}',
        icon: Icons.payments_rounded,
        gradient: AppDecor.indigoGradient.colors,
        helper: '${stats.todayTransactions} transactions',
        badge: 'LIVE',
        onTap: widget.onOpenPos,
      ),
      MetricCard(
        label: "Today's profit",
        value: '$_currency ${_compact(stats.todayProfit)}',
        icon: Icons.trending_up_rounded,
        gradient: AppDecor.moneyGradient.colors,
        badge: profitUp ? 'UP' : 'DOWN',
        badgeUp: profitUp,
        helper: profitUp ? 'Healthy margin today' : 'Review your costs',
        onTap: () => _go(7),
      ),
      MetricCard(
        label: 'Avg. basket',
        value: '$_currency ${_compact(avgSale)}',
        icon: Icons.shopping_bag_rounded,
        gradient: AppDecor.tealGradient.colors,
        helper: 'Per completed sale',
        onTap: () => _go(3),
      ),
      MetricCard(
        label: 'Customers',
        value: '${stats.totalCustomers}',
        icon: Icons.people_alt_rounded,
        gradient: AppDecor.violetGradient.colors,
        helper: 'In your directory',
        onTap: () => _go(4),
      ),
      MetricCard(
        label: 'Products',
        value: '${stats.totalProducts}',
        icon: Icons.inventory_2_rounded,
        gradient: AppDecor.skyGradient.colors,
        helper: '${stats.lowStockProducts} need attention',
        onTap: () => _go(1),
      ),
      MetricCard(
        label: 'Low stock',
        value: '${stats.lowStockProducts}',
        icon: Icons.warning_amber_rounded,
        gradient: AppDecor.amberGradient.colors,
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
                        delay: Duration(milliseconds: 70 * entry.key),
                      )
                      .fadeIn(duration: 420.ms, curve: Curves.easeOutCubic)
                      .slideY(begin: 0.10, end: 0, curve: Curves.easeOutCubic)
                      .scale(
                        begin: const Offset(0.94, 0.94),
                        end: const Offset(1, 1),
                        duration: 420.ms,
                        curve: Curves.easeOutBack,
                      ),
                ),
              )
              .toList(),
        );
      },
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

        return BrandCard(
          padding: const EdgeInsets.all(22),
          gradientBorder: true,
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
                      color: scheme.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.show_chart_rounded,
                      size: 20,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              MiniBarChart(
                values: values,
                labels: labels,
                barColor: AppColors.primary,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 15,
                      color: AppColors.brandAmber,
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
                          color: scheme.onSurface.withValues(alpha: 0.55),
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
              compact: true,
              icon: Icons.receipt_long_rounded,
              title: 'No sales yet',
              message:
                  'Your first completed sale will appear here with its receipt.',
              actionLabel: 'Open the till',
              onAction: widget.onOpenPos,
            ),
          );
        }

        return Column(
          children: sales.asMap().entries.map((entry) {
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
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.03, end: 0),
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
        gradient: AppDecor.indigoGradient.colors,
        onTap: widget.onOpenPos,
      ),
      _QuickAction(
        label: 'Products',
        hint: 'Catalog & prices',
        icon: Icons.inventory_2_rounded,
        gradient: AppDecor.skyGradient.colors,
        onTap: () => _go(1),
      ),
      _QuickAction(
        label: 'Customers',
        hint: 'Loyalty & credit',
        icon: Icons.people_alt_rounded,
        gradient: AppDecor.violetGradient.colors,
        onTap: () => _go(4),
      ),
      _QuickAction(
        label: 'Reports',
        hint: 'Know your numbers',
        icon: Icons.insights_rounded,
        gradient: AppDecor.moneyGradient.colors,
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
              const gap = 9.0;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: actions
                    .map(
                      (action) => SizedBox(
                        width: width,
                        child: _QuickActionTile(action: action),
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
          accent: AppColors.brandAmber,
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
                                        : AppColors.brandAmber)
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
                                  : AppColors.brandAmber,
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
          scale: _pressed ? 0.94 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: widget.primary ? AppDecor.indigoGradient : null,
            color: widget.primary
                ? null
                : Colors.white.withValues(alpha: _hovered ? 0.16 : 0.10),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: widget.primary ? 0.18 : 0.22,
              ),
            ),
            boxShadow: widget.primary
                ? AppDecor.glow(AppColors.primary, alpha: 0.30)
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
    return AppColors.brandAmber;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              BrandIconBadge(
                icon: _paymentIcon,
                color: _paymentColor,
                size: 38,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SaleReference.format(sale),
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
                      '${_formatDateTime(sale.createdAt)} · '
                      '${sale.paymentMethod.toUpperCase()}',
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
                    '$currency ${sale.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrandPill(
                        label: sale.status.toUpperCase(),
                        color: sale.status == 'completed'
                            ? AppColors.brandMintDeep
                            : AppColors.brandAmber,
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
    );
  }
}

class _QuickAction {
  final String label;
  final String hint;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.hint,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}

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

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.action.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 110),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.onSurface.withValues(alpha: 0.028),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: 0.055),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.action.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.action.icon,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              Text(
                widget.action.hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface.withValues(alpha: 0.42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
