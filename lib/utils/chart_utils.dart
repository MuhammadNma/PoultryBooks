import '../models/profit_record.dart';

class ChartUtils {
  static List<DateTime> lastNDays(int days) {
    final now = DateTime.now();
    return List.generate(
      days,
      (i) => DateTime(now.year, now.month, now.day - (days - 1 - i)),
    );
  }

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static double profitForDay(DateTime day, List<ProfitRecord> records) {
    final r = records.where((e) => sameDay(e.date, day));
    if (r.isEmpty) return 0;
    return r.first.profit;
  }

  static double eggProductionForDay(
    DateTime day,
    List<ProfitRecord> records,
  ) {
    final r = records.where((e) => sameDay(e.date, day));
    if (r.isEmpty) return 0;

    // crude estimate — replace later if needed
    return r.first.eggIncome > 0 ? r.first.eggIncome : 0;
  }

  static double eggSalesForDay(
    DateTime day,
    List<ProfitRecord> records,
  ) {
    final r = records.where((e) => sameDay(e.date, day));
    if (r.isEmpty) return 0;

    return r.fold(0.0, (sum, e) => sum + e.eggIncome);
  }
}
