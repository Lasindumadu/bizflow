import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
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
      appBar: AppBar(title: const Text('Cashier Shifts')),
      body: _loading
          ? const AppLoadingState(message: 'Loading shifts…')
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                children: [
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
    );
  }

  Widget _closedState() {
    return HoverLiftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(
                icon: Icons.lock_open_rounded,
                gradient: AppDecor.indigoGradient.colors,
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
                        color: Theme.of(context).colorScheme.onSurface
                            .withValues(alpha: 0.6),
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
            onPressed: _openShift,
          ),
        ],
      ),
    );
  }

  Widget _openState(OpenShift open) {
    final r = open.reconciliation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HoverLiftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconTile(
                    icon: Icons.point_of_sale_rounded,
                    gradient: AppDecor.moneyGradient.colors,
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shift #${open.shift.shiftNumber} • open',
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          'Since ${_time(open.shift.openedAt)}',
                          style: AppTextStyles.caption.copyWith(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const StatusBadge(
                    label: 'OPEN',
                    color: AppColors.success,
                    icon: Icons.circle,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              _kv('Opening float', _money(r.openingFloat)),
              _kv('Cash sales', _money(r.cashSales)),
              _kv('Cash in', _money(r.cashIn)),
              _kv('Cash out', '- ${_money(r.cashOut)}'),
              _kv('Cash refunds', '- ${_money(r.cashRefunds)}'),
              const Divider(height: 24),
              Row(
                children: [
                  Text('Expected in drawer', style: AppTextStyles.titleSmall),
                  const Spacer(),
                  Text(
                    _money(r.expectedCash),
                    style: AppTextStyles.priceSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: SoftButton(
                      label: 'Cash In',
                      icon: Icons.add_rounded,
                      color: AppColors.success,
                      onPressed: () => _recordMovement('in'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  Expanded(
                    child: SoftButton(
                      label: 'Cash Out',
                      icon: Icons.remove_rounded,
                      color: AppColors.warning,
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
    );
  }

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
          Text(value, style: AppTextStyles.numericSmall),
        ],
      ),
    );
  }

  Widget _historyTile(CashShift shift) {
    final scheme = Theme.of(context).colorScheme;
    final closed = !shift.isOpen;
    final counted = shift.closingCount;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Row(
          children: [
            IconTile(
              icon: closed ? Icons.lock_rounded : Icons.lock_open_rounded,
              gradient: closed
                  ? [AppColors.chartGray, AppColors.chartGray]
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
                  Text(
                    'Float ${_money(shift.openingFloat)} • '
                    '${closed && counted != null ? 'Counted ${_money(counted)}' : 'Open'}',
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: closed ? 'CLOSED' : 'OPEN',
              color: closed ? AppColors.chartGray : AppColors.success,
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
