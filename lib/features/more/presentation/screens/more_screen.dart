import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
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

    // Section tint pairing — royal gradient anchors per tool group.
    final royal = AppDecor.royalGradient;
    final mint = AppDecor.flowGradient;
    final blue = AppDecor.infoGradient;
    final amber = AppDecor.amberGradient;
    final coral = AppDecor.roseGradient;
    final violet = AppDecor.violetGradient;
    final gray = AppDecor.grayGradient;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('More'),
              backgroundColor: colorScheme.surface,
              elevation: 0,
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const _CompactHero(),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: notificationStore,
            builder: (context, _) {
              final unread = notificationStore.unreadCount;
              return _GroupTile(
                title: 'Notifications',
                subtitle: unread > 0
                    ? '$unread unread update${unread == 1 ? '' : 's'}'
                    : 'Sales, stock & system updates',
                icon: Icons.notifications_none_rounded,
                gradient: amber,
                trailingCount: unread,
                onTap: () => _open(context, const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(height: 18),
          const _GroupHeader('Operations').animate(delay: 60.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 10),
          _GroupTile(
            title: 'Customers',
            subtitle: 'Customer records & balances',
            icon: Icons.people_alt_outlined,
            gradient: coral,
            onTap: () => _open(context, const CustomersScreen()),
          ).animate(delay: 90.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          if (canPerform(sessionController.current, {StaffRole.owner, StaffRole.manager}))
            _GroupTile(
              title: 'Inventory',
              subtitle: 'Stock levels & movements',
              icon: Icons.inventory_2_outlined,
              gradient: blue,
              isGated: true,
              onTap: () => _open(context, const InventoryScreen()),
            ).animate(delay: 120.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          if (canPerform(sessionController.current, {StaffRole.owner, StaffRole.manager}))
            _GroupTile(
              title: 'Inventory Intelligence',
              subtitle: 'Reorder suggestions, dead stock & valuation',
              icon: Icons.insights_rounded,
              gradient: amber,
              isGated: true,
              onTap: () => _open(context, const InventoryIntelligenceScreen()),
            ).animate(delay: 150.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          if (canPerform(sessionController.current, {StaffRole.owner, StaffRole.manager}))
            _GroupTile(
              title: 'Reports',
              subtitle: 'Sales, profit & stock insights',
              icon: Icons.insights_outlined,
              gradient: violet,
              isGated: true,
              onTap: () => _open(context, const ReportsScreen()),
            ).animate(delay: 180.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          _GroupTile(
            title: 'Suppliers',
            subtitle: 'Manage supplier contacts & terms',
            icon: Icons.local_shipping_outlined,
            gradient: blue,
            onTap: () => _open(context, const SuppliersScreen()),
          ).animate(delay: 210.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          _GroupTile(
            title: 'Purchase Orders',
            subtitle: 'Create & receive stock orders',
            icon: Icons.shopping_cart_outlined,
            gradient: blue,
            onTap: () => _open(context, const PurchaseOrdersScreen()),
          ).animate(delay: 240.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          if (canPerform(sessionController.current, {StaffRole.owner, StaffRole.manager}))
            _GroupTile(
              title: 'Returns & Refunds',
              subtitle: 'Process partial or full returns',
              icon: Icons.assignment_return_outlined,
              gradient: coral,
              isGated: true,
              onTap: () => _open(context, const ReturnsScreen()),
            ).animate(delay: 270.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 18),
          const _GroupHeader('Money').animate(delay: 180.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 10),
          _GroupTile(
            title: 'Customer Credit',
            subtitle: 'Accounts receivable & payments',
            icon: Icons.credit_card_outlined,
            gradient: mint,
            onTap: () => _open(context, const CustomerCreditScreen()),
          ).animate(delay: 210.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          if (canPerform(sessionController.current, {StaffRole.owner, StaffRole.manager}))
            _GroupTile(
              title: 'Expenses',
              subtitle: 'Track business costs',
              icon: Icons.receipt_long_outlined,
              gradient: amber,
              isGated: true,
              onTap: () => _open(context, const ExpensesScreen()),
            ).animate(delay: 240.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          if (canPerform(sessionController.current, {StaffRole.owner, StaffRole.manager}))
            _GroupTile(
              title: 'Cashier Shifts',
              subtitle: 'Opening float, cash drawer & reconciliation',
              icon: Icons.point_of_sale_outlined,
              gradient: mint,
              isGated: true,
              onTap: () => _open(context, const CashShiftScreen()),
            ).animate(delay: 270.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 18),
          const _GroupHeader('People & admin').animate(delay: 240.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 10),
          _GroupTile(
            title: 'Activity Log',
            subtitle: 'Audit trail of key actions',
            icon: Icons.history_rounded,
            gradient: gray,
            onTap: () => _open(context, const AuditLogScreen()),
          ).animate(delay: 270.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          if (canPerform(sessionController.current, {StaffRole.owner, StaffRole.manager}))
            _GroupTile(
              title: 'Import Products',
              subtitle: 'Bulk-add products from a CSV file',
              icon: Icons.upload_file_rounded,
              gradient: blue,
              isGated: true,
              onTap: () => _open(context, const ProductImportScreen()),
            ).animate(delay: 300.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          if (canPerform(sessionController.current, {StaffRole.owner}))
            _GroupTile(
              title: 'Staff & Access',
              subtitle: 'Staff accounts, roles & owner recovery',
              icon: Icons.group_rounded,
              gradient: royal,
              isGated: true,
              onTap: () => _open(context, const StaffManagementScreen()),
            ).animate(delay: 330.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          if (canPerform(sessionController.current, {StaffRole.owner}))
            _GroupTile(
              title: 'Settings',
              subtitle: 'Business profile, receipts & backups',
              icon: Icons.tune_rounded,
              gradient: royal,
              isGated: true,
              onTap: () => _open(context, const SettingsScreen()),
            ).animate(delay: 360.ms).fadeIn(duration: 380.ms, curve: Curves.easeOutCubic).moveY(begin: 14, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: AppDimensions.spacingLg),
          const _MoreFooter(),
        ],
      ),
    );
  }
}

/// Compact photo-backed hero for the toolbox — [AppImages.purpleAbstract]
/// under the brand wash, ≤ 200px tall per the guide.
class _CompactHero extends StatelessWidget {
  const _CompactHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: 170,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AppImages.purpleAbstract,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            for (final g in AppDecor.photoWash())
              DecoratedBox(decoration: BoxDecoration(gradient: g)),
            const Positioned(
              top: -30,
              right: -36,
              child: IgnorePointer(
                child: _HeroOrb(size: 180, color: AppColors.auroraTeal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BrandMark(size: 30, showShadow: false),
                      const SizedBox(width: 8),
                      Text(
                        'TOOLBOX',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: AppColors.onPhotoMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'More tools',
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      color: AppColors.onPhoto,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Everything else your business needs — suppliers, staff, '
                    'refunds, shifts and settings.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.onPhotoSoft,
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 60.ms).fadeIn(
          duration: 420.ms,
          curve: Curves.easeOutCubic,
        ).moveY(
          begin: 14,
          end: 0,
          duration: 420.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

class _HeroOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _HeroOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// Eyebrow-style group heading (uppercase, tracked).
class _GroupHeader extends StatelessWidget {
  final String label;

  const _GroupHeader(this.label);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            gradient: AppDecor.auroraBar,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
            color: scheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

/// A tool card: gradient squircle icon + hover lift (BrandCard) +
/// press scale, styled like [BrandActionTile].
class _GroupTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final int trailingCount;
  final bool isGated;

  const _GroupTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    this.trailingCount = 0,
    this.isGated = false,
  });

  @override
  State<_GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<_GroupTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = widget.gradient.colors.last;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Listener(
        onPointerDown: (_) => setState(() => _pressed = true),
        onPointerUp: (_) => setState(() => _pressed = false),
        onPointerCancel: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: BrandCard(
            padding: const EdgeInsets.all(13),
            radius: 18,
            onTap: widget.onTap,
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppDecor.glow(
                      tone,
                      alpha: isDark ? 0.30 : 0.22,
                    ),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
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
                if (widget.trailingCount > 0) ...[
                  const SizedBox(width: 6),
                  BrandPill(
                    label: widget.trailingCount > 9
                        ? '9+'
                        : '${widget.trailingCount}',
                    color: AppColors.brandCoral,
                  ),
                ],
                if (widget.isGated) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: AppColors.brandAmber,
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: tone.withValues(alpha: isDark ? 0.16 : 0.09),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: tone,
                  ),
                ),
              ],
            ),
          ),
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
            gradient: AppDecor.royalGradient,
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
