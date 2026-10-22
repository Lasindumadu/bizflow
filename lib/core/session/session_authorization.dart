import 'package:bizflow/core/session/session_controller.dart';
import 'package:bizflow/data/database/app_database.dart';
import 'package:bizflow/data/repositories/business_settings_repository.dart';
import 'package:bizflow/data/repositories/staff_account_repository.dart';

export 'package:bizflow/data/repositories/staff_account_repository.dart'
    show StaffAccountSummary, StaffRole;

/// The resolved acting identity for a protected business operation.
class ResolvedActor {
  /// The authenticated staff member, or null in login-disabled mode.
  final StaffAccountSummary? staff;

  /// Whether login enforcement is enabled (true = session required).
  final bool loginRequired;

  const ResolvedActor({this.staff, required this.loginRequired});
}

/// Resolves the acting staff for the current request context.
///
/// - When a session exists: re-verifies the account still exists and is active
///   in the database. Signs out and throws [StateError] if the account has
///   been deactivated, so stale sessions cannot authorize protected actions.
/// - When the session is **locked** (Phase F): throws [StateError]. A locked
///   session is authenticated but suspended — it must not authorize business
///   operations until the owner re-enters their PIN.
/// - When no session exists: checks `business_settings.loginRequired`. Throws
///   if login is enforced; returns a null-staff actor (login-disabled mode)
///   otherwise, preserving backward compatibility.
Future<ResolvedActor> resolveActor(AppDatabase database) async {
  final session = sessionController;
  final current = session.current;

  if (current == null) {
    final loginRequired = await BusinessSettingsRepository(database)
        .getSettings()
        .then((s) => s.loginRequired);
    if (loginRequired) {
      throw StateError(
        'Authentication required. Please sign in before performing this operation.',
      );
    }
    return const ResolvedActor(staff: null, loginRequired: false);
  }

  // Phase F: a locked session must not authorize anything. The lock is
  // cleared only by a successful PIN re-entry (`SessionController.unlock`).
  if (session.isLocked) {
    throw StateError(
      'The session is locked. Re-enter your PIN to continue this operation.',
    );
  }

  final staffRepo = StaffAccountRepository(database);
  final staff = await staffRepo.getAccountById(current.id);
  if (staff == null || !staff.isActive) {
    session.signOut();
    throw StateError(
      'The account "${current.username}" is deactivated or no longer exists. '
      'Please sign in again with an active account.',
    );
  }

  return ResolvedActor(staff: staff, loginRequired: true);
}

/// Returns true when [staff] is permitted to perform an operation restricted
/// to [allowedRoles]. In login-disabled mode (staff == null) all roles are
/// implicitly allowed, preserving backward compatibility.
bool canPerform(StaffAccountSummary? staff, Set<StaffRole> allowedRoles) {
  if (staff == null) return true;
  return allowedRoles.contains(staff.role);
}

/// Throws [StateError] when [staff] is not in [allowedRoles].
void requireRole(
  StaffAccountSummary? staff,
  Set<StaffRole> allowedRoles,
  String operation,
) {
  if (!canPerform(staff, allowedRoles)) {
    final roleName = staff?.role.name ?? 'unauthenticated';
    throw StateError(
      'Insufficient permissions for $operation: $roleName is not authorized.',
    );
  }
}

/// Resolves the acting staff and requires the owner role.
///
/// Returns the verified owner summary, or null when no session exists and
/// login enforcement is disabled (legacy/bootstrap mode — the caller
/// preserves its pre-Phase-E behavior in that case).
///
/// When a session exists it is re-verified against the database (deactivated
/// or deleted accounts sign out and throw via [resolveActor]), so a caller
/// cannot spoof ownership with a username or boolean flag.
Future<StaffAccountSummary?> requireOwner(
  AppDatabase database,
  String operation,
) async {
  final actor = await resolveActor(database);
  requireRole(actor.staff, {StaffRole.owner}, operation);
  return actor.staff;
}
