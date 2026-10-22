import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/services/backup_service.dart';

/// Loyalty-specific backup/restore coverage: proves the loyalty programme
/// (lifetime points, spendable balance, and settings) survives a backup
/// round-trip, and that older backups still restore safely.
void main() {
  late AppDatabase database;
  late BackupService service;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    service = BackupService(database);
  });

  tearDown(() async {
    await database.close();
  });

  Uint8List bytesOf(String json) => Uint8List.fromList(utf8.encode(json));

  Future<void> seedCustomer() async {
    await database
        .into(database.customers)
        .insert(
          CustomersCompanion.insert(
            id: 'c1',
            name: 'Loyal Customer',
            loyaltyPoints: const Value(2500),
            pointsBalance: const Value(500),
            loyaltyTier: const Value('Gold'),
          ),
        );
  }

  Future<void> seedSettings() async {
    await database
        .into(database.businessSettings)
        .insert(
          const BusinessSettingsCompanion(
            id: Value('default'),
            businessName: Value('Test Shop'),
            loyaltyEnabled: Value(true),
            loyaltyEarnRate: Value(2.5),
            loyaltyRedeemValue: Value(0.05),
          ),
        );
  }

  group('loyalty backup integrity', () {
    test('exports the current schema version (not a stale one)', () async {
      final json = await service.createBackupJson();
      final decoded = jsonDecode(json) as Map<String, dynamic>;

      expect(
        decoded['databaseSchemaVersion'],
        AppDatabase.currentSchemaVersion,
      );
    });

    test('records both lifetime points and spendable balance', () async {
      await seedCustomer();

      final json = await service.createBackupJson();
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final customer = (decoded['data']['customers'] as List).single as Map;

      expect(customer['loyaltyPoints'], 2500);
      expect(customer['pointsBalance'], 500);
    });

    test('round-trips loyalty values AND loyalty settings', () async {
      await seedCustomer();
      await seedSettings();

      final json = await service.createBackupJson();

      await service.resetAllData();
      expect(await database.select(database.customers).get(), isEmpty);

      await service.restoreBackup(bytesOf(json));

      final customer = (await database.select(database.customers).get()).single;
      expect(customer.loyaltyPoints, 2500, reason: 'lifetime preserved');
      expect(customer.pointsBalance, 500, reason: 'balance preserved');
      expect(customer.loyaltyTier, 'Gold');

      final settings =
          (await database.select(database.businessSettings).get()).single;
      expect(settings.businessName, 'Test Shop');
      expect(settings.loyaltyEnabled, isTrue);
      expect(settings.loyaltyEarnRate, 2.5, reason: 'earn rate preserved');
      expect(
        settings.loyaltyRedeemValue,
        0.05,
        reason: 'redeem value preserved',
      );
    });

    test('rejects a backup from a future, unsupported schema', () async {
      final json = await service.createBackupJson();
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      decoded['databaseSchemaVersion'] = 99;

      await expectLater(
        service.restoreBackup(bytesOf(jsonEncode(decoded))),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'restores an older v5 backup by defaulting loyalty settings',
      () async {
        final v5 = jsonEncode({
          'backupFormatVersion': 1,
          'application': 'BizFlow',
          'databaseSchemaVersion': 5,
          'data': {
            'products': <dynamic>[],
            'categories': <dynamic>[],
            'sales': <dynamic>[],
            'saleItems': <dynamic>[],
            'customers': [
              {
                'id': 'legacy',
                'name': 'Legacy Customer',
                'phone': '',
                'email': '',
                'address': '',
                'outstandingBalance': 0.0,
                'loyaltyPoints': 800,
              },
            ],
            'expenses': <dynamic>[],
            'stockMovements': <dynamic>[],
            'businessSettings': [
              {
                'id': 'default',
                'businessName': 'Legacy Shop',
                'address': '',
                'phone': '',
                'email': '',
                'currency': 'USD',
              },
            ],
          },
        });

        await service.restoreBackup(bytesOf(v5));

        final customer =
            (await database.select(database.customers).get()).single;
        expect(customer.loyaltyPoints, 800);
        expect(customer.pointsBalance, 800, reason: 'backfilled from lifetime');

        final settings =
            (await database.select(database.businessSettings).get()).single;
        expect(settings.loyaltyEnabled, isTrue);
        expect(settings.loyaltyEarnRate, 1.0);
        expect(settings.loyaltyRedeemValue, 0.01);
      },
    );
  });
}
