import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/services/notification_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_ui.dart';

/// In-app notification center. Reads from the global [notificationStore]
/// and re-renders reactively via [AnimatedBuilder].
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notificationStore,
      builder: (context, _) {
        final items = notificationStore.items;

        return Scaffold(
          body: BrandBackdrop(
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _AuroraHeader(
                    hasUnread: notificationStore.hasUnread,
                    onMarkAll: notificationStore.markAllRead,
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? const BrandEmptyState(
                            title: 'You are all caught up',
                            message:
                                'Sales, stock alerts and system updates will '
                                'appear here as they happen.',
                            icon: Icons.notifications_none_rounded,
                            image: AppImages.auroraGlow,
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppDimensions.screenPadding,
                              AppDimensions.spacingMd,
                              AppDimensions.screenPadding,
                              32,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final tile = _NotificationTile(
                                notification: items[index],
                                onTap: () =>
                                    notificationStore.markRead(items[index].id),
                                onDismiss: () =>
                                    notificationStore.remove(items[index].id),
                              );
                              // Stagger only the first screenful.
                              if (index > 11) {
                                return tile;
                              }
                              return tile
                                  .animate(delay: (60.milliseconds * index))
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
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact aurora header with the mark-all affordance.
class _AuroraHeader extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback onMarkAll;

  const _AuroraHeader({required this.hasUnread, required this.onMarkAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppImages.auroraGlow,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            for (final g in AppDecor.photoWash())
              Positioned.fill(
                child: DecoratedBox(decoration: BoxDecoration(gradient: g)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 14,
                              color: const Color(0xFF7DF3DF),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'UPDATES',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.bodyFont,
                                  color: Color(0xFF9FE9DE),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Notifications',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                          'Sales, stock alerts & system updates',
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
                  if (hasUnread)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _HeaderPillButton(
                        icon: Icons.done_all_rounded,
                        label: 'Mark all',
                        onTap: onMarkAll,
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

/// Frosted action button used inside the aurora header.
class _HeaderPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderPillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 15),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  /// Per-type tint pair: low-stock/stock=amber, credit/customer=mint,
  /// summary/system=royal, sales=mint, achievements=violet.
  ({IconData icon, List<Color> gradient, Color tone}) _visual() {
    switch (notification.type) {
      case AppNotificationType.sale:
        return (
          icon: notification.icon,
          gradient: AppDecor.moneyGradient.colors,
          tone: AppColors.brandMintDeep,
        );
      case AppNotificationType.stock:
        return (
          icon: notification.icon,
          gradient: AppDecor.amberGradient.colors,
          tone: AppColors.tertiaryDark,
        );
      case AppNotificationType.customer:
        return (
          icon: notification.icon,
          gradient: AppDecor.moneyGradient.colors,
          tone: AppColors.brandMintDeep,
        );
      case AppNotificationType.system:
        return (
          icon: notification.icon,
          gradient: AppDecor.royalGradient.colors,
          tone: AppColors.primary,
        );
      case AppNotificationType.achievement:
        return (
          icon: notification.icon,
          gradient: AppDecor.violetGradient.colors,
          tone: AppColors.accent,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final v = _visual();
    final unread = !notification.read;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: unread
                    ? AppColors.primary.withValues(alpha: isDark ? 0.55 : 0.38)
                    : scheme.outline.withValues(alpha: 0.5),
                width: unread ? 1.4 : 1,
              ),
              boxShadow: unread ? AppDecor.subtleShadow(context) : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: v.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppDecor.glow(v.tone, alpha: 0.24),
                  ),
                  child: Icon(
                    notification.icon,
                    color: Colors.white,
                    size: 21,
                  ),
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
                              notification.title,
                              style: AppTextStyles.titleSmall.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          // Unread dot — always royal, per brand.
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: AppDecor.glow(
                                  AppColors.primary,
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notification.message,
                        style: AppTextStyles.helper.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.relativeTime,
                        style: AppTextStyles.badge.copyWith(
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                          color: scheme.onSurface.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
