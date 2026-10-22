class Sale {
  final String id;
  final String? customerId;
  final String? staffId;
  final double subtotal;
  final double discount;
  final double total;
  final double paidAmount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  const Sale({
    required this.id,
    this.customerId,
    this.staffId,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paidAmount,
    required this.paymentMethod,
    this.status = 'completed',
    required this.createdAt,
  });

  double get changeAmount {
    return paidAmount - total;
  }

  bool get isCompleted {
    return status == 'completed';
  }

  bool get isCancelled {
    return status == 'cancelled';
  }
}
