import 'package:drift/drift.dart';

class BusinessSettings extends Table {
  TextColumn get id => text()();

  TextColumn get businessName =>
      text().withDefault(const Constant('My Business'))();

  TextColumn get address => text().withDefault(const Constant(''))();

  TextColumn get phone => text().withDefault(const Constant(''))();

  TextColumn get email => text().withDefault(const Constant(''))();

  TextColumn get currency => text().withDefault(const Constant('USD'))();

  @override
  Set<Column> get primaryKey => {id};
}
