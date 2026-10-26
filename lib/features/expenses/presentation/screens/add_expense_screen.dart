import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/expense_repository.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  bool get isEditing => expense != null;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final ExpenseRepository _expenseRepository = ExpenseRepository(appDatabase);

  late DateTime _selectedDate;

  bool _isSaving = false;

  static const _categorySuggestions = [
    'Rent',
    'Utilities',
    'Transport',
    'Supplies',
    'Salaries',
    'Marketing',
    'Maintenance',
  ];

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    _selectedDate = expense?.date ?? DateTime.now();

    if (expense != null) {
      _titleController.text = expense.title;
      _categoryController.text = expense.category;
      _amountController.text = expense.amount.toStringAsFixed(2);
      _noteController.text = expense.note;
    }

    _amountController.addListener(_refreshPreview);
    _categoryController.addListener(_refreshPreview);
  }

  void _refreshPreview() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_refreshPreview);
    _categoryController.removeListener(_refreshPreview);
    _titleController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
    });
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.isEditing) {
        await _expenseRepository.updateExpense(
          id: widget.expense!.id,
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          amount: amount,
          date: _selectedDate,
          note: _noteController.text.trim(),
        );
      } else {
        final expenseId = DateTime.now().microsecondsSinceEpoch.toString();

        await _expenseRepository.addExpense(
          id: expenseId,
          title: _titleController.text.trim(),
          category: _categoryController.text.trim(),
          amount: amount,
          date: _selectedDate,
          note: _noteController.text.trim(),
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Expense updated successfully.'
                : 'Expense added successfully.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Unable to update expense: $error'
                : 'Unable to add expense: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final category = _categoryController.text.trim();
    final title = _titleController.text.trim();

    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BrandPageHeader(
                eyebrow: 'Money out',
                title: widget.isEditing ? 'Edit expense' : 'Log an expense',
                subtitle: 'Record spending so reports reflect true profit.',
                icon: Icons.receipt_long_rounded,
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ExpensePreview(
                              amount: amount,
                              category: category,
                              date: _selectedDate,
                            ),
                            const SizedBox(height: 16),
                            BrandFormSection(
                              title: 'Expense details',
                              subtitle:
                                  'What was paid for and where it belongs.',
                              icon: Icons.shopping_bag_outlined,
                              accent: AppColors.warningDark,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _titleController,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: _inputDecoration(
                                      labelText: 'Title',
                                      hintText: 'e.g. Shop electricity bill',
                                      icon: Icons.receipt_long_outlined,
                                      valid: title.length >= 2,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Expense title is required.';
                                      }

                                      if (value.trim().length < 2) {
                                        return 'Title must contain at least 2 characters.';
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingMd,
                                  ),
                                  TextFormField(
                                    controller: _categoryController,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: _inputDecoration(
                                      labelText: 'Category',
                                      hintText: 'e.g. Rent, Utilities',
                                      icon: Icons.category_outlined,
                                      valid: category.isNotEmpty,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Expense category is required.';
                                      }

                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 7,
                                    runSpacing: 7,
                                    children: _categorySuggestions.map((label) {
                                      final selected =
                                          category.toLowerCase() ==
                                          label.toLowerCase();

                                      return _SuggestionChip(
                                        label: label,
                                        selected: selected,
                                        onTap: () {
                                          _categoryController.text = label;
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            BrandFormSection(
                              title: 'Amount',
                              subtitle:
                                  'What the cost came to — it feeds the '
                                  'profit math directly.',
                              icon: Icons.payments_outlined,
                              accent: AppColors.brandMintDeep,
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.displayFont,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                                decoration: _inputDecoration(
                                  labelText: 'Amount',
                                  hintText: '0.00',
                                  icon: Icons.payments_outlined,
                                  valid:
                                      (double.tryParse(
                                            _amountController.text.trim(),
                                          ) ??
                                          0) >
                                      0,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Expense amount is required.';
                                  }

                                  final amount = double.tryParse(value.trim());

                                  if (amount == null) {
                                    return 'Enter a valid amount.';
                                  }

                                  if (amount <= 0) {
                                    return 'Amount must be greater than zero.';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            BrandFormSection(
                              title: 'When & notes',
                              subtitle: 'Date of payment and anything worth remembering.',
                              icon: Icons.event_note_rounded,
                              accent: AppColors.primary,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: _selectDate,
                                    borderRadius: BorderRadius.circular(14),
                                    child: InputDecorator(
                                      decoration: _inputDecoration(
                                        labelText: 'Date',
                                        hintText: '',
                                        icon: Icons.calendar_today_outlined,
                                        icon2:
                                            Icons.keyboard_arrow_down_rounded,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            _formatDate(_selectedDate),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          BrandPill(
                                            label: _relativeDayLabel(
                                              _selectedDate,
                                            ),
                                            color: AppColors.primary,
                                            icon: Icons.schedule_rounded,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppDimensions.spacingMd,
                                  ),
                                  TextFormField(
                                    controller: _noteController,
                                    textInputAction: TextInputAction.done,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      labelText: 'Note',
                                      hintText: 'Optional note',
                                      prefixIcon: Icon(Icons.notes_outlined),
                                      alignLabelWithHint: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              BrandStickyBar(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'RUNNING TOTAL',
                            style: AppTextStyles.kpiLabel.copyWith(
                              fontSize: 9.5,
                              letterSpacing: 1.1,
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              amount > 0
                                  ? amount.toStringAsFixed(2)
                                  : 'Add an amount to save',
                              style: TextStyle(
                                fontFamily: AppTextStyles.displayFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                color: amount > 0
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    GradientButton(
                      label: _isSaving
                          ? 'Saving…'
                          : widget.isEditing
                          ? 'Save changes'
                          : 'Save expense',
                      icon: Icons.check_rounded,
                      isLoading: _isSaving,
                      gradient: AppDecor.royalGradient.colors,
                      expanded: false,
                      onPressed: _isSaving ? null : _saveExpense,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    IconData? icon2,
    bool valid = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark
        ? AppColors.darkBorderStrong
        : AppColors.lightBorderStrong;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: icon2 != null
          ? Icon(icon2)
          : (valid
                ? Icon(
                    Icons.check_circle_rounded,
                    size: 19,
                    color: AppColors.brandMint,
                  )
                : null),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: outline),
      ),
      // Royal focus ring per the Aurora brand ring.
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.royalMid, width: 1.8),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _relativeDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';
    return '${diff.abs()} days ${diff < 0 ? 'ago' : 'ahead'}';
  }
}

/// Live summary of the expense being typed — photo-backed hero card.
class _ExpensePreview extends StatelessWidget {
  final double amount;
  final String category;
  final DateTime date;

  const _ExpensePreview({
    required this.amount,
    required this.category,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: AppDecor.photoHero(
              image: AppImages.auroraGlow,
              anchor: 'left',
              imageAlignmentY: 0.4,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppDecor.amberGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppDecor.glow(
                          AppColors.brandAmber,
                          alpha: 0.3,
                        ),
                      ),
                      child: const Icon(
                        Icons.trending_down_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.isEmpty
                                ? 'UNCATEGORISED'
                                : category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFFFC48A),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Expense preview',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: CountUpText(
                    amount,
                    decimals: 2,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_formatDate(date)} · ${_relativeDayLabel(date)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _relativeDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    return '${diff.abs()} days ${diff < 0 ? 'ago' : 'ahead'}';
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final preset = AppDecor.toneGradient(label.hashCode.abs());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: selected
            ? LinearGradient(
                colors: preset.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: selected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: selected
            ? AppDecor.glow(preset.colors.first, alpha: 0.28)
            : null,
        border: Border.all(
          color: selected ? Colors.transparent : scheme.outline,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
