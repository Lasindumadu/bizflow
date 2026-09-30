import 'package:drift/drift.dart';

class Customers extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get phone => text().withDefault(const Constant(''))();

  TextColumn get email => text().withDefault(const Constant(''))();

  TextColumn get address => text().withDefault(const Constant(''))();

  RealColumn get outstandingBalance =>
      real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}
