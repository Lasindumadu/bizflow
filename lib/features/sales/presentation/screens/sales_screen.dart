import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/database/app_database.dart' hide Sale;
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/customer_repository.dart';
import '../../../../data/repositories/sale_repository.dart';
import '../../../../models/sale.dart';
import 'sale_details_screen.dart';
import '../../../../core/utils/sale_reference.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search sales, customer, or payment method',
            prefixIcon: const Icon(Icons.search_rounded),
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
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Wrap(
          spacing: AppDimensions.spacingSm,
          runSpacing: AppDimensions.spacingSm,
          children: [
            for (final filter in const [
              'All Sales',
              'Today',
              'This Week',
              'This Month',
            ])
              ChoiceChip(
                label: Text(filter),
                selected: _selectedDateFilter == filter,
                showCheckmark: false,
                onSelected: (selected) {
                  if (!selected) {
                    return;
                  }

                  setState(() {
                    _selectedDateFilter = filter;
                  });
                },
              ),
          ],
        ),
      ],
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
      appBar: AppBar(title: const Text('Sales')),
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
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.screenPadding,
                            AppDimensions.screenPadding,
                            AppDimensions.screenPadding,
                            0,
                          ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
         color: AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sales', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  '${filteredSales.length}',
                  style: AppTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenue', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  '$_currency ${total.toStringAsFixed(2)}',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
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

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'bank_transfer':
        return 'BANK TRANSFER';
      case 'cash':
        return 'CASH';
      case 'card':
        return 'CARD';
      default:
        return method.toUpperCase();
    }
  }

  String _formatStatus(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
        return 'Cancelled';
      case 'REFUNDED':
        return 'Refunded';
      case 'COMPLETED':
      default:
        return 'Completed';
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status.toUpperCase()) {
      case 'CANCELLED':
        return colorScheme.error;
      case 'REFUNDED':
        return colorScheme.tertiary;
      case 'COMPLETED':
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerName = customer == null ? 'Walk-in Customer' : customer!.name;
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            SaleReference.format(sale),
                            style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              context,
                              sale.status,
                            ).withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatStatus(sale.status),
                            style: TextStyle(
                              color: _getStatusColor(context, sale.status),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 15,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Expanded(
                          child: Text(
                            customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      _formatDateTime(sale.createdAt),
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 15,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Text(
                          _formatPaymentMethod(sale.paymentMethod),
                          style: AppTextStyles.caption,
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
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
