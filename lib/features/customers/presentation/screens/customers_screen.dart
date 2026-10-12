import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
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
  State<CustomersScreen> createState() => CustomersScreenState();
}

class CustomersScreenState extends State<CustomersScreen> {
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

  void _openAddCustomer() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddCustomerScreen()));
  }

  Future<void> refreshBusinessSettings() async {
    await _loadBusinessSettings();
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
    final colorScheme = Theme.of(context).colorScheme;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Customer?',
            style: AppTextStyles.heading3.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to permanently delete '
                '"${customer.name}"?\n\n'
                'This action cannot be undone.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              if (hasOutstandingBalance) ...[
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'Warning: This customer has an outstanding balance of '
                  '$_currency '
                  '${customer.outstandingBalance.toStringAsFixed(2)}.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
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
              child: Text(
                'Cancel',
                style: AppTextStyles.labelLarge.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.onErrorContainer,
              ),
              child: Text('Delete', style: AppTextStyles.labelLarge),
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
        title: Text(
          'Customers',
          style: AppTextStyles.heading3.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppDecor.heroGradient(
              Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppDimensions.spacingLg),
            child: FilledButton.icon(
              onPressed: _openAddCustomer,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add Customer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.onPrimary,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingSm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.buttonRadius,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingSettings
          ? _buildLoadingState()
          : StreamBuilder<List<Customer>>(
              stream: _customersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }
                // final query = _searchController.text.trim().toLowerCase();
                final customers = snapshot.data ?? [];
                final filteredCustomers =
                    customers.where((customer) {
                      final query = _searchController.text.trim().toLowerCase();
                      if (query.isEmpty) {
                        return true;
                      }
                      return customer.name.toLowerCase().contains(query) ||
                          customer.phone.toLowerCase().contains(query) ||
                          customer.email.toLowerCase().contains(query);
                    }).toList()..sort(
                      (a, b) => a.name.trim().toLowerCase().compareTo(
                        b.name.trim().toLowerCase(),
                      ),
                    );
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
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.clear_rounded, color: AppColors.primary),
                ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXxl),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: AppDecor.cardShadow(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppDecor.indigoGradient,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                'Loading customers',
                style: AppTextStyles.heading2.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Please wait while we load your customers.',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppDecor.indigoGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 44,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'No customers yet',
              style: AppTextStyles.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Add your first customer to start tracking customer details and outstanding balances.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            FilledButton.icon(
              onPressed: _openAddCustomer,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Add Customer'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXl,
                  vertical: AppDimensions.spacingMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
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
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_outlined,
                size: 36,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'No customers found',
              style: AppTextStyles.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Try a different search term.',
              style: AppTextStyles.bodySecondary.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Text(
              'Unable to load customers',
              style: AppTextStyles.heading2.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Something went wrong while loading your customers.',
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
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
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
    final colorScheme = Theme.of(context).colorScheme;
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
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppDecor.indigoGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                customer.name.trim().isEmpty
                    ? '?'
                    : customer.name.trim()[0].toUpperCase(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
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
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (hasPhone) ...[
                    const SizedBox(height: AppDimensions.spacingXs),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone,
                          style: AppTextStyles.caption.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (hasEmail) ...[
                    const SizedBox(height: AppDimensions.spacingXs),
                    Row(
                      children: [
                        Icon(
                          Icons.email_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            customer.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasOutstandingBalance) ...[
              const SizedBox(width: AppDimensions.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error.withValues(alpha: 0.15),
                      AppColors.error.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$currency '
                  '${customer.outstandingBalance.toStringAsFixed(2)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
              icon: Icon(
                Icons.more_vert_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
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
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
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
