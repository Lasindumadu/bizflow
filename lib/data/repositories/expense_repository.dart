import 'package:drift/drift.dart';

import '../database/app_database.dart';

class ExpenseRepository {
  final AppDatabase database;

  ExpenseRepository(this.database);

  Stream<List<Expense>> watchExpenses() {
    final query = database.select(database.expenses)
      ..orderBy([(table) => OrderingTerm.desc(table.date)]);

    return query.watch();
  }

  Future<List<Expense>> getExpenses() {
    final query = database.select(database.expenses)
      ..orderBy([(table) => OrderingTerm.desc(table.date)]);

    return query.get();
  }

  Future<Expense?> getExpenseById(String id) async {
    final query = database.select(database.expenses)
      ..where((table) => table.id.equals(id));

    return query.getSingleOrNull();
  }

  Future<void> addExpense({
    required String id,
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Expense title cannot be empty.');
    }

    if (category.trim().isEmpty) {
      throw ArgumentError('Expense category cannot be empty.');
    }

    if (amount <= 0) {
      throw ArgumentError('Expense amount must be greater than zero.');
    }

    await database
        .into(database.expenses)
        .insert(
          ExpensesCompanion.insert(
            id: id,
            title: title.trim(),
            category: category.trim(),
            amount: amount,
            date: date,
            note: Value(note.trim()),
          ),
        );
  }

  Future<void> updateExpense({
    required String id,
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Expense title cannot be empty.');
    }

    if (category.trim().isEmpty) {
      throw ArgumentError('Expense category cannot be empty.');
    }

    if (amount <= 0) {
      throw ArgumentError('Expense amount must be greater than zero.');
    }

    await (database.update(
      database.expenses,
    )..where((table) => table.id.equals(id))).write(
      ExpensesCompanion(
        title: Value(title.trim()),
        category: Value(category.trim()),
        amount: Value(amount),
        date: Value(date),
        note: Value(note.trim()),
      ),
    );
  }

  Future<void> deleteExpense(String id) async {
    await (database.delete(
      database.expenses,
    )..where((table) => table.id.equals(id))).go();
  }
}
