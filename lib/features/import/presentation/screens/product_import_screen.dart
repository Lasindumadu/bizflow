import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/services/product_csv_importer.dart';
import '../../../../models/product.dart';

/// Import products from a CSV file: choose a file, preview the parsed rows,
/// see validation errors and duplicates, then commit.
class ProductImportScreen extends StatefulWidget {
  const ProductImportScreen({super.key});

  @override
  State<ProductImportScreen> createState() => _ProductImportScreenState();
}

class _ProductImportScreenState extends State<ProductImportScreen> {
  final ProductRepository _productRepository = ProductRepository(appDatabase);

  CsvImportPreview? _preview;
  String? _fileName;
  String? _error;
  bool _importing = false;
  int? _importedCount;

  Future<void> _pickFile() async {
    setState(() {
      _error = null;
      _preview = null;
      _importedCount = null;
    });

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();

      final text = String.fromCharCodes(bytes);

      // Existing SKUs / barcodes for duplicate detection.
      final existing = await _productRepository.getProducts();
      final preview = ProductCsvImporter.parse(
        text,
        existingSkus: existing.map((p) => p.sku.toLowerCase()).toSet(),
        existingBarcodes: existing
            .where((p) => p.barcode.isNotEmpty)
            .map((p) => p.barcode.toLowerCase())
            .toSet(),
      );

      if (!mounted) return;
      setState(() {
        _fileName = file.name;
        _preview = preview;
      });
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _import() async {
    final preview = _preview;
    if (preview == null) return;

    final rows = preview.importableRows;
    if (rows.isEmpty) return;

    setState(() => _importing = true);

    var imported = 0;
    try {
      for (final row in rows) {
        final id = 'prd_${DateTime.now().microsecondsSinceEpoch}_$imported';
        await _productRepository.addProduct(
          Product(
            id: id,
            name: row.name,
            sku: row.sku,
            category: row.category,
            purchasePrice: row.purchasePrice,
            sellingPrice: row.sellingPrice,
            stockQuantity: row.stockQuantity,
            lowStockThreshold: row.lowStockThreshold,
            barcode: row.barcode,
          ),
        );
        imported++;
      }
      if (!mounted) return;
      setState(() {
        _importing = false;
        _importedCount = imported;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Imported $imported product(s).')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _importing = false;
        _error = 'Import stopped after $imported row(s): $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Products (CSV)')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          _instructionsCard(),
          const SizedBox(height: AppDimensions.spacingLg),
          GradientButton(
            label: _preview == null ? 'Choose CSV file' : 'Choose another file',
            icon: Icons.upload_file_rounded,
            onPressed: _importing ? null : _pickFile,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            _errorCard(_error!),
          ],
          if (_importedCount != null) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            _successCard(_importedCount!),
          ],
          if (_preview != null) ...[
            const SizedBox(height: AppDimensions.spacingXl),
            _previewSection(_preview!),
          ],
        ],
      ),
    );
  }

  Widget _instructionsCard() {
    final scheme = Theme.of(context).colorScheme;
    return HoverLiftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(
                icon: Icons.file_download_outlined,
                gradient: AppDecor.skyGradient.colors,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Text('CSV format', style: AppTextStyles.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Your file needs these columns (order does not matter):',
            style: AppTextStyles.helper.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'name, sku, category, purchase_price, selling_price,\n'
              'stock_quantity, low_stock_threshold, barcode',
              style: AppTextStyles.code.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Required: name, sku, purchase_price, selling_price.',
            style: AppTextStyles.caption.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _successCard(int count) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              'Imported $count product(s) successfully.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewSection(CsvImportPreview preview) {
    final importable = preview.importableRows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Preview',
          subtitle: '${_fileName ?? 'file'} • ${preview.totalRows} row(s) read',
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusBadge(
              label: '${importable.length} ready',
              color: AppColors.success,
              icon: Icons.check_rounded,
            ),
            if (preview.errors.isNotEmpty)
              StatusBadge(
                label: '${preview.errors.length} error(s)',
                color: AppColors.error,
                icon: Icons.error_outline_rounded,
              ),
            if (preview.duplicateSkus.isNotEmpty)
              StatusBadge(
                label: '${preview.duplicateSkus.length} duplicate SKU(s)',
                color: AppColors.warning,
                icon: Icons.content_copy_rounded,
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        if (importable.isNotEmpty) ...[
          for (final row in importable.take(20)) _rowTile(row),
          if (importable.length > 20)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                '+ ${importable.length - 20} more…',
                style: AppTextStyles.caption,
              ),
            ),
          const SizedBox(height: AppDimensions.spacingLg),
          GradientButton(
            label: 'Import ${importable.length} product(s)',
            icon: Icons.download_done_rounded,
            gradient: AppDecor.moneyGradient.colors,
            isLoading: _importing,
            onPressed: _importing ? null : _import,
          ),
        ],
        if (preview.errors.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingXl),
          Text('Rows with problems', style: AppTextStyles.titleSmall),
          const SizedBox(height: AppDimensions.spacingSm),
          for (final error in preview.errors) _errorRow(error),
        ],
      ],
    );
  }

  Widget _rowTile(ParsedProductRow row) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.name, style: AppTextStyles.titleSmall),
                  Text(
                    '${row.sku} • ${row.category}',
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${row.stockQuantity} @ ${row.sellingPrice.toStringAsFixed(2)}',
              style: AppTextStyles.numericSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorRow(CsvRowError error) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Line ${error.line}',
              style: AppTextStyles.badge.copyWith(color: AppColors.error),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error.reason,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
