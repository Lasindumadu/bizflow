import 'package:drift/drift.dart';

import '../../core/session/session_authorization.dart';
import '../database/app_database.dart';
import 'audit_repository.dart';

/// A supplier record for display.
class SupplierRecord {
  final String id;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String taxNumber;
  final int paymentTermsDays;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupplierRecord({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.taxNumber,
    required this.paymentTermsDays,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  static SupplierRecord fromRow(Supplier row) => SupplierRecord(
    id: row.id,
    name: row.name,
    contactPerson: row.contactPerson,
    phone: row.phone,
    email: row.email,
    address: row.address,
    taxNumber: row.taxNumber,
    paymentTermsDays: row.paymentTermsDays,
    notes: row.notes,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

/// Manages suppliers.
class SupplierRepository {
  final AppDatabase database;
  final AuditRepository _audit;

  SupplierRepository(this.database, {AuditRepository? audit})
    : _audit = audit ?? AuditRepository(database);

  /// Resolves the acting staff and enforces owner-or-manager authorization
  /// for supplier management (purchasing is not a cashier responsibility).
  ///
  /// Also re-verifies the session account is still active, so a deactivated
  /// staff member cannot continue managing suppliers with a stale session.
  Future<ResolvedActor> _authorizeSuppliers() async {
    final actor = await resolveActor(database);
    requireRole(actor.staff, {
      StaffRole.owner,
      StaffRole.manager,
    }, 'supplier management');
    return actor;
  }

  /// Watches all suppliers ordered by name.
  Stream<List<SupplierRecord>> watchSuppliers() async* {
    await _authorizeSuppliers();
    yield* (database.select(database.suppliers)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(SupplierRecord.fromRow).toList());
  }

  /// Gets all suppliers ordered by name.
  Future<List<SupplierRecord>> getSuppliers() async {
    await _authorizeSuppliers();
    final rows = await (database.select(
      database.suppliers,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    return rows.map(SupplierRecord.fromRow).toList();
  }

  /// Gets a supplier by ID.
  Future<SupplierRecord?> getSupplierById(String id) async {
    await _authorizeSuppliers();
    final row = await (database.select(
      database.suppliers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? SupplierRecord.fromRow(row) : null;
  }

  /// Creates a new supplier.
  Future<SupplierRecord> createSupplier({
    required String name,
    String contactPerson = '',
    String phone = '',
    String email = '',
    String address = '',
    String taxNumber = '',
    int paymentTermsDays = 30,
    String notes = '',
  }) async {
    final actor = await _authorizeSuppliers();
    final id = 'sup_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();

    await database
        .into(database.suppliers)
        .insert(
          SuppliersCompanion.insert(
            id: id,
            name: name,
            contactPerson: Value(contactPerson),
            phone: Value(phone),
            email: Value(email),
            address: Value(address),
            taxNumber: Value(taxNumber),
            paymentTermsDays: Value(paymentTermsDays),
            notes: Value(notes),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _audit.log(
      action: 'supplier.create',
      actor: actor.staff?.username ?? 'Owner',
      entityType: 'supplier',
      entityId: id,
      summary: 'Created supplier "$name"',
      after: {
        'name': name,
        'contactPerson': contactPerson,
        'phone': phone,
        'email': email,
      },
    );

    final row = await (database.select(
      database.suppliers,
    )..where((t) => t.id.equals(id))).getSingle();
    return SupplierRecord.fromRow(row);
  }

  /// Updates an existing supplier.
  Future<SupplierRecord> updateSupplier({
    required String id,
    required String name,
    String contactPerson = '',
    String phone = '',
    String email = '',
    String address = '',
    String taxNumber = '',
    int paymentTermsDays = 30,
    String notes = '',
  }) async {
    final actor = await _authorizeSuppliers();
    final existing = await getSupplierById(id);
    if (existing == null) {
      throw StateError('Supplier not found.');
    }

    final now = DateTime.now();

    await (database.update(
      database.suppliers,
    )..where((t) => t.id.equals(id))).write(
      SuppliersCompanion(
        name: Value(name),
        contactPerson: Value(contactPerson),
        phone: Value(phone),
        email: Value(email),
        address: Value(address),
        taxNumber: Value(taxNumber),
        paymentTermsDays: Value(paymentTermsDays),
        notes: Value(notes),
        updatedAt: Value(now),
      ),
    );

    await _audit.log(
      action: 'supplier.update',
      actor: actor.staff?.username ?? 'Owner',
      entityType: 'supplier',
      entityId: id,
      summary: 'Updated supplier "$name"',
      before: {
        'name': existing.name,
        'contactPerson': existing.contactPerson,
        'phone': existing.phone,
        'email': existing.email,
      },
      after: {
        'name': name,
        'contactPerson': contactPerson,
        'phone': phone,
        'email': email,
      },
    );

    final row = await (database.select(
      database.suppliers,
    )..where((t) => t.id.equals(id))).getSingle();
    return SupplierRecord.fromRow(row);
  }

  /// Deletes a supplier (only if no purchase orders reference it).
  Future<void> deleteSupplier(String id) async {
    final actor = await _authorizeSuppliers();
    final existing = await getSupplierById(id);
    if (existing == null) {
      throw StateError('Supplier not found.');
    }

    // Check for existing purchase orders.
    final poCount = await (database.select(
      database.purchaseOrders,
    )..where((t) => t.supplierId.equals(id))).get();
    if (poCount.isNotEmpty) {
      throw StateError(
        'Cannot delete supplier with existing purchase orders. '
        'Archive or delete the purchase orders first.',
      );
    }

    await (database.delete(
      database.suppliers,
    )..where((t) => t.id.equals(id))).go();

    await _audit.log(
      action: 'supplier.delete',
      actor: actor.staff?.username ?? 'Owner',
      entityType: 'supplier',
      entityId: id,
      summary: 'Deleted supplier "${existing.name}"',
      before: {'name': existing.name, 'contactPerson': existing.contactPerson},
    );
  }
}
