import 'package:flutter/material.dart';

/// In-memory parked (held) sales — no DB migration needed.
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
}

class ParkedSalesStore extends ChangeNotifier {
  final List<ParkedSale> _sales = [];
  List<ParkedSale> get sales => List.unmodifiable(_sales);
  void park(ParkedSale s) {
    _sales.add(s);
    notifyListeners();
  }

  ParkedSale? recall(int index) {
    if (index < 0 || index >= _sales.length) return null;
    final s = _sales.removeAt(index);
    notifyListeners();
    return s;
  }

  void removeAt(int index) {
    if (index < 0 || index >= _sales.length) return;
    _sales.removeAt(index);
    notifyListeners();
  }
}

final parkedSalesStore = ParkedSalesStore();
