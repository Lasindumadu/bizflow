import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/session/session_authorization.dart';
import '../database/app_database.dart';

class ExpenseRepository {
  final AppDatabase database;

  ExpenseRepository(this.database);

  /// Resolves the acting staff and enforces owner-or-manager authorization
  /// for expense operations.
  Future<ResolvedActor> _authorizeExpense() async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner, StaffRole.manager},
      'expense operation',
    );
    return actor;
  }

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
    final actor = await _authorizeExpense();

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

    // Audit the expense (best-effort).
    try {
      await database
          .into(database.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              id: 'aud_${DateTime.now().microsecondsSinceEpoch}',
              action: 'expense.create',
              actor: Value(actor.staff?.username ?? 'Owner'),
              summary: Value('Added expense: $title ($category) ${amount.toStringAsFixed(2)}'),
              entityType: Value('expense'),
              entityId: Value(id),
              afterJson: Value(
                jsonEncode({
                  'title': title,
                  'category': category,
                  'amount': amount,
                }),
              ),
              createdAt: date,
            ),
          );
    } catch (_) {
      // Auditing must never block an expense entry.
    }
  }

  Future<void> updateExpense({
    required String id,
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final actor = await _authorizeExpense();

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

    // Audit the expense update (best-effort).
    try {
      await database
          .into(database.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              id: 'aud_${DateTime.now().microsecondsSinceEpoch}',
              action: 'expense.update',
              actor: Value(actor.staff?.username ?? 'Owner'),
              summary: Value('Updated expense: $title ($category)'),
              entityType: Value('expense'),
              entityId: Value(id),
              afterJson: Value(
                jsonEncode({
                  'title': title,
                  'category': category,
                  'amount': amount,
                }),
              ),
              createdAt: date,
            ),
          );
    } catch (_) {
      // Auditing must never block an expense update.
    }
  }

  Future<void> deleteExpense(String id) async {
    final actor = await _authorizeExpense();

    await (database.delete(
      database.expenses,
    )..where((table) => table.id.equals(id))).go();

    // Audit the expense deletion (best-effort).
    try {
      await database
          .into(database.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              id: 'aud_${DateTime.now().microsecondsSinceEpoch}',
              action: 'expense.delete',
              actor: Value(actor.staff?.username ?? 'Owner'),
              summary: Value('Deleted expense $id'),
              entityType: Value('expense'),
              entityId: Value(id),
              createdAt: DateTime.now(),
            ),
          );
    } catch (_) {
      // Auditing must never block an expense deletion.
    }
  }
}
