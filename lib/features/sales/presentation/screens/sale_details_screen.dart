import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../data/database/app_database.dart' hide Sale, SaleItem;
import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
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

  /// Whether the acting session can cancel sales (owner or manager).
  bool get _canCancelSales => canPerform(
        sessionController.current,
        {StaffRole.owner, StaffRole.manager},
      );

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
      return const Scaffold(
        body: Center(child: AuroraLoader(size: 46)),
      );
    }

    return Scaffold(
      body: FutureBuilder<Sale?>(
        future: _saleFuture,
        builder: (context, saleSnapshot) {
          if (saleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AuroraLoader(size: 46));
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
                return const Center(child: AuroraLoader(size: 46));
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
                    return const Center(child: AuroraLoader(size: 46));
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
      padding: EdgeInsets.zero,
      children: [
        BrandPageHeader(
          eyebrow: 'Sales history',
          title: 'Sale details',
          subtitle: 'Payment, customer and line items for this order.',
          icon: Icons.receipt_long_rounded,
          actions: [
            BrandHeaderAction(
              icon: Icons.picture_as_pdf_outlined,
              tooltip: 'Open receipt',
              onTap: _openReceipt,
            ),
          ],
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  _buildSaleHeader(sale, items.length),
                  const SizedBox(height: 14),
                  _buildCustomerCard(sale: sale, customer: customer),
                  const SizedBox(height: 14),
                  _buildItemsCard(items),
                  const SizedBox(height: 14),
                  _buildSummaryCard(sale),
                  const SizedBox(height: 18),
                  _buildReceiptButton(),
                  if (sale.isCompleted && _canCancelSales) ...[
                    const SizedBox(height: 10),
                    _buildCancelButton(sale),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppDecor.royalGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.30),
        ),
        child: FilledButton.icon(
          onPressed: _openReceipt,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.receipt_long_outlined, size: 18),
          label: const Text(
            'View receipt',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildSaleHeader(Sale sale, int itemCount) {
    final cancelled = sale.status.toLowerCase() == 'cancelled';
    final gradient = LinearGradient(
      colors: cancelled
          ? const [Color(0xFF3B1220), Color(0xFF5B1B2A), Color(0xFF1C1018)]
          : const [
              Color(0xFF0B0730),
              Color(0xFF31246E),
              Color(0xFF4338CA),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: AppDecor.glow(
          cancelled ? AppColors.error : AppColors.primary,
          alpha: 0.22,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(child: GrainOverlay()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SALE ${sale.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF9FE9DE),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatDateTime(sale.createdAt),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BrandPill(
                      label: sale.status.toUpperCase(),
                      color: cancelled
                          ? AppColors.brandCoral
                          : AppColors.brandMint,
                      icon: cancelled
                          ? Icons.cancel_rounded
                          : Icons.check_circle_rounded,
                      filled: true,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'TOTAL',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$_currency ${sale.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _HeaderMetric(
                      label: 'Items',
                      value: '$itemCount',
                      icon: Icons.shopping_bag_rounded,
                    ),
                    const SizedBox(width: 10),
                    _HeaderMetric(
                      label: 'Payment',
                      value: _formatPaymentMethod(sale.paymentMethod),
                      icon: Icons.credit_card_rounded,
                    ),
                    const SizedBox(width: 10),
                    _HeaderMetric(
                      label: 'Paid',
                      value: '$_currency ${sale.paidAmount.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                  ],
                ),
              ],
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
      return BrandCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const BrandIconBadge(
              icon: Icons.person_outline_rounded,
              color: AppColors.primary,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Walk-in customer',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No customer was attached to this sale.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final phone = customer.phone.trim();
    final email = customer.email.trim();
    final address = customer.address.trim();

    final initials = customer.name.trim().isEmpty
        ? '?'
        : customer.name.trim().substring(0, 1).toUpperCase();

    return BrandCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppDecor.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: AppTextStyles.displayFont,
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    if (phone.isNotEmpty) _ContactChip(label: phone),
                    if (email.isNotEmpty) _ContactChip(label: email),
                    if (address.isNotEmpty) _ContactChip(label: address),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(List<SaleItem> items) {
    return BrandCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: 'Items',
            subtitle: '${items.length} line${items.length == 1 ? '' : 's'}',
            icon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              'No items found for this sale.',
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SaleItemRow(item: item, currency: _currency),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Sale sale) {
    return BrandCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            title: 'Payment summary',
            icon: Icons.calculate_outlined,
          ),
          const SizedBox(height: 14),
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
            const SizedBox(height: 6),
            _SummaryRow(
              label: 'Amount paid',
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
    );
  }

  Widget _buildCancelButton(Sale sale) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isCancelling ? null : () => _cancelSale(sale),
        icon: _isCancelling
            ? const SizedBox(
                width: 16,
                height: 16,
                child: AuroraLoader(size: 16, strokeWidth: 2),
              )
            : const Icon(Icons.cancel_outlined, size: 18),
        label: Text(_isCancelling ? 'Cancelling…' : 'Cancel sale'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.error.withValues(alpha: 0.45),
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

/// Small frosted metric used inside the sale hero.
class _HeaderMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF8FE9DB)),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
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
}

class _ContactChip extends StatelessWidget {
  final String label;

  const _ContactChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          size: 4,
          color: scheme.onSurface.withValues(alpha: 0.35),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: scheme.onSurface.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }
}

class _SaleItemRow extends StatelessWidget {
  final SaleItem item;
  final String currency;

  const _SaleItemRow({required this.item, required this.currency});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark
        ? AppColors.primaryLight.withValues(alpha: 0.18)
        : AppColors.posTint.first;
    final tintInk = isDark ? AppColors.primaryLight : AppColors.royalEnd;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.035)
            : AppColors.lightSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: tintInk.withValues(alpha: isDark ? 0.35 : 0.24),
              ),
            ),
            child: Text(
              '${item.quantity}×',
              style: TextStyle(
                fontFamily: AppTextStyles.displayFont,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: tintInk,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$currency ${item.unitPrice.toStringAsFixed(2)} each',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$currency ${item.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
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
              ? TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: -0.6,
                  color: Theme.of(context).colorScheme.primary,
                )
              : TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isDiscount
                      ? AppColors.brandMint
                      : Theme.of(context).colorScheme.onSurface,
                ),
        ),
      ],
    );
  }
}
