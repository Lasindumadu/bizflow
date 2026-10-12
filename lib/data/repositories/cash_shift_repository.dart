import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'audit_repository.dart';

/// A computed reconciliation of a shift's cash position.
class ShiftReconciliation {
  final double openingFloat;
  final double cashSales;
  final double cashIn;
  final double cashOut;
  final double cashRefunds;

  const ShiftReconciliation({
    required this.openingFloat,
    required this.cashSales,
    required this.cashIn,
    required this.cashOut,
    required this.cashRefunds,
  });

  /// Cash that should be in the drawer.
  double get expectedCash =>
      openingFloat + cashSales + cashIn - cashOut - cashRefunds;

  /// Difference between counted and expected (positive = surplus).
  double discrepancyVs(double counted) => counted - expectedCash;
}

/// The currently open shift, if any.
class OpenShift {
  final CashShift shift;
  final ShiftReconciliation reconciliation;

  const OpenShift({required this.shift, required this.reconciliation});
}

/// Manages cashier shifts and cash reconciliation.
///
/// Cash figures are derived from real records — cash sales from the `sales`
/// table and cash refunds from `sale_returns` — so the reconciliation can
/// never drift from what actually happened.
class CashShiftRepository {
  final AppDatabase database;
  final AuditRepository _audit;

  CashShiftRepository(this.database, {AuditRepository? audit})
    : _audit = audit ?? AuditRepository(database);

  /// Opens a new shift. Throws if a shift is already open.
  Future<CashShift> openShift({required double openingFloat}) async {
    final existing = await getOpenShift();
    if (existing != null) {
      throw StateError(
        'A shift is already open. Close it before opening a new one.',
      );
    }

    final count = (await database.select(database.cashShifts).get()).length;

    await database
        .into(database.cashShifts)
        .insert(
          CashShiftsCompanion.insert(
            id: 'shift_${DateTime.now().microsecondsSinceEpoch}',
            shiftNumber: count + 1,
            openingFloat: Value(openingFloat),
            openedAt: DateTime.now(),
          ),
        );

    final shift = await getOpenShift();
    await _audit.log(
      action: 'shift.open',
      entityType: 'shift',
      entityId: shift!.shift.id,
      summary:
          'Opened shift #${shift.shift.shiftNumber} with float '
          '${openingFloat.toStringAsFixed(2)}',
    );
    return shift.shift;
  }

  /// Records a manual cash movement against the open shift.
  Future<void> recordMovement({
    required String direction,
    required double amount,
    String note = '',
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Cash movement amount must be positive.');
    }
    if (direction != 'in' && direction != 'out') {
      throw ArgumentError("Direction must be 'in' or 'out'.");
    }

    final open = await getOpenShift();
    if (open == null) {
      throw StateError('No open shift to record a cash movement against.');
    }

    await database
        .into(database.cashMovements)
        .insert(
          CashMovementsCompanion.insert(
            id: 'cash_${DateTime.now().microsecondsSinceEpoch}',
            shiftId: open.shift.id,
            direction: direction,
            amount: amount,
            note: Value(note),
            createdAt: DateTime.now(),
          ),
        );

    await _audit.log(
      action: 'cash.$direction',
      entityType: 'shift',
      entityId: open.shift.id,
      summary:
          'Cash ${direction == 'in' ? 'in' : 'out'} '
          '${amount.toStringAsFixed(2)}${note.isEmpty ? '' : ' — $note'}',
    );
  }

  /// The open shift with its live reconciliation, or null.
  Future<OpenShift?> getOpenShift() async {
    final shift = await (database.select(
      database.cashShifts,
    )..where((t) => t.isOpen.equals(true))).getSingleOrNull();

    if (shift == null) return null;
    return OpenShift(shift: shift, reconciliation: await reconcile(shift));
  }

  /// Computes the cash position for [shift].
  Future<ShiftReconciliation> reconcile(CashShift shift) async {
    final cashSales = await _cashSalesBetween(shift.openedAt, shift.closedAt);
    final cashRefunds = await _cashRefundsBetween(
      shift.openedAt,
      shift.closedAt,
    );

    final movements = await (database.select(
      database.cashMovements,
    )..where((t) => t.shiftId.equals(shift.id))).get();

    double cashIn = 0;
    double cashOut = 0;
    for (final m in movements) {
      if (m.direction == 'in') {
        cashIn += m.amount;
      } else {
        cashOut += m.amount;
      }
    }

    return ShiftReconciliation(
      openingFloat: shift.openingFloat,
      cashSales: cashSales,
      cashIn: cashIn,
      cashOut: cashOut,
      cashRefunds: cashRefunds,
    );
  }

  /// Closes the open shift, recording the counted cash and any discrepancy.
  Future<ShiftReconciliation> closeShift({
    required double countedCash,
    String discrepancyReason = '',
  }) async {
    final open = await getOpenShift();
    if (open == null) {
      throw StateError('No open shift to close.');
    }

    final reconciliation = open.reconciliation;
    final discrepancy = reconciliation.discrepancyVs(countedCash);

    await (database.update(
      database.cashShifts,
    )..where((t) => t.id.equals(open.shift.id))).write(
      CashShiftsCompanion(
        closingCount: Value(countedCash),
        discrepancyReason: Value(discrepancyReason),
        closedAt: Value(DateTime.now()),
        isOpen: const Value(false),
      ),
    );

    await _audit.log(
      action: 'shift.close',
      entityType: 'shift',
      entityId: open.shift.id,
      summary:
          'Closed shift #${open.shift.shiftNumber}. Expected '
          '${reconciliation.expectedCash.toStringAsFixed(2)}, counted '
          '${countedCash.toStringAsFixed(2)}, '
          '${discrepancy >= 0 ? 'surplus' : 'short'} '
          '${discrepancy.abs().toStringAsFixed(2)}',
      after: {
        'counted': countedCash,
        'expected': reconciliation.expectedCash,
        'discrepancy': discrepancy,
      },
    );

    return reconciliation;
  }

  /// All shifts, newest first.
  Future<List<CashShift>> getShifts() async {
    final query = database.select(database.cashShifts)
      ..orderBy([(t) => OrderingTerm.desc(t.openedAt)]);
    return query.get();
  }

  Future<double> _cashSalesBetween(DateTime start, DateTime? end) async {
    final sales = await (database.select(
      database.sales,
    )..where((t) => t.status.equals('completed'))).get();

    return sales
        .where((s) {
          if (s.createdAt.isBefore(start)) return false;
          if (end != null && !s.createdAt.isBefore(end)) return false;
          return s.paymentMethod.toLowerCase() == 'cash';
        })
        .fold<double>(0, (sum, s) => sum + s.total);
  }

  Future<double> _cashRefundsBetween(DateTime start, DateTime? end) async {
    final returns = await database.select(database.saleReturns).get();

    return returns
        .where((r) {
          if (r.createdAt.isBefore(start)) return false;
          if (end != null && !r.createdAt.isBefore(end)) return false;
          return r.refundMethod.toLowerCase() == 'cash';
        })
        .fold<double>(0, (sum, r) => sum + r.refundAmount);
  }
}
