class SaleItem {
  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final double quantity;
  final double unitPrice;
  final double purchasePrice;
  final String? batchNumber;
  final String? expiryDate;

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.purchasePrice,
    this.batchNumber,
    this.expiryDate,
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
