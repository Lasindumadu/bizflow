import 'package:flutter/material.dart';

import '../../data/database/database_provider.dart';
import '../../data/repositories/business_settings_repository.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_decor.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../session/session_controller.dart';
import '../theme/theme_controller.dart';
import 'app_shell.dart';
import 'brand_badge.dart';

/// Runs the minimum startup work the app genuinely needs before the shell
/// can be shown:
///
/// 1. Hydrate the persisted theme preferences. This is best-effort — the
///   controller already ships with working defaults, and a failure here
///   must never block the app (the current app never calls it at all).
/// 2. Open the existing database singleton with a single query. The database
///   is lazily opened by design; this forces that open (and any pending
///   schema migration) to happen once, *before* [AppShell] and its screens
///   start querying — while the startup screen is still visible.
///
/// It never constructs a second database instance, performs no network I/O,
/// and contains no artificial delays.
Future<void> _initializeEssentialServices() async {
  // 1) Theme preferences — non-essential, never fatal.
  try {
    await themeController.initialize();
  } catch (_) {
    // Keep the in-memory defaults (same behavior as today's cold start).
  }

  // 2) Database open — essential. Any failure propagates so the gate can
  //   surface a recoverable error state with Retry.
  //   The first statement on the lazy singleton triggers open + migration.
  await appDatabase.customSelect('SELECT 1').getSingle();
}

/// Reads the persistent Phase D `loginRequired` flag from the existing
/// business-settings row (the forced database open above has already run,
/// so the row and any pending migration are guaranteed available).
Future<bool> _loadLoginRequired() async {
  final settings = await BusinessSettingsRepository().getSettings();
  return settings.loginRequired;
}

/// A branded startup gate shown as `MaterialApp.home`.
///
/// While [initializer] is pending it displays the BizFlow name and a loading
/// indicator. If [initializer] completes successfully it switches to [child]
/// (the existing [AppShell] by default). If it throws, it shows a clear,
/// recoverable error state with a Retry button that re-runs [initializer].
///
/// [initializer] and [child] are injectable for tests; production code uses
/// the defaults.
class StartupGate extends StatefulWidget {
  const StartupGate({
    super.key,
    this.initializer,
    this.child = const AppShell(),
    this.loginRequiredLoader,
    this.session,
    this.loginBuilder,
  });

  /// The startup work to await. Defaults to [_initializeEssentialServices].
  final Future<void> Function()? initializer;

  /// Shown once initialization succeeds (and, when login is required, once
  /// a staff session has been established).
  final Widget child;

  /// Phase D: loads the persistent `loginRequired` flag. Defaults to
  /// [_loadLoginRequired]. Tests inject a loader (or an initializer without
  /// a loader) so they never touch the database.
  final Future<bool> Function()? loginRequiredLoader;

  /// Phase D: the authenticated session. Defaults to the app-wide
  /// [sessionController] (in-memory only).
  final SessionController? session;

  /// Phase D: shown when login is required and no session exists.
  /// Defaults to the real [LoginScreen].
  final WidgetBuilder? loginBuilder;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

enum _GatePhase { initializing, failed, ready }

class _StartupGateState extends State<StartupGate> {
  _GatePhase _phase = _GatePhase.initializing;
  Object? _error;
  int _attempt = 0;
  bool _requiresLogin = false;

  @override
  void initState() {
    super.initState();
    _phase = _GatePhase.initializing;
    _error = null;
    _requiresLogin = false;
    _run();
  }

  /// Retry path (safe: called from a button callback, outside build).
  void _start() {
    setState(() {
      _phase = _GatePhase.initializing;
      _error = null;
    });
    _run();
  }

  void _run() {
    final attempt = ++_attempt;
    _initialize()
        .then((_) {
          if (!mounted || attempt != _attempt) return;
          setState(() => _phase = _GatePhase.ready);
        })
        .catchError((Object error) {
          if (!mounted || attempt != _attempt) return;
          setState(() {
            _phase = _GatePhase.failed;
            _error = error;
          });
        });
  }

  /// Runs the essential initializer, then — on the production path — loads
  /// the persistent `loginRequired` flag so the gate knows whether to
  /// require a staff session before revealing [StartupGate.child].
  ///
  /// The settings lookup runs only when using the default initializer (or
  /// when a [StartupGate.loginRequiredLoader] is injected), so existing
  /// hermetic tests that inject an initializer are unaffected.
  Future<void> _initialize() async {
    await (widget.initializer ?? _initializeEssentialServices)();
    final bool requiresLogin;
    if (widget.loginRequiredLoader != null) {
      requiresLogin = await widget.loginRequiredLoader!();
    } else if (widget.initializer == null) {
      requiresLogin = await _loadLoginRequired();
    } else {
      requiresLogin = false;
    }
    if (!mounted) return;
    setState(() => _requiresLogin = requiresLogin);
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _GatePhase.initializing:
        return const _StartupBranding();
      case _GatePhase.failed:
        return _StartupError(error: _error, onRetry: _start);
      case _GatePhase.ready:
        return _buildReady(context);
    }
  }

  /// Phase D: when `loginRequired` is enabled, the existing [AppShell] is
  /// revealed only after a successful staff PIN login. Logout (session
  /// cleared) returns here to the login screen without re-running
  /// initialization — the database is already open and no data is lost.
  /// A refresh/restart constructs a fresh session (in-memory only), so
  /// login is required again — by design.
  Widget _buildReady(BuildContext context) {
    if (!_requiresLogin) {
      return widget.child;
    }
    final session = widget.session ?? sessionController;
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        if (session.isAuthenticated) {
          return widget.child;
        }
        if (widget.loginBuilder != null) {
          return widget.loginBuilder!(context);
        }
        return const LoginScreen();
      },
    );
  }
}

/// Full-screen branded surface shared by the loading and error states.
class _BrandedSurface extends StatelessWidget {
  const _BrandedSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppDecor.primaryGradient,
      ),
      child: child,
    );
  }
}

/// Loading state: BizFlow name + activity indicator, centered and responsive.
class _StartupBranding extends StatelessWidget {
  const _StartupBranding();

  @override
  Widget build(BuildContext context) {
    return _BrandedSurface(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.contentMaxWidthNarrow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.screenPaddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandBadge(size: 72),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Text(
                    'BizFlow',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    'Point of Sale & Inventory',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXxl),
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Starting your workspace…',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Recoverable error state with a Retry action.
///
/// Retry is safe: it simply re-runs the same idempotent initializer
/// (theme hydration is best-effort, and re-querying the database opens the
/// same singleton again).
class _StartupError extends StatelessWidget {
  const _StartupError({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final detail = error?.toString() ?? 'Unknown error';

    return _BrandedSurface(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.contentMaxWidthNarrow,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.screenPaddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Text(
                    "BizFlow couldn't start",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    'Something went wrong while preparing your workspace. '
                    'Your local data has not been changed — it is safe to '
                    'try again.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.80),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Text(
                      detail,
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.code.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: FilledButton.icon(
                      onPressed: onRetry,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text(
                        'Try again',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
