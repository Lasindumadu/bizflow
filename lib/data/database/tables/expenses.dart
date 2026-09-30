import 'package:drift/drift.dart';

class Expenses extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get category => text()();

  RealColumn get amount => real()();

  DateTimeColumn get date => dateTime()();

  TextColumn get note => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
