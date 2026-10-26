path = r'C:\Users\Admin\Desktop\APss\bizflow_v1.1.0_dev\lib\core\widgets\app_shell.dart'
with open(path, 'r') as f:
    content = f.read()

# 1. Add import for session_authorization
old_import = "import '../../../core/session/session_controller.dart';"
new_import = """import '../../../core/session/session_controller.dart';
import '../../../core/session/session_authorization.dart';"""
if old_import in content:
    content = content.replace(old_import, new_import)
    print('Import added')
else:
    print('Import already added or not found')

# 2. Add role-check getters after _currentIndex field
old_field = """  int _currentIndex = 0;
  bool _sidebarCollapsed = false;"""
new_field = """  int _currentIndex = 0;
  bool _sidebarCollapsed = false;

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

  /// Navigation items visible to the current role.
  List<_NavItem> get _visibleNavItems {
    return _navItems.where((item) {
      switch (item.index) {
        case 0: // Home/Dashboard
        case 2: // POS Terminal
        case 3: // Sales
        case 4: // Customers
        case 8: // More Tools
          return true;
        case 1: // Products
        case 5: // Inventory
        case 6: // Expenses
        case 7: // Analytics/Reports
          return _canManage;
        default:
          return true;
      }
    }).toList();
  }

  /// Ensures [_currentIndex] points to a visible nav item.
  void _ensureVisibleIndex() {
    if (!_visibleNavItems.any((item) => item.index == _currentIndex)) {
      _currentIndex = _visibleNavItems.first.index;
    }
  }"""
if old_field in content:
    content = content.replace(old_field, new_field)
    print('Role getters added')
else:
    print('Role getters field not found')

# 3. Replace _navItems usage in sidebar with _visibleNavItems
old_sidebar1 = "..._navItems\n                          .where((item) => item.index == 0 ||\n                              item.index == 2 ||\n                              item.index == 1 ||\n                              item.index == 3 ||\n                              item.index == 4)\n                          .map(_buildSidebarItem),"
new_sidebar1 = "..._visibleNavItems\n                          .where((item) => item.index == 0 ||\n                              item.index == 2 ||\n                              item.index == 1 ||\n                              item.index == 3 ||\n                              item.index == 4)\n                          .map(_buildSidebarItem),"
if old_sidebar1 in content:
    content = content.replace(old_sidebar1, new_sidebar1)
    print('Sidebar 1 updated')
else:
    print('Sidebar 1 not found')

old_sidebar2 = "..._navItems\n                          .where((item) => item.index >= 5)\n                          .map(_buildSidebarItem),"
new_sidebar2 = "..._visibleNavItems\n                          .where((item) => item.index >= 5)\n                          .map(_buildSidebarItem),"
if old_sidebar2 in content:
    content = content.replace(old_sidebar2, new_sidebar2)
    print('Sidebar 2 updated')
else:
    print('Sidebar 2 not found')

with open(path, 'w') as f:
    f.write(content)

print('Done')