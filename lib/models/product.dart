class Product {
  final String id;
  final String name;
  final String sku;
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final int stockQuantity;
  final int lowStockThreshold;
  final String barcode;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    this.barcode = '',
  });

  bool get isLowStock {
    return stockQuantity <= lowStockThreshold;
  }
}
