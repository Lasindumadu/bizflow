import 'package:flutter_test/flutter_test.dart';

import 'package:bizflow/core/services/notification_store.dart';

void main() {
  group('NotificationStore', () {
    test('starts empty with no unread', () {
      final store = NotificationStore();
      expect(store.items, isEmpty);
      expect(store.unreadCount, 0);
      expect(store.hasUnread, isFalse);
    });

    test('push adds an unread notification at the top', () {
      final store = NotificationStore();
      store.push(
        type: AppNotificationType.sale,
        title: 'Sale completed',
        message: 'LKR 500',
      );
      store.push(
        type: AppNotificationType.stock,
        title: 'Low stock',
        message: 'Only 2 left',
      );

      expect(store.items, hasLength(2));
      expect(store.unreadCount, 2);
      expect(store.items.first.title, 'Low stock');
    });

    test('markRead clears a single unread flag', () {
      final store = NotificationStore();
      store.push(type: AppNotificationType.sale, title: 'A', message: 'x');
      final id = store.items.first.id;
      store.push(type: AppNotificationType.sale, title: 'B', message: 'y');

      store.markRead(id);

      expect(store.unreadCount, 1);
      expect(store.items.firstWhere((n) => n.id == id).read, isTrue);
    });

    test('markAllRead clears every unread flag', () {
      final store = NotificationStore();
      store.push(type: AppNotificationType.sale, title: 'A', message: 'x');
      store.push(type: AppNotificationType.sale, title: 'B', message: 'y');

      store.markAllRead();

      expect(store.unreadCount, 0);
      expect(store.hasUnread, isFalse);
    });

    test('remove deletes a notification', () {
      final store = NotificationStore();
      store.push(type: AppNotificationType.sale, title: 'A', message: 'x');
      final id = store.items.first.id;

      store.remove(id);

      expect(store.items, isEmpty);
    });

    test('feed is bounded to 50 most recent items', () {
      final store = NotificationStore();
      for (var i = 0; i < 60; i++) {
        store.push(
          type: AppNotificationType.system,
          title: 'N$i',
          message: 'm',
        );
      }

      expect(store.items, hasLength(50));
      // Most recent first.
      expect(store.items.first.title, 'N59');
    });

    test('notifies listeners on change', () {
      final store = NotificationStore();
      var notifications = 0;
      store.addListener(() => notifications++);

      store.push(type: AppNotificationType.sale, title: 'A', message: 'x');
      store.markAllRead();

      expect(notifications, greaterThanOrEqualTo(2));
    });

    test('seedWelcome adds welcome items only once', () {
      final store = NotificationStore();
      store.seedWelcome();
      final count = store.items.length;
      store.seedWelcome();

      expect(store.items, hasLength(count));
      expect(count, greaterThan(0));
    });

    test('duplicate events each create a distinct entry', () {
      final store = NotificationStore();
      store.push(type: AppNotificationType.stock, title: 'Low', message: 'x');
      store.push(type: AppNotificationType.stock, title: 'Low', message: 'x');

      // Two identical events are still two notifications (distinct ids).
      expect(store.items, hasLength(2));
      expect(store.items[0].id, isNot(store.items[1].id));
      expect(store.unreadCount, 2);
    });

    test('read state is independent per item', () {
      final store = NotificationStore();
      store.push(type: AppNotificationType.sale, title: 'A', message: 'x');
      store.push(type: AppNotificationType.sale, title: 'B', message: 'y');

      final firstId = store.items.first.id;
      store.markRead(firstId);
      store.markRead(firstId); // idempotent

      expect(store.items.firstWhere((n) => n.id == firstId).read, isTrue);
      expect(store.items.firstWhere((n) => n.id != firstId).read, isFalse);
      expect(store.unreadCount, 1);
    });

    test('dismissing one alert does not hide other alerts', () {
      final store = NotificationStore();
      store.push(
        type: AppNotificationType.stock,
        title: 'Critical stock',
        message: 'Out of stock',
      );
      store.push(
        type: AppNotificationType.stock,
        title: 'Low stock',
        message: 'Only 2 left',
      );

      final lowId = store.items.firstWhere((n) => n.title == 'Low stock').id;
      store.remove(lowId);

      // The critical stock warning is untouched.
      expect(store.items, hasLength(1));
      expect(store.items.single.title, 'Critical stock');
    });

    test('clear removes everything and resets unread', () {
      final store = NotificationStore();
      store.push(type: AppNotificationType.sale, title: 'A', message: 'x');
      store.clear();

      expect(store.items, isEmpty);
      expect(store.unreadCount, 0);
    });
  });
}
