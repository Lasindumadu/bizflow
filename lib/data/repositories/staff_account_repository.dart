import 'dart:isolate';
import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/session/session_controller.dart';
import '../database/app_database.dart';
import 'audit_repository.dart';

/// Computes a bcrypt PIN verifier (blocking KDF).
///
/// Top-level so it can run inside [Isolate.run] on native platforms.
/// Takes only primitive arguments (no closures, database handles, or
/// repository state cross the isolate boundary).
String hashPinSync(({String pin, int cost}) args) {
  return BCrypt.hashpw(args.pin, BCrypt.gensalt(logRounds: args.cost));
}

/// Checks a PIN against a bcrypt verifier (blocking KDF).
///
/// Top-level for the same isolate reasons as [hashPinSync]. Returns false
/// instead of throwing on malformed verifiers so a corrupt row blocks
/// login safely.
bool checkPinSync(({String pin, String verifier}) args) {
  try {
    return BCrypt.checkpw(args.pin, args.verifier);
  } catch (_) {
    // A malformed or corrupt verifier must never grant access.
    return false;
  }
}

/// The staff roles supported by the local PIN foundation.
enum StaffRole { owner, manager, cashier }

/// A staff account as returned by ordinary listings and lookups.
///
/// Deliberately excludes the [StaffAccount.pinVerifier] and
/// [StaffAccount.recoveryCodeVerifier] columns so credential verifiers never
/// leave the repository's private verification path.
class StaffAccountSummary {
  const StaffAccountSummary({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.isActive,
    required this.failedPinAttempts,
    required this.pinLockedUntil,
    required this.pinChangedAt,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String displayName;
  final StaffRole role;
  final bool isActive;
  final int failedPinAttempts;
  final DateTime? pinLockedUntil;
  final DateTime pinChangedAt;
  final DateTime createdAt;
}

/// Result of a successful owner recovery.
///
/// [newRecoveryCode] is the rotated plaintext code, returned only after the
/// new verifier has been committed. The previous code stops working.
class RecoveredOwnerPin {
  const RecoveredOwnerPin({
    required this.account,
    required this.newRecoveryCode,
  });

  final StaffAccountSummary account;
  final String newRecoveryCode;
}

/// Result of creating an account.
///
/// [recoveryCode] is set exactly once, only for the owner. It is the sole
/// opportunity to record it: it is never stored in plaintext and cannot be
/// retrieved again.
class CreatedStaffAccount {
  const CreatedStaffAccount({required this.account, this.recoveryCode});

  final StaffAccountSummary account;
  final String? recoveryCode;
}

/// Outcome of a PIN verification attempt.
enum StaffAuthStatus {
  /// The PIN matched the stored verifier.
  success,

  /// The PIN was malformed or did not match. Well-formed wrong PINs count
  /// as failed attempts; malformed input does not (it can never be correct).
  invalidPin,

  /// No account exists for the given identifier.
  accountNotFound,

  /// The account exists but is deactivated.
  disabled,

  /// Too many failed attempts; the account is temporarily locked and no
  /// verification runs until [StaffAuthResult.lockedUntil] passes.
  locked,
}

/// Result of [StaffAccountRepository.verifyPin].
class StaffAuthResult {
  const StaffAuthResult({required this.status, this.account, this.lockedUntil});

  final StaffAuthStatus status;

  /// The signed-in account; set only when [status] is [StaffAuthStatus.success].
  final StaffAccountSummary? account;

  /// When the lock expires; set only when [status] is [StaffAuthStatus.locked].
  final DateTime? lockedUntil;
}

/// Local staff accounts with salted, computationally expensive PIN
/// verifiers (bcrypt, work factor [pinHashCost]).
///
/// Security notes — read before extending:
/// * PINs and recovery codes are never stored; only bcrypt verifiers with a
///   per-row `Random.secure()` salt are persisted.
/// * Verifiers are never returned from this API, written to the audit log,
///   printed, or included in backup/CSV exports.
/// * A 4-8 digit PIN has limited entropy. bcrypt raises the cost of offline
///   guessing from a stolen database and [maxFailedPinAttempts] throttling
///   raises the cost of online guessing, but this is device-access control,
///   not cryptographic proof of identity against a sophisticated local
///   attacker.
/// * The lockout relies on the device clock: rolling it back shortens locks.
/// * Throttling state lives in the database, so it survives app restarts and
///   web refreshes, but it is intentionally not part of backup files.
class StaffAccountRepository {
  StaffAccountRepository(
    this.database, {
    AuditRepository? audit,
    this.pinHashCost = defaultPinHashCost,
    DateTime Function()? now,
  }) : _audit = audit ?? AuditRepository(database),
       _now = now ?? DateTime.now;

  /// bcrypt work factor for new verifiers (OWASP recommends >= 10).
  static const int defaultPinHashCost = 10;

  /// Consecutive failed attempts before an account is locked.
  static const int maxFailedPinAttempts = 5;

  /// How long an account stays locked after [maxFailedPinAttempts] failures.
  ///
  /// Standardized to 15 minutes: short enough not to strand a cashier for a
  /// shift, long enough to make online PIN guessing uneconomical when
  /// combined with bcrypt verification cost. Tests and docs that reference
  /// this policy must use this constant, not a literal.
  static const Duration pinLockoutDuration = Duration(minutes: 15);

  static const int minPinLength = 4;
  static const int maxPinLength = 8;

  /// Length of generated recovery codes: 16 Crockford-base32 characters
  /// (~80 bits of entropy).
  static const int recoveryCodeLength = 16;

  final AppDatabase database;
  final AuditRepository _audit;
  final int pinHashCost;
  final DateTime Function() _now;
  int _idSequence = 0;

  /// Test-only hook: when true, the next staff-table write inside a
  /// transaction throws a [StateError] to simulate a database failure.
  /// Used to prove that failed recovery rotation leaves the previous
  /// recovery code valid. Never set in production code.
  @visibleForTesting
  bool failNextStaffWrite = false;

  // ─────────────────────────────────────────────
  // Validation & normalization
  // ─────────────────────────────────────────────

  /// Trimmed, lowercased form used for storage and lookup.
  static String normalizeUsername(String username) =>
      username.trim().toLowerCase();

  /// Returns an error message when [username] is invalid, else null.
  /// Pass the [normalizeUsername] form.
  static String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username is required.';
    }
    if (!RegExp(r'^[a-z0-9][a-z0-9._-]{2,23}$').hasMatch(username)) {
      return 'Username must be 3-24 characters using letters, digits, '
          " '.', '_', or '-'.";
    }
    return null;
  }

  /// Returns an error message when [pin] is invalid, else null.
  static String? validatePin(String pin) {
    if (!RegExp(r'^[0-9]{4,8}$').hasMatch(pin)) {
      return 'PIN must be $minPinLength to $maxPinLength digits.';
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // Credential helpers (private)
  // ─────────────────────────────────────────────

  /// Derives a bcrypt verifier without blocking the UI isolate.
  ///
  /// Platform behavior (genuine offload, not merely `Future`-wrapped sync
  /// work):
  /// * Native (Android/iOS/desktop): [Isolate.run] executes [hashPinSync] on
  ///   a worker isolate; the arguments are a plain record of primitives.
  /// * Flutter Web: isolates are single-threaded, so [Isolate.run] executes
  ///   inline and the KDF occupies the UI thread for its duration (hundreds
  ///   of milliseconds at the default cost). Callers (Phase D login UI) must
  ///   show a busy indicator while awaiting. No dependency can change this;
  ///   it is a platform constraint, documented here instead of hidden.
  Future<String> _hashPinOffload(String pin) {
    // Capture the cost as a local primitive so `this` (and transitively the
    // FfiDatabase) is NOT sent across the isolate boundary. Only `pin` and
    // `cost` cross the boundary — both are sendable primitives.
    final cost = pinHashCost;
    if (kIsWeb) {
      return Future(() => hashPinSync((pin: pin, cost: cost)));
    }
    return Isolate.run(() => hashPinSync((pin: pin, cost: cost)));
  }

  /// Checks a PIN without blocking the UI isolate. Same platform behavior as
  /// [_hashPinOffload]: true background execution on native, inline on Web.
  Future<bool> _checkPinOffload(String pin, String verifier) {
    if (kIsWeb) {
      return Future(() => checkPinSync((pin: pin, verifier: verifier)));
    }
    return Isolate.run(() => checkPinSync((pin: pin, verifier: verifier)));
  }

  String _generateRecoveryCode() {
    // Crockford base32: digits + letters excluding I, L, O and U.
    const alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < recoveryCodeLength; i++) {
      buffer.write(alphabet[random.nextInt(alphabet.length)]);
    }
    final raw = buffer.toString();
    return '${raw.substring(0, 4)}-${raw.substring(4, 8)}-'
        '${raw.substring(8, 12)}-${raw.substring(12, 16)}';
  }

  /// Uppercases and strips separators so 'abcd-efgh' == 'ABCDEFGH'.
  static String normalizeRecoveryCode(String code) =>
      code.trim().toUpperCase().replaceAll(RegExp('[^0-9A-Z]'), '');

  // ─────────────────────────────────────────────
  // Row helpers
  // ─────────────────────────────────────────────

  StaffAccountSummary _summary(StaffAccount row) => StaffAccountSummary(
    id: row.id,
    username: row.username,
    displayName: row.displayName,
    role: StaffRole.values.byName(row.role),
    isActive: row.isActive,
    failedPinAttempts: row.failedPinAttempts,
    pinLockedUntil: row.pinLockedUntil,
    pinChangedAt: row.pinChangedAt,
    createdAt: row.createdAt,
  );

  /// Session-derived authority for owner-only staff administration.
  ///
  /// Phase E hardening: the caller-supplied `asOwner` boolean and
  /// `actingUsername` string are NOT proof of authority — anyone can pass
  /// them. When an authenticated session exists, the session identity is
  /// authoritative and is re-verified against the database here:
  /// - account deleted or deactivated → the session is signed out and the
  ///   call throws (stale sessions cannot administer staff);
  /// - account is not the owner → the call throws.
  ///
  /// Returns the verified acting owner for audit attribution, or null when
  /// no session exists (login-disabled/bootstrap mode). In that legacy
  /// path the pre-Phase-E `asOwner` + `actingUsername` checks remain in
  /// force, preserving every existing caller and test.
  Future<StaffAccountSummary?> _requireOwnerAuthority(String operation) async {
    final current = sessionController.current;
    if (current == null) {
      return null;
    }

    final row = await _findById(current.id);
    if (row == null || !row.isActive) {
      sessionController.signOut();
      throw StateError(
        'The account "${current.username}" is deactivated or no longer '
        'exists. Please sign in again with an active account.',
      );
    }
    if (row.role != StaffRole.owner.name) {
      throw StateError(
        'Insufficient permissions for $operation: '
        '${row.role} is not authorized.',
      );
    }
    return _summary(row);
  }

  Future<StaffAccount?> _findByUsername(String normalizedUsername) {
    return (database.select(
      database.staffAccounts,
    )..where((t) => t.username.equals(normalizedUsername))).getSingleOrNull();
  }

  Future<StaffAccount?> _findById(String id) {
    return (database.select(
      database.staffAccounts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> _clearFailures(String id) async {
    await (database.update(
      database.staffAccounts,
    )..where((t) => t.id.equals(id))).write(
      const StaffAccountsCompanion(
        failedPinAttempts: Value(0),
        pinLockedUntil: Value(null),
      ),
    );
  }

  /// Test-only failure injector used by [_maybeFailStaffWriteForTest].
  void _maybeFailStaffWriteForTest() {
    if (failNextStaffWrite) {
      failNextStaffWrite = false;
      throw StateError('Simulated staff write failure (test hook).');
    }
  }

  // ─────────────────────────────────────────────
  // Account management
  // ─────────────────────────────────────────────

  /// Creates a staff account and returns its summary.
  ///
  /// For the owner, also generates a one-time recovery code returned in
  /// [CreatedStaffAccount.recoveryCode] — the only chance to record it.
  ///
  /// Throws [ArgumentError] for invalid input (messages never contain the
  /// PIN) and [StateError] when the username is taken or a second owner
  /// would be created. The bcrypt derivation runs before the write so the
  /// slow KDF never holds a database transaction open; the uniqueness
  /// check and the insert share one transaction, so a partial write is
  /// impossible.
  Future<CreatedStaffAccount> createAccount({
    required StaffRole role,
    required String username,
    required String pin,
    String displayName = '',
    bool isActive = true,
    String? actor,
  }) async {
    // Owner-only when an authenticated session exists (staff administration).
    // With no session (first-run bootstrap, login-disabled mode) the
    // pre-Phase-E behavior is preserved so the first owner can still be
    // created before any session can exist.
    final verifiedOwner = await _requireOwnerAuthority('create staff accounts');

    final normalizedUsername = normalizeUsername(username);
    final usernameError = validateUsername(normalizedUsername);
    if (usernameError != null) {
      throw ArgumentError.value(username, 'username', usernameError);
    }
    final pinError = validatePin(pin);
    if (pinError != null) {
      throw ArgumentError('Invalid PIN — $pinError');
    }

    final String pinHash = await _hashPinOffload(pin);
    final String? recoveryCode;
    final String? recoveryCodeHash;
    if (role == StaffRole.owner) {
      recoveryCode = _generateRecoveryCode();
      recoveryCodeHash = await _hashPinOffload(
        normalizeRecoveryCode(recoveryCode),
      );
    } else {
      recoveryCode = null;
      recoveryCodeHash = null;
    }

    final id =
        'staff_${DateTime.now().microsecondsSinceEpoch}_${_idSequence++}';

    final StaffAccount row = await database.transaction(() async {
      final existing = await _findByUsername(normalizedUsername);
      if (existing != null) {
        throw StateError(
          "A staff account with username '$normalizedUsername' already exists.",
        );
      }
      if (role == StaffRole.owner) {
        // Exactly one owner row may ever exist so owner recovery always
        // targets a single, unambiguous account.
        final owners = await (database.select(
          database.staffAccounts,
        )..where((t) => t.role.equals(StaffRole.owner.name))).get();
        if (owners.isNotEmpty) {
          throw StateError(
            'An owner account already exists. Recover its PIN instead of '
            'creating a second owner.',
          );
        }
      }

      final now = _now();
      await database
          .into(database.staffAccounts)
          .insert(
            StaffAccountsCompanion.insert(
              id: id,
              username: normalizedUsername,
              displayName: Value(displayName.trim()),
              role: role.name,
              isActive: Value(isActive),
              pinVerifier: pinHash,
              recoveryCodeVerifier: Value(recoveryCodeHash),
              pinChangedAt: now,
              createdAt: now,
            ),
          );
      final inserted = await _findById(id);
      return inserted!;
    });

    await _audit.log(
      action: 'staff.create',
      actor: verifiedOwner?.username ?? actor ?? 'Owner',
      summary: "Created ${role.name} account '$normalizedUsername'",
      entityType: 'staff',
      entityId: id,
    );

    return CreatedStaffAccount(
      account: _summary(row),
      recoveryCode: recoveryCode,
    );
  }

  /// Lists all staff accounts, ordered by username.
  /// Never includes credential verifiers.
  Future<List<StaffAccountSummary>> listStaff() async {
    final rows = await (database.select(
      database.staffAccounts,
    )..orderBy([(t) => OrderingTerm.asc(t.username)])).get();
    return rows.map(_summary).toList();
  }

  /// Looks up a single account by username (normalized). Never includes
  /// credential verifiers.
  Future<StaffAccountSummary?> getAccountByUsername(String username) async {
    final row = await _findByUsername(normalizeUsername(username));
    return row == null ? null : _summary(row);
  }

  /// Looks up a single account by id. Never includes credential verifiers.
  Future<StaffAccountSummary?> getAccountById(String id) async {
    final row = await _findById(id);
    return row == null ? null : _summary(row);
  }

  // ─────────────────────────────────────────────
  // PIN verification (throttled, persisted)
  // ─────────────────────────────────────────────

  /// Verifies [pin] against the stored bcrypt verifier.
  ///
  /// Order of checks: unknown account → disabled → locked → PIN format →
  /// bcrypt. A lock blocks verification before any KDF work runs. A
  /// successful verification resets the failed-attempt counter.
  Future<StaffAuthResult> verifyPin({
    required String username,
    required String pin,
  }) async {
    final row = await _findByUsername(normalizeUsername(username));
    if (row == null) {
      return const StaffAuthResult(status: StaffAuthStatus.accountNotFound);
    }
    if (!row.isActive) {
      return const StaffAuthResult(status: StaffAuthStatus.disabled);
    }

    final now = _now();
    final lockedUntil = row.pinLockedUntil;
    if (lockedUntil != null && now.isBefore(lockedUntil)) {
      return StaffAuthResult(
        status: StaffAuthStatus.locked,
        lockedUntil: lockedUntil,
      );
    }

    if (validatePin(pin) != null) {
      // Malformed input can never be correct, so it is rejected without
      // consuming a failed attempt.
      return const StaffAuthResult(status: StaffAuthStatus.invalidPin);
    }

    if (await _checkPinOffload(pin, row.pinVerifier)) {
      if (row.failedPinAttempts != 0 || row.pinLockedUntil != null) {
        await _clearFailures(row.id);
      }
      return StaffAuthResult(
        status: StaffAuthStatus.success,
        account: StaffAccountSummary(
          id: row.id,
          username: row.username,
          displayName: row.displayName,
          role: StaffRole.values.byName(row.role),
          isActive: row.isActive,
          failedPinAttempts: 0,
          pinLockedUntil: null,
          pinChangedAt: row.pinChangedAt,
          createdAt: row.createdAt,
        ),
      );
    }

    return _recordFailedAttempt(row);
  }

  /// Increments the persisted failed-attempt counter, locking the account
  /// once [maxFailedPinAttempts] is reached. Returns the status to surface.
  Future<StaffAuthResult> _recordFailedAttempt(StaffAccount row) async {
    final attempts = row.failedPinAttempts + 1;
    if (attempts >= maxFailedPinAttempts) {
      final lockedUntil = _now().add(pinLockoutDuration);
      await (database.update(
        database.staffAccounts,
      )..where((t) => t.id.equals(row.id))).write(
        StaffAccountsCompanion(
          failedPinAttempts: const Value(0),
          pinLockedUntil: Value(lockedUntil),
        ),
      );
      await _audit.log(
        action: 'staff.pin_lock',
        summary:
            "Locked account '${row.username}' after "
            '$attempts failed PIN attempts',
        entityType: 'staff',
        entityId: row.id,
      );
      return StaffAuthResult(
        status: StaffAuthStatus.locked,
        lockedUntil: lockedUntil,
      );
    }

    await (database.update(database.staffAccounts)
          ..where((t) => t.id.equals(row.id)))
        .write(StaffAccountsCompanion(failedPinAttempts: Value(attempts)));
    return const StaffAuthResult(status: StaffAuthStatus.invalidPin);
  }

  // ─────────────────────────────────────────────
  // PIN changes, roles, activation, owner recovery
  // ─────────────────────────────────────────────
  //
  // Repository permission model (Phase C foundation — the full UI
  // permission system belongs to a later phase):
  // * `changePin` on your OWN account: allowed with the current PIN.
  // * `changePin` on ANOTHER account: only with `asOwner: true`
  //   (a Phase D caller must prove the operator is the owner).
  // * `setRole` / `setActive` / `setDisplayName`: only with `asOwner: true`.
  // * The only owner row can never be deactivated via [setActive].
  // Ordinary staff operations therefore cannot arbitrarily change another
  // account's PIN or role; every privileged action is audit-logged.

  /// Changes the PIN of [username].
  ///
  /// Self-service (`asOwner: false`, the default) requires the correct
  /// [currentPin]. An owner-initiated reset (`asOwner: true`) skips the
  /// current-PIN check and is audit-logged as `staff.pin_reset`.
  /// The new verifier overwrites the old one atomically, so the previous
  /// PIN stops working; success also clears failures and lock.
  Future<void> changePin({
    required String username,
    String? currentPin,
    required String newPin,
    bool asOwner = false,
    String? actor,
  }) async {
    // Owner-initiated resets must come from an authenticated owner session;
    // self-service changes are authorized by knowledge of the current PIN
    // and stay available in every mode.
    final verifiedOwner = asOwner
        ? await _requireOwnerAuthority("reset account '$username' PIN")
        : null;

    final row = await _findByUsername(normalizeUsername(username));
    if (row == null) {
      throw StateError(
        "No staff account with username '${normalizeUsername(username)}'.",
      );
    }
    if (!asOwner) {
      if (currentPin == null || currentPin.isEmpty) {
        throw StateError('The current PIN is required to change your own PIN.');
      }
      if (!await _checkPinOffload(currentPin, row.pinVerifier)) {
        throw StateError('The current PIN is incorrect.');
      }
    }
    final pinError = validatePin(newPin);
    if (pinError != null) {
      throw ArgumentError('Invalid PIN — $pinError');
    }

    final newHash = await _hashPinOffload(newPin);
    final now = _now();
    await database.transaction(() async {
      _maybeFailStaffWriteForTest();
      await (database.update(
        database.staffAccounts,
      )..where((t) => t.id.equals(row.id))).write(
        StaffAccountsCompanion(
          pinVerifier: Value(newHash),
          failedPinAttempts: const Value(0),
          pinLockedUntil: const Value(null),
          pinChangedAt: Value(now),
        ),
      );
    });

    await _audit.log(
      action: asOwner ? 'staff.pin_reset' : 'staff.pin_change',
      actor: verifiedOwner?.username ?? actor ?? 'Owner',
      summary: asOwner
          ? "Owner reset the PIN of account '${row.username}'"
          : "Changed the PIN of account '${row.username}'",
      entityType: 'staff',
      entityId: row.id,
    );
  }

  /// Changes the role of [username]. Owner-only (`asOwner: true`).
  /// Promotion *to* owner and demotion *of* the owner are both rejected
  /// (single-owner invariant).
  Future<StaffAccountSummary> setRole({
    required String username,
    required StaffRole role,
    bool asOwner = false,
    String? actor,
  }) async {
    if (!asOwner) {
      throw StateError('Only the owner can change staff roles.');
    }
    final verifiedOwner = await _requireOwnerAuthority('change staff roles');
    final row = await _findByUsername(normalizeUsername(username));
    if (row == null) {
      throw StateError(
        "No staff account with username '${normalizeUsername(username)}'.",
      );
    }
    if (row.role == role.name) {
      return _summary(row);
    }
    if (role == StaffRole.owner) {
      throw StateError(
        'An owner account already exists. Recover its PIN instead of '
        'creating a second owner.',
      );
    }
    if (row.role == StaffRole.owner.name) {
      throw StateError(
        'The owner account cannot be demoted. Transfer ownership through '
        'a dedicated flow instead.',
      );
    }

    await database.transaction(() async {
      _maybeFailStaffWriteForTest();
      await (database.update(database.staffAccounts)
            ..where((t) => t.id.equals(row.id)))
          .write(StaffAccountsCompanion(role: Value(role.name)));
    });

    await _audit.log(
      action: 'staff.role_change',
      actor: verifiedOwner?.username ?? actor ?? 'Owner',
      summary:
          "Changed role of account '${row.username}' "
          "from ${row.role} to ${role.name}",
      entityType: 'staff',
      entityId: row.id,
    );
    final updated = await _findById(row.id);
    return _summary(updated!);
  }

  /// Activates or deactivates [username]. Owner-only (`asOwner: true`,
  /// enforced here, not just in future UI).
  ///
  /// The only owner row can never be deactivated — deactivating it would
  /// irreversibly lock the business out of owner-gated operations. Throws
  /// [StateError] for that case and for unknown accounts.
  Future<StaffAccountSummary> setActive({
    required String username,
    required bool isActive,
    bool asOwner = false,
    String? actor,
  }) async {
    if (!asOwner) {
      throw StateError('Only the owner can activate staff accounts.');
    }
    final verifiedOwner = await _requireOwnerAuthority(
      'activate / deactivate staff accounts',
    );
    final row = await _findByUsername(normalizeUsername(username));
    if (row == null) {
      throw StateError(
        "No staff account with username '${normalizeUsername(username)}'.",
      );
    }
    if (row.role == StaffRole.owner.name && !isActive) {
      throw StateError(
        'The owner account cannot be deactivated. Recover its PIN instead.',
      );
    }
    if (row.isActive == isActive) {
      return _summary(row);
    }

    await database.transaction(() async {
      _maybeFailStaffWriteForTest();
      await (database.update(database.staffAccounts)
            ..where((t) => t.id.equals(row.id)))
          .write(StaffAccountsCompanion(isActive: Value(isActive)));
    });

    await _audit.log(
      action: isActive ? 'staff.activate' : 'staff.deactivate',
      actor: verifiedOwner?.username ?? actor ?? 'Owner',
      summary: isActive
          ? "Reactivated account '${row.username}'"
          : "Deactivated account '${row.username}'",
      entityType: 'staff',
      entityId: row.id,
    );
    final updated = await _findById(row.id);
    return _summary(updated!);
  }

  /// Edits the display label of [username]. Owner-only (`asOwner: true`),
  /// consistent with [setRole] and [setActive].
  ///
  /// Only [displayName] can be edited here: the username is the unique
  /// lookup key (changing it would break lookups and audit references) and
  /// role changes go through [setRole]. The write touches no credential
  /// columns, so the existing PIN and recovery code keep working. The
  /// label is trimmed exactly as in [createAccount]; an unchanged label
  /// is a no-op that performs no write and no audit entry.
  Future<StaffAccountSummary> setDisplayName({
    required String username,
    required String displayName,
    bool asOwner = false,
    String? actor,
  }) async {
    if (!asOwner) {
      throw StateError('Only the owner can edit staff details.');
    }
    final verifiedOwner = await _requireOwnerAuthority('edit staff details');
    final row = await _findByUsername(normalizeUsername(username));
    if (row == null) {
      throw StateError(
        "No staff account with username '${normalizeUsername(username)}'.",
      );
    }
    final trimmed = displayName.trim();
    if (row.displayName == trimmed) {
      return _summary(row);
    }

    await database.transaction(() async {
      _maybeFailStaffWriteForTest();
      await (database.update(database.staffAccounts)
            ..where((t) => t.id.equals(row.id)))
          .write(StaffAccountsCompanion(displayName: Value(trimmed)));
    });

    await _audit.log(
      action: 'staff.display_name_change',
      actor: verifiedOwner?.username ?? actor ?? 'Owner',
      summary: "Changed display name of account '${row.username}'",
      entityType: 'staff',
      entityId: row.id,
    );
    final updated = await _findById(row.id);
    return _summary(updated!);
  }

  /// Recovers the owner PIN using the one-time recovery code.
  ///
  /// Atomicity contract (acceptance criterion 2): the new PIN verifier and
  /// the rotated recovery-code verifier are committed in a single Drift
  /// transaction; the plaintext [RecoveredOwnerPin.newRecoveryCode] is
  /// returned only after that commit succeeds. A failed rotation throws
  /// and the previous recovery code remains valid (tests pin this with
  /// [failNextStaffWrite]).
  ///
  /// Success also clears failures/lock and reactivates the owner if it was
  /// deactivated, so recovery can never leave the business locked out.
  Future<RecoveredOwnerPin> recoverOwnerPin({
    required String recoveryCode,
    required String newPin,
    String? actor,
  }) async {
    final rows = await (database.select(
      database.staffAccounts,
    )..where((t) => t.role.equals(StaffRole.owner.name))).get();
    if (rows.isEmpty) {
      throw StateError('No owner account exists to recover.');
    }
    final owner = rows.first;
    final stored = owner.recoveryCodeVerifier;
    if (stored == null ||
        !await _checkPinOffload(normalizeRecoveryCode(recoveryCode), stored)) {
      throw StateError('The recovery code is incorrect.');
    }
    final pinError = validatePin(newPin);
    if (pinError != null) {
      throw ArgumentError('Invalid PIN — $pinError');
    }

    final newPinHash = await _hashPinOffload(newPin);
    final newRecoveryCode = _generateRecoveryCode();
    final newRecoveryHash = await _hashPinOffload(
      normalizeRecoveryCode(newRecoveryCode),
    );
    final now = _now();

    final StaffAccount committed = await database.transaction(() async {
      _maybeFailStaffWriteForTest();
      await (database.update(
        database.staffAccounts,
      )..where((t) => t.id.equals(owner.id))).write(
        StaffAccountsCompanion(
          pinVerifier: Value(newPinHash),
          recoveryCodeVerifier: Value(newRecoveryHash),
          isActive: const Value(true),
          failedPinAttempts: const Value(0),
          pinLockedUntil: const Value(null),
          pinChangedAt: Value(now),
        ),
      );
      final row = await _findById(owner.id);
      return row!;
    });

    await _audit.log(
      action: 'staff.recover',
      actor: actor ?? 'recovery',
      summary: "Recovered the PIN of owner account '${owner.username}'",
      entityType: 'staff',
      entityId: owner.id,
    );

    return RecoveredOwnerPin(
      account: _summary(committed),
      newRecoveryCode: newRecoveryCode,
    );
  }

  // ─────────────────────────────────────────────
  // Phase D: optional startup login (setting + owner gates)
  // ─────────────────────────────────────────────

  /// Writes the single-row `business_settings.loginRequired` flag.
  ///
  /// Kept private here so the ONLY paths that can enable or disable startup
  /// login are [setLoginRequired] calls made by an authenticated owner
  /// (verified against the database, audited). The rest of the business
  /// settings continue to flow through `BusinessSettingsRepository.saveSettings`
  /// which passes `loginRequired: null` → `Value.absent()` and therefore
  /// cannot silently reset this flag.
  Future<void> _writeLoginRequired(bool value) async {
    await database
        .into(database.businessSettings)
        .insertOnConflictUpdate(
          BusinessSettingsCompanion(
            id: const Value('default'),
            loginRequired: Value(value),
          ),
        );
  }

  /// Pre-flight lockout check: can login enforcement be switched on without
  /// risking permanent owner lockout?
  ///
  /// Requires ALL of:
  /// 1. an owner account exists (single-owner invariant guarantees at most one);
  /// 2. that owner is active;
  /// 3. the owner has a stored PIN verifier (a usable credential);
  /// 4. the owner has a stored recovery-code verifier, so
  ///    [recoverOwnerPin] remains available if the owner PIN is forgotten.
  ///
  /// A staff row's mere existence is NOT treated as proof of recovery
  /// capability — the verifiers themselves are checked.
  Future<({bool ready, String message})> checkLoginReadiness() async {
    final rows = await (database.select(
      database.staffAccounts,
    )..where((t) => t.role.equals(StaffRole.owner.name))).get();
    if (rows.isEmpty) {
      return (
        ready: false,
        message:
            'No owner account exists yet. Create the owner account first — '
            'without an active owner and its recovery code, enabling PIN '
            'login could lock you out permanently.',
      );
    }
    final owner = rows.first;
    if (!owner.isActive) {
      return (
        ready: false,
        message:
            "The owner account '${owner.username}' is deactivated and "
            'could not sign in. Reactivate it before enabling PIN login.',
      );
    }
    if (owner.pinVerifier.isEmpty) {
      return (
        ready: false,
        message:
            "The owner account '${owner.username}' has no PIN set. Set "
            'an owner PIN before enabling PIN login.',
      );
    }
    if (owner.recoveryCodeVerifier == null ||
        owner.recoveryCodeVerifier!.isEmpty) {
      return (
        ready: false,
        message:
            "The owner account '${owner.username}' has no recovery code, so "
            'a forgotten owner PIN could not be recovered. Restore owner '
            'recovery before enabling PIN login.',
      );
    }
    return (ready: true, message: 'Owner account is ready for PIN login.');
  }

  /// Enables (or, with [enable: false], disables) required startup PIN login.
  ///
  /// Owner-only. [asOwner] is a caller assertion that the acting identity is
  /// the authenticated owner session; it is re-verified here against the
  /// database so a UI-only check cannot bypass the gate. When
  /// [enable: true] this also runs [checkLoginReadiness] first and refuses
  /// when it would risk owner lockout.
  ///
  /// Throws [StateError] when the acting account is missing, deactivated, or
  /// not the owner — enforced in the repository, not just in the UI.
  Future<void> setLoginRequired({
    required bool enable,
    required String actingUsername,
    bool asOwner = false,
    String? actor,
  }) async {
    if (!asOwner) {
      throw StateError('Only the owner can change the PIN-login requirement.');
    }
    // Phase E: when a session exists, its identity is authoritative — the
    // caller-supplied [actingUsername] is NOT accepted as proof, so a
    // cashier session cannot spoof the owner's username to flip this
    // setting. With no session (bootstrap), the [actingUsername] lookup
    // below remains the verification, preserving Phase D behavior.
    final verifiedOwner = await _requireOwnerAuthority(
      'change the PIN-login requirement',
    );
    final row = await _findByUsername(normalizeUsername(actingUsername));
    if (row == null) {
      throw StateError(
        "No staff account with username '${normalizeUsername(actingUsername)}'.",
      );
    }
    if (row.role != StaffRole.owner.name) {
      throw StateError('Only the owner can change the PIN-login requirement.');
    }
    if (!row.isActive) {
      throw StateError(
        'The acting owner account is deactivated and cannot change settings.',
      );
    }
    if (enable) {
      final readiness = await checkLoginReadiness();
      if (!readiness.ready) {
        throw StateError(readiness.message);
      }
    }

    await _writeLoginRequired(enable);

    await _audit.log(
      action: enable ? 'settings.login_enable' : 'settings.login_disable',
      actor: verifiedOwner?.username ?? actor ?? row.username,
      summary: enable
          ? 'Enabled required PIN login at startup'
          : 'Disabled required PIN login at startup',
      entityType: 'business_settings',
      entityId: 'default',
    );
  }
}
