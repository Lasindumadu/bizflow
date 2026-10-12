import 'package:flutter/material.dart';

import '../../../core/services/notification_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decor.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_controller.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/sales/presentation/screens/sales_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _sidebarCollapsed = false;

  final GlobalKey<DashboardScreenState> _dashboardScreenKey =
      GlobalKey<DashboardScreenState>();
  final GlobalKey<ProductsScreenState> _productsScreenKey =
      GlobalKey<ProductsScreenState>();
  final GlobalKey<PosScreenState> _posScreenKey = GlobalKey<PosScreenState>();
  final GlobalKey<SalesScreenState> _salesScreenKey =
      GlobalKey<SalesScreenState>();
  final GlobalKey<CustomersScreenState> _customersScreenKey =
      GlobalKey<CustomersScreenState>();
  final GlobalKey<InventoryScreenState> _inventoryScreenKey =
      GlobalKey<InventoryScreenState>();
  final GlobalKey<ExpensesScreenState> _expensesScreenKey =
      GlobalKey<ExpensesScreenState>();
  final GlobalKey<ReportsScreenState> _reportsScreenKey =
      GlobalKey<ReportsScreenState>();

  late final List<Widget> _screens = [
    DashboardScreen(
      key: _dashboardScreenKey,
      onOpenSettings: _openSettings,
      onOpenPos: _openPos,
    ),
    ProductsScreen(key: _productsScreenKey),
    PosScreen(key: _posScreenKey),
    SalesScreen(key: _salesScreenKey),
    CustomersScreen(key: _customersScreenKey),
    InventoryScreen(key: _inventoryScreenKey),
    ExpensesScreen(key: _expensesScreenKey),
    ReportsScreen(key: _reportsScreenKey),
    const MoreScreen(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem('Home', Icons.grid_view_outlined, Icons.grid_view_rounded, 0),
    _NavItem('POS Terminal', Icons.point_of_sale_outlined, Icons.point_of_sale_rounded, 2, isProminent: true),
    _NavItem('Products', Icons.inventory_2_outlined, Icons.inventory_2_rounded, 1),
    _NavItem('Sales & Invoices', Icons.receipt_long_outlined, Icons.receipt_long_rounded, 3),
    _NavItem('Customers', Icons.people_alt_outlined, Icons.people_alt_rounded, 4),
    _NavItem('Inventory', Icons.warehouse_outlined, Icons.warehouse_rounded, 5),
    _NavItem('Expenses', Icons.payments_outlined, Icons.payments_rounded, 6),
    _NavItem('Analytics', Icons.insights_outlined, Icons.insights_rounded, 7),
    _NavItem('More Tools', Icons.apps_outlined, Icons.apps_rounded, 8),
  ];

  String get _currentSectionTitle {
    switch (_currentIndex) {
      case 0:
        return 'Overview & Real-time Metrics';
      case 1:
        return 'Product Catalog & Pricing';
      case 2:
        return 'Point of Sale Terminal';
      case 3:
        return 'Transaction History & Receipts';
      case 4:
        return 'Customer Directory & Accounts';
      case 5:
        return 'Stock Levels & Movements';
      case 6:
        return 'Expenditure & Cost Tracking';
      case 7:
        return 'Business Reports & Insights';
      case 8:
        return 'System Utilities & Extensions';
      default:
        return 'BizFlow';
    }
  }

  void _onNavigationSelected(int index) {
    if (index == 0) _dashboardScreenKey.currentState?.refreshBusinessSettings();
    if (index == 1) _productsScreenKey.currentState?.refreshBusinessSettings();
    if (index == 2) _posScreenKey.currentState?.refreshBusinessSettings();
    if (index == 3) _salesScreenKey.currentState?.refreshBusinessSettings();
    if (index == 4) _customersScreenKey.currentState?.refreshBusinessSettings();
    if (index == 5) _inventoryScreenKey.currentState?.refreshBusinessSettings();
    if (index == 6) _expensesScreenKey.currentState?.refreshBusinessSettings();
    if (index == 7) _reportsScreenKey.currentState?.refreshBusinessSettings();

    setState(() {
      _currentIndex = index;
    });
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openPos() {
    _onNavigationSelected(2);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isPhone = width < 680;
        final isTablet = width >= 680 && width < 1100;

        if (isPhone) {
          return _buildMobileLayout(context);
        }

        return _buildDesktopLayout(context, isTablet: isTablet);
      },
    );
  }

  // ─────────────────────────────────────────────
  // Mobile Layout
  // ─────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            right: 16,
            bottom: 84,
            child: _MobileNotificationsButton(onTap: _openNotifications),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMobileNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                _buildMobileNavItem(1, Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Products'),
                _buildMobilePosCenterButton(),
                _buildMobileNavItem(3, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Sales'),
                _buildMobileNavItem(8, Icons.grid_view_outlined, Icons.grid_view_rounded, 'More'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(int index, IconData outline, IconData filled, String label) {
    final sel = _currentIndex == index;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _onNavigationSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? scheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sel ? filled : outline,
              size: 22,
              color: sel ? scheme.primary : scheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel ? scheme.primary : scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePosCenterButton() {
    return GestureDetector(
      onTap: () => _onNavigationSelected(2),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: AppDecor.indigoGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.point_of_sale_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Desktop & Tablet Layout with Top Bar
  // ─────────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, {required bool isTablet}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarWidth = _sidebarCollapsed ? 76.0 : (isTablet ? 220.0 : 256.0);

    return Scaffold(
      body: Row(
        children: [
          // Sleek Left Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            width: sidebarWidth,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                right: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSidebarHeader(isDark),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    children: _navItems.map((item) {
                      return _buildSidebarItem(item, isDark);
                    }).toList(),
                  ),
                ),
                _buildSidebarFooter(isDark),
              ],
            ),
          ),

          // Main Canvas with Top Header Bar
          Expanded(
            child: Column(
              children: [
                _buildTopHeaderBar(context, isDark),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Top Header Bar
  // ─────────────────────────────────────────────
  Widget _buildTopHeaderBar(BuildContext context, bool isDark) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Breadcrumb Title & Subtitle
          Expanded(
            child: Row(
              children: [
                IconButton(
                  tooltip: _sidebarCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                  icon: Icon(
                    _sidebarCollapsed
                        ? Icons.menu_open_rounded
                        : Icons.menu_rounded,
                    size: 20,
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                  onPressed: () {
                    setState(() {
                      _sidebarCollapsed = !_sidebarCollapsed;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _navItems.firstWhere((it) => it.index == _currentIndex).label,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      _currentSectionTitle,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Action: POS Launch
          if (_currentIndex != 2) ...[
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _openPos,
                icon: const Icon(Icons.flash_on_rounded, size: 18),
                label: const Text(
                  'Quick POS',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],

          // Theme Mode Switcher
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.lightBorder,
              ),
            ),
            child: IconButton(
              tooltip: themeController.isDark
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              icon: Icon(
                themeController.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                size: 19,
                color: themeController.isDark
                    ? AppColors.tertiary
                    : scheme.onSurface.withValues(alpha: 0.75),
              ),
              onPressed: () {
                themeController.toggle();
              },
            ),
          ),

          // Notifications Bell
          _NotificationBell(onTap: _openNotifications),

          const SizedBox(width: 8),

          // Settings Button
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.lightBorder,
              ),
            ),
            child: IconButton(
              tooltip: 'Settings & Business Config',
              icon: Icon(
                Icons.settings_outlined,
                size: 20,
                color: scheme.onSurface.withValues(alpha: 0.75),
              ),
              onPressed: _openSettings,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Left Sidebar Components
  // ─────────────────────────────────────────────
  Widget _buildSidebarHeader(bool isDark) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _sidebarCollapsed ? 12 : 18,
        vertical: 18,
      ),
      child: Row(
        mainAxisAlignment:
            _sidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppDecor.indigoGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (!_sidebarCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'BizFlow',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: -0.3,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PRO',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Smart POS & Retail',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_NavItem item, bool isDark) {
    final sel = _currentIndex == item.index;
    final scheme = Theme.of(context).colorScheme;

    if (_sidebarCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Tooltip(
          message: item.label,
          preferBelow: false,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onNavigationSelected(item.index),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: sel && item.isProminent
                      ? AppDecor.indigoGradient
                      : null,
                  color: sel && !item.isProminent
                      ? scheme.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: sel && !item.isProminent
                      ? Border.all(
                          color: scheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Center(
                  child: Icon(
                    sel ? item.filledIcon : item.outlinedIcon,
                    size: 22,
                    color: sel && item.isProminent
                        ? Colors.white
                        : sel
                            ? scheme.primary
                            : scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNavigationSelected(item.index),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              gradient: sel && item.isProminent
                  ? AppDecor.indigoGradient
                  : null,
              color: sel && !item.isProminent
                  ? scheme.primary.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: sel && !item.isProminent
                  ? Border.all(
                      color: scheme.primary.withValues(alpha: 0.25),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  sel ? item.filledIcon : item.outlinedIcon,
                  size: 20,
                  color: sel && item.isProminent
                      ? Colors.white
                      : sel
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel && item.isProminent
                          ? Colors.white
                          : sel
                              ? scheme.primary
                              : scheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                if (sel)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.isProminent ? Colors.white : scheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(bool isDark) {
    if (_sidebarCollapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Tooltip(
          message: 'Offline Capable & Local Database Active',
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Offline Database',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Sync ready & safe',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
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

class _NavItem {
  final String label;
  final IconData outlinedIcon;
  final IconData filledIcon;
  final int index;
  final bool isProminent;

  const _NavItem(
    this.label,
    this.outlinedIcon,
    this.filledIcon,
    this.index, {
    this.isProminent = false,
  });
}

/// A bell icon button with a live unread badge, driven by [notificationStore].
class _NotificationBell extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationBell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: notificationStore,
      builder: (context, _) {
        final unread = notificationStore.unreadCount;

        return Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.lightBorder,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.75),
                      size: 20,
                    ),
                    if (unread > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1.5,
                          ),
                          constraints: const BoxConstraints(minWidth: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.rose, AppColors.error],
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: scheme.surface, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating notification button used on mobile layouts.
class _MobileNotificationsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MobileNotificationsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notificationStore,
      builder: (context, _) {
        final unread = notificationStore.unreadCount;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppDecor.indigoGradient,
                shape: BoxShape.circle,
                boxShadow: AppDecor.glow(AppColors.primary, alpha: 0.4),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        decoration: BoxDecoration(
                          color: AppColors.rose,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
