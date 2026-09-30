import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/customer_repository.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerRepository _customerRepository = CustomerRepository(
    appDatabase,
  );

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository();

  final TextEditingController _searchController = TextEditingController();

  late final Stream<List<Customer>> _customersStream;

  String _currency = 'USD';
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();

    _customersStream = _customerRepository.watchCustomers();
    _loadBusinessSettings();
  }

  Future<void> _loadBusinessSettings() async {
    final settings = await _businessSettingsRepository.getSettings();

    if (!mounted) {
      return;
    }

    setState(() {
      _currency = settings.currency;
      _isLoadingSettings = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openEditCustomer(Customer customer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCustomerScreen(customer: customer),
      ),
    );
  }

  Future<void> _confirmDeleteCustomer(Customer customer) async {
    final hasOutstandingBalance = customer.outstandingBalance > 0;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Customer?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to permanently delete '
                '"${customer.name}"?\n\n'
                'This action cannot be undone.',
              ),
              if (hasOutstandingBalance) ...[
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'Warning: This customer has an outstanding balance of '
                  '$_currency '
                  '${customer.outstandingBalance.toStringAsFixed(2)}.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _customerRepository.deleteCustomer(customer.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete customer: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddCustomerScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Add customer',
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
                    'Loading customers...',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            )
          : StreamBuilder<List<Customer>>(
              stream: _customersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppDimensions.spacingMd),
                        Text(
                          'Loading customers...',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final customers = snapshot.data ?? [];

                final query = _searchController.text.trim().toLowerCase();

                final filteredCustomers = customers.where((customer) {
                  if (query.isEmpty) {
                    return true;
                  }

                  return customer.name.toLowerCase().contains(query) ||
                      customer.phone.toLowerCase().contains(query) ||
                      customer.email.toLowerCase().contains(query);
                }).toList();

                return Column(
                  children: [
                    _buildSearchField(),
                    Expanded(
                      child: filteredCustomers.isEmpty
                          ? customers.isEmpty
                                ? _buildEmptyState()
                                : _buildNoResultsState()
                          : ListView.separated(
                              padding: const EdgeInsets.all(
                                AppDimensions.screenPadding,
                              ),
                              itemCount: filteredCustomers.length,
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: AppDimensions.spacingMd,
                                );
                              },
                              itemBuilder: (context, index) {
                                final customer = filteredCustomers[index];

                                return _CustomerCard(
                                  customer: customer,
                                  currency: _currency,
                                  onEdit: () {
                                    _openEditCustomer(customer);
                                  },
                                  onDelete: () {
                                    _confirmDeleteCustomer(customer);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.screenPadding,
        AppDimensions.screenPadding,
        AppDimensions.screenPadding,
        0,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Search customers...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
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
                Icons.people_outline,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text('No customers yet', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Add customers to keep track of their purchases.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_outlined, size: 48),
            SizedBox(height: AppDimensions.spacingMd),
            Text('No customers found', style: AppTextStyles.heading2),
            SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Try a different search term.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
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
              'Unable to load customers.',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Please try again.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              error,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({
    required this.customer,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = customer.phone.trim().isNotEmpty;
    final hasEmail = customer.email.trim().isNotEmpty;
    final hasOutstandingBalance = customer.outstandingBalance > 0;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (hasPhone) ...[
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(customer.phone, style: AppTextStyles.caption),
                  ],
                  if (hasEmail) ...[
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      customer.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            if (hasOutstandingBalance) ...[
              const SizedBox(width: AppDimensions.spacingSm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Outstanding', style: AppTextStyles.caption),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    '$currency '
                    '${customer.outstandingBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(width: AppDimensions.spacingSm),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
