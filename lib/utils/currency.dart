import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat.currency(
  locale: 'en_NG',
  symbol: '₦',
  decimalDigits: 2,
);

String formatMoney(num value) => _currencyFormatter.format(value);
