import 'package:drift/drift.dart';

class Sales extends Table {
  TextColumn get id => text()();

  TextColumn get customerId => text().nullable()();

  RealColumn get subtotal => real()();

  RealColumn get discount => real().withDefault(const Constant(0.0))();

  RealColumn get total => real()();

  RealColumn get paidAmount => real()();

  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();

  /// Phase G: tax amount included in this sale total.
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();

  /// Phase G: JSON string describing split payments when multiple methods
  /// are used (e.g. `[{"method":"cash","amount":10},{"method":"card","amount":5}]`).
  /// Null when a single payment method is used.
  TextColumn get paymentMethodDetails => text().nullable()();

  TextColumn get status => text().withDefault(const Constant('completed'))();

  DateTimeColumn get createdAt => dateTime()();

  /// The authenticated staff member who completed the sale. Null for legacy
  /// records and for operations performed while login enforcement is disabled.
  TextColumn get staffId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
