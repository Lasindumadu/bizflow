import 'package:drift/drift.dart';

import '../../core/session/session_authorization.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'audit_repository.dart';

class BusinessSettingsRepository {
  final AppDatabase _database;
  final AuditRepository _audit;

  BusinessSettingsRepository([AppDatabase? database, AuditRepository? audit])
    : _database = database ?? appDatabase,
      _audit = audit ?? AuditRepository(database ?? appDatabase);

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
    return _database
        .select(_database.businessSettings)
        .watchSingleOrNull()
        .map((row) => row ?? _defaults);
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
    loginRequired: false,
    inactivityTimeoutMinutes: 0,
  );

  /// Guards a security-relevant change to `loginRequired`.
  ///
  /// Returns the verified acting owner (or null in login-disabled mode) for
  /// audit attribution. Rules:
  /// - `loginRequired == null` or equal to the stored value → no-op (the
  ///   settings screen echoes the current value on every ordinary save).
  /// - A session exists → it must be an active owner (re-verified against
  ///   the database via [requireOwner]); managers and cashiers are rejected.
  /// - No session, login currently disabled → allowed (bootstrap/Phase D
  ///   path: enabling login for the first time happens before any session
  ///   can exist).
  /// - No session, login currently enabled → rejected ([requireOwner]
  ///   requires authentication when `loginRequired` is true), so the
  ///   security setting cannot be flipped off by an unauthenticated caller.
  ///
  /// Returns the change that was authorized (or null when nothing is being
  /// changed) so the caller can audit it after a successful write.
  Future<({StaffAccountSummary? actor, bool enable})?> _guardSecurityChange(
    bool? loginRequired,
  ) async {
    if (loginRequired == null) {
      return null;
    }
    final current = await getSettings();
    if (current.loginRequired == loginRequired) {
      return null;
    }

    final actor = await requireOwner(
      _database,
      'change the startup login requirement',
    );

    return (actor: actor, enable: loginRequired);
  }

  /// Guards a change to the Phase F inactivity auto-lock timeout.
  ///
  /// The timeout is a security control (it decides how long a terminal stays
  /// unattended before it locks), so changing it is owner-only, exactly like
  /// `loginRequired`. A manager or cashier must not be able to disable the
  /// auto-lock on the terminal they are using.
  ///
  /// Rules mirror [_guardSecurityChange]:
  /// - `inactivityTimeoutMinutes == null` → no-op (ordinary saves).
  /// - Equal to the stored value → no-op (the settings screen echoes the
  ///   current value on every save).
  /// - A session exists → it must be an active owner.
  /// - No session and login is disabled → allowed (bootstrap path).
  /// - No session and login is enabled → rejected.
  ///
  /// Returns the verified acting owner (or null) for audit attribution, or
  /// null when nothing is being changed.
  Future<StaffAccountSummary?> _guardInactivityTimeoutChange(
    int? inactivityTimeoutMinutes,
  ) async {
    if (inactivityTimeoutMinutes == null) {
      return null;
    }
    if (inactivityTimeoutMinutes < 0) {
      throw ArgumentError.value(
        inactivityTimeoutMinutes,
        'inactivityTimeoutMinutes',
        'The inactivity timeout cannot be negative.',
      );
    }
    final current = await getSettings();
    if (current.inactivityTimeoutMinutes == inactivityTimeoutMinutes) {
      return null;
    }

    return requireOwner(_database, 'change the inactivity auto-lock timeout');
  }

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
    bool? loginRequired,
    int? inactivityTimeoutMinutes,
  }) async {
    // Security gate: flipping the `loginRequired` setting is an owner-only
    // operation, enforced here so no caller can bypass it by going through
    // `saveSettings` instead of `StaffAccountRepository.setLoginRequired`.
    //
    // Only actual *changes* are gated — ordinary settings saves that echo
    // the current value (the settings screen does this on every save) keep
    // working for all callers, preserving existing behavior.
    final securityChange = await _guardSecurityChange(loginRequired);

    // Phase F: the inactivity auto-lock timeout is a security control and is
    // owner-only for the same reason (see [_guardInactivityTimeoutChange]).
    final timeoutChange = await _guardInactivityTimeoutChange(
      inactivityTimeoutMinutes,
    );

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
            loginRequired: loginRequired == null
                ? const Value.absent()
                : Value(loginRequired),
            inactivityTimeoutMinutes: inactivityTimeoutMinutes == null
                ? const Value.absent()
                : Value(inactivityTimeoutMinutes),
          ),
        );

    if (securityChange != null) {
      await _audit.log(
        action: securityChange.enable
            ? 'settings.login_enable'
            : 'settings.login_disable',
        actor: securityChange.actor?.username ?? 'Owner',
        summary: securityChange.enable
            ? 'Enabled required PIN login at startup'
            : 'Disabled required PIN login at startup',
        entityType: 'business_settings',
        entityId: 'default',
      );
    }

    if (timeoutChange != null) {
      await _audit.log(
        action: 'settings.inactivity_timeout_change',
        actor: timeoutChange.username,
        summary: inactivityTimeoutMinutes == 0
            ? 'Disabled the inactivity auto-lock'
            : 'Set the inactivity auto-lock to '
                  '$inactivityTimeoutMinutes minutes',
        entityType: 'business_settings',
        entityId: 'default',
      );
    }
  }
}
