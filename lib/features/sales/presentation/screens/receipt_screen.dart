import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../data/database/app_database.dart' hide Sale, SaleItem;
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/customer_repository.dart';
import '../../../../data/repositories/sale_repository.dart';
import '../../../../models/sale.dart';
import '../../../../models/sale_item.dart';
import '../../services/receipt_pdf_service.dart';

class ReceiptScreen extends StatefulWidget {
  final String saleId;

  const ReceiptScreen({super.key, required this.saleId});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final SaleRepository _saleRepository = SaleRepository(appDatabase);

  final CustomerRepository _customerRepository = CustomerRepository(
    appDatabase,
  );

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository(appDatabase);

  final ReceiptPdfService _receiptPdfService = ReceiptPdfService();

  late Future<Sale?> _saleFuture;
  late Future<List<SaleItem>> _itemsFuture;
  late Future<Customer?> _customerFuture;
  late Future<BusinessSetting> _businessSettingsFuture;

  @override
  void initState() {
    super.initState();

    _saleFuture = _saleRepository.getSaleById(widget.saleId);
    _itemsFuture = _saleRepository.getSaleItems(widget.saleId);
    _customerFuture = _loadCustomer();
    _businessSettingsFuture = _businessSettingsRepository.getSettings();
  }

  Future<Customer?> _loadCustomer() async {
    final sale = await _saleRepository.getSaleById(widget.saleId);

    if (sale == null || sale.customerId == null || sale.customerId!.isEmpty) {
      return null;
    }

    return _customerRepository.getCustomerById(sale.customerId!);
  }

  Future<void> _openPdfPreview() async {
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(title: const Text('PDF Receipt')),
            body: PdfPreview(
              build: (format) {
                return _receiptPdfService.generateReceiptPdf(widget.saleId);
              },
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: true,
              pdfFileName: 'bizflow_receipt_${widget.saleId}.pdf',
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Sale?>(
        future: _saleFuture,
        builder: (context, saleSnapshot) {
          if (saleSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AuroraLoader(size: 46));
          }

          if (saleSnapshot.hasError) {
            return _buildErrorState(
              'Unable to load sale.\n\n${saleSnapshot.error}',
            );
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
                return _buildErrorState(
                  'Unable to load customer.\n\n'
                  '${customerSnapshot.error}',
                );
              }

              return FutureBuilder<List<SaleItem>>(
                future: _itemsFuture,
                builder: (context, itemsSnapshot) {
                  if (itemsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: AuroraLoader(size: 46));
                  }

                  if (itemsSnapshot.hasError) {
                    return _buildErrorState(
                      'Unable to load sale items.\n\n'
                      '${itemsSnapshot.error}',
                    );
                  }

                  final items = itemsSnapshot.data ?? [];

                  return FutureBuilder<BusinessSetting>(
                    future: _businessSettingsFuture,
                    builder: (context, businessSettingsSnapshot) {
                      if (businessSettingsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: AuroraLoader(size: 46));
                      }

                      if (businessSettingsSnapshot.hasError) {
                        return _buildErrorState(
                          'Unable to load business settings.\n\n'
                          '${businessSettingsSnapshot.error}',
                        );
                      }

                      final businessSettings = businessSettingsSnapshot.data;

                      if (businessSettings == null) {
                        return _buildErrorState(
                          'Unable to load business settings.',
                        );
                      }

                      return _buildReceipt(
                        sale: sale,
                        customer: customerSnapshot.data,
                        items: items,
                        businessSettings: businessSettings,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReceipt({
    required Sale sale,
    required Customer? customer,
    required List<SaleItem> items,
    required BusinessSetting businessSettings,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrandBackdrop(
      showArtwork: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            BrandPageHeader(
              eyebrow: 'Sale ${sale.id}',
              title: 'Digital receipt',
              subtitle: 'A customer-ready copy you can print or export.',
              icon: Icons.receipt_long_rounded,
              actions: [
                BrandHeaderAction(
                  icon: Icons.picture_as_pdf_outlined,
                  tooltip: 'Open PDF receipt',
                  onTap: _openPdfPreview,
                ),
              ],
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.lightBorder,
                      ),
                      boxShadow: AppDecor.layeredShadow(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBusinessHeader(businessSettings),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSaleInformation(sale),

                              const SizedBox(height: AppDimensions.spacingLg),

                              _buildCustomerInformation(sale, customer),

                              const SizedBox(height: AppDimensions.spacingLg),

                              const _DashedDivider(),

                              const SizedBox(height: AppDimensions.spacingLg),

                              _buildItems(items, businessSettings.currency),

                              const SizedBox(height: AppDimensions.spacingLg),

                              const _DashedDivider(),

                              const SizedBox(height: AppDimensions.spacingLg),

                              _buildSummary(sale, businessSettings.currency),

                              const SizedBox(height: AppDimensions.spacingXl),

                              const _DashedDivider(),

                              const SizedBox(height: AppDimensions.spacingLg),

                              _buildFooter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Primary gradient print CTA — uses the existing PDF pipeline.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppDecor.royalGradient,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: AppDecor.glow(
                          AppColors.royalMid,
                          alpha: 0.32,
                        ),
                      ),
                      child: FilledButton.icon(
                        onPressed: _openPdfPreview,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.print_rounded, size: 19),
                        label: const Text(
                          'Print or export receipt',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHeader(BusinessSetting settings) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: const BoxDecoration(
        gradient: AppDecor.royalGradient,
      ),
      child: Column(
        children: [
          const BrandMark(size: 46, showShadow: false),

          const SizedBox(height: AppDimensions.spacingMd),

          Text(
            settings.businessName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTextStyles.displayFont,
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),

          if (settings.address.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              settings.address.trim(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],

          if (settings.phone.trim().isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              settings.phone.trim(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11.5,
              ),
            ),
          ],

          if (settings.email.trim().isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              settings.email.trim(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11.5,
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.spacingMd),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Text(
              'SALES RECEIPT',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9FE9DE),
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleInformation(Sale sale) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 19,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                'Transaction Details',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          _ReceiptInfoRow(label: 'Receipt', value: '#${sale.id}'),

          const SizedBox(height: AppDimensions.spacingSm),

          _ReceiptInfoRow(
            label: 'Date',
            value: _formatDateTime(sale.createdAt),
          ),

          const SizedBox(height: AppDimensions.spacingSm),

          _ReceiptInfoRow(
            label: 'Payment',
            value: _formatPaymentMethod(sale.paymentMethod),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInformation(Sale sale, Customer? customer) {
    final hasCustomer =
        sale.customerId != null &&
        sale.customerId!.isNotEmpty &&
        customer != null;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer', style: AppTextStyles.caption),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  hasCustomer ? customer.name : 'Walk-in Customer',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (hasCustomer && customer.phone.trim().isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(customer.phone.trim(), style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItems(List<SaleItem> items, String currency) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 28,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'No items found for this sale.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 19,
              color: colorScheme.primary,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Text(
              'Items',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '${items.length} '
              '${items.length == 1 ? 'item' : 'items'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(width: AppDimensions.spacingMd),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spacingXs),

                        Text(
                          '${item.quantity} × '
                          '${_money(item.unitPrice, currency)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppDimensions.spacingMd),

                  Text(
                    _money(item.total, currency),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              if (index < items.length - 1) ...[
                const SizedBox(height: AppDimensions.spacingMd),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: AppDimensions.spacingMd),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSummary(Sale sale, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReceiptSummaryRow(
          label: 'Subtotal',
          value: sale.subtotal,
          currency: currency,
        ),

        if (sale.discount > 0) ...[
          const SizedBox(height: AppDimensions.spacingSm),
          _ReceiptSummaryRow(
            label: 'Discount',
            value: sale.discount,
            currency: currency,
            isDiscount: true,
          ),
        ],

        const SizedBox(height: AppDimensions.spacingMd),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            gradient: AppDecor.royalGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.28),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'TOTAL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                _money(sale.total, currency),
                style: const TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        _ReceiptSummaryRow(
          label: 'Amount Paid',
          value: sale.paidAmount,
          currency: currency,
        ),

        const SizedBox(height: AppDimensions.spacingSm),

        _ReceiptSummaryRow(
          label: 'Change',
          value: sale.changeAmount,
          currency: currency,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        const BrandMark(size: 34, showShadow: false),

        const SizedBox(height: AppDimensions.spacingMd),

        Text(
          'Thank you for your business!',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppDimensions.spacingXs),

        Text(
          'We appreciate your support.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            'POWERED BY BIZFLOW',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: SelectableText(message, textAlign: TextAlign.center),
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

  String _money(double value, String currency) {
    return '$currency ${value.toStringAsFixed(2)}';
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

    return '$day/$month/$year • '
        '$hour:$minute $period';
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

/// Receipt-style dashed rule drawn with a tiny CustomPaint, replacing the
/// solid hairline between receipt sections.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 1,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: (isDark ? Colors.white : AppColors.lightBorderStrong)
              .withValues(alpha: isDark ? 0.22 : 1),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashWidth = 6.0;
    const dashGap = 5.0;

    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(
          x + dashWidth > size.width ? size.width : x + dashWidth,
          size.height / 2,
        ),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ReceiptInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        const Spacer(),
        Flexible(
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

class _ReceiptSummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final String currency;
  final bool isDiscount;

  const _ReceiptSummaryRow({
    required this.label,
    required this.value,
    required this.currency,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDiscount
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}'
          '$currency ${value.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDiscount ? colorScheme.error : colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
