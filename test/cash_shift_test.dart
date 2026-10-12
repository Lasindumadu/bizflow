import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/cash_shift_repository.dart';

void main() {
  late AppDatabase database;
  late CashShiftRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = CashShiftRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertSale({
    required String id,
    required double total,
    String method = 'cash',
  }) async {
    await database
        .into(database.sales)
        .insert(
          SalesCompanion.insert(
            id: id,
            subtotal: total,
            total: total,
            paidAmount: total,
            paymentMethod: Value(method),
            status: const Value('completed'),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> insertCashRefund({
    required String id,
    required double amount,
  }) async {
    await database
        .into(database.saleReturns)
        .insert(
          SaleReturnsCompanion.insert(
            id: id,
            saleId: 's-$id',
            refundAmount: amount,
            refundMethod: const Value('cash'),
            createdAt: DateTime.now(),
          ),
        );
  }

  group('open/close lifecycle', () {
    test('opens a shift with a float and reports it open', () async {
      final shift = await repository.openShift(openingFloat: 1000);

      expect(shift.isOpen, isTrue);
      expect(shift.openingFloat, 1000);
      expect(shift.shiftNumber, 1);

      final open = await repository.getOpenShift();
      expect(open, isNotNull);
      expect(open!.shift.id, shift.id);
    });

    test('refuses to open a second shift while one is open', () async {
      await repository.openShift(openingFloat: 500);

      await expectLater(
        repository.openShift(openingFloat: 500),
        throwsA(isA<StateError>()),
      );
    });

    test('closes the shift and no longer reports it open', () async {
      await repository.openShift(openingFloat: 200);

      await repository.closeShift(countedCash: 200);

      expect(await repository.getOpenShift(), isNull);
      final shifts = await repository.getShifts();
      expect(shifts.single.isOpen, isFalse);
      expect(shifts.single.closingCount, 200);
    });
  });

  group('reconciliation math', () {
    test('expected cash = float + cash sales (ignores card sales)', () async {
      await repository.openShift(openingFloat: 1000);
      await insertSale(id: 's1', total: 300, method: 'cash');
      await insertSale(id: 's2', total: 500, method: 'card');

      final open = await repository.getOpenShift();

      expect(open!.reconciliation.cashSales, 300, reason: 'card excluded');
      expect(open.reconciliation.expectedCash, 1300);
    });

    test('subtracts cash refunds from expected cash', () async {
      await repository.openShift(openingFloat: 1000);
      await insertSale(id: 's1', total: 400, method: 'cash');
      await insertCashRefund(id: 'r1', amount: 150);

      final open = await repository.getOpenShift();

      expect(open!.reconciliation.cashRefunds, 150);
      expect(open.reconciliation.expectedCash, 1250);
    });

    test('cash in and cash out adjust the drawer', () async {
      await repository.openShift(openingFloat: 500);
      await repository.recordMovement(direction: 'in', amount: 200);
      await repository.recordMovement(
        direction: 'out',
        amount: 50,
        note: 'Petty cash',
      );

      final open = await repository.getOpenShift();

      expect(open!.reconciliation.cashIn, 200);
      expect(open.reconciliation.cashOut, 50);
      expect(open.reconciliation.expectedCash, 650);
    });

    test(
      'discrepancy is positive for a surplus and negative for a short',
      () async {
        await repository.openShift(openingFloat: 1000);
        await insertSale(id: 's1', total: 0, method: 'cash');

        final open = await repository.getOpenShift();

        expect(open!.reconciliation.discrepancyVs(1050), 50);
        expect(open.reconciliation.discrepancyVs(950), -50);
      },
    );

    test('rejects movements without an open shift', () async {
      await expectLater(
        repository.recordMovement(direction: 'in', amount: 10),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects invalid movement direction and amount', () async {
      await repository.openShift(openingFloat: 100);

      await expectLater(
        repository.recordMovement(direction: 'sideways', amount: 10),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        repository.recordMovement(direction: 'in', amount: 0),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('audit trail', () {
    test('logs shift open, movements and close', () async {
      await repository.openShift(openingFloat: 100);
      await repository.recordMovement(direction: 'out', amount: 20);
      await repository.closeShift(countedCash: 80, discrepancyReason: 'tea');

      final logs = await database.select(database.auditLogs).get();
      final actions = logs.map((l) => l.action).toSet();
      expect(actions, containsAll(['shift.open', 'cash.out', 'shift.close']));
    });
  });
}
