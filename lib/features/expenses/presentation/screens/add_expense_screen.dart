import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
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
  }

  @override
  void dispose() {
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
    final title = widget.isEditing ? 'Edit Expense' : 'Add Expense';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            Text(
              widget.isEditing
                  ? 'Update Expense Information'
                  : 'Expense Information',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter expense title',
                prefixIcon: Icon(Icons.receipt_long_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Expense title is required.';
                }

                if (value.trim().length < 2) {
                  return 'Title must contain at least 2 characters.';
                }

                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            TextFormField(
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Rent, Utilities, Transport',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Expense category is required.';
                }

                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'Enter expense amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
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
            const SizedBox(height: AppDimensions.spacingLg),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/'
                  '${_selectedDate.month.toString().padLeft(2, '0')}/'
                  '${_selectedDate.year}',
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            TextFormField(
              controller: _noteController,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Optional note',
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _saveExpense,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(widget.isEditing ? Icons.save_outlined : Icons.add),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : widget.isEditing
                      ? 'Update Expense'
                      : 'Save Expense',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
