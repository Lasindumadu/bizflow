import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent parked (held) sales — survives app restart via shared_preferences.
class ParkedSale {
  final String label;
  final DateTime parkedAt;
  final List<ParkedItem> items;
  final String? customerId;
  ParkedSale({
    required this.label,
    required this.parkedAt,
    required this.items,
    this.customerId,
  });

  double get subtotal =>
      items.fold(0, (s, i) => s + i.price * i.qty);

  /// Serializes this [ParkedSale] to a JSON map.
  Map<String, dynamic> toJson() => {
        'label': label,
        'parkedAt': parkedAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'customerId': customerId,
      };

  /// Deserializes a [ParkedSale] from a JSON map.
  static ParkedSale fromJson(Map<String, dynamic> json) => ParkedSale(
        label: json['label'] as String,
        parkedAt: DateTime.parse(json['parkedAt'] as String),
        items: (json['items'] as List<dynamic>)
            .map((e) => ParkedItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        customerId: json['customerId'] as String?,
      );
}

class ParkedItem {
  final String productId;
  final String name;
  final double price;
  final double cost;
  final int qty;
  ParkedItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.cost,
    required this.qty,
  });

  /// Serializes this [ParkedItem] to a JSON map.
  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'cost': cost,
        'qty': qty,
      };

  /// Deserializes a [ParkedItem] from a JSON map.
  static ParkedItem fromJson(Map<String, dynamic> json) => ParkedItem(
        productId: json['productId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        cost: (json['cost'] as num).toDouble(),
        qty: json['qty'] as int,
      );
}

/// Persistent parked (held) sales store.
///
/// Cart data is serialized to JSON and persisted via `shared_preferences` on
/// every mutation, so held carts survive app restart.
class ParkedSalesStore extends ChangeNotifier {
  static const String _prefsKey = 'bizflow_parked_sales_v1';

  final List<ParkedSale> _sales = [];
  List<ParkedSale> get sales => List.unmodifiable(_sales);

  SharedPreferences? _prefs;

  /// Loads parked carts from persistent storage.
  ///
  /// Must be called before the store is used. Safe to call multiple times;
  /// subsequent calls are no-ops once prefs are loaded.
  Future<void> init() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final raw = _prefs?.getStringList(_prefsKey);
    if (raw == null) return;
    _sales.clear();
    for (final entry in raw) {
      try {
        final decoded = jsonDecode(entry) as Map<String, dynamic>;
        _sales.add(ParkedSale.fromJson(decoded));
      } catch (_) {
        // Skip corrupt entries — never crash on load.
      }
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    await _prefs!.setStringList(
      _prefsKey,
      _sales.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  void park(ParkedSale s) {
    _sales.add(s);
    unawaited(_persist());
    notifyListeners();
  }

  ParkedSale? recall(int index) {
    if (index < 0 || index >= _sales.length) return null;
    final s = _sales.removeAt(index);
    unawaited(_persist());
    notifyListeners();
    return s;
  }

  void removeAt(int index) {
    if (index < 0 || index >= _sales.length) return;
    _sales.removeAt(index);
    unawaited(_persist());
    notifyListeners();
  }
}

final parkedSalesStore = ParkedSalesStore();
