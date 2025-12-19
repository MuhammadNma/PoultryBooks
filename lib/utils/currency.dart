String money(double v, {String symbol = '₦'}) =>
    '$symbol${v.toStringAsFixed(2)}';
