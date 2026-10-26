import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
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

  /// Whether the acting session can manage suppliers (owner or manager).
  bool get _canManageSupplies => canPerform(
        sessionController.current,
        {StaffRole.owner, StaffRole.manager},
      );

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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: _SuppliersHeader(
                  canManage: _canManageSupplies,
                  onAdd: _openAddSupplier,
                ),
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
                        );
                      }

                      if (snapshot.hasError) {
                        return AppErrorState(
                          message: snapshot.error.toString(),
                          onRetry: _refresh,
                        );
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
                                actionLabel: _canManageSupplies
                                    ? 'Add supplier'
                                    : null,
                                onAction: _canManageSupplies
                                    ? _openAddSupplier
                                    : null,
                                icon: Icons.local_shipping_outlined,
                                image: AppImages.shoppingCustomers,
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
                                    color: AppColors.royalMid,
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

                          final card = _SupplierCard(
                            supplier: supplier,
                            onTap: () => _openEditSupplier(supplier),
                            onDelete: _canManageSupplies
                                ? () => _confirmDeleteSupplier(supplier)
                                : null,
                          );

                          if (index - 1 >= 12) return card;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: card,
                          )
                              .animate(
                                delay: Duration(
                                  milliseconds: 60 * (index - 1),
                                ),
                              )
                              .fadeIn(
                                duration: 400.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .moveY(
                                begin: 14,
                                end: 0,
                                duration: 400.ms,
                                curve: Curves.easeOutCubic,
                              );
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
      floatingActionButton: _canManageSupplies
          ? FloatingActionButton.extended(
              onPressed: _openAddSupplier,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add supplier'),
            ).animate().fadeIn(duration: 400.ms, delay: 500.ms)
          : null,
    );
  }
}

/// Photo micro-wash header — warehouse imagery under the brand wash,
/// replacing the plain gradient band.
class _SuppliersHeader extends StatelessWidget {
  final bool canManage;
  final VoidCallback? onAdd;

  const _SuppliersHeader({required this.canManage, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 168,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppDecor.photoHero(
              image: AppImages.warehouse,
              anchor: 'left',
              imageAlignmentY: 0.55,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 12),
                    child: _GlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_shipping_rounded,
                              size: 14,
                              color: AppColors.auroraTeal,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'SUPPLY CHAIN',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont,
                                  color: Colors.white.withValues(alpha: 0.66),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Suppliers',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Who you buy from, and on what terms.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (canManage)
                    _GlassIconButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Add supplier',
                      onTap: onAdd,
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final SupplierRecord supplier;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

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

    final initial = supplier.name.trim().isEmpty
        ? '•'
        : supplier.name.trim()[0].toUpperCase();

    return BrandCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      accent: AppColors.royalMid,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo-initial gradient tile — royal brand.
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppDecor.royalGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.28),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
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
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 14.5,
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
              if (value == 'delete') onDelete?.call();
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (onDelete != null)
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
              ];
              return items;
            },
          ),
        ],
      ),
    );
  }
}
