// lib/utils/formatters.dart
import 'package:intl/intl.dart';
import '../core/constants.dart';

String formatMoney(double v) {
  final f = NumberFormat('#,##0.00', 'en_NG');
  return '${AppConstants.currencySymbol}${f.format(v)}';
}

String formatMoneyCompact(double v) {
  if (v.abs() >= 1000000) return '${AppConstants.currencySymbol}${(v/1000000).toStringAsFixed(1)}M';
  if (v.abs() >= 1000)    return '${AppConstants.currencySymbol}${(v/1000).toStringAsFixed(1)}K';
  return formatMoney(v);
}

String formatDate(DateTime d)      => DateFormat('dd MMM yyyy').format(d);
String formatDateShort(DateTime d) => DateFormat('dd MMM').format(d);
String formatMonthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);

String formatEggs(int count) {
  final crates = count ~/ AppConstants.eggsPerCrate;
  final pieces = count %  AppConstants.eggsPerCrate;
  if (crates > 0 && pieces > 0) return '$crates crates + $pieces pcs';
  if (crates > 0) return '$crates crates';
  return '$pieces pcs';
}

double parseAmount(String v) =>
    double.tryParse(v.replaceAll(',', '').trim()) ?? 0;

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
