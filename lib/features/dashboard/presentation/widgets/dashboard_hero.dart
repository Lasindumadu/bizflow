import 'package:flutter/material.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../data/repositories/dashboard_repository.dart';

/// Premium gradient hero for dashboard.
class DashboardHero extends StatelessWidget {
  final DashboardStats stats;
  final String businessName;
  final String currency;
  final String greeting;
  final VoidCallback onNewSale;
  final VoidCallback onSettings;
  const DashboardHero({
    super.key,
    required this.stats,
    required this.businessName,
    required this.currency,
    required this.greeting,
    required this.onNewSale,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppDecor.heroGradient(isDark),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppDecor.softShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded,
                        color: Color(0xFF34D399), size: 14),
                    SizedBox(width: 6),
                    Text('LIVE • OPEN FOR SALE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSettings,
                icon: const Icon(Icons.settings_outlined,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(greeting,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14)),
          Text(businessName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text("Today's revenue",
                          style: TextStyle(
                              color: Colors.white.withValues(
                                  alpha: 0.75),
                              fontSize: 12)),
                      const SizedBox(height: 6),
                      Text(
                        '$currency ${stats.todaySales.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats.todayTransactions} txns • Profit $currency ${stats.todayProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: Colors.white.withValues(
                                alpha: 0.82),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                        const Color(0xFF4F46E5),
                  ),
                  onPressed: onNewSale,
                  child: const Text('New Sale',
                      style: TextStyle(
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
