import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_badge.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/staff_account_repository.dart';

/// Real staff PIN login (Phase D).
///
/// Replaces the earlier demo screen (which accepted any 4-digit PIN and
/// hardcoded operators). Authentication always goes through
/// [StaffAccountRepository.verifyPin]: bcrypt comparison with persisted
/// failed-attempt throttling and lockout.
///
/// Selecting a staff member is NOT authentication — the session is
/// established only after [StaffAuthStatus.success], via [SessionController].
/// The PIN is held only in this screen's text controller; it is never
/// stored, logged, or passed to the session.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.repository,
    this.session,
    this.onAuthenticated,
  });

  /// Injectable for tests; defaults to the app database singleton.
  final StaffAccountRepository? repository;

  /// Injectable for tests; defaults to the app-wide [sessionController].
  final SessionController? session;

  /// Called after the session has been established (optional hook; the
  /// startup gate also reacts to the session itself).
  final VoidCallback? onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final StaffAccountRepository _repository;
  late final SessionController _session;

  List<StaffAccountSummary> _staff = [];
  bool _isLoadingStaff = true;
  StaffAccountSummary? _selected;
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();
  bool _isVerifying = false;
  bool _obscurePin = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? StaffAccountRepository(appDatabase);
    _session = widget.session ?? sessionController;
    _loadStaff();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  /// Loads ACTIVE staff only — deactivated accounts are not offered.
  Future<void> _loadStaff() async {
    setState(() {
      _isLoadingStaff = true;
      _error = null;
    });
    try {
      final all = await _repository.listStaff();
      if (!mounted) return;
      setState(() {
        _staff = all.where((a) => a.isActive).toList();
        _isLoadingStaff = false;
        if (_staff.isEmpty) {
          _selected = null;
        } else if (_selected != null) {
          // Keep selection only if that account is still listed.
          _selected = _staff.cast<StaffAccountSummary?>().firstWhere(
            (a) => a!.id == _selected!.id,
            orElse: () => null,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingStaff = false;
        _error = 'Could not load staff accounts. Try again.';
      });
    }
  }

  void _select(StaffAccountSummary account) {
    if (_isVerifying) return;
    setState(() {
      _selected = account;
      _error = null;
      _pinController.clear();
    });
    _pinFocus.requestFocus();
  }

  /// Verifies the entered PIN through the real repository. Busy-guarded so
  /// repeated taps cannot fire multiple verifications.
  Future<void> _verify() async {
    if (_isVerifying) return;
    final selected = _selected;
    if (selected == null) {
      setState(() => _error = 'Select your staff account first.');
      return;
    }
    final pin = _pinController.text;
    // Client-side format check first: malformed PINs can never be correct
    // and must not consume a failed attempt (mirrors the repository).
    final pinError = StaffAccountRepository.validatePin(pin);
    if (pinError != null) {
      setState(() => _error = pinError);
      return;
    }

    // Paint the busy state before the (possibly UI-blocking on web)
    // bcrypt verification starts.
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final result = await _repository.verifyPin(
      username: selected.username,
      pin: pin,
    );

    if (!mounted) return;
    _pinController.clear();

    switch (result.status) {
      case StaffAuthStatus.success:
        final account = result.account!;
        _session.signIn(account);
        widget.onAuthenticated?.call();
        setState(() => _isVerifying = false);
      case StaffAuthStatus.invalidPin:
        setState(() {
          _isVerifying = false;
          _error = 'Incorrect PIN. Please try again.';
        });
      case StaffAuthStatus.accountNotFound:
        setState(() {
          _isVerifying = false;
          _error = 'That account no longer exists.';
        });
        unawaited(_loadStaff());
      case StaffAuthStatus.disabled:
        setState(() {
          _isVerifying = false;
          _selected = null;
          _error =
              'This account is deactivated. '
              'Ask the owner to reactivate it.';
        });
        unawaited(_loadStaff());
      case StaffAuthStatus.locked:
        setState(() {
          _isVerifying = false;
          _error = _lockedMessage(result.lockedUntil);
        });
    }
  }

  String _lockedMessage(DateTime? lockedUntil) {
    if (lockedUntil == null) {
      return 'Too many failed attempts. This account is temporarily locked.';
    }
    final local = lockedUntil.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return 'Too many failed attempts. Locked until $hh:$mm.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXl),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppDimensions.spacingLg),
                        if (_isLoadingStaff) ...[
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: AppDimensions.spacingMd),
                          Text(
                            'Loading staff accounts…',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryDark.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ] else if (_staff.isEmpty) ...[
                          _emptyState(),
                        ] else ...[
                          _buildStaffPicker(),
                          const SizedBox(height: AppDimensions.spacingLg),
                          _buildPinForm(),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: AppDimensions.spacingMd),
                          _buildError(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const BrandBadge(size: 52),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          'Sign in to BizFlow',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          'Select your account and enter your PIN to continue.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryDark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingLg),
      child: Column(
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 40,
            color: AppColors.primaryDark.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'No active staff accounts',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Login is required, but no active account can sign in. '
            'Ask the owner to create or reactivate a staff account.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          TextButton.icon(
            onPressed: _loadStaff,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  String _initials(StaffAccountSummary account) {
    final label = account.displayName.trim().isNotEmpty
        ? account.displayName.trim()
        : account.username;
    final parts = label.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts.first.substring(0, 1);
      final last = parts.last.substring(0, 1);
      return (first + last).toUpperCase();
    }
    return label.substring(0, label.length.clamp(1, 2)).toUpperCase();
  }

  Widget _buildStaffPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Staff account',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Wrap(
          spacing: AppDimensions.spacingSm,
          runSpacing: AppDimensions.spacingSm,
          children: _staff.map((account) {
            final selected = _selected?.id == account.id;
            return ChoiceChip(
              avatar: CircleAvatar(
                backgroundColor: selected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  _initials(account),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              label: Text(
                account.displayName.trim().isNotEmpty
                    ? '${account.displayName} (${account.username})'
                    : account.username,
              ),
              selected: selected,
              onSelected: _isVerifying ? null : (_) => _select(account),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPinForm() {
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selected == null ? 'PIN' : 'PIN for ${selected.username}',
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        TextField(
          controller: _pinController,
          focusNode: _pinFocus,
          enabled: !_isVerifying && selected != null,
          obscureText: _obscurePin,
          keyboardType: TextInputType.number,
          maxLength: StaffAccountRepository.maxPinLength,
          onSubmitted: (_) => _verify(),
          style: AppTextStyles.code.copyWith(
            color: AppColors.primaryDark,
            letterSpacing: 3,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: selected == null
                ? 'Select an account first'
                : '${StaffAccountRepository.minPinLength}-'
                      '${StaffAccountRepository.maxPinLength} digits',
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primaryDark.withValues(alpha: 0.6),
            ),
            suffixIcon: IconButton(
              tooltip: _obscurePin ? 'Show PIN' : 'Hide PIN',
              icon: Icon(
                _obscurePin
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.primaryDark.withValues(alpha: 0.6),
              ),
              onPressed: () => setState(() => _obscurePin = !_obscurePin),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: AppColors.primaryDark.withValues(alpha: 0.15),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: AppColors.primaryDark.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        SizedBox(
          height: AppDimensions.buttonHeight,
          child: FilledButton.icon(
            onPressed: (_isVerifying || selected == null) ? null : _verify,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
            ),
            icon: _isVerifying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login_rounded, size: 20),
            label: Text(_isVerifying ? 'Verifying…' : 'Sign in'),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              _error!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
