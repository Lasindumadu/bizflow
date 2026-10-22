import 'package:bizflow/core/session/session_controller.dart';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'audit_repository.dart';
import 'package:bizflow/data/repositories/business_settings_repository.dart';

class CustomerCreditRecord {
  final int id;
  final String customerId;
  final String customerName;
  final double creditLimit;
  final double currentBalance;
  final String paymentTerms;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerCreditRecord({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.creditLimit,
    required this.currentBalance,
    required this.paymentTerms,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  double get availableCredit => creditLimit - currentBalance;
  bool get isOverLimit => currentBalance > creditLimit && creditLimit > 0;
}

class CustomerCreditTransactionRecord {
  final int id;
  final int accountId;
  final String type;
  final String? reference;
  final double amount;
  final double balanceAfter;
  final String? description;
  final DateTime createdAt;
  final int? createdBy;

  CustomerCreditTransactionRecord({
    required this.id,
    required this.accountId,
    required this.type,
    this.reference,
    required this.amount,
    required this.balanceAfter,
    this.description,
    required this.createdAt,
    this.createdBy,
  });
}

class CustomerCreditRepository {
  final AppDatabase db;
  final AuditRepository _audit = AuditRepository(appDatabase);

  CustomerCreditRepository(this.db);

  /// Get all credit accounts with customer names
  Future<List<CustomerCreditRecord>> getCreditAccounts({
    bool onlyActive = true,
  }) async {
    final query = db.select(db.customerCreditAccounts);

    if (onlyActive) {
      query.where((t) => t.isActive.equals(true));
    }

    query.orderBy([(t) => OrderingTerm.asc(t.id)]);

    final accounts = await query.get();
    
    // Fetch customer names separately
    final customerIds = accounts.map((a) => a.customerId).toSet();
    final customers = <String, String>{};
    if (customerIds.isNotEmpty) {
      final customerRows = await (db.select(db.customers)
            ..where((t) => t.id.isIn(customerIds.toList())))
          .get();
      for (final c in customerRows) {
        customers[c.id] = c.name;
      }
    }

    return accounts.map((account) {
      return CustomerCreditRecord(
        id: account.id,
        customerId: account.customerId,
        customerName: customers[account.customerId] ?? 'Unknown',
        creditLimit: account.creditLimit,
        currentBalance: account.currentBalance,
        paymentTerms: account.paymentTerms,
        isActive: account.isActive,
        createdAt: account.createdAt,
        updatedAt: account.updatedAt,
      );
    }).toList();
  }

  /// Get credit account by customer ID
  Future<CustomerCreditRecord?> getCreditAccountByCustomer(String customerId) async {
    final account = await (db.select(db.customerCreditAccounts)
          ..where((t) => t.customerId.equals(customerId)))
        .getSingleOrNull();

    if (account == null) return null;

    final customer = await (db.select(db.customers)
          ..where((t) => t.id.equals(customerId)))
        .getSingleOrNull();

    return CustomerCreditRecord(
      id: account.id,
      customerId: account.customerId,
      customerName: customer?.name ?? 'Unknown',
      creditLimit: account.creditLimit,
      currentBalance: account.currentBalance,
      paymentTerms: account.paymentTerms,
      isActive: account.isActive,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
  }

  /// Create or get credit account for a customer
  Future<CustomerCreditRecord> ensureCreditAccount(String customerId, {double creditLimit = 0.0}) async {
    final existing = await getCreditAccountByCustomer(customerId);
    if (existing != null) return existing;

    // Create new account
    final accountId = await db.into(db.customerCreditAccounts).insert(
      CustomerCreditAccountsCompanion(
        customerId: Value(customerId),
        creditLimit: Value(creditLimit),
        currentBalance: const Value(0.0),
        paymentTerms: const Value('Net 30'),
        isActive: const Value(true),
      ),
    );

    await _audit.log(
      action: 'customer_credit_account.create',
      entityType: 'customer_credit_account',
      entityId: accountId.toString(),
      after: {
        'customerId': customerId,
        'creditLimit': creditLimit,
        'paymentTerms': 'Net 30',
      },
    );

    return getCreditAccountByCustomer(customerId).then((v) => v!);
  }

  /// Update credit account
  Future<void> updateCreditAccount({
    required int accountId,
    double? creditLimit,
    String? paymentTerms,
    bool? isActive,
  }) async {
    final account = await (db.select(db.customerCreditAccounts)
          ..where((t) => t.id.equals(accountId)))
        .getSingleOrNull();

    if (account == null) throw Exception('Credit account not found');

    final oldValues = {
      'creditLimit': account.creditLimit,
      'paymentTerms': account.paymentTerms,
      'isActive': account.isActive,
    };

    final companion = CustomerCreditAccountsCompanion(
      creditLimit: creditLimit != null ? Value(creditLimit) : const Value.absent(),
      paymentTerms: paymentTerms != null ? Value(paymentTerms) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    await (db.update(db.customerCreditAccounts)..where((t) => t.id.equals(accountId))).write(companion);

    await _audit.log(
      action: 'customer_credit_account.update',
      entityType: 'customer_credit_account',
      entityId: accountId.toString(),
      before: oldValues,
      after: {
        'creditLimit': creditLimit ?? account.creditLimit,
        'paymentTerms': paymentTerms ?? account.paymentTerms,
        'isActive': isActive ?? account.isActive,
      },
    );
  }

/// Ensure the session is authorized for credit operations.
  /// Throws [StateError] if the session is locked or login is required but no session exists.
  Future<void> _requireCreditOperationAuthorizaton() async {
    // If session is locked, block all operations (Phase F)
    if (sessionController.isLocked) {
      throw StateError('Cannot perform credit operations on a locked session. Unlock first.');
    }
    // If no session exists, check if login is required
    if (sessionController.current == null) {
      // Check business settings for login requirement
      final settings = await BusinessSettingsRepository(db).getSettings();
      if (settings.loginRequired) {
        throw StateError('Login required to perform credit operations.');
      }
      // If login is not required, allow backward compatibility (createdBy = null)
    }
  }

  /// Resolve the acting staff member from the current session.
  /// Returns the staff ID to use as [createdBy], or [null] if no session and login is not required.
  int? _resolveCreatedBy() {
    // If we have a session, resolve the actor from it (use the staff member's ID)
    if (sessionController.current != null) {
      return int.tryParse(sessionController.current!.id);
    }
    // If login is not required and no session, allow backward compatibility with null
    // (This should only be reached if requireAuthorization already passed)
    return null;
  }
  /// Add a transaction (invoice, payment, adjustment, credit_note)
  Future<void> addTransaction({
    required int accountId,
    required String type,
    String? reference,
    required double amount,
    String? description,
    int? createdBy,
  }) async {
    // Ensure the session is authorized for credit operations
    await _requireCreditOperationAuthorizaton();

    // Resolve the acting staff member from the current session
    final resolvedCreatedBy = _resolveCreatedBy();

    // Use resolved createdBy if provided, otherwise fall back to the method parameter
    final effectiveCreatedBy = createdBy ?? resolvedCreatedBy;

    // Get current balance
    final account = await (db.select(db.customerCreditAccounts)
          ..where((t) => t.id.equals(accountId)))
        .getSingleOrNull();

    if (account == null) throw Exception('Credit account not found');

    final newBalance = account.currentBalance + amount;

    // Insert transaction
    await db.into(db.customerCreditTransactions).insert(
      CustomerCreditTransactionsCompanion(
        accountId: Value(accountId),
        type: Value(type),
        reference: Value(reference),
        amount: Value(amount),
        balanceAfter: Value(newBalance),
        description: Value(description),
        createdBy: effectiveCreatedBy != null ? Value(effectiveCreatedBy) : const Value.absent(),
      ),
    );

    // Update account balance
    await (db.update(db.customerCreditAccounts)
          ..where((t) => t.id.equals(accountId)))
        .write(CustomerCreditAccountsCompanion(
          currentBalance: Value(newBalance),
          updatedAt: Value(DateTime.now()),
        ));

    await _audit.log(
      action: 'customer_credit_transaction.create',
      entityType: 'customer_credit_transaction',
      entityId: accountId.toString(),
      after: {
        'type': type,
        'reference': reference,
        'amount': amount,
        'newBalance': newBalance,
        'description': description,
      },
    );
  }

  /// Record a credit sale (invoice)
  Future<void> recordCreditSale({
    required String customerId,
    required double amount,
    required String saleId,
    String? description,
    int? createdBy,
  }) async {
    final account = await ensureCreditAccount(customerId);
    await addTransaction(
      accountId: account.id,
      type: 'invoice',
      reference: saleId,
      amount: amount,
      description: description ?? 'Credit sale #$saleId',
      createdBy: createdBy,
    );
  }

  /// Record a payment
  Future<void> recordPayment({
    required String customerId,
    required double amount,
    required String paymentReference,
    String? description,
    int? createdBy,
  }) async {
    final account = await getCreditAccountByCustomer(customerId);
    if (account == null) throw Exception('Customer has no credit account');

    await addTransaction(
      accountId: account.id,
      type: 'payment',
      reference: paymentReference,
      amount: -amount.abs(), // Payments reduce balance
      description: description ?? 'Payment received: $paymentReference',
      createdBy: createdBy,
    );
  }

  /// Record an adjustment
  Future<void> recordAdjustment({
    required String customerId,
    required double amount,
    required String reason,
    int? createdBy,
  }) async {
    final account = await getCreditAccountByCustomer(customerId);
    if (account == null) throw Exception('Customer has no credit account');

    await addTransaction(
      accountId: account.id,
      type: 'adjustment',
      reference: 'ADJ-${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      description: 'Adjustment: $reason',
      createdBy: createdBy,
    );
  }

  /// Record a credit note (return/refund)
  Future<void> recordCreditNote({
    required String customerId,
    required double amount,
    required String returnId,
    String? description,
    int? createdBy,
  }) async {
    final account = await getCreditAccountByCustomer(customerId);
    if (account == null) throw Exception('Customer has no credit account');

    await addTransaction(
      accountId: account.id,
      type: 'credit_note',
      reference: returnId,
      amount: -amount.abs(), // Credit notes reduce balance
      description: description ?? 'Credit note #$returnId',
      createdBy: createdBy,
    );
  }

  /// Get transactions for an account
  Future<List<CustomerCreditTransactionRecord>> getTransactions(int accountId, {int limit = 50}) async {
    final rows = await (db.select(db.customerCreditTransactions)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();

    return rows.map((row) => CustomerCreditTransactionRecord(
      id: row.id,
      accountId: row.accountId,
      type: row.type,
      reference: row.reference,
      amount: row.amount,
      balanceAfter: row.balanceAfter,
      description: row.description,
      createdAt: row.createdAt,
      createdBy: row.createdBy,
    )).toList();
  }

  /// Get overdue accounts (balance > 0, past due date)
  Future<List<CustomerCreditRecord>> getOverdueAccounts() async {
    // For now, return all accounts with positive balance
    // In a full implementation, you'd check payment terms and due dates
    final all = await getCreditAccounts();
    return all.where((a) => a.currentBalance > 0).toList();
  }
}