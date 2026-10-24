import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/notification_store.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decor.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../data/database/database_provider.dart';
import '../../../data/repositories/business_settings_repository.dart';
import '../../../data/repositories/staff_account_repository.dart';
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
import '../../features/staff/presentation/screens/staff_management_screen.dart';
import 'brand_ui.dart';
import 'universal_search.dart';

/// The BizFlow application shell.
///
/// Desktop: a floating ink sidebar, a glass toolbar and an animated page
/// canvas. Mobile: a compact brand bar and a floating bottom dock with the
/// POS action at its centre.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _sidebarCollapsed = false;

  /// Soft fade + lift applied whenever the active section changes.
  late final AnimationController _pageController;
  late final Animation<double> _pageOpacity;
  late final Animation<Offset> _pageOffset;

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

  // ─────────────────────────────────────────────
  // Session locking & inactivity auto-lock
  // ─────────────────────────────────────────────

  Timer? _inactivityTimer;
  int _inactivityTimeoutMinutes = 0;
  bool _isShowingLockScreen = false;
  bool _hasParkedCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionController.addListener(_onSessionChanged);
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      value: 1,
    );
    _pageOpacity = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    _pageOffset = Tween<Offset>(
      begin: const Offset(0, 0.015),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));
    unawaited(_loadInactivityTimeout());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    sessionController.removeListener(_onSessionChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _evaluateInactivity();
    }
  }

  Future<void> _loadInactivityTimeout() async {
    final settings = await BusinessSettingsRepository().getSettings();
    if (!mounted) return;
    _inactivityTimeoutMinutes = settings.inactivityTimeoutMinutes;
    _armInactivityTimer();
  }

  void _armInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;

    if (_inactivityTimeoutMinutes <= 0) return;
    if (!sessionController.isAuthenticated) return;
    if (sessionController.isLocked) return;

    _inactivityTimer = Timer(Duration(minutes: _inactivityTimeoutMinutes), () {
      _inactivityTimer = null;
      if (!mounted) return;
      sessionController.lock();
    });
  }

  void _evaluateInactivity() {
    if (!mounted) return;
    if (!sessionController.isAuthenticated) return;
    if (sessionController.isLocked) return;
    if (_inactivityTimeoutMinutes <= 0) return;

    final lastActivity = sessionController.lastActivity;
    if (lastActivity == null) {
      _armInactivityTimer();
      return;
    }

    final elapsed = DateTime.now().difference(lastActivity);
    if (elapsed >= Duration(minutes: _inactivityTimeoutMinutes)) {
      sessionController.lock();
    } else {
      _armInactivityTimer();
    }
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void _onSessionChanged() {
    if (!mounted) return;

    if (sessionController.current == null) {
      _preservePosCart();
      _cancelInactivityTimer();
      setState(() {
        _isShowingLockScreen = false;
      });
      return;
    }

    if (sessionController.isLocked) {
      _preservePosCart();
      _cancelInactivityTimer();
      _showLockScreen();
      return;
    }

    _restorePosCart();
    _armInactivityTimer();
    setState(() {
      _isShowingLockScreen = false;
    });
  }

  void _resetInactivity() {
    if (!mounted) return;
    if (!sessionController.isAuthenticated) return;
    if (sessionController.isLocked) return;

    sessionController.resetActivitySilently();
    _armInactivityTimer();
  }

  void _preservePosCart() {
    if (_hasParkedCart) return;
    final posState = _posScreenKey.currentState;
    if (posState == null) return;
    if (posState.parkActiveCart()) {
      _hasParkedCart = true;
    }
  }

  void _restorePosCart() {
    if (!_hasParkedCart) return;
    _hasParkedCart = false;
    final posState = _posScreenKey.currentState;
    if (posState == null) return;
    posState.restoreLastParkedCart();
  }

  void _showLockScreen() {
    if (_isShowingLockScreen) return;
    _isShowingLockScreen = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _LockScreenDialog(
          onUnlock: () {
            _isShowingLockScreen = false;
            sessionController.unlock();
          },
          onSignOut: () {
            _isShowingLockScreen = false;
            sessionController.signOut();
          },
        );
      },
    ).whenComplete(() {
      if (!mounted) return;
      if (sessionController.isLocked) {
        _isShowingLockScreen = false;
        _showLockScreen();
      } else {
        _isShowingLockScreen = false;
      }
    });
  }

  late final List<Widget> _screens = [
    DashboardScreen(
      key: _dashboardScreenKey,
      onOpenSettings: _openSettings,
      onOpenPos: _openPos,
      onNavigate: _onNavigationSelected,
      showAppBar: false,
    ),
    ProductsScreen(key: _productsScreenKey, showAppBar: false),
    PosScreen(key: _posScreenKey, showAppBar: false),
    SalesScreen(key: _salesScreenKey, showAppBar: false),
    CustomersScreen(key: _customersScreenKey, showAppBar: false),
    InventoryScreen(key: _inventoryScreenKey, showAppBar: false),
    ExpensesScreen(key: _expensesScreenKey, showAppBar: false),
    ReportsScreen(key: _reportsScreenKey, showAppBar: false),
    const MoreScreen(showAppBar: false),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem('Home', Icons.grid_view_outlined, Icons.grid_view_rounded, 0),
    _NavItem(
      'POS Terminal',
      Icons.point_of_sale_outlined,
      Icons.point_of_sale_rounded,
      2,
      isProminent: true,
    ),
    _NavItem(
      'Products',
      Icons.inventory_2_outlined,
      Icons.inventory_2_rounded,
      1,
    ),
    _NavItem(
      'Sales',
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
      3,
    ),
    _NavItem(
      'Customers',
      Icons.people_alt_outlined,
      Icons.people_alt_rounded,
      4,
    ),
    _NavItem('Inventory', Icons.warehouse_outlined, Icons.warehouse_rounded, 5),
    _NavItem('Expenses', Icons.payments_outlined, Icons.payments_rounded, 6),
    _NavItem('Analytics', Icons.insights_outlined, Icons.insights_rounded, 7),
    _NavItem('More Tools', Icons.apps_outlined, Icons.apps_rounded, 8),
  ];

  _NavItem get _activeItem => _navItems.firstWhere(
        (item) => item.index == _currentIndex,
        orElse: () => _navItems.first,
      );

  String get _currentSectionTitle {
    switch (_currentIndex) {
      case 0:
        return 'Overview & live metrics';
      case 1:
        return 'Catalog, pricing & stock';
      case 2:
        return 'Fast checkout & payments';
      case 3:
        return 'Transactions & receipts';
      case 4:
        return 'Directory & loyalty';
      case 5:
        return 'Stock levels & movements';
      case 6:
        return 'Costs & spending';
      case 7:
        return 'Reports & business insight';
      case 8:
        return 'Tools, settings & extensions';
      default:
        return 'BizFlow workspace';
    }
  }

  void _onNavigationSelected(int index) {
    if (index != _currentIndex) {
      _pageController.forward(from: 0);
    }
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
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  void _openStaffManagement() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const StaffManagementScreen()),
    );
  }

  void _lockNow() {
    if (!sessionController.isAuthenticated) return;
    sessionController.lock();
  }

  void _signOutNow() {
    if (!sessionController.isAuthenticated) return;
    sessionController.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isPhone = width < 760;
        final isTablet = width >= 760 && width < 1180;

        final body = isPhone
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context, isTablet: isTablet);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (_) => _resetInactivity(),
          child: body,
        );
      },
    );
  }

  Widget _buildPageStack() {
    return FadeTransition(
      opacity: _pageOpacity,
      child: SlideTransition(
        position: _pageOffset,
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Mobile
  // ─────────────────────────────────────────────

  Widget _buildMobileLayout(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: BrandBackdrop(
        showArtwork: false,
        child: Column(
          children: [
            _MobileTopBar(
              title: _activeItem.label,
              subtitle: _currentSectionTitle,
              onSearch: () => UniversalSearchOverlay.show(context),
              onNotifications: _openNotifications,
              onSettings: _openSettings,
            ),
            Expanded(child: _buildPageStack()),
          ],
        ),
      ),
      bottomNavigationBar: _MobileDock(
        currentIndex: _currentIndex,
        onSelected: _onNavigationSelected,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Desktop & tablet
  // ─────────────────────────────────────────────

  Widget _buildDesktopLayout(
    BuildContext context, {
    required bool isTablet,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sidebarWidth = _sidebarCollapsed ? 84.0 : (isTablet ? 224.0 : 252.0);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: BrandBackdrop(
        child: SafeArea(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                child: _buildSidebar(sidebarWidth, isTablet),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(context, isTablet: isTablet),
                    Expanded(child: _buildPageStack()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(double width, bool isTablet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      width: width,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11162B), Color(0xFF0A0E1D), Color(0xFF090C18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 40,
            offset: const Offset(0, 18),
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandMint.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _buildSidebarHeader(),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    children: [
                      if (!_sidebarCollapsed) const _SidebarLabel('WORKSPACE'),
                      ..._navItems
                          .where((item) => item.index == 0 ||
                              item.index == 2 ||
                              item.index == 1 ||
                              item.index == 3 ||
                              item.index == 4)
                          .map(_buildSidebarItem),
                      const SizedBox(height: 14),
                      if (!_sidebarCollapsed) const _SidebarLabel('MANAGE'),
                      ..._navItems
                          .where((item) => item.index >= 5)
                          .map(_buildSidebarItem),
                    ],
                  ),
                ),
                _buildSidebarFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _sidebarCollapsed ? 0 : 16,
        16,
        _sidebarCollapsed ? 0 : 10,
        8,
      ),
      child: Row(
        mainAxisAlignment: _sidebarCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          const BrandMark(size: 38),
          if (!_sidebarCollapsed) ...[
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'BizFlow',
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Color(0xFF04372F),
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Retail operating system',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            _CollapseButton(
              collapsed: _sidebarCollapsed,
              onTap: () =>
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_NavItem item) {
    return _SidebarNavItem(
      item: item,
      selected: _currentIndex == item.index,
      collapsed: _sidebarCollapsed,
      onTap: () => _onNavigationSelected(item.index),
    );
  }

  Widget _buildSidebarFooter() {
    final current = sessionController.current;
    final name = current == null
        ? 'Local workspace'
        : (current.displayName.trim().isEmpty
            ? current.username
            : current.displayName);
    final role = current == null ? 'Owner mode' : current.role.name;

    if (_sidebarCollapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14, top: 8),
        child: Tooltip(
          message: name,
          child: _SessionMenuButton(
            compact: true,
            onLockNow: _lockNow,
            onSignOut: _signOutNow,
            onOpenStaff: _openStaffManagement,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.brandMint,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x662DD4BF),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Offline ready',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'All data stays on this device',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.38),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Row(
              children: [
                _Avatar(name: name, size: 34),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        role,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.40),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _SessionMenuButton(
                  compact: true,
                  onLockNow: _lockNow,
                  onSignOut: _signOutNow,
                  onOpenStaff: _openStaffManagement,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, {required bool isTablet}) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(20, 10, 17, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Workspace',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: scheme.onSurface.withValues(alpha: 0.35),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 13,
                        color: scheme.onSurface.withValues(alpha: 0.25),
                      ),
                    ),
                    Text(
                      _activeItem.label,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: scheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  _activeItem.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (!isTablet) ...[
            _HeaderSearchButton(
              onTap: () => UniversalSearchOverlay.show(context),
            ),
            const SizedBox(width: 8),
          ],
          _CircleAction(
            tooltip: 'Search',
            icon: Icons.search_rounded,
            onTap: () => UniversalSearchOverlay.show(context),
            compactOnly: !isTablet,
          ),
          const SizedBox(width: 6),
          _CircleAction(
            tooltip: themeController.isDark
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: themeController.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            iconColor: themeController.isDark
                ? AppColors.brandAmber
                : scheme.onSurface.withValues(alpha: 0.7),
            onTap: themeController.toggle,
          ),
          const SizedBox(width: 6),
          _NotificationBell(onTap: _openNotifications),
          const SizedBox(width: 6),
          _CircleAction(
            tooltip: 'Settings',
            icon: Icons.tune_rounded,
            onTap: _openSettings,
          ),
          const SizedBox(width: 10),
          if (!isTablet)
            _QuickPosButton(onTap: _openPos)
          else
            _CircleAction(
              tooltip: 'Open POS',
              icon: Icons.bolt_rounded,
              iconColor: Colors.white,
              background: AppDecor.indigoGradient,
              onTap: _openPos,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shell building blocks
// ─────────────────────────────────────────────

class _SidebarLabel extends StatelessWidget {
  final String text;
  const _SidebarLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 7),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.26),
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final _NavItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final selected = widget.selected;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      padding: EdgeInsets.symmetric(
        horizontal: widget.collapsed ? 0 : 12,
        vertical: 10.5,
      ),
      decoration: BoxDecoration(
        gradient: selected ? AppDecor.indigoGradient : null,
        color: !selected && _hovered
            ? Colors.white.withValues(alpha: 0.055)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        border: selected
            ? Border.all(color: Colors.white.withValues(alpha: 0.16))
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: widget.collapsed
          ? Center(
              child: Icon(
                selected ? item.filledIcon : item.outlinedIcon,
                size: 20,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: _hovered ? 0.85 : 0.48),
              ),
            )
          : Row(
              children: [
                Icon(
                  selected ? item.filledIcon : item.outlinedIcon,
                  size: 19,
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: _hovered ? 0.88 : 0.48),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.05,
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.74),
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  )
                else if (item.isProminent)
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.30),
                  ),
              ],
            ),
    );

    final tappable = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHover: (value) => setState(() => _hovered = value),
        borderRadius: BorderRadius.circular(13),
        hoverColor: Colors.transparent,
        splashColor: Colors.white.withValues(alpha: 0.06),
        child: content,
      ),
    );

    if (!widget.collapsed) return tappable;
    return Tooltip(
      message: item.label,
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 250),
      child: tappable,
    );
  }
}

class _CollapseButton extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;

  const _CollapseButton({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              collapsed
                  ? Icons.keyboard_double_arrow_right_rounded
                  : Icons.keyboard_double_arrow_left_rounded,
              size: 17,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  const _Avatar({required this.name, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(1, 2)).toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C5CFF), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _HeaderSearchButton extends StatelessWidget {
  final VoidCallback onTap;
  const _HeaderSearchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 224,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.045)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : AppColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 17,
                color: scheme.onSurface.withValues(alpha: 0.42),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search anything…',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.42),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.07),
                  ),
                ),
                child: Text(
                  '⌘K',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Gradient? background;
  final bool compactOnly;

  const _CircleAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.background,
    this.compactOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (compactOnly) return const SizedBox.shrink();

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(11),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: background != null
                  ? null
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.045)
                      : Colors.white.withValues(alpha: 0.75)),
              gradient: background,
              borderRadius: BorderRadius.circular(11),
              border: background == null
                  ? Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : AppColors.lightBorder,
                    )
                  : null,
              boxShadow: background != null
                  ? AppDecor.glow(AppColors.primary, alpha: 0.30)
                  : null,
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? scheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickPosButton extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickPosButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            gradient: AppDecor.indigoGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppDecor.glow(AppColors.primary, alpha: 0.35),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: Colors.white, size: 17),
              SizedBox(width: 6),
              Text(
                'New sale',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mobile top bar & dock
// ─────────────────────────────────────────────

class _MobileTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onSearch;
  final VoidCallback onNotifications;
  final VoidCallback onSettings;

  const _MobileTopBar({
    required this.title,
    required this.subtitle,
    required this.onSearch,
    required this.onNotifications,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 4),
        child: Row(
          children: [
            const BrandMark(size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            _CircleAction(
              tooltip: 'Search',
              icon: Icons.search_rounded,
              onTap: onSearch,
            ),
            const SizedBox(width: 6),
            _NotificationBell(onTap: onNotifications),
            const SizedBox(width: 6),
            _CircleAction(
              tooltip: 'Settings',
              icon: Icons.tune_rounded,
              onTap: onSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _MobileDock({required this.currentIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF0E1322) : Colors.white)
                .withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                blurRadius: 28,
                offset: const Offset(0, 12),
                spreadRadius: -6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MobileDockItem(
                label: 'Home',
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                selected: currentIndex == 0,
                onTap: () => onSelected(0),
              ),
              _MobileDockItem(
                label: 'Products',
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2_rounded,
                selected: currentIndex == 1,
                onTap: () => onSelected(1),
              ),
              GestureDetector(
                onTap: () => onSelected(2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppDecor.indigoGradient,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.surface,
                      width: 3,
                    ),
                    boxShadow: AppDecor.glow(AppColors.primary, alpha: 0.45),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              _MobileDockItem(
                label: 'Sales',
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                selected: currentIndex == 3,
                onTap: () => onSelected(3),
              ),
              _MobileDockItem(
                label: 'More',
                icon: Icons.grid_view_outlined,
                activeIcon: Icons.grid_view_rounded,
                selected: currentIndex == 8,
                onTap: () => onSelected(8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileDockItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  const _MobileDockItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? activeIcon : icon,
                size: 21,
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header actions
// ─────────────────────────────────────────────

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

        return Tooltip(
          message: 'Notifications',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(11),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.045)
                      : Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : AppColors.lightBorder,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 18,
                        color: scheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                    if (unread > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.brandCoral,
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.surface, width: 1.5),
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

class _SessionMenuButton extends StatelessWidget {
  final VoidCallback onLockNow;
  final VoidCallback onSignOut;
  final VoidCallback onOpenStaff;
  final bool compact;

  const _SessionMenuButton({
    required this.onLockNow,
    required this.onSignOut,
    required this.onOpenStaff,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final current = sessionController.current;

    return PopupMenuButton<String>(
      tooltip: 'Session',
      offset: const Offset(0, 34),
      color: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.lightBorder,
        ),
      ),
      icon: compact
          ? Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : scheme.onSurface.withValues(alpha: 0.55),
            )
          : Icon(
              Icons.account_circle_outlined,
              size: 20,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
      onSelected: (value) {
        switch (value) {
          case 'lock':
            onLockNow();
          case 'staff':
            onOpenStaff();
          case 'signout':
            onSignOut();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            current == null
                ? 'Local workspace'
                : '${current.displayName.isEmpty ? current.username : current.displayName}'
                    ' · ${current.role.name}',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'lock',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.lock_outline_rounded, size: 18),
            title: Text('Lock now'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'staff',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.group_outlined, size: 18),
            title: Text('Staff & access'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'signout',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded, size: 18),
            title: Text('Sign out'),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Lock dialog
// ─────────────────────────────────────────────

class _LockScreenDialog extends StatefulWidget {
  final VoidCallback onUnlock;
  final VoidCallback onSignOut;

  const _LockScreenDialog({required this.onUnlock, required this.onSignOut});

  @override
  State<_LockScreenDialog> createState() => _LockScreenDialogState();
}

class _LockScreenDialogState extends State<_LockScreenDialog> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();
  bool _isVerifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pinFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _signOut() {
    Navigator.of(context).pop();
    widget.onSignOut();
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _error = 'Enter your PIN to unlock.');
      return;
    }

    final current = sessionController.current;
    if (current == null) {
      _signOut();
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final result = await StaffAccountRepository(appDatabase)
          .verifyPin(username: current.username, pin: pin);

      if (!mounted) return;

      switch (result.status) {
        case StaffAuthStatus.success:
          _pinController.clear();
          Navigator.of(context).pop();
          widget.onUnlock();
        case StaffAuthStatus.invalidPin:
          setState(() {
            _isVerifying = false;
            _error = 'Incorrect PIN. Please try again.';
            _pinController.clear();
          });
        case StaffAuthStatus.locked:
          setState(() {
            _isVerifying = false;
            _error =
                'Account is temporarily locked. Please sign out and contact the owner.';
            _pinController.clear();
          });
        case StaffAuthStatus.accountNotFound:
        case StaffAuthStatus.disabled:
          setState(() {
            _isVerifying = false;
            _error = 'This account is no longer available. Please sign out.';
            _pinController.clear();
          });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _error = 'Verification failed. Please try again.';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : AppColors.lightBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 48,
                offset: const Offset(0, 24),
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 50),
              const SizedBox(height: 16),
              Text(
                'Session locked',
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Enter your PIN to jump back into BizFlow.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: scheme.error.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: scheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: scheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              TextField(
                controller: _pinController,
                focusNode: _pinFocus,
                obscureText: true,
                maxLength: StaffAccountRepository.maxPinLength,
                autofocus: true,
                enabled: !_isVerifying,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  hintText:
                      '${StaffAccountRepository.minPinLength}-${StaffAccountRepository.maxPinLength} digits',
                  counterText: '',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
                ),
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isVerifying ? null : _signOut,
                      child: const Text('Sign out'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isVerifying ? null : _verifyPin,
                      icon: _isVerifying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.lock_open_rounded, size: 18),
                      label: Text(_isVerifying ? 'Verifying…' : 'Unlock'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
