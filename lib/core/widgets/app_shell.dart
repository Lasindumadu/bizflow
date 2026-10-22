import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/session/session_controller.dart';
import '../../../core/services/notification_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decor.dart';
import '../../../core/theme/app_dimensions.dart';
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

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
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

  // ─────────────────────────────────────────────
  // Phase F: session locking & inactivity auto-lock
  // ─────────────────────────────────────────────

  /// The pending inactivity auto-lock. One-shot: it fires once and locks the
  /// session. It is restarted on activity, not on every session notification.
  Timer? _inactivityTimer;

  /// The configured auto-lock timeout, in minutes. `0` disables auto-lock.
  int _inactivityTimeoutMinutes = 0;

  /// True while the lock dialog is on screen.
  bool _isShowingLockScreen = false;

  /// True while a POS cart is parked and awaiting restoration. Guards the
  /// park/restore pair so a cart can never be restored twice (which would
  /// silently duplicate the customer's items).
  bool _hasParkedCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionController.addListener(_onSessionChanged);
    unawaited(_loadInactivityTimeout());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    sessionController.removeListener(_onSessionChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The clock keeps running while the app is backgrounded, so a timeout
      // that elapsed in the background must lock as soon as the app returns.
      _evaluateInactivity();
      return;
    }
  }

  /// Loads the persisted auto-lock timeout and (re)arms the timer.
  ///
  /// The timeout is read once per session change; it is NOT re-read on every
  /// activity event, which would issue a database query per user interaction.
  Future<void> _loadInactivityTimeout() async {
    final settings = await BusinessSettingsRepository().getSettings();
    if (!mounted) return;
    _inactivityTimeoutMinutes = settings.inactivityTimeoutMinutes;
    _armInactivityTimer();
  }

  /// Arms the one-shot inactivity timer for the configured timeout.
  ///
  /// Does nothing when auto-lock is disabled (`0`) or when there is no
  /// authenticated session — a signed-out session has nothing to lock.
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

  /// Locks the session when the inactivity timeout has already elapsed.
  ///
  /// Used when the app returns from the background: the Dart timer may not
  /// have fired while suspended, so the elapsed wall-clock time is compared
  /// against the configured timeout directly.
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

  /// Called whenever the session changes (sign in, sign out, lock, unlock).
  ///
  /// Deliberately NOT called for ordinary activity: [resetActivity] uses
  /// [SessionController.resetActivitySilently] for high-frequency events so
  /// this listener is not invoked on every tap (which would rebuild the shell
  /// and re-read the settings on each interaction).
  void _onSessionChanged() {
    if (!mounted) return;

    // Signed out: preserve any active POS cart, then stop the timer.
    if (sessionController.current == null) {
      _preservePosCart();
      _cancelInactivityTimer();
      setState(() {
        _isShowingLockScreen = false;
      });
      return;
    }

    // Locked: preserve any active POS cart, show the lock screen.
    if (sessionController.isLocked) {
      _preservePosCart();
      _cancelInactivityTimer();
      _showLockScreen();
      return;
    }

    // Unlocked and authenticated: restore the parked cart (exactly once) and
    // re-arm the timer.
    _restorePosCart();
    _armInactivityTimer();
    setState(() {
      _isShowingLockScreen = false;
    });
  }

  /// Records user activity, resetting the inactivity clock.
  ///
  /// Called from a gesture detector wrapped around the shell body. The
  /// activity timestamp is updated without notifying listeners (the shell
  /// does not need to rebuild for a timestamp change); the timer is restarted
  /// here instead. This keeps the interaction cheap: no `setState`, no
  /// settings query, no cart restore.
  void _resetInactivity() {
    if (!mounted) return;
    if (!sessionController.isAuthenticated) return;
    if (sessionController.isLocked) return;

    sessionController.resetActivitySilently();
    _armInactivityTimer();
  }

  /// Parks the current POS cart (if any) so it survives a lock/sign-out.
  ///
  /// Parks at most once per lock/sign-out boundary: the cart is emptied by
  /// parking, so a second call is a no-op anyway, but the explicit guard
  /// makes the "exactly once" contract obvious and testable.
  void _preservePosCart() {
    if (_hasParkedCart) return;
    final posState = _posScreenKey.currentState;
    if (posState == null) return;
    if (posState.parkActiveCart()) {
      _hasParkedCart = true;
    }
  }

  /// Restores the parked POS cart (if any) after a lock.
  ///
  /// Restores at most once: the parked sale is removed from the store when it
  /// is recalled, so a repeated call could not duplicate it — but the explicit
  /// guard prevents the shell from recalling a *different* parked sale on a
  /// second unlock.
  void _restorePosCart() {
    if (!_hasParkedCart) return;
    _hasParkedCart = false;
    final posState = _posScreenKey.currentState;
    if (posState == null) return;
    posState.restoreLastParkedCart();
  }

  /// Shows a modal lock screen requiring PIN re-entry to unlock the session.
  ///
  /// The dialog is not dismissible (no barrier tap, no back button) — the
  /// only ways out are a successful PIN re-entry or an explicit sign-out.
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
            // The dialog closes itself; the session listener below restores
            // the parked cart and re-arms the timer.
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
      // The dialog can only be dismissed by unlocking or signing out, but
      // guard anyway: a session that is still locked must show the dialog
      // again rather than leaving an unauthenticated terminal unlocked.
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
      'Sales & Invoices',
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  /// Phase F: opens the staff management screen (owner-only actions are
  /// enforced in the repository, not in the UI).
  void _openStaffManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const StaffManagementScreen()),
    );
  }

  /// Phase F: locks the session immediately, exactly as the inactivity
  /// timeout would. The user must re-enter their PIN to resume.
  void _lockNow() {
    if (!sessionController.isAuthenticated) return;
    sessionController.lock();
  }

  /// Phase F: signs out of the current session. The startup gate returns to
  /// the login screen when login is required.
  void _signOutNow() {
    if (!sessionController.isAuthenticated) return;
    sessionController.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isPhone = width < 680;
        final isTablet = width >= 680 && width < 1100;

        final body = isPhone
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context, isTablet: isTablet);

        // Phase F: wrap the shell body with a gesture detector so any user
        // interaction resets the inactivity auto-lock clock.
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _resetInactivity,
          child: body,
        );
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
                _buildMobileNavItem(
                  0,
                  Icons.home_outlined,
                  Icons.home_rounded,
                  'Home',
                ),
                _buildMobileNavItem(
                  1,
                  Icons.inventory_2_outlined,
                  Icons.inventory_2_rounded,
                  'Products',
                ),
                _buildMobilePosCenterButton(),
                _buildMobileNavItem(
                  3,
                  Icons.receipt_long_outlined,
                  Icons.receipt_long_rounded,
                  'Sales',
                ),
                _buildMobileNavItem(
                  8,
                  Icons.grid_view_outlined,
                  Icons.grid_view_rounded,
                  'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(
    int index,
    IconData outline,
    IconData filled,
    String label,
  ) {
    final sel = _currentIndex == index;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _onNavigationSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel
              ? scheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sel ? filled : outline,
              size: 22,
              color: sel
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                color: sel
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.6),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                  child: IndexedStack(index: _currentIndex, children: _screens),
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
                  tooltip: _sidebarCollapsed
                      ? 'Expand Sidebar'
                      : 'Collapse Sidebar',
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
                      _navItems
                          .firstWhere((it) => it.index == _currentIndex)
                          .label,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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

          // Phase F: session controls (lock now, sign out, staff accounts).
          if (sessionController.isAuthenticated) ...[
            _SessionMenuButton(
              onLockNow: _lockNow,
              onSignOut: _signOutNow,
              onOpenStaff: _openStaffManagement,
            ),
            const SizedBox(width: 8),
          ],

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
        mainAxisAlignment: _sidebarCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
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
                            border: Border.all(
                              color: scheme.surface,
                              width: 1.5,
                            ),
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

/// Phase F: session controls menu (lock now, staff accounts, sign out).
class _SessionMenuButton extends StatelessWidget {
  final VoidCallback onLockNow;
  final VoidCallback onSignOut;
  final VoidCallback onOpenStaff;

  const _SessionMenuButton({
    required this.onLockNow,
    required this.onSignOut,
    required this.onOpenStaff,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final current = sessionController.current;

    return Container(
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
      child: PopupMenuButton<String>(
        tooltip: 'Session',
        icon: Icon(
          Icons.account_circle_outlined,
          size: 20,
          color: scheme.onSurface.withValues(alpha: 0.75),
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
                  ? 'Signed out'
                  : '${current.displayName.isEmpty ? current.username : current.displayName}'
                        ' (${current.role.name})',
              style: AppTextStyles.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
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
      ),
    );
  }
}

/// Phase F: modal dialog shown when the session is locked by inactivity or
/// an explicit lock. Requires PIN re-entry to unlock, or offers sign-out.
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
    // The PIN field is the only way out of the lock, so it takes focus as
    // soon as the dialog appears.
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

  /// Signs the user out of the locked session and closes the dialog.
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
          // Close the dialog first so the shell is not left with a dialog
          // over an already-unlocked session.
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
            _error = 'Account is temporarily locked. Please sign out and contact the owner.';
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

    // The lock screen must not be dismissible: not by the barrier, not by
    // the system back button, and not by the predictive-back gesture. The
    // only ways out are a successful PIN re-entry or an explicit sign-out.
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : AppColors.lightBorder,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                'Session Locked',
                style: AppTextStyles.titleLarge.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Please enter your PIN to resume your session.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppDimensions.spacingXs),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingXs),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.spacingXl),
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
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.7),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: BorderSide(
                      color: AppColors.primaryDark.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: const BorderSide(
                      color: AppColors.primaryDark,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (_) => _verifyPin(),
              ),
              const SizedBox(height: AppDimensions.spacingXl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isVerifying ? null : _signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.onSurfaceVariant,
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isVerifying ? null : _verifyPin,
                      icon: _isVerifying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.lock_open_rounded, size: 20),
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
