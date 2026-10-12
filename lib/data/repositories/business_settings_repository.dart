import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

class BusinessSettingsRepository {
  final AppDatabase _database;

  BusinessSettingsRepository([AppDatabase? database])
    : _database = database ?? appDatabase;

  Future<BusinessSetting> getSettings() async {
    final settings = await _database
        .select(_database.businessSettings)
        .getSingleOrNull();

    if (settings != null) {
      return settings;
    }

    const defaultId = 'default';

    await _database
        .into(_database.businessSettings)
        .insert(
          const BusinessSettingsCompanion(
            id: Value(defaultId),
            businessName: Value('My Business'),
            address: Value(''),
            phone: Value(''),
            email: Value(''),
            currency: Value('USD'),
            loyaltyEnabled: Value(true),
            loyaltyEarnRate: Value(1.0),
            loyaltyRedeemValue: Value(0.01),
          ),
        );

    return await _database.select(_database.businessSettings).getSingle();
  }

  Stream<BusinessSetting> watchSettings() {
    return _database.select(_database.businessSettings).watchSingleOrNull().map(
      (row) => row ?? _defaults,
    );
  }

  static const _defaults = BusinessSetting(
    id: 'default',
    businessName: 'My Business',
    address: '',
    phone: '',
    email: '',
    currency: 'USD',
    loyaltyEnabled: true,
    loyaltyEarnRate: 1.0,
    loyaltyRedeemValue: 0.01,
    receiptHeader: 'Thank you for your purchase!',
    receiptFooter: '',
    receiptShowPhone: true,
    receiptShowAddress: true,
    receiptNote: '',
  );

  Future<void> saveSettings({
    required String businessName,
    required String address,
    required String phone,
    required String email,
    required String currency,
    bool? loyaltyEnabled,
    double? loyaltyEarnRate,
    double? loyaltyRedeemValue,
    String? receiptHeader,
    String? receiptFooter,
    bool? receiptShowPhone,
    bool? receiptShowAddress,
    String? receiptNote,
  }) async {
    await _database
        .into(_database.businessSettings)
        .insertOnConflictUpdate(
          BusinessSettingsCompanion(
            id: const Value('default'),
            businessName: Value(businessName),
            address: Value(address),
            phone: Value(phone),
            email: Value(email),
            currency: Value(currency),
            loyaltyEnabled: loyaltyEnabled == null
                ? const Value.absent()
                : Value(loyaltyEnabled),
            loyaltyEarnRate: loyaltyEarnRate == null
                ? const Value.absent()
                : Value(loyaltyEarnRate),
            loyaltyRedeemValue: loyaltyRedeemValue == null
                ? const Value.absent()
                : Value(loyaltyRedeemValue),
            receiptHeader: receiptHeader == null
                ? const Value.absent()
                : Value(receiptHeader),
            receiptFooter: receiptFooter == null
                ? const Value.absent()
                : Value(receiptFooter),
            receiptShowPhone: receiptShowPhone == null
                ? const Value.absent()
                : Value(receiptShowPhone),
            receiptShowAddress: receiptShowAddress == null
                ? const Value.absent()
                : Value(receiptShowAddress),
            receiptNote: receiptNote == null
                ? const Value.absent()
                : Value(receiptNote),
          ),
        );
  }
}
