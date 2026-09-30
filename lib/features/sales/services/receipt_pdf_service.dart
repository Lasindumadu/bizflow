import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/database/app_database.dart' hide Sale, SaleItem;
import '../../../data/database/database_provider.dart';
import '../../../data/repositories/business_settings_repository.dart';
import '../../../data/repositories/customer_repository.dart';
import '../../../data/repositories/sale_repository.dart';
import '../../../models/sale.dart';
import '../../../models/sale_item.dart';

class ReceiptPdfService {
  final SaleRepository _saleRepository;
  final CustomerRepository _customerRepository;
  final BusinessSettingsRepository _businessSettingsRepository;

  ReceiptPdfService()
    : _saleRepository = SaleRepository(appDatabase),
      _customerRepository = CustomerRepository(appDatabase),
      _businessSettingsRepository = BusinessSettingsRepository(appDatabase);

  Future<Uint8List> generateReceiptPdf(String saleId) async {
    final sale = await _saleRepository.getSaleById(saleId);

    if (sale == null) {
      throw Exception('Sale not found.');
    }

    final items = await _saleRepository.getSaleItems(saleId);

    if (items.isEmpty) {
      throw Exception('No items found for this sale.');
    }

    final customer = sale.customerId == null
        ? null
        : await _customerRepository.getCustomerById(sale.customerId!);

    final businessSettings = await _businessSettingsRepository.getSettings();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(businessSettings),
            pw.SizedBox(height: 24),
            _buildSaleInformation(sale, customer),
            pw.SizedBox(height: 24),
            _buildItemsTable(items, businessSettings.currency),
            pw.SizedBox(height: 24),
            _buildSummary(sale, businessSettings.currency),
            pw.SizedBox(height: 40),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(BusinessSetting settings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          settings.businessName,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
        ),
        if (settings.address.isNotEmpty) ...[
          pw.SizedBox(height: 5),
          pw.Text(
            settings.address,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
        if (settings.phone.isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            settings.phone,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
        if (settings.email.isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            settings.email,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
        pw.SizedBox(height: 16),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
          ),
          child: pw.Center(
            child: pw.Text(
              'SALES RECEIPT',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSaleInformation(Sale sale, Customer? customer) {
    final customerName = customer?.name.isNotEmpty == true
        ? customer!.name
        : 'Walk-in Customer';

    final customerPhone = customer?.phone.isNotEmpty == true
        ? customer!.phone
        : null;

    return pw.Column(
      children: [
        _infoRow('Receipt ID', sale.id),
        _infoRow('Date', _formatDate(sale.createdAt)),
        _infoRow('Payment', _formatPaymentMethod(sale.paymentMethod)),
        _infoRow('Customer', customerName),
        if (customerPhone != null) _infoRow('Phone', customerPhone),
      ],
    );
  }

  pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 7),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildItemsTable(List<SaleItem> items, String currency) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3.5),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableHeader('Item'),
            _tableHeader('Qty'),
            _tableHeader('Price'),
            _tableHeader('Total'),
          ],
        ),
        ...items.map((item) {
          return pw.TableRow(
            children: [
              _tableCell(item.productName),
              _tableCell(item.quantity.toString(), align: pw.TextAlign.center),
              _tableCell(
                _money(item.unitPrice, currency),
                align: pw.TextAlign.right,
              ),
              _tableCell(
                _money(item.total, currency),
                align: pw.TextAlign.right,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _tableCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(
        text,
        textAlign: align,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  pw.Widget _buildSummary(Sale sale, String currency) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.SizedBox(
        width: 260,
        child: pw.Column(
          children: [
            _summaryRow('Subtotal', sale.subtotal, currency),
            _summaryRow('Discount', sale.discount, currency),
            pw.Divider(),
            _summaryRow(
              'Total',
              sale.total,
              currency,
              bold: true,
              fontSize: 13,
            ),
            pw.SizedBox(height: 6),
            _summaryRow('Paid', sale.paidAmount, currency),
            _summaryRow('Change', sale.changeAmount, currency),
          ],
        ),
      ),
    );
  }

  pw.Widget _summaryRow(
    String label,
    double value,
    String currency, {
    bool bold = false,
    double fontSize = 10,
  }) {
    final style = pw.TextStyle(
      fontSize: fontSize,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text(_money(value, currency), style: style),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 12),
        pw.Text(
          'Thank you for your business!',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Powered by BizFlow',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    );
  }

  String _money(double amount, String currency) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Card';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method;
    }
  }

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;

    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year $hour:$minute $period';
  }
}
