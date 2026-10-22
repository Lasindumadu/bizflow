import 'package:drift/drift.dart';

class Sales extends Table {
  TextColumn get id => text()();

  TextColumn get customerId => text().nullable()();

  RealColumn get subtotal => real()();

  RealColumn get discount => real().withDefault(const Constant(0.0))();

  RealColumn get total => real()();

  RealColumn get paidAmount => real()();

  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();

  TextColumn get status => text().withDefault(const Constant('completed'))();

  DateTimeColumn get createdAt => dateTime()();

  /// The authenticated staff member who completed the sale. Null for legacy
  /// records and for operations performed while login enforcement is disabled.
  TextColumn get staffId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
