import 'package:drift/drift.dart';

/// A supplier/vendor from whom products are purchased.
class Suppliers extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get contactPerson => text().withDefault(const Constant(''))();

  TextColumn get phone => text().withDefault(const Constant(''))();

  TextColumn get email => text().withDefault(const Constant(''))();

  TextColumn get address => text().withDefault(const Constant(''))();

  /// Optional tax/VAT number for the supplier.
  TextColumn get taxNumber => text().withDefault(const Constant(''))();

  /// Payment terms in days (e.g., 30 for net-30).
  IntColumn get paymentTermsDays =>
      integer().withDefault(const Constant(30))();

  /// Notes about the supplier.
  TextColumn get notes => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}