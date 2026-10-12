import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/widgets/premium_ui.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/business_settings_repository.dart';
import '../../../../data/repositories/inventory_intelligence_repository.dart';
import '../../../inventory/presentation/screens/inventory_screen.dart'
    as inventory;

/// Inventory intelligence: reorder suggestions, dead stock and valuation.
///
/// This turns raw stock numbers into decisions a shop owner can act on.
class InventoryIntelligenceScreen extends StatefulWidget {
  const InventoryIntelligenceScreen({super.key});

  @override
  State<InventoryIntelligenceScreen> createState() =>
      _InventoryIntelligenceScreenState();
}

class _InventoryIntelligenceScreenState
    extends State<InventoryIntelligenceScreen> {
  final InventoryIntelligenceRepository _repository =
      InventoryIntelligenceRepository(appDatabase);
  final BusinessSettingsRepository _settingsRepository =
      BusinessSettingsRepository(appDatabase);

  String _currency = 'USD';

  late Future<_IntelligenceData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      final settings = await _settingsRepository.getSettings();
      if (!mounted) return;
      setState(() => _currency = settings.currency);
    } catch (_) {}
  }

  Future<_IntelligenceData> _load() async {
    final reorder = await _repository.getReorderSuggestions();
    final dead = await _repository.getDeadStock();
    final valuation = await _repository.getStockValuation();
    return _IntelligenceData(
      reorder: reorder,
      deadStock: dead,
      valuation: valuation,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  String _money(double value) => '$_currency ${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Intelligence'),
        actions: [
          IconButton(
            tooltip: 'Manage inventory',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const inventory.InventoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<_IntelligenceData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState(message: 'Analysing your inventory…');
          }

          if (snapshot.hasError) {
            return AppErrorState(
              title: 'Could not analyse inventory',
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              children: [
                _valuationSection(data.valuation),
                const SizedBox(height: AppDimensions.spacingXl),
                ModernSectionHeader(
                  title: 'Reorder suggestions',
                  subtitle:
                      '${data.reorder.length} product'
                      '${data.reorder.length == 1 ? '' : 's'} need attention',
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                if (data.reorder.isEmpty)
                  const _InlineNote(
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    message: 'Everything is well stocked. Nothing to reorder.',
                  )
                else
                  ...data.reorder.map(_reorderCard),
                const SizedBox(height: AppDimensions.spacingXl),
                ModernSectionHeader(
                  title: 'Dead stock',
                  subtitle:
                      'No sales in 60 days • ${_money(_deadValue(data.deadStock))} '
                      'tied up',
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                if (data.deadStock.isEmpty)
                  const _InlineNote(
                    icon: Icons.auto_graph_rounded,
                    color: AppColors.info,
                    message: 'No dead stock — your inventory is moving well.',
                  )
                else
                  ...data.deadStock.map(_deadStockTile),
                const SizedBox(height: AppDimensions.spacingXl),
              ],
            ),
          );
        },
      ),
    );
  }

  double _deadValue(List<DeadStockItem> items) =>
      items.fold(0.0, (sum, i) => sum + i.stockValue);

  Widget _valuationSection(StockValuation v) {
    return ResponsiveGrid(
      children: [
        PremiumKpiTile(
          title: 'Stock Value (cost)',
          value: _money(v.costValue),
          icon: Icons.account_balance_wallet_rounded,
          gradient: AppDecor.indigoGradient.colors,
        ),
        PremiumKpiTile(
          title: 'Stock Value (retail)',
          value: _money(v.retailValue),
          icon: Icons.storefront_rounded,
          gradient: AppDecor.skyGradient.colors,
        ),
        PremiumKpiTile(
          title: 'Potential Profit',
          value: _money(v.potentialProfit),
          icon: Icons.trending_up_rounded,
          gradient: AppDecor.moneyGradient.colors,
        ),
        PremiumKpiTile(
          title: 'Units / Products',
          value: '${v.totalUnits} / ${v.productCount}',
          icon: Icons.inventory_2_rounded,
          gradient: AppDecor.amberGradient.colors,
        ),
      ],
    );
  }

  Widget _reorderCard(ReorderSuggestion s) {
    final urgent = s.isOutOfStock;
    final tone = urgent ? AppColors.error : AppColors.warning;
    final status = urgent
        ? 'OUT OF STOCK'
        : '${s.currentStock} left • ${s.daysOfCover == 999 ? '—' : s.daysOfCover}d cover';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        borderColor: tone.withValues(alpha: 0.3),
        child: Row(
          children: [
            IconTile(
              icon: urgent
                  ? Icons.error_outline_rounded
                  : Icons.shopping_cart_checkout_rounded,
              gradient: urgent
                  ? [AppColors.error, AppColors.errorDark]
                  : [AppColors.warning, AppColors.warningDark],
              size: 44,
              iconSize: 21,
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'SKU ${s.sku} • sold ${s.soldLast30Days} in 30d',
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 6),
                  StatusBadge(label: status, color: tone),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Reorder',
                  style: AppTextStyles.badge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '+${s.suggestedReorderQuantity}',
                  style: AppTextStyles.priceSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _deadStockTile(DeadStockItem d) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Row(
          children: [
            IconTile(
              icon: Icons.inventory_2_outlined,
              gradient: [AppColors.chartGray, AppColors.chartGray],
              size: 42,
              iconSize: 20,
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  Text(
                    d.lastSoldAt == null
                        ? 'Never sold • ${d.stockQuantity} in stock'
                        : 'Last sold ${_formatDate(d.lastSoldAt!)} • '
                              '${d.stockQuantity} in stock',
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _money(d.stockValue),
              style: AppTextStyles.priceSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _IntelligenceData {
  final List<ReorderSuggestion> reorder;
  final List<DeadStockItem> deadStock;
  final StockValuation valuation;

  const _IntelligenceData({
    required this.reorder,
    required this.deadStock,
    required this.valuation,
  });
}

class _InlineNote extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _InlineNote({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
