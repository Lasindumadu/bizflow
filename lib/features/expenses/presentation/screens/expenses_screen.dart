import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/expense_repository.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => ExpensesScreenState();
}

class ExpensesScreenState extends State<ExpensesScreen> {
  final ExpenseRepository _expenseRepository = ExpenseRepository(appDatabase);

  final BusinessSettingsRepository _businessSettingsRepository =
      BusinessSettingsRepository();

  late final Stream<List<Expense>> _expensesStream;

  String _currency = 'USD';
  bool _isLoadingSettings = true;

  @override
  void initState() {
    super.initState();

    _expensesStream = _expenseRepository.watchExpenses();
    _loadBusinessSettings();
  }

  Future<void> refreshBusinessSettings() async {
    await _loadBusinessSettings();
  }

  Future<void> _loadBusinessSettings() async {
    final settings = await _businessSettingsRepository.getSettings();

    if (!mounted) {
      return;
    }

    setState(() {
      _currency = settings.currency;
      _isLoadingSettings = false;
    });
  }

  double _calculateTotal(List<Expense> expenses) {
    return expenses.fold<double>(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  Future<void> _openEditExpense(Expense expense) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  Future<void> _confirmDeleteExpense(Expense expense) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: Text(
            'Are you sure you want to permanently delete '
            '"${expense.title}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await _expenseRepository.deleteExpense(expense.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete expense: $error')),
      );
    }
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text(
              'Unable to load expenses',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Something went wrong while loading your expenses.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _expensesStream = _expenseRepository.watchExpenses();
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: _isLoadingSettings
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Expense>>(
              stream: _expensesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppDimensions.spacingMd),
                        Text(
                          'Loading expenses...',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  );
                }

                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView(
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  children: [
                    _buildSummaryCard(expenses),
                    const SizedBox(height: AppDimensions.spacingXl),
                    const Text(
                      'Expense History',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    ...expenses.map((expense) => _buildExpenseCard(expense)),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildSummaryCard(List<Expense> expenses) {
    final total = _calculateTotal(expenses);
    final now = DateTime.now();

    final monthExpenses = expenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).toList();

    final monthTotal = _calculateTotal(monthExpenses);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppDecor.indigoGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                'Total Expenses',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$_currency ${total.toStringAsFixed(2)}',
            style: AppTextStyles.priceLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _summaryMiniStat(
                'This month',
                '$_currency ${monthTotal.toStringAsFixed(2)}',
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              _summaryMiniStat('Entries', '${expenses.length}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMiniStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  (IconData, Color) _expenseStyle(String category) {
    final c = category.toLowerCase();

    if (c.contains('rent')) {
      return (Icons.home_outlined, AppColors.accent);
    }
    if (c.contains('util') ||
        c.contains('electric') ||
        c.contains('internet')) {
      return (Icons.bolt_outlined, AppColors.tertiary);
    }
    if (c.contains('sal') || c.contains('wage')) {
      return (Icons.badge_outlined, AppColors.secondaryDark);
    }
    if (c.contains('transport') || c.contains('fuel')) {
      return (Icons.local_shipping_outlined, AppColors.info);
    }
    if (c.contains('inventory') || c.contains('stock') || c.contains('suppl')) {
      return (Icons.inventory_2_outlined, AppColors.primaryDark);
    }
    if (c.contains('market') || c.contains('ads')) {
      return (Icons.campaign_outlined, AppColors.error);
    }
    return (Icons.receipt_long_outlined, AppColors.lightTextTertiary);
  }

  Widget _buildExpenseCard(Expense expense) {
    final (icon, color) = _expenseStyle(expense.category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.lightBorder,
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingSm,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
          child: Text(
            '${expense.category} • ${_formatDate(expense.date)}',
            style: AppTextStyles.caption,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '-$_currency ${expense.amount.toStringAsFixed(2)}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _openEditExpense(expense);
                } else if (value == 'delete') {
                  _confirmDeleteExpense(expense);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          _openEditExpense(expense);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text(
              'No expenses yet',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            const Text(
              'Record your first expense to start tracking business costs.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
