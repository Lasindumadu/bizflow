import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders').animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0),
        actions: [
          PopupMenuButton<String>(
            initialValue: _statusFilter,
            onSelected: (value) => setState(() => _statusFilter = value),
            itemBuilder: (context) => _statusOptions
                .map((s) => PopupMenuItem(value: s, child: Text(s == 'All' ? 'All Statuses' : s.toUpperCase())))
                .toList(),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: 0.2, end: 0),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<PurchaseOrderRecord>>(
          future: _posFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingState(message: 'Loading purchase orders…').animate().fadeIn(duration: 300.ms);
            }

            if (snapshot.hasError) {
              return AppErrorState(message: snapshot.error.toString(), onRetry: _refresh)
                  .animate().fadeIn(duration: 300.ms).shake();
            }

            final pos = snapshot.data ?? const <PurchaseOrderRecord>[];
            final filtered = _filterPOs(pos);

            if (filtered.isEmpty) {
              return AppEmptyState(
                icon: Icons.shopping_cart_outlined,
                title: pos.isEmpty ? 'No purchase orders yet' : 'No matching purchase orders',
                message: pos.isEmpty
                    ? 'Create your first purchase order to order stock from suppliers.'
                    : 'Try changing the status filter.',
                actionLabel: pos.isEmpty ? 'Create PO' : null,
                onAction: pos.isEmpty ? _openCreatePO : null,
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final po = filtered[index];
                return _POTile(
                  po: po,
                  onTap: () => _openEditPO(po),
                  onSend: po.status == 'draft' ? () => _sendPO(po) : null,
                  onReceive: (po.status == 'sent' || po.status == 'partially_received') ? () => _receiveStock(po) : null,
                  onCancel: (po.status == 'draft' || po.status == 'sent' || po.status == 'partially_received')
                      ? () => _cancelPO(po)
                      : null,
                  onDelete: po.status == 'draft' ? () => _confirmDeletePO(po) : null,
                ).animate(delay: Duration(milliseconds: 100 + 50 * index))
                  .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
                  .slideX(begin: 0.1, end: 0);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePO,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Create PO'),
      ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideY(begin: 0.2, end: 0),
    );
  }
}

class _POTile extends StatelessWidget {
  final PurchaseOrderRecord po;
  final VoidCallback onTap;
  final VoidCallback? onSend;
  final VoidCallback? onReceive;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const _POTile({
    required this.po,
    required this.onTap,
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
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconTile(
                  icon: Icons.shopping_cart_outlined,
                  gradient: AppDecor.indigoGradient.colors,
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
                              style: AppTextStyles.titleSmall,
                            ),
                          ),
                          StatusBadge(label: status.label, color: status.color, icon: status.icon),
                        ],
                      ),
                      Text(
                        _formatDate(po.createdAt),
                        style: AppTextStyles.caption.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_money(po.total), style: AppTextStyles.priceSmall),
                    const SizedBox(height: 2),
                    if (po.expectedDate != null)
                      Text(
                        'Due: ${_formatDate(po.expectedDate!)}',
                        style: AppTextStyles.caption.copyWith(color: scheme.onSurface.withValues(alpha: 0.55)),
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
                  SoftButton(label: 'Send', icon: Icons.send_rounded, color: AppColors.info, onPressed: onSend!),
                if (onReceive != null)
                  SoftButton(label: 'Receive', icon: Icons.inventory_2_rounded, color: AppColors.success, onPressed: onReceive!),
                if (onCancel != null)
                  SoftButton(label: 'Cancel', icon: Icons.cancel_outlined, color: AppColors.error, onPressed: onCancel!),
                if (onDelete != null)
                  SoftButton(label: 'Delete', icon: Icons.delete_outline, color: AppColors.error, onPressed: onDelete!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}