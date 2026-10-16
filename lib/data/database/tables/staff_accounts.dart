import 'package:drift/drift.dart';

/// Local staff accounts used for PIN-based operator identification.
///
/// [pinVerifier] and [recoveryCodeVerifier] hold bcrypt hashes (per-row
/// random salt and cost factor embedded, `$2a$…` format) — never the
/// plaintext PIN or recovery code. They must never be exposed in listings,
/// logs, UI, CSV exports, or backup files; the repository returns summary
/// DTOs that structurally exclude them.
class StaffAccounts extends Table {
  TextColumn get id => text()();

  /// Normalized (trimmed, lowercased) unique login identifier.
  TextColumn get username => text().unique()();

  /// Optional display label shown in future UIs.
  TextColumn get displayName => text().withDefault(const Constant(''))();

  /// 'owner' | 'manager' | 'cashier' — validated by the repository.
  TextColumn get role => text()();

  /// Deactivated accounts cannot verify PINs (login) but keep their data.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// bcrypt verifier of the staff PIN. Never exposed outside the
  /// repository's private verification path.
  TextColumn get pinVerifier => text()();

  /// bcrypt verifier of the owner's one-time recovery code. Set (only) on
  /// the owner row at creation and rotated on each recovery.
  TextColumn get recoveryCodeVerifier => text().nullable()();

  /// Consecutive failed PIN attempts; reset on success and when a lock
  /// begins. Persisted so restarts and web refreshes cannot bypass it.
  IntColumn get failedPinAttempts => integer().withDefault(const Constant(0))();

  /// While in the future, the account is locked and no PIN verification is
  /// attempted. Null when not locked.
  DateTimeColumn get pinLockedUntil => dateTime().nullable()();

  DateTimeColumn get pinChangedAt => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}