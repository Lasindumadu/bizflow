import 'package:flutter/foundation.dart';

import '../../data/repositories/staff_account_repository.dart';

/// In-memory authenticated session for the current app run (Phase D + F).
///
/// Deliberately NOT persisted: no PIN, verifier, or token is stored, so a
/// browser refresh or application restart always requires a fresh PIN
/// login when `loginRequired` is enabled (see `docs/STARTUP_AUTH_PLAN.md`).
///
/// A successful [StaffAccountRepository.verifyPin] is the only way to
/// establish the identity; selecting a staff member on the login screen is
/// not authentication.
///
/// Phase F adds session locking: [lock] transitions the session to a locked
/// state that requires PIN re-entry (via [unlock]) before business operations
/// can proceed. [signOut] fully clears the identity and any lock state.
class SessionController extends ChangeNotifier {
  StaffAccountSummary? _current;

  /// The signed-in staff account, or null when signed out.
  StaffAccountSummary? get current => _current;

  bool get isAuthenticated => _current != null;

  /// The lock state of the current session.
  ///
  /// - [SessionLockState.signedOut] - no staff account is authenticated.
  /// - [SessionLockState.unlocked] - an authenticated session is active and
  ///   business operations are permitted.
  /// - [SessionLockState.locked] - an authenticated session exists but is
  ///   locked (inactivity timeout or explicit lock); PIN re-entry is required
  ///   via [unlock] before operations can proceed.
  SessionLockState _lockState = SessionLockState.signedOut;

  SessionLockState get lockState => _lockState;

  /// True when the session is locked (authenticated but awaiting PIN
  /// re-entry). Convenience for [lockState] == [SessionLockState.locked].
  bool get isLocked => _lockState == SessionLockState.locked;

  /// The last user-activity timestamp, updated by [resetActivity] and on
  /// every [signIn], [lock], [unlock]. Used by the inactivity auto-lock
  /// timer in [AppShell].
  DateTime? _lastActivity;

  DateTime? get lastActivity => _lastActivity;

  /// When the current authenticated session was established. Null when
  /// signed out.
  DateTime? _startedAt;

  DateTime? get startedAt => _startedAt;

  /// How long the current authenticated session has been active. Null when
  /// signed out.
  Duration? get sessionDuration =>
      _startedAt != null ? DateTime.now().difference(_startedAt!) : null;

  /// Establishes the authenticated identity after successful PIN
  /// verification. Replaces any previous identity and clears any lock.
  void signIn(StaffAccountSummary account) {
    _current = account;
    _lockState = SessionLockState.unlocked;
    _lastActivity = DateTime.now();
    _startedAt = DateTime.now();
    notifyListeners();
  }

  /// Clears the authenticated identity and any lock state. Idempotent.
  /// The startup gate returns to the login screen (while login is required)
  /// on the next notification.
  void signOut() {
    if (_current == null && _lockState == SessionLockState.signedOut) return;
    _current = null;
    _lockState = SessionLockState.signedOut;
    _lastActivity = null;
    _startedAt = null;
    notifyListeners();
  }

  /// Locks the authenticated session. Requires PIN re-entry via [unlock]
  /// before business operations can proceed. No-op when signed out or
  /// already locked.
  void lock() {
    if (_current == null) return;
    if (_lockState == SessionLockState.locked) return;
    _lockState = SessionLockState.locked;
    _lastActivity = DateTime.now();
    notifyListeners();
  }

  /// Unlocks the session, restoring it to the [SessionLockState.unlocked]
  /// state. Called after successful PIN re-entry. No-op when signed out or
  /// already unlocked.
  void unlock() {
    if (_current == null) return;
    if (_lockState == SessionLockState.unlocked) return;
    _lockState = SessionLockState.unlocked;
    _lastActivity = DateTime.now();
    notifyListeners();
  }

  /// Records user activity, resetting the inactivity clock.
  ///
  /// This NEVER unlocks a locked session. Unlocking requires a successful
  /// PIN re-entry via [unlock] — a locked session must not be escapable by
  /// simply touching the screen, otherwise the inactivity lock would be
  /// bypassable by a stray tap.
  ///
  /// No-op when signed out.
  void resetActivity() {
    if (_current == null) return;
    _lastActivity = DateTime.now();
    notifyListeners();
  }

  /// Records user activity without notifying listeners.
  ///
  /// Used by high-frequency activity sources (pointer moves, key presses) where
  /// rebuilding the UI on every event would be wasteful. The inactivity clock
  /// is still reset; only the notification is suppressed. Callers that need
  /// to react to the reset (for example, to restart the auto-lock timer)
  /// should use [resetActivity] instead.
  void resetActivitySilently() {
    if (_current == null) return;
    _lastActivity = DateTime.now();
  }
}

/// The lock state of an authenticated session.
enum SessionLockState {
  /// No staff account is authenticated.
  signedOut,

  /// An authenticated session is active and business operations are permitted.
  unlocked,

  /// An authenticated session exists but is locked; PIN re-entry is required.
  locked,
}

/// The app-wide session instance. In-memory only — intentionally lost on
/// refresh/restart.
final SessionController sessionController = SessionController();
