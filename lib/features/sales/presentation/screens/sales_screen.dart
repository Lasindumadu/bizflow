import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../data/database/app_database.dart' hide Sale;
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/customer_repository.dart';
import '../../../../data/repositories/sale_repository.dart';
import '../../../../models/sale.dart';
import 'sale_details_screen.dart';
import '../../../../core/utils/sale_reference.dart';

class SalesScreen extends StatefulWidget {
  final bool showAppBar;
  const SalesScreen({super.key, this.showAppBar = true});

  @override
  SalesScreenState createState() => SalesScreenState();
}

class SalesScreenState extends State<SalesScreen> {
  final SaleRepository _saleRepository = SaleRepository(appDatabase);
  final CustomerRepository _customerRepository = CustomerRepository(
    appDatabase,
  );

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  late final Stream<List<Sale>> _salesStream;
  late final Stream<List<Customer>> _customersStream;

  String _currency = 'USD';
  bool _isLoadingSettings = true;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedDateFilter = 'All Sales';

  @override
  void initState() {
    super.initState();

    _salesStream = _saleRepository.watchSales();
    _customersStream = _customerRepository.watchCustomers();

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

  Future<void> refreshBusinessSettings() async {
    await _loadBusinessSettings();
  }

  List<Sale> _filterSales(List<Sale> sales, Map<String, Customer> customerMap) {
    final query = _searchQuery.trim().toLowerCase();
    final now = DateTime.now();

    return sales.where((sale) {
      final customerName = sale.customerId == null
          ? 'walk-in customer'
          : (customerMap[sale.customerId!]?.name ?? 'walk-in customer');

      final saleReference = SaleReference.format(sale).toLowerCase();
      final paymentMethod = sale.paymentMethod.toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          saleReference.contains(query) ||
          customerName.toLowerCase().contains(query) ||
          paymentMethod.contains(query);

      if (!matchesSearch) {
        return false;
      }

      final saleDate = sale.createdAt.toLocal();

      switch (_selectedDateFilter) {
        case 'Today':
          return saleDate.year == now.year &&
              saleDate.month == now.month &&
              saleDate.day == now.day;

        case 'This Week':
          final today = DateTime(now.year, now.month, now.day);
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

          return !saleDate.isBefore(startOfWeek);

        case 'This Month':
          return saleDate.year == now.year && saleDate.month == now.month;

        case 'All Sales':
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildNoMatchingSalesState() {
    return Center(
      child: BrandEmptyState(
        title: 'No matching sales',
        message: 'Try another search or date filter.',
        icon: Icons.search_off_rounded,
        image: AppImages.posPayment,
        actionLabel: 'Clear Filters',
        onAction: () {
          _searchController.clear();

          setState(() {
            _searchQuery = '';
            _selectedDateFilter = 'All Sales';
          });
        },
      ),
    );
  }

  /// Compact "today" summary row: revenue, transaction count and average
  /// ticket — derived purely from the loaded sales for display.
  Widget _buildTodaySummary(List<Sale> sales) {
    final now = DateTime.now();

    final todaySales = sales.where((sale) {
      final date = sale.createdAt.toLocal();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();

    final revenue = todaySales.fold<double>(0, (sum, sale) => sum + sale.total);
    final avg = todaySales.isEmpty ? 0.0 : revenue / todaySales.length;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.45);

    Widget stat({
      required String label,
      required String value,
      required IconData icon,
      required Color soft,
      required Color deep,
      required Color darkDeep,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isDark
                ? darkDeep.withValues(alpha: 0.22)
                : soft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: deep.withValues(alpha: isDark ? 0.35 : 0.28),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: isDark ? darkDeep : deep),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: isDark ? darkDeep : deep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (todaySales.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        stat(
          label: 'TODAY REVENUE',
          value: '$_currency ${revenue.toStringAsFixed(2)}',
          icon: Icons.trending_up_rounded,
          soft: AppColors.moneyTint.first,
          deep: AppColors.brandMintDeep,
          darkDeep: AppColors.brandMint,
        ),
        const SizedBox(width: 10),
        stat(
          label: 'TODAY SALES',
          value: '${todaySales.length}',
          icon: Icons.receipt_long_rounded,
          soft: AppColors.posTint.first,
          deep: AppColors.royalEnd,
          darkDeep: AppColors.primaryLight,
        ),
        const SizedBox(width: 10),
        stat(
          label: 'AVG TICKET',
          value: '$_currency ${avg.toStringAsFixed(2)}',
          icon: Icons.speed_rounded,
          soft: AppColors.moneyTint.first,
          deep: AppColors.brandMintDeep,
          darkDeep: AppColors.auroraTeal,
        ),
      ],
    );
  }

  Widget _buildSalesFilters() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BrandCard(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final search = TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search reference, customer or payment',
              prefixIcon: const Icon(Icons.search_rounded, size: 19),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded, size: 17),
                    ),
              isDense: true,
              filled: true,
              fillColor: colorScheme.onSurface.withValues(alpha: 0.025),
            ),
          );
          final filters = Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final filter in const [
                'All Sales',
                'Today',
                'This Week',
                'This Month',
              ])
                _DateFilterChip(
                  label: filter,
                  selected: _selectedDateFilter == filter,
                  onSelected: (selected) {
                    if (!selected) return;
                    setState(() {
                      _selectedDateFilter = filter;
                    });
                  },
                ),
            ],
          );
          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 9),
                filters,
              ],
            );
          }
          return Row(
            children: [
              Expanded(flex: 5, child: search),
              const SizedBox(width: 12),
              Expanded(flex: 6, child: filters),
            ],
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBusinessSettings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(title: const Text('Sales')) : null,
      body: _isLoadingSettings
          ? const Center(child: AuroraLoader(size: 46))
          : StreamBuilder<List<Sale>>(
              stream: _salesStream,
              builder: (context, salesSnapshot) {
                if (salesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: AuroraLoader(size: 46));
                }

                if (salesSnapshot.hasError) {
                  return _buildErrorState();
                }

                final sales = salesSnapshot.data ?? [];

                if (sales.isEmpty) {
                  return _buildEmptyState();
                }

                return StreamBuilder<List<Customer>>(
                  stream: _customersStream,
                  builder: (context, customerSnapshot) {
                    if (customerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: AuroraLoader(size: 46));
                    }

                    if (customerSnapshot.hasError) {
                      return _buildErrorState();
                    }

                    final customers = customerSnapshot.data ?? [];

                    final customerMap = <String, Customer>{
                      for (final customer in customers) customer.id: customer,
                    };

                    final filteredSales = _filterSales(sales, customerMap);

                    // Slivers instead of a pinned Column: the hero, summary
                    // and filters scroll away with the content, so the sale
                    // cards reclaim the full screen while scrolling.
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: PageHero(
                              eyebrow: 'Transactions',
                              title: 'Sales & receipts',
                              subtitle:
                                  'Every sale, payment and refund in one '
                                  'clear timeline.',
                              showIllustration: false,
                              image: AppImages.posPayment,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: _buildTodaySummary(sales),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: _buildSalesFilters(),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimensions.screenPadding,
                              AppDimensions.spacingMd,
                              AppDimensions.screenPadding,
                              0,
                            ),
                            child: _buildResultsStrip(filteredSales),
                          ),
                        ),
                        if (filteredSales.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildNoMatchingSalesState(),
                          )
                        else
                          SliverList.separated(
                            itemCount: filteredSales.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: AppDimensions.spacingMd,
                              );
                            },
                            itemBuilder: (context, index) {
                              final sale = filteredSales[index];

                              final card = _SaleCard(
                                sale: sale,
                                currency: _currency,
                                customer: sale.customerId == null
                                    ? null
                                    : customerMap[sale.customerId!],
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SaleDetailsScreen(
                                        saleId: sale.id,
                                      ),
                                    ),
                                  );
                                },
                              );

                              // Staggered entrance for the first
                              // screenful; rows below arrive instantly.
                              if (index >= 12) {
                                return card;
                              }

                              return card
                                  .animate(
                                    delay: Duration(
                                      milliseconds: 60 * index,
                                    ),
                                  )
                                  .fadeIn(
                                    duration: 380.ms,
                                    curve: Curves.easeOutCubic,
                                  )
                                  .moveY(
                                    begin: 14,
                                    end: 0,
                                    duration: 380.ms,
                                    curve: Curves.easeOutCubic,
                                  );
                            },
                          ),
                        // Breathing room under the last card.
                        const SliverToBoxAdapter(
                          child: SizedBox(height: AppDimensions.spacingXl),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildResultsStrip(List<Sale> filteredSales) {
    final total = filteredSales.fold<double>(
      0.0,
      (sum, sale) => sum + sale.total,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.auroraTeal.withValues(alpha: 0.08),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.auroraTeal.withValues(alpha: 0.10),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: isDark ? 0.24 : 0.14,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${filteredSales.length} transactions',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'in this view',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'REVENUE',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.40),
                ),
              ),
              Text(
                '$_currency ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
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
                Icons.error_outline_rounded,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text(
              'Unable to load sales',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Something went wrong while loading your sales.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            FilledButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: BrandEmptyState(
        title: 'No sales yet',
        message: 'Completed sales will appear here. Ring up your first '
            'checkout on the POS screen and it lands in this timeline.',
        icon: Icons.receipt_long_rounded,
        image: AppImages.posPayment,
      ),
    );
  }
}

/// Premium date-filter pill with the royal tint when selected.
class _DateFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _DateFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deep = AppColors.posTint.last;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(true),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? (isDark
                    ? deep.withValues(alpha: 0.24)
                    : AppColors.posTint.first)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.045)
                    : Colors.white),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? deep.withValues(alpha: isDark ? 0.55 : 0.65)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : AppColors.lightBorder),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_rounded : Icons.filter_list_rounded,
                size: 13,
                color: selected
                    ? (isDark ? AppColors.primaryLight : deep)
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? (isDark ? AppColors.primaryLight : deep)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Sale sale;
  final Customer? customer;
  final String currency;
  final VoidCallback onTap;

  const _SaleCard({
    required this.sale,
    required this.customer,
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

  String _paymentLabel(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'BANK';
      case 'cash':
        return 'CASH';
      case 'card':
        return 'CARD';
      default:
        return method.toUpperCase();
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
        return 'CANCELLED';
      case 'REFUNDED':
        return 'REFUNDED';
      case 'COMPLETED':
      default:
        return 'PAID';
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
        return AppColors.error;
      case 'REFUNDED':
        return AppColors.brandAmber;
      default:
        return AppColors.brandMintDeep;
    }
  }

  IconData _paymentIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.payments_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      default:
        return Icons.phone_android_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customerName = customer?.name ?? 'Walk-in customer';
    final statusColor = _statusColor(sale.status);

    return BrandCard(
      padding: const EdgeInsets.all(14),
      radius: 16,
      onTap: onTap,
      accent: isDark ? AppColors.primaryLight : AppColors.royalMid,
      child: Row(
        children: [
          BrandIconBadge(
            icon: _paymentIcon(sale.paymentMethod),
            color: sale.status.toUpperCase() == 'COMPLETED'
                ? (isDark ? AppColors.primaryLight : AppColors.royalMid)
                : statusColor,
            size: 42,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        SaleReference.format(sale),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    BrandPill(
                      label: _statusLabel(sale.status),
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$customerName · ${_formatDateTime(sale.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.46),
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
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _paymentLabel(sale.paymentMethod),
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: scheme.onSurface.withValues(alpha: 0.35),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 15,
                    color: scheme.onSurface.withValues(alpha: 0.28),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
