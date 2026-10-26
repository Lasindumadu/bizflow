import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
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

  /// Bumped every time a NEW error appears so the one-shot shake
  /// (flutter_animate) replays only for fresh errors.
  int _errorSeq = 0;

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

  /// Single place to raise an error — also ticks the shake sequence.
  void _fail(String message, {void Function()? extra}) {
    setState(() {
      _error = message;
      _errorSeq++;
      extra?.call();
    });
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
      _fail('Could not load staff accounts. Try again.');
      setState(() => _isLoadingStaff = false);
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
      _fail('Select your staff account first.');
      return;
    }
    final pin = _pinController.text;
    final pinError = StaffAccountRepository.validatePin(pin);
    if (pinError != null) {
      _fail(pinError);
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
        _fail('Incorrect PIN. Please try again.');
        setState(() => _isVerifying = false);
      case StaffAuthStatus.accountNotFound:
        _fail('That account no longer exists.');
        unawaited(_loadStaff());
      case StaffAuthStatus.disabled:
        _fail('This account is deactivated. Ask the owner to reactivate it.');
        setState(() => _selected = null);
        unawaited(_loadStaff());
      case StaffAuthStatus.locked:
        _fail(_lockedMessage(result.lockedUntil));
        setState(() => _isVerifying = false);
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 980;
          if (wide) {
            // Desktop split: branded photo story left, PIN deck right.
            return Row(
              children: [
                const Expanded(flex: 11, child: _BrandPanel()),
                Expanded(
                  flex: 9,
                  child: BrandBackdrop(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 28,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: _buildAuthCard(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          // Mobile: compact photo hero on top, then the card.
          return BrandBackdrop(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                children: [
                  const _CompactBrandHero(),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: _buildAuthCard(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    final card = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0D1222).withValues(alpha: 0.88)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.brandInk)
                .withValues(alpha: isDark ? 0.45 : 0.14),
            blurRadius: 56,
            offset: const Offset(0, 26),
            spreadRadius: -12,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.16 : 0.10),
            blurRadius: 72,
            offset: const Offset(0, 18),
            spreadRadius: -18,
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
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontFamily: AppTextStyles.displayFont,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Pick your profile and enter your PIN to open the till.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: scheme.onSurface.withValues(alpha: 0.56),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandMint.withValues(
                    alpha: isDark ? 0.12 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.brandMint.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 11,
                      color: AppColors.brandMintDeep,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'SECURE',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.brandMint
                            : AppColors.brandMintDeep,
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
          const SizedBox(height: 20),
          if (_isLoadingStaff)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuroraLoader(size: 26, strokeWidth: 2.4),
                    const SizedBox(height: 12),
                    Text(
                      'Loading your team…',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_staff.isEmpty)
            _emptyState()
          else ...[
            _buildStaffPicker(),
            const SizedBox(height: 18),
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
                color: scheme.onSurface.withValues(alpha: 0.30),
              ),
              const SizedBox(width: 5),
              Text(
                'Local access · no cloud account needed',
                style: TextStyle(
                  fontSize: 10.5,
                  color: scheme.onSurface.withValues(alpha: 0.34),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return card
        .animate()
        .fadeIn(duration: 420.ms, curve: Curves.easeOutCubic)
        .moveY(begin: 12, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildStaffPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHO IS SELLING TODAY?',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: scheme.onSurface.withValues(alpha: 0.42),
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
                              ? AppColors.primary.withValues(
                                  alpha: isDark ? 0.18 : 0.10,
                                )
                              : scheme.onSurface.withValues(
                                  alpha: isDark ? 0.04 : 0.035,
                                ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.primaryLight.withValues(
                                    alpha: isDark ? 0.55 : 0.60,
                                  )
                                : scheme.onSurface.withValues(
                                    alpha: isDark ? 0.07 : 0.08,
                                  ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: selected ? AppDecor.royalGradient : null,
                                color:
                                    selected ? null : scheme.primary.withValues(
                                  alpha: isDark ? 0.14 : 0.10,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _initials(account),
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : scheme.onSurface
                                            .withValues(alpha: 0.62),
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
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '@${account.username} · ${account.role.name}',
                                    style: TextStyle(
                                      color: scheme.onSurface
                                          .withValues(alpha: 0.42),
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
                                      : scheme.onSurface.withValues(
                                          alpha: 0.20,
                                        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

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
                color: scheme.onSurface.withValues(alpha: 0.42),
              ),
            ),
            const Spacer(),
            Text(
              _selected == null ? '' : '@${_selected!.username}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: scheme.primary.withValues(alpha: 0.85),
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
                style: TextStyle(color: scheme.onSurface),
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
                  color: scheme.onSurface.withValues(
                    alpha: isDark ? 0.045 : 0.035,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.onSurface.withValues(alpha: 0.09),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  key: ValueKey('pin-dots-$_errorSeq'),
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
                              : scheme.onSurface.withValues(alpha: 0.14),
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
        const SizedBox(height: 12),
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
    final enabled = !_isVerifying && canSignIn;
    return SizedBox(
      height: 50,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.55,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: enabled ? AppDecor.royalGradient : null,
            color: enabled
                ? null
                : Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.06,
                  ),
            boxShadow: enabled
                ? AppDecor.glow(AppColors.royalMid, alpha: 0.34)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? _verify : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: AuroraLoader(
                          size: 20,
                          strokeWidth: 2,
                          onDarkSurface: true,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Open my workspace',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 17,
                            color: Colors.white.withValues(
                              alpha: enabled ? 1 : 0.30,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.09),
              ),
            ),
            child: Icon(
              Icons.person_off_outlined,
              size: 28,
              color: scheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No active staff accounts',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Ask the owner to create or reactivate a staff account, then refresh.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.45),
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
              foregroundColor: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      key: ValueKey('error-$_errorSeq'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.08,
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFFDA4AF)
                    : const Color(0xFFB91C1C),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate(key: ValueKey('error-shake-$_errorSeq')).shakeX(amount: 4);
  }
}

/// ─────────────────────────────────────────────────────────────
/// Aurora 2.0 brand panels
/// ─────────────────────────────────────────────────────────────

/// Desktop left panel — real photography under the brand wash,
/// carrying the Sora wordmark, tagline and three aurora features.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final features = const [
      (
        Icons.bolt_rounded,
        'Checkout in seconds',
        'Tap, total, done — the till never slows the queue.',
      ),
      (
        Icons.wifi_off_rounded,
        'Works offline',
        'Sell anywhere; everything syncs when you are back.',
      ),
      (
        Icons.insights_rounded,
        'Live insight',
        'Revenue, stock and customers in one calm view.',
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppDecor.photoHero(
            image: AppImages.purpleAbstract,
            anchor: 'left',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(52, 48, 48, 44),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandMark(size: 54),
                    const SizedBox(width: 13),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BizFlow',
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                            color: AppColors.onPhoto,
                          ),
                        ),
                        Text(
                          'RETAIL OPERATING SYSTEM',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: AppColors.onPhotoSoft,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Retail,\nin flow.',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 56,
                    height: 1.02,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2.2,
                    color: AppColors.onPhoto,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'One calm place to sell, track stock, understand your '
                  'numbers and keep every customer coming back.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onPhotoMuted,
                  ),
                ),
                const SizedBox(height: 30),
                ...features.indexed.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StoryFeatureRow(
                      icon: item.$2.$1,
                      label: item.$2.$2,
                      detail: item.$2.$3,
                    )
                        .animate(delay: (60 * item.$1 + 120).ms)
                        .fadeIn(
                          duration: 380.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .moveY(
                          begin: 14,
                          end: 0,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Local-first · PIN protected · yours',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPhotoSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 420.ms, curve: Curves.easeOutCubic)
        .scale(
          begin: const Offset(1.02, 1.02),
          end: const Offset(1, 1),
          duration: 420.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Mobile top hero — a compact photo-backed brand strip.
class _CompactBrandHero extends StatelessWidget {
  const _CompactBrandHero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 176,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppDecor.photoHero(image: AppImages.purpleAbstract, anchor: 'top'),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BrandMark(size: 44),
                      const SizedBox(width: 11),
                      const Text(
                        'BizFlow',
                        style: TextStyle(
                          fontFamily: AppTextStyles.displayFont,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                          color: AppColors.onPhoto,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Retail,\nin flow.',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 30,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.4,
                      color: AppColors.onPhoto,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Checkout in seconds · Works offline · Live insight',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPhotoSoft,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 420.ms, curve: Curves.easeOutCubic)
        .moveY(begin: 12, end: 0, curve: Curves.easeOutCubic);
  }
}

class _StoryFeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;

  const _StoryFeatureRow({
    required this.icon,
    required this.label,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: AppDecor.flowGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppDecor.glow(AppColors.auroraTeal, alpha: 0.28),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onPhoto,
                ),
              ),
              Text(
                detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onPhotoSoft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// Keypad
/// ─────────────────────────────────────────────────────────────

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
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: row
                  .map(
                    (key) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
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
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(height: 48),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _KeypadKey(
                  label: '0',
                  enabled: enabled,
                  onTap: () => onDigit('0'),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
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
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseAlpha = widget.enabled ? (_pressed ? 0.12 : 0.06) : 0.03;
    final hoverAlpha = widget.enabled && _hovered && !_pressed;

    return MouseRegion(
      onEnter: widget.enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: widget.enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onTap();
              }
            : null,
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : (hoverAlpha ? 1.02 : 1),
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(
                alpha: isDark ? baseAlpha + (hoverAlpha ? 0.025 : 0) : baseAlpha,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hoverAlpha
                    ? AppColors.primaryLight.withValues(alpha: 0.45)
                    : scheme.onSurface.withValues(
                        alpha: isDark ? 0.08 : 0.09,
                      ),
              ),
              boxShadow: _pressed
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.enabled ? widget.onTap : null,
                borderRadius: BorderRadius.circular(14),
                splashColor: AppColors.primary.withValues(alpha: 0.08),
                highlightColor: AppColors.primary.withValues(alpha: 0.05),
                child: Center(
                  child: widget.icon != null
                      ? Icon(
                          widget.icon,
                          size: 18,
                          color: scheme.onSurface.withValues(alpha: 0.55),
                        )
                      : Text(
                          widget.label!,
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface.withValues(
                              alpha: widget.enabled ? 0.85 : 0.35,
                            ),
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
}
