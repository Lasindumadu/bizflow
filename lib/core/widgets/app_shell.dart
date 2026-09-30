import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/sales/presentation/screens/sales_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final GlobalKey<DashboardScreenState> _dashboardScreenKey =
      GlobalKey<DashboardScreenState>();

  final GlobalKey<ProductsScreenState> _productsScreenKey =
      GlobalKey<ProductsScreenState>();

  final GlobalKey<PosScreenState> _posScreenKey = GlobalKey<PosScreenState>();

  final GlobalKey<SalesScreenState> _salesScreenKey =
      GlobalKey<SalesScreenState>();

  late final List<Widget> _screens = [
    DashboardScreen(
      key: _dashboardScreenKey,
      onOpenSettings: _openSettings,
      onOpenPos: _openPos,
    ),
    ProductsScreen(key: _productsScreenKey),
    PosScreen(key: _posScreenKey),
    SalesScreen(key: _salesScreenKey),
    const MoreScreen(),
  ];

  void _onNavigationSelected(int index) {
    if (index == 0) {
      _dashboardScreenKey.currentState?.refreshBusinessSettings();
    }

    if (index == 1) {
      _productsScreenKey.currentState?.refreshBusinessSettings();
    }

    if (index == 2) {
      _posScreenKey.currentState?.refreshBusinessSettings();
    }

    if (index == 3) {
      _salesScreenKey.currentState?.refreshBusinessSettings();
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _openPos() {
    _onNavigationSelected(2);
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        if (isMobile) {
          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: _screens),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onNavigationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: 'Products',
                ),
                NavigationDestination(
                  icon: Icon(Icons.point_of_sale_outlined),
                  selectedIcon: Icon(Icons.point_of_sale),
                  label: 'POS',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Sales',
                ),
                NavigationDestination(
                  icon: Icon(Icons.more_horiz),
                  selectedIcon: Icon(Icons.more_horiz),
                  label: 'More',
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onNavigationSelected,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: Text('Products'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.point_of_sale_outlined),
                    selectedIcon: Icon(Icons.point_of_sale),
                    label: Text('POS'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: Text('Sales'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.more_horiz),
                    selectedIcon: Icon(Icons.more_horiz),
                    label: Text('More'),
                  ),
                ],
              ),

              const VerticalDivider(width: 1),

              Expanded(
                child: IndexedStack(index: _currentIndex, children: _screens),
              ),
            ],
          ),
        );
      },
    );
  }
}
