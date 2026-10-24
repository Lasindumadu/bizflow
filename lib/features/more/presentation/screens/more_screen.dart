import 'package:flutter/material.dart';

import '../../../../core/services/notification_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../audit/presentation/screens/audit_log_screen.dart';
import '../../../customer_credit/presentation/screens/customer_credit_screen.dart';
import '../../../customers/presentation/screens/customers_screen.dart';
import '../../../expenses/presentation/screens/expenses_screen.dart';
import '../../../import/presentation/screens/product_import_screen.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../inventory/presentation/screens/inventory_intelligence_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../purchase_orders/presentation/screens/purchase_orders_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../returns/presentation/screens/returns_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../staff/presentation/screens/staff_management_screen.dart';
import '../../../shifts/presentation/screens/cash_shift_screen.dart';
import '../../../suppliers/presentation/screens/suppliers_screen.dart';

class MoreScreen extends StatelessWidget {
  final bool showAppBar;
  const MoreScreen({super.key, this.showAppBar = true});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('More'),
              backgroundColor: colorScheme.surface,
              elevation: 0,
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PageHero(
            eyebrow: 'Toolbox',
            title: 'More tools',
            subtitle:
                'Everything else your business needs — suppliers, staff, '
                'refunds, shifts and settings.',
            showIllustration: false,
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: notificationStore,
            builder: (context, _) {
              final unread = notificationStore.unreadCount;
              return _MoreTile(
                title: 'Notifications',
                subtitle: unread > 0
                    ? '$unread unread update${unread == 1 ? '' : 's'}'
                    : 'Sales, stock & system updates',
                icon: Icons.notifications_none_rounded,
                gradient: AppDecor.tealGradient,
                trailingCount: unread,
                onTap: () => _open(context, const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(height: 6),
          const SectionHeading(
            title: 'Management',
            subtitle: 'The controls behind the counter',
            icon: Icons.tune_rounded,
          ),
          const SizedBox(height: 12),
          _MoreTile(
            title: 'Customers',
            subtitle: 'Customer records & balances',
            icon: Icons.people_alt_outlined,
            gradient: AppDecor.indigoGradient,
            onTap: () => _open(context, const CustomersScreen()),
          ),
          _MoreTile(
            title: 'Inventory',
            subtitle: 'Stock levels & movements',
            icon: Icons.inventory_2_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
            ),
            onTap: () => _open(context, const InventoryScreen()),
          ),
          _MoreTile(
            title: 'Inventory Intelligence',
            subtitle: 'Reorder suggestions, dead stock & valuation',
            icon: Icons.insights_rounded,
            gradient: AppDecor.tealGradient,
            onTap: () => _open(context, const InventoryIntelligenceScreen()),
          ),
          _MoreTile(
            title: 'Suppliers',
            subtitle: 'Manage supplier contacts & terms',
            icon: Icons.local_shipping_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
            ),
            onTap: () => _open(context, const SuppliersScreen()),
          ),
          _MoreTile(
            title: 'Purchase Orders',
            subtitle: 'Create & receive stock orders',
            icon: Icons.shopping_cart_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
            ),
            onTap: () => _open(context, const PurchaseOrdersScreen()),
          ),
          _MoreTile(
            title: 'Customer Credit',
            subtitle: 'Accounts receivable & payments',
            icon: Icons.credit_card_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
            ),
            onTap: () => _open(context, const CustomerCreditScreen()),
          ),
          _MoreTile(
            title: 'Expenses',
            subtitle: 'Track business costs',
            icon: Icons.receipt_long_outlined,
            gradient: const LinearGradient(
              colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
            ),
            onTap: () => _open(context, const ExpensesScreen()),
          ),
          _MoreTile(
            title: 'Reports',
            subtitle: 'Sales, profit & stock insights',
            icon: Icons.insights_outlined,
            gradient: AppDecor.moneyGradient,
            onTap: () => _open(context, const ReportsScreen()),
          ),
          _MoreTile(
            title: 'Returns & Refunds',
            subtitle: 'Process partial or full returns',
            icon: Icons.assignment_return_outlined,
            gradient: AppDecor.roseGradient,
            onTap: () => _open(context, const ReturnsScreen()),
          ),
          _MoreTile(
            title: 'Cashier Shifts',
            subtitle: 'Opening float, cash drawer & reconciliation',
            icon: Icons.point_of_sale_outlined,
            gradient: AppDecor.amberGradient,
            onTap: () => _open(context, const CashShiftScreen()),
          ),
          _MoreTile(
            title: 'Activity Log',
            subtitle: 'Audit trail of key actions',
            icon: Icons.history_rounded,
            gradient: AppDecor.skyGradient,
            onTap: () => _open(context, const AuditLogScreen()),
          ),
          _MoreTile(
            title: 'Import Products',
            subtitle: 'Bulk-add products from a CSV file',
            icon: Icons.upload_file_rounded,
            gradient: AppDecor.violetGradient,
            onTap: () => _open(context, const ProductImportScreen()),
          ),
          _MoreTile(
            title: 'Staff & Access',
            subtitle: 'Staff accounts, roles & owner recovery',
            icon: Icons.group_rounded,
            gradient: AppDecor.indigoGradient,
            onTap: () => _open(context, const StaffManagementScreen()),
          ),
          _MoreTile(
            title: 'Settings',
            subtitle: 'Business profile, receipts & backups',
            icon: Icons.tune_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF475569), Color(0xFF64748B)],
            ),
            onTap: () => _open(context, const SettingsScreen()),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          const _MoreFooter(),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final int trailingCount;

  const _MoreTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.trailingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: BrandCard(
        padding: const EdgeInsets.all(13),
        radius: 16,
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.1,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            if (trailingCount > 0)
              BrandPill(
                label: trailingCount > 9 ? '9+' : '$trailingCount',
                color: AppColors.brandCoral,
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.30),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreFooter extends StatelessWidget {
  const _MoreFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppDecor.indigoGradient,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'BizFlow • Premium POS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          'v1.1.0 • Offline-first',
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
