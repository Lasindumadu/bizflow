import 'package:flutter/foundation.dart';

import '../../data/repositories/staff_account_repository.dart';

/// In-memory authenticated session for the current app run (Phase D).
///
/// Deliberately NOT persisted: no PIN, verifier, or token is stored, so a
/// browser refresh or application restart always requires a fresh PIN
/// login when `loginRequired` is enabled (see `docs/STARTUP_AUTH_PLAN.md`).
///
/// A successful [StaffAccountRepository.verifyPin] is the only way to
/// establish the identity; selecting a staff member on the login screen is
/// not authentication.
class SessionController extends ChangeNotifier {
  StaffAccountSummary? _current;

  /// The signed-in staff account, or null when signed out.
  StaffAccountSummary? get current => _current;

  bool get isAuthenticated => _current != null;

  /// Establishes the authenticated identity after successful PIN
  /// verification. Replaces any previous identity.
  void signIn(StaffAccountSummary account) {
    _current = account;
    notifyListeners();
  }

  /// Clears the authenticated identity. Idempotent. The startup gate
  /// returns to the login screen (while login is required) on the next
  /// notification.
  void signOut() {
    if (_current == null) return;
    _current = null;
    notifyListeners();
  }
}

/// The app-wide session instance. In-memory only — intentionally lost on
/// refresh/restart.
final SessionController sessionController = SessionController();