import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
import '../../../../core/widgets/modern_widgets.dart';
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
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BrandPageHeader(
                eyebrow: 'Insights',
                title: 'Inventory intelligence',
                subtitle:
                    'What to reorder, what is sleeping, and what it is all worth.',
                icon: Icons.insights_rounded,
                actions: [
                  BrandHeaderAction(
                    icon: Icons.tune_rounded,
                    tooltip: 'Manage inventory',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const inventory.InventoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: FutureBuilder<_IntelligenceData>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const AppLoadingState(
                          message: 'Analysing your inventory…',
                        );
                      }

                      if (snapshot.hasError) {
                        return AppErrorState(
                          title: 'Could not analyse inventory',
                          message: snapshot.error.toString(),
                          onRetry: _refresh,
                        );
                      }

                      final data = snapshot.data!;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.screenPadding,
                          AppDimensions.spacingMd,
                          AppDimensions.screenPadding,
                          AppDimensions.spacingXl,
                        ),
                        children: [
                          _valuationSection(data.valuation)
                              .animate(delay: 60.ms)
                              .fadeIn(
                                duration: 400.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .moveY(
                                begin: 14,
                                end: 0,
                                duration: 400.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          const SizedBox(height: AppDimensions.spacingXl),
                          SectionHeading(
                            title: 'Reorder suggestions',
                            subtitle:
                                '${data.reorder.length} product'
                                '${data.reorder.length == 1 ? '' : 's'} need attention',
                            icon: Icons.shopping_cart_checkout_rounded,
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          if (data.reorder.isEmpty)
                            const _InlineNote(
                              icon: Icons.check_circle_rounded,
                              color: AppColors.success,
                              message:
                                  'Everything is well stocked. Nothing to reorder.',
                            ).animate().fadeIn(duration: 400.ms)
                          else
                            ...data.reorder.asMap().entries.map(
                              (entry) {
                                final card = _reorderCard(entry.value);
                                if (entry.key >= 12) return card;
                                return card
                                    .animate(
                                      delay: Duration(
                                        milliseconds:
                                            60 * (entry.key + 1) + 100,
                                      ),
                                    )
                                    .fadeIn(
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .moveY(
                                      begin: 14,
                                      end: 0,
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    );
                              },
                            ),
                          const SizedBox(height: AppDimensions.spacingXl),
                          SectionHeading(
                            title: 'Dead stock',
                            subtitle:
                                'No sales in 60 days • '
                                '${_money(_deadValue(data.deadStock))} tied up',
                            icon: Icons.hourglass_bottom_rounded,
                          ),
                          const SizedBox(height: AppDimensions.spacingMd),
                          if (data.deadStock.isEmpty)
                            const _InlineNote(
                              icon: Icons.auto_graph_rounded,
                              color: AppColors.info,
                              message:
                                  'No dead stock — your inventory is moving well.',
                            ).animate().fadeIn(duration: 400.ms)
                          else
                            ...data.deadStock.asMap().entries.map(
                              (entry) {
                                final tile = _deadStockTile(entry.value);
                                if (entry.key >= 12) return tile;
                                return tile
                                    .animate(
                                      delay: Duration(
                                        milliseconds:
                                            60 * (entry.key + 1) + 100,
                                      ),
                                    )
                                    .fadeIn(
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .moveY(
                                      begin: 14,
                                      end: 0,
                                      duration: 400.ms,
                                      curve: Curves.easeOutCubic,
                                    );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _deadValue(List<DeadStockItem> items) =>
      items.fold(0.0, (sum, i) => sum + i.stockValue);

  /// Valuation hero: warehouse photo under the brand wash, flowGradient
  /// accent bar, and the stock-value numbers as the headline.
  Widget _valuationSection(StockValuation v) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: AppDecor.layeredShadow(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo micro-wash anchor (warehouse) with headline numbers.
            SizedBox(
              height: 168,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppDecor.photoHero(
                    image: AppImages.warehouse,
                    anchor: 'left',
                    imageAlignmentY: 0.35,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.account_balance_rounded,
                                    size: 13,
                                    color: AppColors.auroraTeal,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'STOCK VALUATION',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Potential profit',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.1,
                                      color: Colors.white.withValues(
                                        alpha: 0.62,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _money(v.potentialProfit),
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.displayFont,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1,
                                        height: 1.05,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _heroStat(
                              'Cost',
                              _money(v.costValue),
                            ),
                            const SizedBox(width: 10),
                            _heroStat(
                              'Retail',
                              _money(v.retailValue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // flowGradient accent bar.
            Container(height: 3, decoration: const BoxDecoration(gradient: AppDecor.flowGradient)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _auxStat(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'COST VALUE',
                      value: _money(v.costValue),
                      soft: AppColors.stockTint.first,
                      deep: AppColors.stockTint.last,
                      darkDeep: AppColors.auroraBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _auxStat(
                      icon: Icons.storefront_rounded,
                      label: 'RETAIL VALUE',
                      value: _money(v.retailValue),
                      soft: AppColors.moneyTint.first,
                      deep: AppColors.brandMintDeep,
                      darkDeep: AppColors.brandMint,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _auxStat(
                      icon: Icons.inventory_2_rounded,
                      label: 'UNITS / SKUS',
                      value: '${v.totalUnits} / ${v.productCount}',
                      soft: AppColors.growthTint.first,
                      deep: AppColors.warningDark,
                      darkDeep: AppColors.warningLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: Colors.white.withValues(alpha: 0.60),
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTextStyles.displayFont,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _auxStat({
    required IconData icon,
    required String label,
    required String value,
    required Color soft,
    required Color deep,
    required Color darkDeep,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? darkDeep.withValues(alpha: 0.20) : soft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: deep.withValues(alpha: isDark ? 0.32 : 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: isDark ? darkDeep : deep),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.displayFont,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              fontFeatures: const [
                FontFeature.tabularFigures(),
              ],
              color: isDark ? darkDeep : deep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reorderCard(ReorderSuggestion s) {
    // Priority: out of stock = critical (red), thin cover = soon
    // (amber), otherwise ok (mint).
    final critical = s.isOutOfStock;
    final soon = !critical && s.currentStock <= s.daysOfCover + 5;
    final tone = critical
        ? AppColors.error
        : (soon ? AppColors.warning : AppColors.brandMintDeep);
    final toneDark = critical
        ? AppColors.errorLight
        : (soon ? AppColors.warningLight : AppColors.brandMint);
    final priorityLabel = critical ? 'CRITICAL' : (soon ? 'SOON' : 'OK');

    final status = critical
        ? 'Out of stock'
        : '${s.currentStock} left • ${s.daysOfCover == 999 ? '—' : s.daysOfCover}d cover';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        radius: 20,
        borderColor: tone.withValues(alpha: isDark ? 0.38 : 0.30),
        child: Row(
          children: [
            IconTile(
              icon: critical
                  ? Icons.error_outline_rounded
                  : Icons.shopping_cart_checkout_rounded,
              gradient: critical
                  ? AppDecor.errorGradient.colors
                  : (soon
                      ? AppDecor.amberGradient.colors
                      : AppDecor.flowGradient.colors),
              size: 44,
              iconSize: 21,
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.displayFont,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BrandPill(
                        label: priorityLabel,
                        color: isDark ? toneDark : tone,
                        icon: critical
                            ? Icons.priority_high_rounded
                            : (soon
                                ? Icons.schedule_rounded
                                : Icons.check_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'SKU ${s.sku} • sold ${s.soldLast30Days} in 30d',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? toneDark : tone,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Reorder',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '+${s.suggestedReorderQuantity}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.displayFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: isDark ? AppColors.auroraLilac : AppColors.royalEnd,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final dust = scheme.onSurface.withValues(alpha: isDark ? 0.45 : 0.48);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        radius: 18,
        child: Row(
          children: [
            // Dust-style squircle — muted gray with a "sleeping" glyph.
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: AppDecor.grayGradient.colors),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.dark_mode_outlined,
                color: Colors.white,
                size: 20,
              ),
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
                    style: TextStyle(
                      fontFamily: AppTextStyles.displayFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withValues(
                        alpha: isDark ? 0.78 : 0.82,
                      ),
                    ),
                  ),
                  Text(
                    d.lastSoldAt == null
                        ? 'Never sold • ${d.stockQuantity} in stock'
                        : 'Last sold ${_formatDate(d.lastSoldAt!)} • '
                              '${d.stockQuantity} in stock',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: dust,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : AppColors.brandInk)
                    .withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: scheme.onSurface.withValues(alpha: 0.10),
                ),
              ),
              child: Text(
                _money(d.stockValue),
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: dust,
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.08),
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
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
