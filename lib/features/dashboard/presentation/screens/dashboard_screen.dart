import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/dashboard_repository.dart';
import '../../../../models/sale.dart';
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
                    icon: Icons.payments_outlined,
                  ),
                  DashboardStatCard(
                    title: "Today's Profit",
                    value: '$_currency ${stats.todayProfit.toStringAsFixed(2)}',
                    icon: Icons.trending_up_outlined,
                  ),
                  DashboardStatCard(
                    title: 'Transactions',
                    value: stats.todayTransactions.toString(),
                    icon: Icons.receipt_long_outlined,
                  ),
                  DashboardStatCard(
                    title: 'Products',
                    value: stats.totalProducts.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                  DashboardStatCard(
                    title: 'Low Stock',
                    value: stats.lowStockProducts.toString(),
                    icon: Icons.warning_amber_outlined,
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingXl),

              QuickActionCard(
                title: 'New Sale',
                subtitle: 'Start a new transaction',
                icon: Icons.add_shopping_cart_outlined,
                onTap: widget.onOpenPos,
              ),

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

    if (hour < 12) {
      return 'Good morning 👋';
    }

    if (hour < 17) {
      return 'Good afternoon 👋';
    }

    return 'Good evening 👋';
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: AppTextStyles.heading1.copyWith(color: colorScheme.onSurface),
        ),

        const SizedBox(height: AppDimensions.spacingXs),

        Text(
          "Here's your business overview",
          style: AppTextStyles.bodySecondary.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading2.copyWith(color: colorScheme.onSurface),
        ),

        const SizedBox(height: AppDimensions.spacingXs),

        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.buttonRadius,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(width: AppDimensions.spacingMd),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SaleReference.format(sale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXs),

                    Text(
                      _formatDateTime(sale.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spacingXs),

                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 15,
                          color: colorScheme.onSurfaceVariant,
                        ),

                        const SizedBox(width: AppDimensions.spacingXs),

                        Text(
                          sale.paymentMethod.toUpperCase(),
                          style: AppTextStyles.caption.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingXs),

                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
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
