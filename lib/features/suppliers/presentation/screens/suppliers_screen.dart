import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
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
      MaterialPageRoute(
        builder: (_) => SupplierDetailScreen(supplier: supplier),
      ),
    );
    if (result == true) _refresh();
  }

  Future<void> _confirmDeleteSupplier(SupplierRecord supplier) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete supplier?'),
        content: Text(
          'Are you sure you want to permanently delete "${supplier.name}"?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BrandPageHeader(
                eyebrow: 'Supply chain',
                title: 'Suppliers',
                subtitle: 'Who you buy from, and on what terms.',
                icon: Icons.local_shipping_rounded,
                actions: [
                  BrandHeaderAction(
                    icon: Icons.add_rounded,
                    tooltip: 'Add supplier',
                    onTap: _openAddSupplier,
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: FutureBuilder<List<SupplierRecord>>(
                    future: _suppliersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const AppLoadingState(
                          message: 'Loading suppliers…',
                        ).animate().fadeIn(duration: 300.ms);
                      }

                      if (snapshot.hasError) {
                        return AppErrorState(
                          message: snapshot.error.toString(),
                          onRetry: _refresh,
                        ).animate().fadeIn(duration: 300.ms);
                      }

                      final suppliers =
                          snapshot.data ?? const <SupplierRecord>[];

                      if (suppliers.isEmpty) {
                        return ListView(
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.sizeOf(context).height * 0.45,
                              child: BrandEmptyState(
                                title: 'No suppliers yet',
                                message:
                                    'Add your first supplier to start managing purchase orders.',
                                actionLabel: 'Add supplier',
                                onAction: _openAddSupplier,
                                icon: Icons.local_shipping_outlined,
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
                        itemCount: suppliers.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  BrandPill(
                                    label:
                                        '${suppliers.length} supplier${suppliers.length == 1 ? '' : 's'}',
                                    color: AppColors.primary,
                                    icon: Icons.local_shipping_rounded,
                                  ),
                                  BrandPill(
                                    label: 'Tap a card to edit',
                                    color: AppColors.brandMint,
                                    icon: Icons.touch_app_rounded,
                                  ),
                                ],
                              ),
                            );
                          }

                          final supplier = suppliers[index - 1];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SupplierCard(
                              supplier: supplier,
                              onTap: () => _openEditSupplier(supplier),
                              onDelete: () =>
                                  _confirmDeleteSupplier(supplier),
                            ),
                          ).animate(
                            delay: Duration(milliseconds: 60 * (index - 1)),
                          ).fadeIn(
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          ).slideY(begin: 0.06, end: 0);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSupplier,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add supplier'),
      ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final SupplierRecord supplier;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final details = <(IconData, String)>[
      if (supplier.contactPerson.isNotEmpty)
        (Icons.person_outline_rounded, supplier.contactPerson),
      if (supplier.phone.isNotEmpty)
        (Icons.phone_outlined, supplier.phone),
      if (supplier.email.isNotEmpty)
        (Icons.alternate_email_rounded, supplier.email),
      if (supplier.paymentTermsDays > 0)
        (Icons.schedule_rounded, 'Net ${supplier.paymentTermsDays}'),
    ];

    return BrandCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppDecor.tealGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 10,
                    runSpacing: 3,
                    children: details.map((detail) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            detail.$1,
                            size: 12,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            detail.$2,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Supplier actions',
            onSelected: (value) {
              if (value == 'edit') onTap();
              if (value == 'delete') onDelete();
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
                  title: Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
