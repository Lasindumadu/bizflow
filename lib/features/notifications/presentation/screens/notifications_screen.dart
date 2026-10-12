import 'package:flutter/material.dart';

import '../../../../core/services/notification_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decor.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/modern_widgets.dart';

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
          appBar: AppBar(
            title: const Text('Notifications'),
            actions: [
              if (notificationStore.hasUnread)
                TextButton.icon(
                  onPressed: notificationStore.markAllRead,
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: const Text('Mark all'),
                ),
              const SizedBox(width: 6),
            ],
          ),
          body: items.isEmpty
              ? const AppEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'You are all caught up',
                  message:
                      'Sales, stock alerts and system updates will appear '
                      'here as they happen.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.screenPadding),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _NotificationTile(
                      notification: items[index],
                      onTap: () =>
                          notificationStore.markRead(items[index].id),
                      onDismiss: () =>
                          notificationStore.remove(items[index].id),
                    );
                  },
                ),
        );
      },
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

  Color _accent() {
    switch (notification.type) {
      case AppNotificationType.sale:
        return AppColors.success;
      case AppNotificationType.stock:
        return AppColors.warning;
      case AppNotificationType.customer:
        return AppColors.info;
      case AppNotificationType.system:
        return AppColors.accent;
      case AppNotificationType.achievement:
        return AppColors.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _accent();
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
              color: scheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: unread
                    ? accent.withValues(alpha: 0.35)
                    : scheme.outline.withValues(alpha: 0.6),
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
                      colors: [
                        accent.withValues(alpha: 0.9),
                        accent.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
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
                          if (unread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
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
