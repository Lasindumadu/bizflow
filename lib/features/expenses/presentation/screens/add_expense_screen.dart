import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
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

    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BrandPageHeader(
                eyebrow: 'Money out',
                title: widget.isEditing ? 'Edit expense' : 'Log an expense',
                subtitle:
                    'Record spending so reports reflect true profit.',
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
                                  'What was paid for and how much it cost.',
                              icon: Icons.shopping_bag_outlined,
                              accent: AppColors.orange,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _titleController,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: const InputDecoration(
                                      labelText: 'Title',
                                      hintText: 'e.g. Shop electricity bill',
                                      prefixIcon: Icon(
                                        Icons.receipt_long_outlined,
                                      ),
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
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      hintText: 'e.g. Rent, Utilities',
                                      prefixIcon: Icon(
                                        Icons.category_outlined,
                                      ),
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
                                      final selected = category.toLowerCase() ==
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
                                  const SizedBox(
                                    height: AppDimensions.spacingMd,
                                  ),
                                  TextFormField(
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
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Amount',
                                      hintText: '0.00',
                                      prefixIcon: Icon(
                                        Icons.payments_outlined,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Expense amount is required.';
                                      }

                                      final amount =
                                          double.tryParse(value.trim());

                                      if (amount == null) {
                                        return 'Enter a valid amount.';
                                      }

                                      if (amount <= 0) {
                                        return 'Amount must be greater than zero.';
                                      }

                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            BrandFormSection(
                              title: 'When & notes',
                              subtitle:
                                  'Date of payment and anything worth remembering.',
                              icon: Icons.event_note_rounded,
                              accent: AppColors.cyan,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: _selectDate,
                                    borderRadius: BorderRadius.circular(14),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Date',
                                        prefixIcon: Icon(
                                          Icons.calendar_today_outlined,
                                        ),
                                        suffixIcon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            _formatDate(_selectedDate),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          BrandPill(
                                            label: _relativeDayLabel(
                                              _selectedDate,
                                            ),
                                            color: AppColors.cyan,
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
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveExpense,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 19),
                  label: Text(
                    _isSaving
                        ? 'Saving…'
                        : widget.isEditing
                        ? 'Save changes'
                        : 'Save expense',
                  ),
                ),
              ),
            ],
          ),
        ),
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

/// Live summary of the expense being typed.
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B1436), Color(0xFF3A1F4D), Color(0xFF5B2A3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: AppDecor.glow(AppColors.orange, alpha: 0.22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppDecor.orangeGradient,
                  borderRadius: BorderRadius.circular(12),
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
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount.toStringAsFixed(2),
              style: const TextStyle(
                fontFamily: AppTextStyles.displayFont,
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.2,
              ),
            ),
          ),
        ],
      ),
    );
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

    return Material(
      color: selected
          ? AppColors.orange.withValues(alpha: 0.14)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected
              ? AppColors.orange.withValues(alpha: 0.5)
              : scheme.outline,
        ),
      ),
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
                  ? AppColors.orange
                  : scheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }
}
