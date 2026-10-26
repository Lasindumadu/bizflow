import '../../../../models/product.dart';

/// A line item in the POS cart: a product plus its selected quantity,
/// with optional batch traceability fields.
class CartItem {
  final Product product;
  int quantity;
  final String? batchNumber;
  final String? expiryDate;

  CartItem({
    required this.product,
    required this.quantity,
    this.batchNumber,
    this.expiryDate,
  });

  double get total => product.sellingPrice * quantity;
}
