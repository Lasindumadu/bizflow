import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/staff_account_repository.dart';

/// Real staff PIN login.
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

  final StaffAccountRepository? repository;
  final SessionController? session;
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
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? StaffAccountRepository(appDatabase);
    _session = widget.session ?? sessionController;
    _pinController.addListener(_onPinChanged);
    _loadStaff();
  }

  @override
  void dispose() {
    _pinController.removeListener(_onPinChanged);
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  void _onPinChanged() {
    if (mounted) setState(() {});
  }

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
          _selected = _staff.cast<StaffAccountSummary?>().firstWhere(
            (a) => a!.id == _selected!.id,
            orElse: () => null,
          );
        } else {
          _selected = _staff.first;
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

  void _tapDigit(String digit) {
    if (_isVerifying || _selected == null) return;
    if (_pinController.text.length >= StaffAccountRepository.maxPinLength) {
      return;
    }
    setState(() {
      _pinController.text += digit;
      _error = null;
    });
    _pinFocus.requestFocus();
  }

  void _backspace() {
    if (_isVerifying) return;
    final value = _pinController.text;
    if (value.isEmpty) return;
    setState(() {
      _pinController.text = value.substring(0, value.length - 1);
      _pinController.selection = TextSelection.collapsed(
        offset: _pinController.text.length,
      );
    });
  }

  Future<void> _verify() async {
    if (_isVerifying) return;
    final selected = _selected;
    if (selected == null) {
      setState(() => _error = 'Select your staff account first.');
      return;
    }
    final pin = _pinController.text;
    final pinError = StaffAccountRepository.validatePin(pin);
    if (pinError != null) {
      setState(() => _error = pinError);
      return;
    }

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
          _error = 'This account is deactivated. Ask the owner to reactivate it.';
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

  String _initials(StaffAccountSummary account) {
    final label = account.displayName.trim().isNotEmpty
        ? account.displayName.trim()
        : account.username;
    final parts = label.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
          .toUpperCase();
    }
    return label.substring(0, label.length.clamp(1, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandInk,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImages.backdrop,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF070A14).withValues(alpha: 0.82),
                    const Color(0xFF0B0F20).withValues(alpha: 0.62),
                    const Color(0xFF070A14).withValues(alpha: 0.88),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          const Positioned.fill(child: GrainOverlay()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 960;
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 48 : 20,
                      vertical: 28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1160),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  flex: 6,
                                  child: _LoginStory(),
                                ),
                                const SizedBox(width: 56),
                                Expanded(
                                  flex: 4,
                                  child: _buildAuthCard(),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const _LoginStory(compact: true),
                                const SizedBox(height: 24),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 460),
                                  child: _buildAuthCard(),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1222).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 60,
            offset: const Offset(0, 28),
            spreadRadius: -12,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 80,
            offset: const Offset(0, 20),
            spreadRadius: -20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Pick your profile and enter your PIN to open the till.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.54),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandMint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.brandMint.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 11,
                      color: AppColors.brandMint,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'SECURE',
                      style: TextStyle(
                        color: AppColors.brandMint,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (_isLoadingStaff)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryLight),
              ),
            )
          else if (_staff.isEmpty)
            _emptyState()
          else ...[
            _buildStaffPicker(),
            const SizedBox(height: 20),
            _buildPinPad(),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            _buildError(),
          ],
          const SizedBox(height: 20),
          _signInButton(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: Colors.white.withValues(alpha: 0.28),
              ),
              const SizedBox(width: 5),
              Text(
                'Local access · no cloud account needed',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.white.withValues(alpha: 0.30),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _buildStaffPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHO IS SELLING TODAY?',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white.withValues(alpha: 0.38),
          ),
        ),
        const SizedBox(height: 9),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 186),
          child: SingleChildScrollView(
            child: Column(
              children: _staff.map((account) {
                final selected = _selected?.id == account.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isVerifying ? null : () => _select(account),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryLight.withValues(alpha: 0.55)
                                : Colors.white.withValues(alpha: 0.07),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF8B6CFF),
                                          Color(0xFF5B5BF7),
                                        ],
                                      )
                                    : null,
                                color: selected
                                    ? null
                                    : Colors.white.withValues(alpha: 0.07),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _initials(account),
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.64),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.displayName.trim().isEmpty
                                        ? account.username
                                        : account.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '@${account.username} · ${account.role.name}',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.38),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.brandMint
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? AppColors.brandMint
                                      : Colors.white.withValues(alpha: 0.18),
                                ),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Color(0xFF04372F),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinPad() {
    final pin = _pinController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ENTER PIN',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.white.withValues(alpha: 0.38),
              ),
            ),
            const Spacer(),
            Text(
              _selected == null ? '' : '@${_selected!.username}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Real input supports a physical keyboard and barcode-style entry.
        Stack(
          children: [
            Opacity(
              opacity: 0.015,
              child: TextField(
                controller: _pinController,
                focusNode: _pinFocus,
                enabled: !_isVerifying && _selected != null,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: StaffAccountRepository.maxPinLength,
                onSubmitted: (_) => _verify(),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _pinFocus.requestFocus(),
              child: Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    StaffAccountRepository.maxPinLength,
                    (index) {
                      final filled = index < pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: filled ? 12 : 9,
                        height: filled ? 12 : 9,
                        margin: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: filled
                              ? AppColors.brandMint
                              : Colors.white.withValues(alpha: 0.12),
                          boxShadow: filled
                              ? [
                                  BoxShadow(
                                    color: AppColors.brandMint
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _PinKeypad(
          enabled: !_isVerifying && _selected != null,
          onDigit: _tapDigit,
          onBackspace: _backspace,
        ),
      ],
    );
  }

  Widget _signInButton() {
    final canSignIn = _selected != null &&
        _pinController.text.length >= StaffAccountRepository.minPinLength;
    return SizedBox(
      height: 50,
      child: FilledButton(
        onPressed: _isVerifying || !canSignIn ? null : _verify,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.07),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isVerifying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Open my workspace',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: Colors.white.withValues(
                      alpha: canSignIn ? 1 : 0.30,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(
              Icons.person_off_outlined,
              size: 28,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No active staff accounts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Ask the owner to create or reactivate a staff account, then refresh.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadStaff,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Refresh'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.brandCoral.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.brandCoral.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.brandCoral,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFFFB3C1),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).shakeX(amount: 4);
  }
}

/// Left-hand brand story shown on wide layouts.
class _LoginStory extends StatelessWidget {
  final bool compact;
  const _LoginStory({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            BrandMark(size: compact ? 42 : 54),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BizFlow',
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: compact ? 26 : 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'RETAIL OPERATING SYSTEM',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Colors.white.withValues(alpha: 0.38),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: compact ? 18 : 34),
        Text(
          'Retail,\nin flow.',
          style: TextStyle(
            fontFamily: AppTextStyles.displayFont,
            fontSize: compact ? 34 : 56,
            height: 1.02,
            fontWeight: FontWeight.w700,
            letterSpacing: -2.2,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'One calm place to sell, track stock, understand your numbers '
          'and keep every customer coming back.',
          style: TextStyle(
            fontSize: compact ? 12.5 : 14,
            height: 1.6,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 28),
          SizedBox(
            height: 230,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                AppImages.posIllustration,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _StoryFeature(icon: Icons.bolt_rounded, label: 'Checkout in seconds'),
            _StoryFeature(icon: Icons.offline_bolt_outlined, label: 'Works offline'),
            _StoryFeature(icon: Icons.insights_rounded, label: 'Live insight'),
          ],
        ),
      ],
    );
  }
}

class _StoryFeature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StoryFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.brandMint),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tactile numeric keypad. Keeps the physical-keyboard path intact.
class _PinKeypad extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _PinKeypad({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        ...keys.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: row
                  .map(
                    (key) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.5),
                        child: _KeypadKey(
                          label: key,
                          enabled: enabled,
                          onTap: () => onDigit(key),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        Row(
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.5),
                child: SizedBox(height: 46),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.5),
                child: _KeypadKey(
                  label: '0',
                  enabled: enabled,
                  onTap: () => onDigit('0'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.5),
                child: _KeypadKey(
                  icon: Icons.backspace_outlined,
                  enabled: enabled,
                  onTap: onBackspace,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeypadKey extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final bool enabled;
  final VoidCallback onTap;

  const _KeypadKey({
    this.label,
    this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_KeypadKey> createState() => _KeypadKeyState();
}

class _KeypadKeyState extends State<_KeypadKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: widget.enabled
                  ? (_pressed ? 0.11 : 0.055)
                  : 0.025,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.55),
                  )
                : Text(
                    widget.label!,
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
