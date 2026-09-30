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
          ),
        );

    return await _database.select(_database.businessSettings).getSingle();
  }

  Future<void> saveSettings({
    required String businessName,
    required String address,
    required String phone,
    required String email,
    required String currency,
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
          ),
        );
  }
}
