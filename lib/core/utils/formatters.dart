import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormatter = NumberFormat.currency(
    symbol: 'EGP ',
    decimalDigits: 2,
  );

  static String formatCredits(double amount) =>
      _currencyFormatter.format(amount);

  static String formatPrice(double price) =>
      _currencyFormatter.format(price);

  static String formatDateTime(DateTime dateTime) =>
      DateFormat("MMM d, yyyy 'at' h:mm a").format(dateTime);

  static String formatTimeShort(DateTime dateTime) =>
      DateFormat('h:mm a').format(dateTime);

  static String formatBattery(int percent) => '$percent%';

  static String formatOrderId(String orderId) =>
      '#${orderId.substring(0, 8).toUpperCase()}';
}
