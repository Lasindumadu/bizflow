import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/expense_repository.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  final bool showAppBar;
  const ExpensesScreen({super.key, this.showAppBar = true});

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
      appBar:
          widget.showAppBar ? AppBar(title: const Text('Expenses')) : null,
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
                  padding: const EdgeInsets.all(16),
                  children: [
                    PageHero(
                      eyebrow: 'Costs',
                      title: 'Expenses',
                      subtitle:
                          'Know where the money goes, keep margins healthy and '
                          'stay on top of every cost.',
                      showIllustration: false,
                    ),
                    const SizedBox(height: 18),
                    _buildSummaryCard(expenses),
                    const SizedBox(height: 22),
                    SectionHeading(
                      title: 'Expense history',
                      subtitle: '${expenses.length} recorded entries',
                      icon: Icons.receipt_long_rounded,
                    ),
                    const SizedBox(height: 12),
                    ...expenses.map((expense) => _buildExpenseCard(expense)),
                    const SizedBox(height: 70),
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
    final scheme = Theme.of(context).colorScheme;

    return BrandCard(
      padding: const EdgeInsets.all(13),
      radius: 16,
      onTap: () => _openEditExpense(expense),
      child: Row(
        children: [
          BrandIconBadge(icon: icon, color: color, size: 42),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${expense.category} · ${_formatDate(expense.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '-$_currency ${expense.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: AppTextStyles.displayFont,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Expense actions',
            offset: const Offset(0, 34),
            icon: Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: scheme.onSurface.withValues(alpha: 0.38),
            ),
            onSelected: (value) {
              if (value == 'edit') _openEditExpense(expense);
              if (value == 'delete') _confirmDeleteExpense(expense);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined, size: 18),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline_rounded, size: 18),
                  title: Text('Delete'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: BrandEmptyState(
        title: 'No expenses yet',
        message:
            'Record your first expense to start tracking business costs and '
            'protecting your margins.',
        actionLabel: 'Add expense',
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
        },
        icon: Icons.receipt_long_outlined,
      ),
    );
  }
}
