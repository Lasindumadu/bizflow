import 'package:drift/drift.dart';

import '../../core/session/session_authorization.dart';
import '../database/app_database.dart';

class CustomerRepository {
  final AppDatabase database;

  CustomerRepository(this.database);

  /// Resolves the acting staff and enforces session validity for customer
  /// creation/editing. No role restriction — all authenticated staff may
  /// create or edit customers, consistent with POS checkout workflows.
  /// In login-disabled mode (no session, `loginRequired=false`) the
  /// null-staff actor from [resolveActor] is accepted, preserving legacy
  /// behavior.
  Future<ResolvedActor> _authorizeCustomerSession() async {
    return resolveActor(database);
  }

  /// Resolves the acting staff and enforces owner-only authorization for
  /// customer deletion (destructive: removes purchase history, credit
  /// accounts, and loyalty data).
  Future<ResolvedActor> _authorizeCustomerDeletion() async {
    final actor = await resolveActor(database);
    requireRole(
      actor.staff,
      {StaffRole.owner},
      'customer deletion',
    );
    return actor;
  }

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
    int loyaltyPoints = 0,
  }) async {
    await _authorizeCustomerSession();
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
            loyaltyPoints: Value(loyaltyPoints),
            pointsBalance: Value(loyaltyPoints),
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
    await _authorizeCustomerSession();
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
    await _authorizeCustomerDeletion();
    await (database.delete(
      database.customers,
    )..where((table) => table.id.equals(id))).go();
  }
}
