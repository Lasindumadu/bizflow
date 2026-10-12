import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../data/database/database_provider.dart';
import '../../../../data/repositories/audit_repository.dart';

/// Read-only audit trail of important business actions.
class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AuditRepository(appDatabase);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: StreamBuilder<List<AuditEntry>>(
        stream: repository.watchEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingState(message: 'Loading activity…');
          }

          final entries = snapshot.data ?? const <AuditEntry>[];

          if (entries.isEmpty) {
            return const AppEmptyState(
              icon: Icons.history_rounded,
              title: 'No activity yet',
              message:
                  'Stock changes, cancellations and refunds will be recorded '
                  'here for accountability.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return _AuditTile(entry: entries[index]);
            },
          );
        },
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  final AuditEntry entry;

  const _AuditTile({required this.entry});

  ({IconData icon, Color color, List<Color> gradient}) _visual() {
    switch (entry.action) {
      case 'refund.create':
        return (
          icon: Icons.assignment_return_rounded,
          color: AppColors.error,
          gradient: AppDecor.roseGradient.colors,
        );
      case 'sale.cancel':
        return (
          icon: Icons.cancel_outlined,
          color: AppColors.warning,
          gradient: AppDecor.amberGradient.colors,
        );
      case 'stock.change':
        return (
          icon: Icons.inventory_2_outlined,
          color: AppColors.info,
          gradient: AppDecor.skyGradient.colors,
        );
      case 'loyalty.adjust':
        return (
          icon: Icons.emoji_events_rounded,
          color: AppColors.tertiary,
          gradient: AppDecor.violetGradient.colors,
        );
      default:
        return (
          icon: Icons.bolt_rounded,
          color: AppColors.primary,
          gradient: AppDecor.indigoGradient.colors,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = _visual();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(
              icon: v.icon,
              gradient: v.gradient,
              size: 40,
              iconSize: 19,
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
                          entry.action,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: v.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        entry.relativeTime,
                        style: AppTextStyles.badge.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.summary.isEmpty ? '—' : entry.summary,
                    style: AppTextStyles.helper.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${entry.actor}'
                    '${entry.entityId.isEmpty ? '' : ' • ${entry.entityType} ${entry.entityId}'}',
                    style: AppTextStyles.caption.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.45),
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
}
