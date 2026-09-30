import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../customers/presentation/screens/customers_screen.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart';
import '../../../expenses/presentation/screens/expenses_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        children: [
          const Text('Management', style: AppTextStyles.heading2),

          const SizedBox(height: AppDimensions.spacingMd),

          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Customers'),
              subtitle: const Text('Manage customer records and information'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CustomersScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Inventory'),
              subtitle: const Text('Manage stock levels and stock movements'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InventoryScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Expenses'),
              subtitle: const Text('Track and manage business expenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ExpensesScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Reports'),
              subtitle: const Text(
                'View sales, profit, expenses and stock reports',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReportsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              subtitle: const Text('Configure BizFlow and manage backups'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
