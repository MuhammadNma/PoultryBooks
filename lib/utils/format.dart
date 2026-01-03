String money(double value, {String symbol = '₦'}) {
  return '$symbol${value.toStringAsFixed(2)}';
}
