import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 30,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text('No matching sales', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Try another search or date filter.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();

                setState(() {
                  _searchQuery = '';
                  _selectedDateFilter = 'All Sales';
                });
              },
              icon: const Icon(Icons.clear_rounded),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
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
                ChoiceChip(
                  label: Text(filter, style: const TextStyle(fontSize: 11)),
                  selected: _selectedDateFilter == filter,
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
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
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Sale>>(
              stream: _salesStream,
              builder: (context, salesSnapshot) {
                if (salesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (customerSnapshot.hasError) {
                      return _buildErrorState();
                    }

                    final customers = customerSnapshot.data ?? [];

                    final customerMap = <String, Customer>{
                      for (final customer in customers) customer.id: customer,
                    };

                    final filteredSales = _filterSales(sales, customerMap);

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: PageHero(
                            eyebrow: 'Transactions',
                            title: 'Sales & receipts',
                            subtitle:
                                'Every sale, payment and refund in one clear timeline.',
                            showIllustration: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                          child: _buildSalesFilters(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.screenPadding,
                            AppDimensions.spacingMd,
                            AppDimensions.screenPadding,
                            0,
                          ),
                          child: _buildResultsStrip(filteredSales),
                        ),
                        Expanded(
                          child: filteredSales.isEmpty
                              ? _buildNoMatchingSalesState()
                              : ListView.separated(
                                  padding: const EdgeInsets.all(
                                    AppDimensions.screenPadding,
                                  ),
                                  itemCount: filteredSales.length,
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(
                                      height: AppDimensions.spacingMd,
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    final sale = filteredSales[index];

                                    return _SaleCard(
                                      sale: sale,
                                      currency: _currency,
                                      customer: sale.customerId == null
                                          ? null
                                          : customerMap[sale.customerId!],
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SaleDetailsScreen(
                                                  saleId: sale.id,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.brandMint.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.14),
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
                  color: AppColors.primary,
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
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text('No sales yet', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Completed sales will appear here.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
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
    final customerName = customer?.name ?? 'Walk-in customer';
    final statusColor = _statusColor(sale.status);

    return BrandCard(
      padding: const EdgeInsets.all(14),
      radius: 16,
      onTap: onTap,
      child: Row(
        children: [
          BrandIconBadge(
            icon: _paymentIcon(sale.paymentMethod),
            color: sale.status.toUpperCase() == 'COMPLETED'
                ? AppColors.primary
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
