import 'package:flutter/material.dart';

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
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.screenPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          const Text(
                            'Unable to load expenses',
                            style: AppTextStyles.heading2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.spacingSm),
                          const Text(
                            'Something went wrong while loading your expenses. '
                            'Please try again.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: AppDimensions.spacingLg),
                          FilledButton.icon(
                            onPressed: () {
                              setState(() {
                                _expensesStream = _expenseRepository
                                    .watchExpenses();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
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

                final totalExpenses = _calculateTotal(expenses);

                return ListView(
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  children: [
                    _buildSummaryCard(totalExpenses),
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

  Widget _buildSummaryCard(double totalExpenses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Expenses', style: AppTextStyles.caption),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    '$_currency ${totalExpenses.toStringAsFixed(2)}',
                    style: AppTextStyles.statValue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingSm,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          child: const Icon(Icons.receipt_long_outlined, color: Colors.red),
        ),
        title: Text(
          expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppDimensions.spacingXs),
          child: Text('${expense.category} • ${_formatDate(expense.date)}'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '-$_currency ${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            const Text('No expenses yet', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.spacingSm),
            const Text(
              'Your recorded expenses will appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
