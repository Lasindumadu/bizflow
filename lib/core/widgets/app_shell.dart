import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/notification_store.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/session/session_authorization.dart';
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
  bool _userCardHovered = false;

  /// Focus node for global keyboard shortcuts (Ctrl/Cmd + key).
  final FocusNode _shortcutFocusNode = FocusNode();

  /// Whether the acting session can access owner+manager features.
  bool get _canManage => canPerform(
        sessionController.current,
        {StaffRole.owner, StaffRole.manager},
      );

  /// Whether the acting session can access owner-only features.
  bool get _isOwner => canPerform(
        sessionController.current,
        {StaffRole.owner},
      );

  /// Allowed roles per nav index. Empty set means accessible to all roles.
  static const Map<int, Set<StaffRole>> _navItemRoles = {
    0: {}, // Home/Dashboard — all
    2: {}, // POS Terminal — all
    3: {}, // Sales — all
    4: {}, // Customers — all
    8: {}, // More Tools — all
    1: {StaffRole.owner, StaffRole.manager}, // Products — owner/manager
    5: {StaffRole.owner, StaffRole.manager}, // Inventory — owner/manager
    6: {StaffRole.owner, StaffRole.manager}, // Expenses — owner/manager
    7: {StaffRole.owner, StaffRole.manager}, // Analytics/Reports — owner/manager
  };

  /// Navigation items visible to the current role.
  ///
  /// Each item is gated individually via [SessionAuthorization.canPerform]
  /// rather than a coarse static role list, so cashiers never see
  /// owner/manager-only sections.
  List<_NavItem> get _visibleNavItems {
    return _navItems.where((item) {
      final allowed = _navItemRoles[item.index] ?? <StaffRole>{};
      return canPerform(sessionController.current, allowed);
    }).toList();
  }

  /// Whether a nav index is gated behind owner/manager privileges.
  bool _isNavGated(int index) {
    final allowed = _navItemRoles[index];
    return allowed != null && allowed.isNotEmpty;
  }

  /// Ensures [_currentIndex] points to a visible nav item.
  void _ensureVisibleIndex() {
    if (!_visibleNavItems.any((item) => item.index == _currentIndex)) {
      _currentIndex = _visibleNavItems.first.index;
    }
  }

  /// Soft fade + lift + depth applied whenever the active section changes.
  late final AnimationController _pageController;
  late final Animation<double> _pageOpacity;
  late final Animation<Offset> _pageOffset;
  late final Animation<double> _pageScale;

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
      duration: const Duration(milliseconds: 320),
      value: 1,
    );
    _pageOpacity = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    _pageOffset = Tween<Offset>(
      // Fractional slide ≈ 18px at typical canvas heights — a touch richer
      // than before, but still instant-feeling on tap (320ms, no delay).
      begin: const Offset(0, 0.022),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));
    _pageScale = Tween<double>(
      // Gentle depth: the incoming page breathes from 98.4% to full size.
      begin: 0.984,
      end: 1.0,
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
    _shortcutFocusNode.dispose();
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
    _ensureVisibleIndex();
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

  // ─────────────────────────────────────────────
  // Global keyboard shortcuts (Ctrl/Cmd + key)
  // ─────────────────────────────────────────────

  bool _isCtrlCmd(RawKeyEvent event) =>
      HardwareKeyboard.instance.isControlPressed ||
      HardwareKeyboard.instance.isMetaPressed;

  void _handleKeyEvent(RawKeyEvent event) {
    if (!_isCtrlCmd(event) || event is! RawKeyDownEvent) {
      return;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.keyK:
        UniversalSearchOverlay.show(context);
        break;
      case LogicalKeyboardKey.keyN:
        _openPos();
        break;
      case LogicalKeyboardKey.keyP:
        // Products (screen index 1)
        if (_visibleNavItems.any((item) => item.index == 1)) {
          _onNavigationSelected(1);
        }
        break;
      case LogicalKeyboardKey.keyU:
        // Customers (screen index 4)
        if (_visibleNavItems.any((item) => item.index == 4)) {
          _onNavigationSelected(4);
        }
        break;
      case LogicalKeyboardKey.keyS:
        // Sales (screen index 3)
        if (_visibleNavItems.any((item) => item.index == 3)) {
          _onNavigationSelected(3);
        }
        break;
      case LogicalKeyboardKey.comma:
        _openSettings();
        break;
      default:
        break;
    }
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
          child: RawKeyboardListener(
            focusNode: _shortcutFocusNode,
            autofocus: true,
            onKey: _handleKeyEvent,
            child: body,
          ),
        );
      },
    );
  }

  Widget _buildPageStack() {
    return ScaleTransition(
      scale: _pageScale,
      filterQuality: FilterQuality.low,
      child: FadeTransition(
        opacity: _pageOpacity,
        child: SlideTransition(
          position: _pageOffset,
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
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
        canManageProducts: _canManage,
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
            // Aurora 2.0 micro-detail — a faint lilac breath behind the
            // workspace group so the rail never reads as flat ink.
            Positioned(
              top: 180,
              left: -110,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.auroraLilac.withValues(alpha: 0.09),
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
                      ..._visibleNavItems
                          .where((item) => item.index == 0 ||
                              item.index == 2 ||
                              item.index == 1 ||
                              item.index == 3 ||
                              item.index == 4)
                          .map(_buildSidebarItem),
                      const SizedBox(height: 14),
                      if (!_sidebarCollapsed) const _SidebarLabel('MANAGE'),
                      ..._visibleNavItems
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
                      // Aurora 2.0 "PRO" — signature rail-gradient pill
                      // with a soft brand halo instead of flat mint.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppDecor.auroraBar,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.royalStart.withValues(
                                alpha: 0.38,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
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
      isGated: _isNavGated(item.index),
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
            canOpenStaff: _isOwner,
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
                SizedBox(
                  width: 16,
                  height: 16,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // One-shot mint pulse — a halo blooms once on entry
                      // (never loops) to signal "live" without distracting.
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1100),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, _) => Container(
                          width: 8 + 12 * t,
                          height: 8 + 12 * t,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.brandMint.withValues(
                                alpha: (1 - t) * 0.55,
                              ),
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
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
          // User footer card — hover reveals an aurora-lilac affordance:
          // border bloom, soft brand glow and a nudge chevron.
          MouseRegion(
            onEnter: (_) => setState(() => _userCardHovered = true),
            onExit: (_) => setState(() => _userCardHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(
                0,
                _userCardHovered ? -1.5 : 0,
                0,
              ),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _userCardHovered
                    ? Colors.white.withValues(alpha: 0.085)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _userCardHovered
                      ? AppColors.accentLight.withValues(alpha: 0.38)
                      : Colors.white.withValues(alpha: 0.07),
                ),
                boxShadow: _userCardHovered
                    ? AppDecor.glow(AppColors.primary, alpha: 0.22)
                    : null,
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
                            color: _userCardHovered
                                ? AppColors.auroraLilac.withValues(alpha: 0.85)
                                : Colors.white.withValues(alpha: 0.40),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    opacity: _userCardHovered ? 1 : 0.3,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.auroraLilac.withValues(alpha: 0.9),
                    ),
                  ),
                  _SessionMenuButton(
                    compact: true,
                    onLockNow: _lockNow,
                    onSignOut: _signOutNow,
                    onOpenStaff: _openStaffManagement,
                    canOpenStaff: _isOwner,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, {required bool isTablet}) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 76,
            padding: const EdgeInsets.fromLTRB(20, 10, 17, 4),
            decoration: BoxDecoration(
              // Frosted "brighter glass" — translucent white fill in both
              // themes with a white-alpha hairline and soft lift shadow.
              color: (isDark ? Colors.white : Colors.white)
                  .withValues(alpha: isDark ? 0.055 : 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.85),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.18)
                      : AppColors.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
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
                              fontFamily: AppTextStyles.bodyFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              color: scheme.onSurface.withValues(alpha: 0.36),
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
                              fontFamily: AppTextStyles.bodyFont,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: scheme.primary.withValues(alpha: 0.9),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.55,
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
                  tooltip: 'Search (⌘K)',
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
                if (_isOwner)
                  _CircleAction(
                    tooltip: 'Settings (⌘,)',
                    icon: Icons.tune_rounded,
                    onTap: _openSettings,
                  ),
                const SizedBox(width: 10),
                if (!isTablet)
                  _QuickPosButton(onTap: _openPos)
                else
                  _CircleAction(
                    tooltip: 'New Sale (⌘N)',
                    icon: Icons.bolt_rounded,
                    iconColor: Colors.white,
                    background: AppDecor.royalGradient,
                    onTap: _openPos,
                  ),
              ],
            ),
          ),
        ),
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
  final bool isGated;

  const _SidebarNavItem({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
    this.isGated = false,
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

    // Aurora 2.0 active pill: soft royal-gradient fill over the ink rail,
    // a signature aurora notch bar on the left edge and a brand glow.
    final content = Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          padding: EdgeInsets.symmetric(
            horizontal: widget.collapsed ? 0 : (selected ? 18 : 14),
            vertical: 10.5,
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: AppDecor.royalGradient.colors
                        .map((c) => c.withValues(alpha: 0.24))
                        .toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: selected
                ? Colors.white.withValues(alpha: 0.07)
                : (!selected && _hovered)
                    ? Colors.white.withValues(alpha: 0.055)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: selected
                ? Border.all(color: Colors.white.withValues(alpha: 0.16))
                : null,
            boxShadow: selected
                ? AppDecor.glow(AppColors.primary, alpha: 0.30)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              letterSpacing: 0.05,
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.74),
                            ),
                          ),
                          if (widget.isGated && !selected)
                            const SizedBox(height: 2),
                          if (widget.isGated && !selected)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 10,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'owner/manager',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    if (selected)
                      Container(
                        width: 5.5,
                        height: 5.5,
                        decoration: BoxDecoration(
                          color: AppColors.auroraTeal,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.auroraTeal.withValues(alpha: 0.8),
                              blurRadius: 7,
                            ),
                          ],
                        ),
                      )
                    else if (item.isProminent)
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 13,
                        color: Colors.white.withValues(
                          alpha: _hovered ? 0.55 : 0.30,
                        ),
                      ),
                  ],
                ),
        ),
        // Signature aurora notch — the "active rail" tick on the pill's
        // left edge, glowing mint→royal like the brand bar.
        if (selected)
          Positioned(
            left: 0,
            top: 8,
            bottom: 8,
            child: Container(
              width: 3.2,
              decoration: BoxDecoration(
                gradient: AppDecor.auroraBar,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.auroraTeal.withValues(alpha: 0.55),
                    blurRadius: 8,
                    spreadRadius: -1,
                  ),
                ],
              ),
            ),
          ),
      ],
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
        hoverColor: AppColors.primary.withValues(alpha: 0.10),
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
          hoverColor: AppColors.primary.withValues(alpha: 0.10),
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

class _QuickPosButton extends StatefulWidget {
  final VoidCallback onTap;
  const _QuickPosButton({required this.onTap});

  @override
  State<_QuickPosButton> createState() => _QuickPosButtonState();
}

class _QuickPosButtonState extends State<_QuickPosButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      scale: _pressed ? 0.97 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          borderRadius: BorderRadius.circular(13),
          hoverColor: AppColors.primary.withValues(alpha: 0.10),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: AppDecor.royalGradient,
              borderRadius: BorderRadius.circular(13),
              boxShadow: AppDecor.glow(AppColors.primary, alpha: 0.42),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.white, size: 17),
                SizedBox(width: 7),
                Text(
                  'New sale',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
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
              tooltip: 'Search (⌘K)',
              icon: Icons.search_rounded,
              onTap: onSearch,
            ),
            const SizedBox(width: 6),
            _NotificationBell(onTap: onNotifications),
            const SizedBox(width: 6),
            _CircleAction(
              tooltip: 'Settings (⌘,)',
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
  final bool canManageProducts;

  const _MobileDock({
    required this.currentIndex,
    required this.onSelected,
    required this.canManageProducts,
  });

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
              if (canManageProducts)
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
                    gradient: AppDecor.royalGradient,
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

    // Aurora accent for the active item — royal tint + a tiny live dot.
    final activeColor = AppColors.royalMid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: AppColors.primary.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? activeColor.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tiny aurora dot — sits above the active item and springs
              // in with an elastic settle.
              AnimatedContainer(
                duration: const Duration(milliseconds: 290),
                curve:
                    selected ? Curves.elasticOut : Curves.easeOutCubic,
                height: 5,
                width: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.auroraTeal : Colors.transparent,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.auroraTeal.withValues(alpha: 0.7),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 3),
              // Springy active scale — the icon gently overshoots to 1.15
              // and settles. One short tween, never blocks the tap.
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1, end: selected ? 1.15 : 1),
                duration: const Duration(milliseconds: 320),
                curve: selected ? Curves.elasticOut : Curves.easeOut,
                child: Icon(
                  selected ? activeIcon : icon,
                  size: 21,
                  color: selected
                      ? activeColor
                      : scheme.onSurface.withValues(alpha: 0.45),
                ),
                builder: (context, s, child) =>
                    Transform.scale(scale: s, child: child),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected
                      ? activeColor
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
              hoverColor: AppColors.primary.withValues(alpha: 0.10),
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
  final bool canOpenStaff;
  final bool compact;

  const _SessionMenuButton({
    required this.onLockNow,
    required this.onSignOut,
    required this.onOpenStaff,
    required this.canOpenStaff,
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
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[
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
          if (canOpenStaff)
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
        ];
        return items;
      },
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
          width: 380,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Photo-backed brand chrome: purpleAbstract under a dense
                // brand wash (anchor left) so the headline always sits on
                // readable ink in both themes.
                SizedBox(
                  width: double.infinity,
                  height: 168,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AppImages.purpleAbstract,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                      ),
                      for (final g in AppDecor.photoWash(anchor: 'left'))
                        DecoratedBox(
                          decoration: BoxDecoration(gradient: g),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BrandMark(size: 46),
                            const Spacer(),
                            Text(
                              'Session locked',
                              style: TextStyle(
                                fontFamily: AppTextStyles.displayFont,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: AppColors.onPhoto,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Enter your PIN to jump back into BizFlow.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: AppColors.onPhotoMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_error != null)
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
                      const SizedBox(height: 14),
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
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              size: 19),
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
                                      child: AuroraLoader(
                                        size: 16,
                                        strokeWidth: 2,
                                        onDarkSurface: true,
                                      ),
                                    )
                                  : const Icon(Icons.lock_open_rounded,
                                      size: 18),
                              label: Text(_isVerifying ? 'Verifying…' : 'Unlock'),
                            ),
                          ),
                        ],
                      ),
                    ],
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
