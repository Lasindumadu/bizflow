import 'package:flutter/material.dart';

/// Severity/category of an in-app notification.
enum AppNotificationType { sale, stock, customer, system, achievement }

/// A single in-app notification shown in the notification center.
class AppNotification {
  final String id;
  final AppNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool read;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.read = false,
    this.actionRoute,
  });

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      createdAt: createdAt,
      read: read ?? this.read,
      actionRoute: actionRoute,
    );
  }

  IconData get icon {
    switch (type) {
      case AppNotificationType.sale:
        return Icons.point_of_sale_rounded;
      case AppNotificationType.stock:
        return Icons.inventory_2_rounded;
      case AppNotificationType.customer:
        return Icons.people_alt_rounded;
      case AppNotificationType.system:
        return Icons.settings_suggest_rounded;
      case AppNotificationType.achievement:
        return Icons.emoji_events_rounded;
    }
  }

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final d = createdAt;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

/// In-memory notification feed — mirrors the [parkedSalesStore] pattern so
/// no database migration is required. Business events push into this store
/// and the UI reacts via [ChangeNotifier].
class NotificationStore extends ChangeNotifier {
  final List<AppNotification> _items = [];
  int _seq = 0;

  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.read).length;

  bool get hasUnread => unreadCount > 0;

  void push({
    required AppNotificationType type,
    required String title,
    required String message,
    String? actionRoute,
  }) {
    _items.insert(
      0,
      AppNotification(
        id: 'ntf_${DateTime.now().microsecondsSinceEpoch}_${_seq++}',
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        actionRoute: actionRoute,
      ),
    );

    // Keep the feed bounded — 50 most recent is plenty for a POS.
    if (_items.length > 50) {
      _items.removeRange(50, _items.length);
    }
    notifyListeners();
  }

  void markRead(String id) {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1 || _items[index].read) return;
    _items[index] = _items[index].copyWith(read: true);
    notifyListeners();
  }

  void markAllRead() {
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      if (!_items[i].read) {
        _items[i] = _items[i].copyWith(read: true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void remove(String id) {
    final before = _items.length;
    _items.removeWhere((n) => n.id == id);
    if (_items.length != before) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  /// Seeds a few welcome notifications the first time the app runs so the
  /// center is never empty in a fresh install / demo.
  void seedWelcome({String businessName = 'your business'}) {
    if (_items.isNotEmpty) return;
    push(
      type: AppNotificationType.achievement,
      title: 'Welcome to BizFlow 🎉',
      message:
          'Your point-of-sale for $businessName is ready. Sell offline, '
          'track stock and grow — all from one place.',
    );
    push(
      type: AppNotificationType.system,
      title: 'Everything runs offline',
      message:
          'No internet? No problem. Your data is stored locally and works '
          'everywhere — mobile and web.',
    );
  }
}

/// Global singleton — same pattern as [parkedSalesStore].
final notificationStore = NotificationStore();
