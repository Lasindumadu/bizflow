import 'package:flutter/material.dart';

import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/staff_account_repository.dart';

/// Phase F: staff account administration and owner recovery.
///
/// The screen is a thin shell over [StaffAccountRepository]; every privileged
/// action (create, role change, activation, PIN reset, recovery) is
/// authorized **in the repository**, not here. A non-owner session sees the
/// actions offered but the repository rejects them with a [StateError],
/// which this screen surfaces in a snack bar.
class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key, this.repository});

  /// Injectable for tests; defaults to the app database singleton.
  final StaffAccountRepository? repository;

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  late final StaffAccountRepository _repository;

  List<StaffAccountSummary> _staff = [];
  bool _isLoading = true;
  String? _error;

  /// Result of the login-readiness pre-flight check.
  ({bool ready, String message})? _readiness;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? StaffAccountRepository(appDatabase);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final staff = await _repository.listStaff();
      final readiness = await _repository.checkLoginReadiness();
      if (!mounted) return;
      setState(() {
        _staff = staff;
        _readiness = readiness;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Could not load staff accounts: $error';
      });
    }
  }

  void _report(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$error'), backgroundColor: AppColors.error),
    );
  }

  void _reportOk(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// True when the acting session is the owner.
  bool get _isOwner => sessionController.current?.role == StaffRole.owner;

  Future<void> _createAccount() async {
    final result = await showDialog<_NewStaffAccount>(
      context: context,
      builder: (context) => const _NewStaffAccountDialog(),
    );
    if (result == null) return;

    try {
      final created = await _repository.createAccount(
        role: result.role,
        username: result.username,
        pin: result.pin,
        displayName: result.displayName,
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      _reportOk('Created ${created.account.username}.');
    } catch (error) {
      _report(error);
    }
  }

  Future<void> _resetPin(StaffAccountSummary account) async {
    final newPin = await showDialog<String>(
      context: context,
      builder: (context) => const _ResetPinDialog(),
    );
    if (newPin == null) return;

    try {
      await _repository.changePin(
        username: account.username,
        newPin: newPin,
        asOwner: true,
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      _reportOk('PIN reset for ${account.username}.');
    } catch (error) {
      _report(error);
    }
  }

  Future<void> _toggleActive(StaffAccountSummary account) async {
    try {
      await _repository.setActive(
        username: account.username,
        isActive: !account.isActive,
        asOwner: true,
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      _reportOk(
        '${account.username} ${account.isActive ? 'deactivated' : 'reactivated'}.',
      );
    } catch (error) {
      _report(error);
    }
  }

  Future<void> _changeRole(StaffAccountSummary account) async {
    final role = await showDialog<StaffRole>(
      context: context,
      builder: (context) => _ChangeRoleDialog(currentRole: account.role),
    );
    if (role == null) return;

    try {
      await _repository.setRole(
        username: account.username,
        role: role,
        asOwner: true,
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      _reportOk('${account.username} is now a ${role.name}.');
    } catch (error) {
      _report(error);
    }
  }

  Future<void> _recoverOwnerPin() async {
    final result = await showDialog<_OwnerRecoveryResult>(
      context: context,
      builder: (context) => const _OwnerRecoveryDialog(),
    );
    if (result == null) return;

    if (!mounted) return;
    await _load();
    if (!mounted) return;
    // The rotated recovery code is shown exactly once — it is never stored
    // in plaintext and cannot be retrieved again.
    await showDialog<void>(
      context: context,
      builder: (context) => _RecoveryCodeDialog(
        username: result.username,
        recoveryCode: result.newRecoveryCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BrandPageHeader(
                eyebrow: 'Team',
                title: 'Staff & access',
                subtitle: 'Manage PIN accounts, roles and recovery.',
                icon: Icons.badge_rounded,
              ),
              Expanded(
                child: _isLoading
                    ? const AppLoadingState(message: 'Loading staff accounts…')
                    : _error != null
                    ? AppEmptyState(
                        icon: Icons.error_outline_rounded,
                        title: 'Could not load staff',
                        message: _error!,
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                        children: [
                          _readinessCard(context),
                          const SizedBox(height: 14),
                          _staffCard(context),
                          const SizedBox(height: 14),
                          _recoveryCard(context),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Phase F: the login-readiness pre-flight result.
  Widget _readinessCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final readiness = _readiness;
    final ready = readiness?.ready ?? false;

    return BrandCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: (ready ? AppColors.success : AppColors.warning)
                      .withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  ready
                      ? Icons.verified_user_rounded
                      : Icons.gpp_maybe_rounded,
                  size: 17,
                  color: ready ? AppColors.success : AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Login readiness',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              BrandPill(
                label: ready ? 'READY' : 'CHECK',
                color: ready ? AppColors.brandMint : AppColors.brandAmber,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            readiness?.message ?? 'Readiness has not been checked yet.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Required before startup PIN login can be enabled: an active '
            'owner account with a PIN and a recorded recovery code.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: scheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BrandCard(
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Staff accounts',
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _createAccount,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('Add staff'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            if (_staff.isEmpty)
              Text(
                'No staff accounts yet. Add the first owner to enable PIN login.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else
              ..._staff.map(
                (account) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.spacingXs,
                  ),
                  child: _StaffRow(
                    account: account,
                    isOwner: _isOwner,
                    onResetPin: () => _resetPin(account),
                    onChangeRole: () => _changeRole(account),
                    onToggleActive: () => _toggleActive(account),
                  ),
                ),
              ),
          ],
        ),
    );
  }

  /// Phase F: owner-only recovery. Reachable without a session because it is
  /// the escape hatch for a forgotten owner PIN.
  Widget _recoveryCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BrandCard(
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Owner recovery',
              style: AppTextStyles.labelMedium.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Lost the owner PIN? Enter the one-time recovery code that was '
              'shown when the owner account was created to set a new PIN. The '
              'recovery code is rotated and must be recorded again.',
              style: AppTextStyles.bodySmall.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            OutlinedButton.icon(
              onPressed: _recoverOwnerPin,
              icon: const Icon(Icons.vpn_key_rounded, size: 18),
              label: const Text('Recover owner PIN'),
            ),
          ],
        ),
    );
  }
}

/// A single staff account row with its admin actions.
class _StaffRow extends StatelessWidget {
  final StaffAccountSummary account;
  final bool isOwner;
  final VoidCallback onResetPin;
  final VoidCallback onChangeRole;
  final VoidCallback onToggleActive;

  const _StaffRow({
    required this.account,
    required this.isOwner,
    required this.onResetPin,
    required this.onChangeRole,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppDecor.primaryGradient,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              account.username.isEmpty
                  ? '?'
                  : account.username.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontFamily: AppTextStyles.displayFont,
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.displayName.isEmpty
                      ? account.username
                      : account.displayName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${account.username} • ${account.role.name}'
                  '${account.isActive ? '' : ' • deactivated'}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isOwner) ...[
            IconButton(
              tooltip: 'Change role',
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 20),
              onPressed: account.role == StaffRole.owner ? null : onChangeRole,
            ),
            IconButton(
              tooltip: 'Reset PIN',
              icon: const Icon(Icons.password_rounded, size: 20),
              onPressed: onResetPin,
            ),
            IconButton(
              tooltip: account.isActive ? 'Deactivate' : 'Reactivate',
              icon: Icon(
                account.isActive
                    ? Icons.person_off_outlined
                    : Icons.person_add_alt_1_outlined,
                size: 20,
              ),
              onPressed: account.role == StaffRole.owner
                  ? null
                  : onToggleActive,
            ),
          ],
        ],
      ),
    );
  }
}

/// The result of the "new staff account" dialog.
class _NewStaffAccount {
  final String username;
  final String pin;
  final String displayName;
  final StaffRole role;

  const _NewStaffAccount({
    required this.username,
    required this.pin,
    required this.displayName,
    required this.role,
  });
}

/// Dialog for creating a staff account.
class _NewStaffAccountDialog extends StatefulWidget {
  const _NewStaffAccountDialog();

  @override
  State<_NewStaffAccountDialog> createState() => _NewStaffAccountDialogState();
}

class _NewStaffAccountDialogState extends State<_NewStaffAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  StaffRole _role = StaffRole.cashier;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      _NewStaffAccount(
        username: _usernameController.text.trim(),
        pin: _pinController.text.trim(),
        displayName: _displayNameController.text.trim(),
        role: _role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add staff account'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<StaffRole>(
                  initialValue: _role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(
                      value: StaffRole.owner,
                      child: Text('Owner'),
                    ),
                    DropdownMenuItem(
                      value: StaffRole.manager,
                      child: Text('Manager'),
                    ),
                    DropdownMenuItem(
                      value: StaffRole.cashier,
                      child: Text('Cashier'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _role = value);
                  },
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => StaffAccountRepository.validateUsername(
                    StaffAccountRepository.normalizeUsername(value ?? ''),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(labelText: 'Display name'),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'PIN'),
                  validator: (value) =>
                      StaffAccountRepository.validatePin(value?.trim() ?? ''),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                TextFormField(
                  controller: _confirmPinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm PIN'),
                  validator: (value) =>
                      value?.trim() != _pinController.text.trim()
                      ? 'The PINs do not match.'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}

/// Dialog for resetting a staff PIN (owner action).
class _ResetPinDialog extends StatefulWidget {
  const _ResetPinDialog();

  @override
  State<_ResetPinDialog> createState() => _ResetPinDialogState();
}

class _ResetPinDialogState extends State<_ResetPinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(_pinController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset PIN'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _pinController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New PIN'),
                validator: (value) =>
                    StaffAccountRepository.validatePin(value?.trim() ?? ''),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              TextFormField(
                controller: _confirmPinController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm PIN'),
                validator: (value) =>
                    value?.trim() != _pinController.text.trim()
                    ? 'The PINs do not match.'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Reset PIN')),
      ],
    );
  }
}

/// Dialog for changing a staff role (owner action).
class _ChangeRoleDialog extends StatelessWidget {
  final StaffRole currentRole;

  const _ChangeRoleDialog({required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Change role'),
      children: [
        for (final role in StaffRole.values)
          SimpleDialogOption(
            onPressed: role == currentRole
                ? null
                : () => Navigator.of(context).pop(role),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(role.name),
              trailing: role == currentRole
                  ? const Icon(Icons.check_rounded, size: 18)
                  : null,
            ),
          ),
      ],
    );
  }
}

/// The result of a successful owner recovery.
class _OwnerRecoveryResult {
  final String username;
  final String newRecoveryCode;

  const _OwnerRecoveryResult({
    required this.username,
    required this.newRecoveryCode,
  });
}

/// Dialog for recovering a forgotten owner PIN.
class _OwnerRecoveryDialog extends StatefulWidget {
  const _OwnerRecoveryDialog();

  @override
  State<_OwnerRecoveryDialog> createState() => _OwnerRecoveryDialogState();
}

class _OwnerRecoveryDialogState extends State<_OwnerRecoveryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _recoveryController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isWorking = false;

  @override
  void dispose() {
    _recoveryController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isWorking = true);
    try {
      final recovered = await StaffAccountRepository(appDatabase)
          .recoverOwnerPin(
            recoveryCode: _recoveryController.text.trim(),
            newPin: _pinController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(
        _OwnerRecoveryResult(
          username: recovered.account.username,
          newRecoveryCode: recovered.newRecoveryCode,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isWorking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recover owner PIN'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _recoveryController,
                  decoration: const InputDecoration(
                    labelText: 'Recovery code',
                    hintText: 'XXXX-XXXX-XXXX-XXXX',
                  ),
                  validator: (value) {
                    final code = StaffAccountRepository.normalizeRecoveryCode(
                      value ?? '',
                    );
                    if (code.isEmpty) return 'Enter the recovery code.';
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New PIN'),
                  validator: (value) =>
                      StaffAccountRepository.validatePin(value?.trim() ?? ''),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                TextFormField(
                  controller: _confirmPinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm PIN'),
                  validator: (value) =>
                      value?.trim() != _pinController.text.trim()
                      ? 'The PINs do not match.'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isWorking ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isWorking ? null : _submit,
          child: Text(_isWorking ? 'Recovering…' : 'Recover PIN'),
        ),
      ],
    );
  }
}

/// Shows the rotated recovery code exactly once.
class _RecoveryCodeDialog extends StatelessWidget {
  final String username;
  final String recoveryCode;

  const _RecoveryCodeDialog({
    required this.username,
    required this.recoveryCode,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record your new recovery code'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The owner PIN for "$username" was reset. This recovery code is '
              'shown only once — record it now. The previous code no longer '
              'works.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Text(
                recoveryCode,
                textAlign: TextAlign.center,
                style: AppTextStyles.code.copyWith(
                  color: AppColors.primaryDark,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('I have recorded it'),
        ),
      ],
    );
  }
}
