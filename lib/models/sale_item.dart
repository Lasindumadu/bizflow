class SaleItem {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double purchasePrice;

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.purchasePrice,
  });

  double get total {
    return quantity * unitPrice;
  }

  double get costTotal {
    return quantity * purchasePrice;
  }

  double get grossProfit {
    return total - costTotal;
  }
}
