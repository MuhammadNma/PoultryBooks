import 'package:intl/intl.dart';

String formatNaira(double value) {
  final formatter = NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

String formatDateWithDay(DateTime date) {
  return DateFormat('EEEE, d/M/yyyy').format(date);
}
