import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/session/session_authorization.dart';
import '../../../../core/session/session_controller.dart';
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

  /// Presentation-only selected history filter (a category name or null
  /// for "All"). Never touches the underlying stream or repository.
  String? _filterCategory;

  /// Whether the acting session can record or delete expenses (owner or manager).
  bool get _canManageExpenses => canPerform(sessionController.current, {
    StaffRole.owner,
    StaffRole.manager,
  });

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

  String _monthShort(DateTime date) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[date.month - 1];
  }

  String _monthLabel(DateTime date) =>
      '${_monthShort(date)} ${date.year.toString().substring(2)}';

  List<Expense> _expensesIn(List<Expense> expenses, int year, int month) {
    return expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
  }

  /// Most expensive category across all entries.
  (String, double, int)? _biggestCategory(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    final byCategory = <String, List<Expense>>{};
    for (final e in expenses) {
      byCategory.putIfAbsent(e.category, () => []).add(e);
    }
    String? best;
    var bestTotal = -1.0;
    byCategory.forEach((name, list) {
      final total = _calculateTotal(list);
      if (total > bestTotal) {
        bestTotal = total;
        best = name;
      }
    });
    final chosen = byCategory[best!]!;
    return (best!, _calculateTotal(chosen), chosen.length);
  }

  /// Last 6 calendar months (oldest first) with spend totals.
  List<({String label, double total, bool current})> _monthlyTotals(
    List<Expense> expenses, {
    int months = 6,
  }) {
    final now = DateTime.now();
    final result = <({String label, double total, bool current})>[];
    for (var i = months - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i);
      result.add((
        label: _monthLabel(d),
        total: _calculateTotal(_expensesIn(expenses, d.year, d.month)),
        current: i == 0,
      ));
    }
    return result;
  }

  Future<void> _openEditExpense(Expense expense) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  Future<void> _openAddExpense() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
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
      appBar: widget.showAppBar ? AppBar(title: const Text('Expenses')) : null,
      body: _isLoadingSettings
          ? const Center(child: AuroraLoader(size: 46))
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
                        AuroraLoader(size: 44),
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

                final visible = _filterCategory == null
                    ? expenses
                    : expenses
                          .where((e) => e.category == _filterCategory)
                          .toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  children: [
                    PageHero(
                          eyebrow: 'Money out · ${_monthShort(DateTime.now())}',
                          title: 'Expenses',
                          subtitle:
                              'Know where the money goes, keep margins healthy and '
                              'stay on top of every cost.',
                          image: AppImages.accounting,
                          showIllustration: false,
                          secondaryAction: _MonthDeltaChip(
                            expenses: expenses,
                            monthKey: (
                              year: DateTime.now().year,
                              month: DateTime.now().month,
                            ),
                          ),
                          action: _canManageExpenses
                              ? _HeroCta(
                                  label: 'Add expense',
                                  icon: Icons.add_rounded,
                                  onTap: _openAddExpense,
                                )
                              : null,
                        )
                        .animate()
                        .fadeIn(duration: 420.ms, curve: Curves.easeOutCubic)
                        .slideY(
                          begin: 0.04,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 18),
                    _buildKpiRow(expenses),
                    const SizedBox(height: 16),
                    _buildMonthlyBars(expenses),
                    const SizedBox(height: 22),
                    SectionHeading(
                      title: 'Expense history',
                      subtitle:
                          '${visible.length} recorded '
                          '${visible.length == 1 ? 'entry' : 'entries'}',
                      icon: Icons.receipt_long_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildFilterChips(expenses),
                    if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'No expenses in “$_filterCategory”.',
                          style: AppTextStyles.bodySecondary,
                        ),
                      )
                    else
                      ...List.generate(
                        visible.length,
                        (i) => _buildExpenseCard(visible[i], i),
                      ),
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
    );
  }

  // ─────────────────────────────────────────────
  // KPI row
  // ─────────────────────────────────────────────

  Widget _buildKpiRow(List<Expense> expenses) {
    final now = DateTime.now();
    final total = _calculateTotal(expenses);
    final monthTotal = _calculateTotal(
      _expensesIn(expenses, now.year, now.month),
    );
    final biggest = _biggestCategory(expenses);

    final cards = <Widget>[
      _KpiCard(
        index: 0,
        label: 'SPENT THIS MONTH',
        value: monthTotal,
        currency: _currency,
        icon: Icons.trending_down_rounded,
        gradient: const [AppColors.tertiaryLight, AppColors.tertiaryDark],
        helper: 'Total tracked: $_currency ${total.toStringAsFixed(2)}',
      ),
      if (biggest != null)
        _KpiCard(
          index: 1,
          label: 'BIGGEST CATEGORY',
          value: biggest.$2,
          currency: _currency,
          icon: _expenseStyle(biggest.$1).$1,
          gradient: AppDecor.toneGradient(
            biggest.$1.toLowerCase().hashCode.abs(),
          ).colors,
          helper:
              '${biggest.$1} · ${biggest.$3} '
              '${biggest.$3 == 1 ? 'entry' : 'entries'}',
        ),
      _KpiCard(
        index: 2,
        label: 'AVG. PER ENTRY',
        value: expenses.isEmpty ? 0 : total / expenses.length,
        currency: _currency,
        icon: Icons.south_west_rounded,
        gradient: AppDecor.moneyGradientLight.colors,
        helper: 'Money-out pace per entry',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 680;
        final children = cards.map((c) {
          if (wide) return Expanded(child: c);
          return SizedBox(width: double.infinity, child: c);
        }).toList();

        if (wide) {
          final arranged = <Widget>[];
          for (var i = 0; i < children.length; i++) {
            arranged.add(children[i]);
            if (i != children.length - 1) {
              arranged.add(const SizedBox(width: 14));
            }
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: arranged,
          );
        }

        final stacked = <Widget>[];
        for (var i = 0; i < children.length; i++) {
          stacked.add(children[i]);
          if (i != children.length - 1) stacked.add(const SizedBox(height: 12));
        }
        return Column(children: stacked);
      },
    );
  }

  // ─────────────────────────────────────────────
  // Monthly totals bar
  // ─────────────────────────────────────────────

  Widget _buildMonthlyBars(List<Expense> expenses) {
    final months = _monthlyTotals(expenses);
    final maxTotal = months
        .map((m) => m.total)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final grandTotal = months
        .map((m) => m.total)
        .fold<double>(0, (a, b) => a + b);

    return BrandCard(
          padding: const EdgeInsets.all(18),
          radius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppDecor.royalGradient,
                      boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.24),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly totals',
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Last ${months.length} months',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandMintDeep.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.16
                            : 0.10,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$_currency ${grandTotal.toStringAsFixed(0)} total',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.brandMint
                            : AppColors.brandMintDeep,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...months.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                final pct = maxTotal <= 0
                    ? (m.total > 0 ? 1.0 : 0.0)
                    : m.total / maxTotal;

                return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 42,
                            child: Text(
                              m.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: m.current
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface
                                    .withValues(alpha: m.current ? 0.8 : 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                height: 9,
                                color: Theme.of(context).colorScheme.onSurface
                                    .withValues(alpha: 0.08),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: pct.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: AppDecor.auroraBar,
                                      boxShadow: m.current && m.total > 0
                                          ? AppDecor.glow(
                                              AppColors.auroraTeal,
                                              alpha: 0.38,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 74,
                            child: Text(
                              '$_currency ${m.total.toStringAsFixed(0)}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontFamily: AppTextStyles.displayFont,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: (60 * i).ms)
                    .fadeIn(duration: 350.ms, curve: Curves.easeOutCubic)
                    .moveY(begin: 10, end: 0, curve: Curves.easeOutCubic);
              }),
            ],
          ),
        )
        .animate(delay: 120.ms)
        .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic);
  }

  // ─────────────────────────────────────────────
  // Filter chips
  // ─────────────────────────────────────────────

  Widget _buildFilterChips(List<Expense> expenses) {
    final categories = <String>{};
    for (final e in expenses) {
      categories.add(e.category);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: _filterCategory == null,
            onTap: () => setState(() => _filterCategory = null),
          ),
          ...categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterChip(
                label: c,
                selected: _filterCategory == c,
                onTap: () => setState(
                  () => _filterCategory = _filterCategory == c ? null : c,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Expense rows
  // ─────────────────────────────────────────────

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

  Widget _buildExpenseCard(Expense expense, int index) {
    final icon = _expenseStyle(expense.category).$1;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = AppDecor.toneGradient(
      expense.category.toLowerCase().hashCode.abs(),
    );

    final card = BrandCard(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      radius: 18,
      onTap: () => _openEditExpense(expense),
      child: Row(
        children: [
          // Gradient category squircle with matching glow.
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: AppDecor.glow(gradient.colors.first, alpha: 0.24),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: gradient.colors.last,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        expense.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Tabular money-out amount — amber in honour of growth tint.
              Text(
                '-$_currency ${expense.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isDark
                      ? AppColors.brandAmber
                      : const Color(0xFF9A6400),
                ),
              ),
              const SizedBox(height: 4),
              _DateChip(date: expense.date),
            ],
          ),
          const SizedBox(width: 2),
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
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined, size: 18),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (_canManageExpenses)
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline_rounded, size: 18),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ];
              return items;
            },
          ),
        ],
      ),
    );

    // Stagger is limited to the first screenful, per the motion guide.
    if (index >= 12) return card;

    return card
        .animate(delay: (120 + 60 * index).ms)
        .fadeIn(duration: 360.ms, curve: Curves.easeOutCubic)
        .moveY(begin: 12, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: BrandEmptyState(
        title: 'No expenses yet',
        message:
            'Record your first expense to start tracking business costs and '
            'protecting your margins.',
        actionLabel: 'Add expense',
        onAction: _canManageExpenses ? _openAddExpense : null,
        icon: Icons.receipt_long_outlined,
        image: AppImages.accounting,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Local presentation widgets
// ─────────────────────────────────────────────

/// Gradient primary CTA shown on the photo hero.
class _HeroCta extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _HeroCta({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_HeroCta> createState() => _HeroCtaState();
}

class _HeroCtaState extends State<_HeroCta> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: AppDecor.royalGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: AppDecor.glow(AppColors.royalMid, alpha: 0.34),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: Colors.white),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Month-spend delta chip vs last calendar month, styled for the photo wash.
class _MonthDeltaChip extends StatelessWidget {
  final List<Expense> expenses;
  final ({int year, int month}) monthKey;

  const _MonthDeltaChip({required this.expenses, required this.monthKey});

  double _sumIn(List<Expense> list, int year, int month) {
    return list
        .where((e) => e.date.year == year && e.date.month == month)
        .fold<double>(0, (a, e) => a + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final total = _sumIn(expenses, monthKey.year, monthKey.month);
    final prev = monthKey.month == 1
        ? _sumIn(expenses, monthKey.year - 1, 12)
        : _sumIn(expenses, monthKey.year, monthKey.month - 1);

    final String label;
    final Color accent;
    if (total <= 0) {
      label = 'No spend this month yet';
      accent = const Color(0xFFC4B5FD);
    } else if (prev <= 0) {
      label = 'First spend of the month';
      accent = const Color(0xFF5EEAD4);
    } else {
      final pct = ((total - prev) / prev * 100).abs();
      final up = total >= prev;
      label = '${up ? '+' : '-'}${pct.toStringAsFixed(0)}% vs last month';
      // For money-out, spending more is attention (amber), less is good (mint).
      accent = up ? const Color(0xFFFBBF24) : const Color(0xFF5EEAD4);
    }

    final icon = total <= 0 || prev <= 0
        ? Icons.trending_flat_rounded
        : (total >= prev
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aurora KPI tile: tinted squircle, uppercase label and counting hero number.
class _KpiCard extends StatelessWidget {
  final int index;
  final String label;
  final double value;
  final String currency;
  final IconData icon;
  final List<Color> gradient;
  final String helper;

  const _KpiCard({
    required this.index,
    required this.label,
    required this.value,
    required this.currency,
    required this.icon,
    required this.gradient,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BrandCard(
          padding: const EdgeInsets.all(16),
          radius: 22,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: AppDecor.glow(gradient.first, alpha: 0.26),
                    ),
                    child: Icon(icon, color: Colors.white, size: 19),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTextStyles.kpiLabel.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: CountUpText(
                  value,
                  prefix: '$currency ',
                  style: AppTextStyles.numericMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                helper,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        )
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
        .moveY(begin: 14, end: 0, curve: Curves.easeOutCubic);
  }
}

/// Compact royal tab chip. Selected = soft royal fill + aurora notch tick,
/// mirroring the shell sidebar active treatment.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: AppDecor.royalGradient.colors
                          .map((c) => c.withValues(alpha: 0.22))
                          .toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: selected
                  ? (isDark ? Colors.white.withValues(alpha: 0.06) : null)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.white),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? (isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : const Color(0xFFC9C2F7))
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE3E0F5)),
              ),
              boxShadow: selected
                  ? AppDecor.glow(AppColors.primary, alpha: 0.26)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? (isDark
                              ? AppColors.auroraLilac
                              : AppColors.primaryDark)
                        : Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.6),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 7),
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
                  ),
                ],
              ],
            ),
          ),
          // Aurora notch tick on the left edge of the selected chip.
          if (selected)
            Positioned(
              left: 0,
              top: 7,
              bottom: 7,
              child: Container(
                width: 2.6,
                decoration: BoxDecoration(
                  gradient: AppDecor.auroraBar,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Date pill shown under each row's amount.
class _DateChip extends StatelessWidget {
  final DateTime date;

  const _DateChip({required this.date});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 9,
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Text(
            '$day/$month',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
