import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/database/app_database.dart' hide Sale, SaleItem;
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/customer_repository.dart';
import '../../../../data/repositories/sale_repository.dart';
import '../../../../models/sale.dart';
import '../../../../models/sale_item.dart';
import 'receipt_screen.dart';

class SaleDetailsScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailsScreen({super.key, required this.saleId});

  @override
  State<SaleDetailsScreen> createState() => _SaleDetailsScreenState();
}

class _SaleDetailsScreenState extends State<SaleDetailsScreen> {
  final SaleRepository _saleRepository = SaleRepository(appDatabase);
  final CustomerRepository _customerRepository = CustomerRepository(
    appDatabase,
  );
  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  late Future<Sale?> _saleFuture;
  late Future<List<SaleItem>> _itemsFuture;
  late Future<Customer?> _customerFuture;

  String _currency = 'USD';
  bool _isLoadingSettings = true;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();

    _loadSale();
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

  void _loadSale() {
    _saleFuture = _saleRepository.getSaleById(widget.saleId);
    _itemsFuture = _saleRepository.getSaleItems(widget.saleId);
    _customerFuture = _loadCustomer();
  }

  Future<Customer?> _loadCustomer() async {
    final sale = await _saleRepository.getSaleById(widget.saleId);

    if (sale == null || sale.customerId == null || sale.customerId!.isEmpty) {
      return null;
    }

    return _customerRepository.getCustomerById(sale.customerId!);
  }

  void _openReceipt() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReceiptScreen(saleId: widget.saleId)),
    );
  }

  Future<void> _cancelSale(Sale sale) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Sale?'),
          content: Text(
            'Are you sure you want to cancel Sale #${sale.id}?\n\n'
            'The sale will be marked as cancelled, and quantities for '
            'products that still exist will be returned to inventory.\n\n'
            'Any customer payment refund must be handled separately.\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Keep Sale'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Cancel Sale'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true || !mounted) {
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      await _saleRepository.cancelSale(sale.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _isCancelling = false;
        _loadSale();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale cancelled and stock restored.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isCancelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSettings) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sale Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sale Details')),
      body: FutureBuilder<Sale?>(
        future: _saleFuture,
        builder: (context, saleSnapshot) {
          if (saleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (saleSnapshot.hasError) {
            return _buildErrorState();
          }

          final sale = saleSnapshot.data;

          if (sale == null) {
            return _buildNotFoundState();
          }

          return FutureBuilder<Customer?>(
            future: _customerFuture,
            builder: (context, customerSnapshot) {
              if (customerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (customerSnapshot.hasError) {
                return _buildErrorState();
              }

              final customer = customerSnapshot.data;

              return FutureBuilder<List<SaleItem>>(
                future: _itemsFuture,
                builder: (context, itemsSnapshot) {
                  if (itemsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemsSnapshot.hasError) {
                    return _buildErrorState();
                  }

                  final items = itemsSnapshot.data ?? [];

                  return _buildContent(
                    sale: sale,
                    customer: customer,
                    items: items,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required Sale sale,
    required Customer? customer,
    required List<SaleItem> items,
  }) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.screenPadding),
      children: [
        _buildSaleHeader(sale),
        const SizedBox(height: AppDimensions.spacingLg),
        _buildCustomerCard(sale: sale, customer: customer),
        const SizedBox(height: AppDimensions.spacingLg),
        _buildItemsCard(items),
        const SizedBox(height: AppDimensions.spacingLg),
        _buildSummaryCard(sale),
        const SizedBox(height: AppDimensions.spacingLg),
        _buildReceiptButton(),
        if (sale.isCompleted) ...[
          const SizedBox(height: AppDimensions.spacingLg),
          _buildCancelButton(sale),
        ],
      ],
    );
  }

  Widget _buildReceiptButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _openReceipt,
        icon: const Icon(Icons.receipt_long_outlined),
        label: const Text('View Receipt'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingMd,
          ),
        ),
      ),
    );
  }

  Widget _buildSaleHeader(Sale sale) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Sale Information',
                    style: AppTextStyles.heading2,
                  ),
                ),
                _StatusBadge(status: sale.status),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            _InfoRow(label: 'Sale ID', value: sale.id),
            const SizedBox(height: AppDimensions.spacingMd),
            _InfoRow(label: 'Date', value: _formatDateTime(sale.createdAt)),
            const SizedBox(height: AppDimensions.spacingMd),
            _InfoRow(
              label: 'Payment',
              value: _formatPaymentMethod(sale.paymentMethod),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard({required Sale sale, required Customer? customer}) {
    final hasCustomer =
        sale.customerId != null &&
        sale.customerId!.isNotEmpty &&
        customer != null;

    if (!hasCustomer) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.buttonRadius,
                  ),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customer', style: AppTextStyles.heading2),
                    SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      'Walk-in Customer',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final phone = customer.phone.trim();
    final email = customer.email.trim();
    final address = customer.address.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customer', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.spacingLg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.buttonRadius,
                    ),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(phone, style: AppTextStyles.bodySecondary),
                      ],
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(email, style: AppTextStyles.bodySecondary),
                      ],
                      if (address.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(address, style: AppTextStyles.bodySecondary),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard(List<SaleItem> items) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Items', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.spacingMd),
            if (items.isEmpty)
              const Text(
                'No items found for this sale.',
                style: AppTextStyles.bodySecondary,
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.spacingMd,
                  ),
                  child: _SaleItemRow(item: item, currency: _currency),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Sale sale) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Summary', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.spacingLg),
            _SummaryRow(
              label: 'Subtotal',
              value: sale.subtotal,
              currency: _currency,
            ),
            if (sale.discount > 0) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              _SummaryRow(
                label: 'Discount',
                value: sale.discount,
                currency: _currency,
                isDiscount: true,
              ),
            ],
            const Divider(height: 24),
            _SummaryRow(
              label: 'Total',
              value: sale.total,
              currency: _currency,
              isTotal: true,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            _SummaryRow(
              label: 'Amount Paid',
              value: sale.paidAmount,
              currency: _currency,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            _SummaryRow(
              label: 'Change',
              value: sale.changeAmount,
              currency: _currency,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(Sale sale) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isCancelling ? null : () => _cancelSale(sale),
        icon: _isCancelling
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cancel_outlined),
        label: Text(_isCancelling ? 'Cancelling...' : 'Cancel Sale'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingMd,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
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
              'Unable to load sale details.',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.screenPadding),
        child: Text('Sale not found.', style: AppTextStyles.heading2),
      ),
    );
  }

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
}

class _SaleItemRow extends StatelessWidget {
  final SaleItem item;
  final String currency;

  const _SaleItemRow({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                '${item.quantity} × $currency ${item.unitPrice.toStringAsFixed(2)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Text(
          '$currency ${item.total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: AppTextStyles.bodySecondary),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final String currency;
  final bool isDiscount;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.currency,
    this.isDiscount = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : AppTextStyles.bodySecondary,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}$currency ${value.toStringAsFixed(2)}',
          style: isTotal
              ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              : const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCancelled = status == 'cancelled';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXs,
      ),
      decoration: BoxDecoration(
        color: isCancelled
            ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isCancelled
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
