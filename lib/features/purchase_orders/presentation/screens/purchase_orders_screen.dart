import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/purchase_order_repository.dart';
import '../../../../data/repositories/supplier_repository.dart';
import 'purchase_order_detail_screen.dart';
import 'receive_stock_screen.dart';

/// Purchase orders management screen.
class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  final PurchaseOrderRepository _repository = PurchaseOrderRepository(appDatabase);
  final SupplierRepository _supplierRepository = SupplierRepository(appDatabase);

  late Future<List<PurchaseOrderRecord>> _posFuture;
  late Future<List<SupplierRecord>> _suppliersFuture;

  String _statusFilter = 'All';
  final List<String> _statusOptions = ['All', 'draft', 'sent', 'partially_received', 'received', 'cancelled'];

  /// Whether the acting session can manage purchase orders (owner or manager).
  bool get _canManagePurchaseOrders => canPerform(
        sessionController.current,
        {StaffRole.owner, StaffRole.manager},
      );

  /// Whether the acting session is the owner (PO deletion is owner-only).
  bool get _isOwner => canPerform(
        sessionController.current,
        {StaffRole.owner},
      );

  @override
  void initState() {
    super.initState();
    _posFuture = _repository.getPurchaseOrders();
    _suppliersFuture = _supplierRepository.getSuppliers();
  }

  Future<void> _refresh() async {
    setState(() {
      _posFuture = _repository.getPurchaseOrders();
      _suppliersFuture = _supplierRepository.getSuppliers();
    });
    await _posFuture;
  }

  Future<void> _openCreatePO() async {
    if (!_canManagePurchaseOrders) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase orders are restricted to the owner and managers.')),
      );
      return;
    }
    final suppliers = await _suppliersFuture;
    if (!mounted) return;
    if (suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a supplier first.')),
      );
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PurchaseOrderDetailScreen(suppliers: suppliers)),
    );
    if (result == true) _refresh();
  }

  Future<void> _openEditPO(PurchaseOrderRecord po) async {
    if (!_canManagePurchaseOrders) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase orders are restricted to the owner and managers.')),
      );
      return;
    }
    if (po.status != 'draft') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only draft purchase orders can be edited.')),
      );
      return;
    }

    final suppliers = await _suppliersFuture;
    if (!mounted) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => PurchaseOrderDetailScreen(po: po, suppliers: suppliers)),
    );
    if (result == true) _refresh();
  }

  Future<void> _confirmDeletePO(PurchaseOrderRecord po) async {
    if (!_canManagePurchaseOrders) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase orders are restricted to the owner and managers.')),
      );
      return;
    }
    if (po.status != 'draft') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only draft purchase orders can be deleted.')),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Purchase Order?'),
        content: Text(
          'Are you sure you want to permanently delete PO "${po.id}"?\n\n'
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
      await _repository.deletePurchaseOrder(po.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order deleted successfully.')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete PO: $e')),
      );
    }
  }

  Future<void> _sendPO(PurchaseOrderRecord po) async {
    try {
      await _repository.sendPurchaseOrder(po.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order sent to supplier.')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send PO: $e')),
      );
    }
  }

  Future<void> _receiveStock(PurchaseOrderRecord po) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReceiveStockScreen(po: po, repository: _repository),
      ),
    );
    _refresh();
  }

  Future<void> _cancelPO(PurchaseOrderRecord po) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Purchase Order?'),
        content: Text('Cancel PO "${po.id}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel PO'),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    try {
      await _repository.cancelPurchaseOrder(po.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase order cancelled.')),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel PO: $e')),
      );
    }
  }

  List<PurchaseOrderRecord> _filterPOs(List<PurchaseOrderRecord> pos) {
    if (_statusFilter == 'All') return pos;
    return pos.where((po) => po.status == _statusFilter).toList();
  }

  /// Royal-selected status filter chips (replaces the old overflow menu
  /// with the same `_statusFilter` state).
  Widget _buildStatusFilterStrip() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData iconFor(String status) {
      switch (status) {
        case 'draft':
          return Icons.drafts_outlined;
        case 'sent':
          return Icons.send_outlined;
        case 'partially_received':
          return Icons.inventory_2_outlined;
        case 'received':
          return Icons.check_circle_outlined;
        case 'cancelled':
          return Icons.cancel_outlined;
        default:
          return Icons.filter_list_rounded;
      }
    }

    String labelFor(String status) {
      switch (status) {
        case 'partially_received':
          return 'Partial';
        case 'received':
          return 'Received';
        default:
          return status == 'All' ? 'All' : status;
      }
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _statusOptions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = _statusOptions[index];
          final selected = _statusFilter == status;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: selected ? AppDecor.royalGradient : null,
              color: selected
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.white),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : AppColors.lightBorder),
              ),
              boxShadow: selected
                  ? AppDecor.glow(AppColors.royalMid, alpha: 0.26)
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _statusFilter = status),
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconFor(status),
                        size: 14,
                        color: selected
                            ? Colors.white
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        labelFor(status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.08,
          end: 0,
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BrandPill(
              label: 'STOCK FLOW',
              color: AppColors.stockTint.last,
              icon: Icons.local_shipping_rounded,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildStatusFilterStrip(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<PurchaseOrderRecord>>(
                future: _posFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingState(
                      message: 'Loading purchase orders…',
                    );
                  }

                  if (snapshot.hasError) {
                    return AppErrorState(
                      message: snapshot.error.toString(),
                      onRetry: _refresh,
                    );
                  }

                  final pos = snapshot.data ?? const <PurchaseOrderRecord>[];
                  final filtered = _filterPOs(pos);

                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: BrandEmptyState(
                            icon: Icons.shopping_cart_outlined,
                            title: pos.isEmpty
                                ? 'No purchase orders yet'
                                : 'No matching purchase orders',
                            message: pos.isEmpty
                                ? 'Create your first purchase order to order stock from suppliers.'
                                : 'Try changing the status filter.',
                            actionLabel: pos.isEmpty && _canManagePurchaseOrders
                                ? 'Create PO'
                                : null,
                            onAction:
                                (pos.isEmpty && _canManagePurchaseOrders)
                                    ? _openCreatePO
                                    : null,
                            image: AppImages.warehouse,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.screenPadding),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final po = filtered[index];
                      final tile = _POTile(
                        po: po,
                        onTap: _canManagePurchaseOrders
                            ? () => _openEditPO(po)
                            : null,
                        onSend: (po.status == 'draft' && _canManagePurchaseOrders)
                            ? () => _sendPO(po)
                            : null,
                        onReceive: ((po.status == 'sent' ||
                                    po.status == 'partially_received') &&
                                _canManagePurchaseOrders)
                            ? () => _receiveStock(po)
                            : null,
                        onCancel: ((po.status == 'draft' ||
                                    po.status == 'sent' ||
                                    po.status == 'partially_received') &&
                                _canManagePurchaseOrders)
                            ? () => _cancelPO(po)
                            : null,
                        onDelete: (po.status == 'draft' && _isOwner)
                            ? () => _confirmDeletePO(po)
                            : null,
                      );

                      if (index >= 12) return tile;

                      return tile
                          .animate(
                            delay: Duration(milliseconds: 60 * index),
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
      floatingActionButton: _canManagePurchaseOrders
          ? FloatingActionButton.extended(
              onPressed: _openCreatePO,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: const Text('Create PO'),
            ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideY(begin: 0.2, end: 0)
          : null,
    );
  }
}

class _POTile extends StatelessWidget {
  final PurchaseOrderRecord po;
  final VoidCallback? onTap;
  final VoidCallback? onSend;
  final VoidCallback? onReceive;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const _POTile({
    required this.po,
    this.onTap,
    this.onSend,
    this.onReceive,
    this.onCancel,
    this.onDelete,
  });

  ({Color color, IconData icon, String label}) _getStatusVisual() {
    switch (po.status) {
      case 'draft':
        return (color: AppColors.chartGray, icon: Icons.drafts_outlined, label: 'DRAFT');
      case 'sent':
        return (color: AppColors.info, icon: Icons.send_outlined, label: 'SENT');
      case 'partially_received':
        return (color: AppColors.warning, icon: Icons.inventory_2_outlined, label: 'PARTIAL');
      case 'received':
        return (color: AppColors.success, icon: Icons.check_circle_outlined, label: 'RECEIVED');
      case 'cancelled':
        return (color: AppColors.error, icon: Icons.cancel_outlined, label: 'CANCELLED');
      default:
        return (color: AppColors.primary, icon: Icons.help_outline, label: po.status.toUpperCase());
    }
  }

  String _money(double v) => '\$${v.toStringAsFixed(2)}';

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = _getStatusVisual();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        radius: 20,
        onTap: onTap,
        borderColor: onTap != null
            ? AppColors.royalMid.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.34
                    : 0.22,
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconTile(
                  icon: status.icon,
                  gradient: AppDecor.royalGradient.colors,
                  size: 44,
                  iconSize: 20,
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              po.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: AppTextStyles.displayFont,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: status.label,
                            color: status.color,
                            icon: status.icon,
                          ),
                        ],
                      ),
                      Text(
                        'Created ${_formatDate(po.createdAt)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(po.total),
                      style: TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (po.expectedDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.stockTint.last.withValues(
                            alpha:
                                Theme.of(context).brightness == Brightness.dark
                                    ? 0.16
                                    : 0.08,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.stockTint.last.withValues(
                              alpha:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                      ? 0.28
                                      : 0.18,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_available_rounded,
                              size: 11,
                              color: AppColors.stockTint.last,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Due ${_formatDate(po.expectedDate!)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.stockTint.last,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onSend != null)
                  SoftButton(
                    label: 'Send',
                    icon: Icons.send_rounded,
                    color: AppColors.info,
                    expanded: false,
                    onPressed: onSend!,
                  ),
                if (onReceive != null)
                  SoftButton(
                    label: 'Receive',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.success,
                    expanded: false,
                    onPressed: onReceive!,
                  ),
                if (onCancel != null)
                  SoftButton(
                    label: 'Cancel',
                    icon: Icons.cancel_outlined,
                    color: AppColors.error,
                    expanded: false,
                    onPressed: onCancel!,
                  ),
                if (onDelete != null)
                  SoftButton(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    color: AppColors.error,
                    expanded: false,
                    onPressed: onDelete!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}