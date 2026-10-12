import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/loyalty_repository.dart';

void main() {
  late AppDatabase database;
  late LoyaltyRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = LoyaltyRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<Customer> insertCustomer({
    required String id,
    int loyaltyPoints = 0,
    int pointsBalance = 0,
  }) async {
    await database
        .into(database.customers)
        .insert(
          CustomersCompanion.insert(
            id: id,
            name: 'Customer $id',
            loyaltyPoints: Value(loyaltyPoints),
            pointsBalance: Value(pointsBalance),
            loyaltyTier: Value(LoyaltyService.tierFor(loyaltyPoints).name),
          ),
        );
    return (database.select(
      database.customers,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  Future<Customer> read(String id) {
    return (database.select(
      database.customers,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  group('earnPoints', () {
    test('raises both lifetime points and spendable balance', () async {
      await insertCustomer(id: 'c1');

      await repository.earnPoints('c1', 300);

      final customer = await read('c1');
      expect(customer.loyaltyPoints, 300);
      expect(customer.pointsBalance, 300);
      expect(customer.loyaltyTier, 'Bronze');
    });

    test('promotes tier from lifetime points only', () async {
      await insertCustomer(id: 'c1');

      await repository.earnPoints('c1', 500);

      final customer = await read('c1');
      expect(customer.loyaltyTier, 'Silver');
    });

    test('ignores non-positive awards', () async {
      await insertCustomer(id: 'c1');
      await repository.earnPoints('c1', 0);
      await repository.earnPoints('c1', -50);

      final customer = await read('c1');
      expect(customer.loyaltyPoints, 0);
      expect(customer.pointsBalance, 0);
    });
  });

  group('redeemPoints — tier is never demoted', () {
    test(
      'reduces the balance but leaves lifetime points and tier intact',
      () async {
        // A Gold customer with 2500 lifetime points.
        await insertCustomer(
          id: 'c1',
          loyaltyPoints: 2500,
          pointsBalance: 2500,
        );

        final before = await read('c1');
        expect(before.loyaltyTier, 'Gold');

        await repository.redeemPoints('c1', 2000);

        final after = await read('c1');
        expect(after.pointsBalance, 500, reason: 'balance should drop');
        expect(after.loyaltyPoints, 2500, reason: 'lifetime must not change');
        expect(after.loyaltyTier, 'Gold', reason: 'tier must not be demoted');
      },
    );

    test('rejects redeeming more than the available balance', () async {
      await insertCustomer(id: 'c1', loyaltyPoints: 100, pointsBalance: 100);

      await expectLater(
        repository.redeemPoints('c1', 500),
        throwsA(isA<StateError>()),
      );

      final customer = await read('c1');
      expect(customer.pointsBalance, 100);
    });

    test('rejects non-positive redemption amounts', () async {
      await insertCustomer(id: 'c1', loyaltyPoints: 100, pointsBalance: 100);

      await expectLater(
        repository.redeemPoints('c1', 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws for a missing customer', () async {
      await expectLater(
        repository.redeemPoints('missing', 10),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('adjustPoints', () {
    test('positive delta earns; negative delta only reduces balance', () async {
      await insertCustomer(id: 'c1', loyaltyPoints: 1000, pointsBalance: 1000);

      await repository.adjustPoints('c1', 100);
      var customer = await read('c1');
      expect(customer.loyaltyPoints, 1100);
      expect(customer.pointsBalance, 1100);

      await repository.adjustPoints('c1', -600);
      customer = await read('c1');
      expect(customer.loyaltyPoints, 1100, reason: 'lifetime unchanged');
      expect(customer.pointsBalance, 500);
      expect(customer.loyaltyTier, 'Silver', reason: 'tier unchanged');
    });
  });

  group('topCustomers', () {
    test('orders by lifetime points descending', () async {
      await insertCustomer(id: 'a', loyaltyPoints: 100, pointsBalance: 100);
      await insertCustomer(id: 'b', loyaltyPoints: 900, pointsBalance: 900);
      await insertCustomer(id: 'c', loyaltyPoints: 400, pointsBalance: 400);

      final top = await repository.topCustomers(limit: 2);

      expect(top.map((c) => c.id).toList(), ['b', 'c']);
    });
  });
}
