import 'package:drift/drift.dart';

import 'customers.dart';

/// Customer credit accounts (accounts receivable).
class CustomerCreditAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerId => text().references(Customers, #id, onDelete: KeyAction.cascade)();
  RealColumn get creditLimit => real().withDefault(const Constant(0.0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  TextColumn get paymentTerms => text().withDefault(const Constant('Net 30'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Credit transactions (invoices, payments, adjustments).
class CustomerCreditTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(CustomerCreditAccounts, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text().withLength(min: 1, max: 20)(); // 'invoice', 'payment', 'adjustment', 'credit_note'
  TextColumn get reference => text().nullable()(); // Sale ID, Payment reference, etc.
  RealColumn get amount => real()(); // Positive for charges, negative for payments/credits
  RealColumn get balanceAfter => real()(); // Running balance
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get createdBy => integer().nullable()(); // User ID who created
}