import 'package:intl/intl.dart';

String formatMoney(double value) {
  final formatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: value % 1 == 0 ? 0 : 2,
  );

  return formatter.format(value);
}
