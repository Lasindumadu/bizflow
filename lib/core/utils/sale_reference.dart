import '../../models/sale.dart';

class SaleReference {
  const SaleReference._();

  static String format(Sale sale) {
    final dateTime = sale.createdAt.toLocal();

    final year = dateTime.year.toString();
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return 'SALE-$year$month$day-$hour$minute';
  }
}
