import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/supplier_repository.dart';
import 'supplier_detail_screen.dart';

/// Suppliers management screen.
class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final SupplierRepository _repository = SupplierRepository(appDatabase);

  late Future<List<SupplierRecord>> _suppliersFuture;

  @override
  void initState() {
    super.initState();
    _suppliersFuture = _repository.getSuppliers();
  }

  Future<void> _refresh() async {
    setState(() => _suppliersFuture = _repository.getSuppliers());
    await _suppliersFuture;
  }

  Future<void> _openAddSupplier() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SupplierDetailScreen()),
    );
    if (result == true) _refresh();
  }

  Future<void> _openEditSupplier(SupplierRecord supplier) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SupplierDetailScreen(supplier: supplier)),
    );
    if (result == true) _refresh();
  }

  Future<void> _confirmDeleteSupplier(SupplierRecord supplier) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier?'),
        content: Text(
          'Are you sure you want to permanently delete "${supplier.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await _repository.deleteSupplier(supplier.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supplier deleted successfully.')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete supplier: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers').animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0),
        actions: [
          IconButton(
            onPressed: _openAddSupplier,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Supplier',
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: 0.2, end: 0),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<SupplierRecord>>(
          future: _suppliersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingState(message: 'Loading suppliers…').animate().fadeIn(duration: 300.ms);
            }

            if (snapshot.hasError) {
              return AppErrorState(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              ).animate().fadeIn(duration: 300.ms).shake();
            }

            final suppliers = snapshot.data ?? const <SupplierRecord>[];

            if (suppliers.isEmpty) {
              return const AppEmptyState(
                icon: Icons.local_shipping_outlined,
                title: 'No suppliers yet',
                message: 'Add your first supplier to start managing purchase orders.',
                actionLabel: 'Add Supplier',
                onAction: null, // Will be handled by FAB
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                  child: HoverLiftCard(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    onTap: () => _openEditSupplier(supplier),
                    child: Row(
                      children: [
                        IconTile(
                          icon: Icons.local_shipping_rounded,
                          gradient: AppDecor.tealGradient.colors,
                          size: 48,
                          iconSize: 22,
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supplier.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              if (supplier.contactPerson.isNotEmpty)
                                Text(
                                  'Contact: ${supplier.contactPerson}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              if (supplier.phone.isNotEmpty)
                                Text(
                                  supplier.phone,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              if (supplier.email.isNotEmpty)
                                Text(
                                  supplier.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _openEditSupplier(supplier);
                            if (value == 'delete') _confirmDeleteSupplier(supplier);
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
                                leading: Icon(Icons.delete_outline, color: AppColors.error),
                                title: Text('Delete', style: TextStyle(color: AppColors.error)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: 100 + 50 * index))
                  .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
                  .slideX(begin: 0.1, end: 0);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSupplier,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Supplier'),
      ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideY(begin: 0.2, end: 0),
    );
  }
}