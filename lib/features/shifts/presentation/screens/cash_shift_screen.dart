import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/cash_shift_repository.dart';

/// Cashier shift management with cash reconciliation.
class CashShiftScreen extends StatefulWidget {
  const CashShiftScreen({super.key});

  @override
  State<CashShiftScreen> createState() => _CashShiftScreenState();
}

class _CashShiftScreenState extends State<CashShiftScreen> {
  final CashShiftRepository _repository = CashShiftRepository(appDatabase);
  final BusinessSettingsRepository _settingsRepository =
      BusinessSettingsRepository(appDatabase);

  String _currency = 'USD';
  OpenShift? _open;
  List<CashShift> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final open = await _repository.getOpenShift();
    final history = await _repository.getShifts();
    String currency = _currency;
    try {
      currency = (await _settingsRepository.getSettings()).currency;
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _open = open;
      _history = history;
      _currency = currency;
      _loading = false;
    });
  }

  String _money(double v) => '$_currency ${v.toStringAsFixed(2)}';

  Future<void> _openShift() async {
    final controller = TextEditingController(text: '0.00');
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Open Shift'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Opening float',
            prefixIcon: Icon(Icons.payments_outlined),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              ctx,
              double.tryParse(controller.text.trim()) ?? 0,
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );

    if (value == null) return;
    try {
      await _repository.openShift(openingFloat: value);
      await _load();
      _toast('Shift opened.');
    } catch (e) {
      _toast(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  Future<void> _recordMovement(String direction) async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(direction == 'in' ? 'Cash In' : 'Cash Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Record'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    try {
      await _repository.recordMovement(
        direction: direction,
        amount: amount,
        note: noteController.text.trim(),
      );
      await _load();
      _toast('Cash movement recorded.');
    } catch (e) {
      _toast(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  Future<void> _closeShift() async {
    if (_open == null) return;
    final countController = TextEditingController(
      text: _open!.reconciliation.expectedCash.toStringAsFixed(2),
    );
    final reasonController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expected cash: '
              '${_money(_open!.reconciliation.expectedCash)}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Counted cash',
                prefixIcon: Icon(Icons.calculate_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Discrepancy reason (if any)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Close Shift'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    final counted = double.tryParse(countController.text.trim()) ?? 0;
    try {
      await _repository.closeShift(
        countedCash: counted,
        discrepancyReason: reasonController.text.trim(),
      );
      await _load();
      _toast('Shift closed.');
    } catch (e) {
      _toast(e.toString().replaceFirst('Bad state: ', ''));
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: _loading
              ? const AppLoadingState(message: 'Loading shifts…')
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                    children: [
                      const _ShiftHeader(),
                      const SizedBox(height: AppDimensions.spacingMd),
                      if (_open == null) _closedState() else _openState(_open!),
                      const SizedBox(height: AppDimensions.spacingXl),
                      const ModernSectionHeader(
                        title: 'Shift history',
                        subtitle: 'Previous shifts and reconciliation',
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      if (_history.isEmpty)
                        const AppEmptyState(
                          icon: Icons.history_rounded,
                          title: 'No shifts yet',
                          message:
                              'Open a shift to start tracking your cash drawer.',
                        )
                      else
                        ..._history.map(_historyTile),
                      const SizedBox(height: AppDimensions.spacingXl),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _closedState() {
    final scheme = Theme.of(context).colorScheme;
    return BrandCard(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      radius: 24,
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppDecor.royalGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppDecor.glow(AppColors.primary),
                ),
                child: const Icon(
                  Icons.lock_open_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No open shift', style: AppTextStyles.titleMedium),
                    Text(
                      'Open a shift to begin tracking the cash drawer.',
                      style: AppTextStyles.helper.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          GradientButton(
            label: 'Open Shift',
            icon: Icons.lock_open_rounded,
            gradient: AppDecor.royalGradient.colors,
            onPressed: _openShift,
          ),
        ],
      ),
    );
  }

  Widget _openState(OpenShift open) {
    final r = open.reconciliation;
    final scheme = Theme.of(context).colorScheme;

    return BrandCard(
      padding: EdgeInsets.zero,
      radius: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Shift summary hero strip ────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: const BoxDecoration(
                gradient: AppDecor.royalGradient,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.point_of_sale_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shift #${open.shift.shiftNumber} • open',
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          'Since ${_time(open.shift.openedAt)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.auroraTeal.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.auroraTeal.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.auroraTeal,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'OPEN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('Opening float', _money(r.openingFloat)),
                  _kv('Cash sales', _money(r.cashSales)),
                  _kv('Cash in', _money(r.cashIn)),
                  _kv('Cash out', '- ${_money(r.cashOut)}'),
                  _kv('Cash refunds', '- ${_money(r.cashRefunds)}'),
                  const SizedBox(height: AppDimensions.spacingLg),

                  // ── Reconciliation bar ────────────────────────────
                  Text(
                    'DRAWER COMPOSITION',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _reconBar(r),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Row(
                    children: [
                      Text(
                        'Expected in drawer',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _money(r.expectedCash),
                        style: AppTextStyles.priceSmall.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: AppColors.brandMintDeep,
                        ),
                      ),
                    ],
                  ),
                  if (r.cashOut > 0 || r.cashRefunds > 0) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    Row(
                      children: [
                        if (r.cashOut > 0)
                          _smallPill(
                            label: 'OUT ${_shortMoney(r.cashOut)}',
                            color: AppColors.warning,
                          ),
                        if (r.cashOut > 0 && r.cashRefunds > 0)
                          const SizedBox(width: 6),
                        if (r.cashRefunds > 0)
                          _smallPill(
                            label: 'REFUNDS ${_shortMoney(r.cashRefunds)}',
                            color: AppColors.brandCoral,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppDimensions.spacingLg),
                  Row(
                    children: [
                      Expanded(
                        child: SoftButton(
                          label: 'Cash In',
                          icon: Icons.add_rounded,
                          color: AppColors.brandMintDeep,
                          onPressed: () => _recordMovement('in'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: SoftButton(
                          label: 'Cash Out',
                          icon: Icons.remove_rounded,
                          color: AppColors.warningDark,
                          onPressed: () => _recordMovement('out'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  GradientButton(
                    label: 'Close Shift',
                    icon: Icons.lock_rounded,
                    gradient: AppDecor.roseGradient.colors,
                    onPressed: _closeShift,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallPill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.bodyFont,
          fontFeatures: const [FontFeature.tabularFigures()],
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }

  /// Mint stacked composition bar: positive inflows over the aurora rail.
  Widget _reconBar(ShiftReconciliation r) {
    final inflow = r.openingFloat + r.cashSales + r.cashIn;
    final track = inflow <= 0 ? 1.0 : inflow;

    Widget seg(double v, List<Color> colors, String label) {
      final h = Theme.of(context).brightness == Brightness.dark;
      return Expanded(
        flex: (v / track * 1000).round().clamp(1, 1000),
        child: Tooltip(
          message: '$label ${_money(v)}',
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: AppDecor.glow(colors.last, alpha: h ? 0.20 : 0.12),
            ),
          ),
        ),
      );
    }

    Widget gap(double v) {
      if (v <= 0) return const SizedBox.shrink();
      return Expanded(
        flex: (v / track * 1000).round().clamp(1, 1000),
        child: const SizedBox(height: 18),
      );
    }

    return Row(
      children: [
        if (r.openingFloat > 0) ...[
          seg(
            r.openingFloat,
            [AppColors.royalStart, AppColors.primary],
            'Float',
          ),
          const SizedBox(width: 2),
        ],
        if (r.cashSales > 0) ...[
          seg(
            r.cashSales,
            [AppColors.brandMint, AppColors.brandMintDeep],
            'Cash sales',
          ),
          const SizedBox(width: 2),
        ],
        if (r.cashIn > 0) ...[
          seg(r.cashIn, [AppColors.auroraTeal, AppColors.brandMintDeep], 'In'),
          const SizedBox(width: 2),
        ],
        if (inflow <= 0) gap(1),
      ],
    );
  }

  String _shortMoney(double v) => _money(v).split(' ').last;

  Widget _kv(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.numericSmall.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyTile(CashShift shift) {
    final scheme = Theme.of(context).colorScheme;
    final closed = !shift.isOpen;
    final counted = shift.closingCount;
    final hasVariance = closed && shift.discrepancyReason.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Row(
          children: [
            IconTile(
              icon: closed ? Icons.lock_rounded : Icons.lock_open_rounded,
              gradient: closed
                  ? AppDecor.grayGradient.colors
                  : AppDecor.moneyGradient.colors,
              size: 40,
              iconSize: 19,
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shift #${shift.shiftNumber}',
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Float ${_money(shift.openingFloat)} • '
                    '${closed ? 'Closed ${_time(shift.closedAt ?? shift.openedAt)}' : 'Open'}',
                    style: AppTextStyles.caption.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  if (closed && counted != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      'Counted ${_money(counted)}',
                      style: AppTextStyles.caption.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: scheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasVariance)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandAmber.withValues(
                    alpha:
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.16
                            : 0.13,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.brandAmber.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  'VARIANCE',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.brandAmber
                        : const Color(0xFF9A6400),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            StatusBadge(
              label: closed ? 'CLOSED' : 'OPEN',
              color: closed ? AppColors.chartGray : AppColors.brandMint,
            ),
          ],
        ),
      ),
    );
  }

  String _time(DateTime d) {
    final local = d.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

/// Compact photo-backed header for the shifts page.
class _ShiftHeader extends StatelessWidget {
  const _ShiftHeader();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 132,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AppImages.teamStaff,
                fit: BoxFit.cover,
                alignment: const Alignment(0, 0.35),
              ),
              for (final g in AppDecor.photoWash())
                DecoratedBox(decoration: BoxDecoration(gradient: g)),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (canPop) ...[
                      _HeaderIconButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Back',
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.point_of_sale_rounded,
                                size: 14,
                                color: const Color(0xFF7DF3DF),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'RECONCILIATION',
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.bodyFont,
                                  color: Color(0xFF9FE9DE),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Cashier shifts',
                            style: const TextStyle(
                              fontFamily: AppTextStyles.displayFont,
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Opening float, cash drawer & end-of-day counts',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontSize: 11.5,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header back affordance on photo washes.
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    );
  }
}
