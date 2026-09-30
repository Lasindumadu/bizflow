import 'package:drift/drift.dart';

import '../database/app_database.dart';

class CustomerRepository {
  final AppDatabase database;

  CustomerRepository(this.database);

  Stream<List<Customer>> watchCustomers() {
    final query = database.select(database.customers)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    return query.watch();
  }

  Future<List<Customer>> getCustomers() {
    final query = database.select(database.customers)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);

    return query.get();
  }

  Future<Customer?> getCustomerById(String id) async {
    final query = database.select(database.customers)
      ..where((table) => table.id.equals(id));

    return query.getSingleOrNull();
  }

  Future<void> addCustomer({
    required String id,
    required String name,
    String phone = '',
    String email = '',
    String address = '',
    double outstandingBalance = 0.0,
  }) async {
    await database
        .into(database.customers)
        .insert(
          CustomersCompanion.insert(
            id: id,
            name: name,
            phone: Value(phone),
            email: Value(email),
            address: Value(address),
            outstandingBalance: Value(outstandingBalance),
          ),
        );
  }

  Future<void> updateCustomer({
    required String id,
    required String name,
    String phone = '',
    String email = '',
    String address = '',
  }) async {
    await (database.update(
      database.customers,
    )..where((table) => table.id.equals(id))).write(
      CustomersCompanion(
        name: Value(name),
        phone: Value(phone),
        email: Value(email),
        address: Value(address),
      ),
    );
  }

  Future<void> deleteCustomer(String id) async {
    await (database.delete(
      database.customers,
    )..where((table) => table.id.equals(id))).go();
  }
}
