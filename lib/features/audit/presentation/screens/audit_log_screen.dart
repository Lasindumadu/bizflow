import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';
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
      body: BrandBackdrop(
        child: SafeArea(
          bottom: false,
          child: StreamBuilder<List<AuditEntry>>(
            stream: repository.watchEntries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const AppLoadingState(message: 'Loading activity…');
              }

              final entries = snapshot.data ?? const <AuditEntry>[];

              if (entries.isEmpty) {
                return const BrandEmptyState(
                  title: 'No activity yet',
                  message:
                      'Stock changes, cancellations and refunds will be '
                      'recorded here for accountability.',
                  icon: Icons.history_rounded,
                  image: AppImages.auroraGlow,
                );
              }

              return Column(
                children: [
                  const BrandPageHeader(
                    eyebrow: 'Trust & accountability',
                    title: 'Activity log',
                    subtitle: 'Every key action, recorded for review.',
                    icon: Icons.history_rounded,
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final tile = _AuditTile(entry: entries[index]);
                        // Stagger only the first screenful.
                        if (index > 11) {
                          return tile;
                        }
                        return tile
                            .animate(delay: (60.ms * index))
                            .fadeIn(
                              duration: 380.ms,
                              curve: Curves.easeOutCubic,
                            )
                            .moveY(
                              begin: 14,
                              end: 0,
                              duration: 380.ms,
                              curve: Curves.easeOutCubic,
                            );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuditTile extends StatelessWidget {
  final AuditEntry entry;

  const _AuditTile({required this.entry});

  /// Action → chip color/gradient, mapped off the data enum strings.
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
          gradient: AppDecor.infoGradient.colors,
        );
      case 'loyalty.adjust':
        return (
          icon: Icons.emoji_events_rounded,
          color: AppColors.accent,
          gradient: AppDecor.violetGradient.colors,
        );
      default:
        return (
          icon: Icons.bolt_rounded,
          color: AppColors.primary,
          gradient: AppDecor.royalGradient.colors,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final v = _visual();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actorInitial = entry.actor.isEmpty
        ? 'B'
        : entry.actor.substring(0, 1).toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: HoverLiftCard(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient initials for the acting staff member.
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppDecor.toneGradient(
                  entry.actor.hashCode,
                ),
                shape: BoxShape.circle,
                boxShadow: AppDecor.glow(
                  v.gradient.last,
                  alpha: isDark ? 0.22 : 0.14,
                ),
              ),
              child: Text(
                actorInitial,
                style: TextStyle(
                  fontFamily: AppTextStyles.displayFont,
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ActionChip(
                        label: _actionLabel(entry.action),
                        color: v.color,
                        gradient: v.gradient,
                      ),
                      const Spacer(),
                      Text(
                        entry.relativeTime,
                        style: AppTextStyles.badge.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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

  String _actionLabel(String action) {
    final tail = action.split('.').last;
    switch (tail) {
      case 'create':
      case 'open':
        return 'created';
      case 'cancel':
        return 'cancelled';
      case 'adjust':
        return 'updated';
      case 'close':
        return 'closed';
      default:
        return tail;
    }
  }
}

/// Small chip with a filled gradient dot marking the action family.
class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final List<Color> gradient;

  const _ActionChip({
    required this.label,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              size: 8,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
