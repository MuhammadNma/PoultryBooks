// import '../models/profit_record.dart';

// class ChartUtils {
//   static const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

//   /// Always returns Mon → Sun
//   static List<String> weekdayLabels() => weekdays;

//   static List<double> profitByWeekday(
//     List<ProfitRecord> records,
//   ) {
//     final data = List<double>.filled(7, 0);

//     for (final r in records) {
//       final index = r.date.weekday - 1; // Mon=0 ... Sun=6
//       data[index] += r.profit;
//     }

//     return data;
//   }

//   static List<double> eggProductionByWeekday(
//     List<ProfitRecord> records,
//   ) {
//     final data = List<double>.filled(7, 0);

//     for (final r in records) {
//       final index = r.date.weekday - 1;
//       data[index] += r.eggIncome; // or egg count if you add it later
//     }

//     return data;
//   }

//   static List<double> eggSalesByWeekday(
//     List<ProfitRecord> records,
//   ) {
//     final data = List<double>.filled(7, 0);

//     for (final r in records) {
//       final index = r.date.weekday - 1;
//       data[index] += r.eggIncome;
//     }

//     return data;
//   }

//   /* Last 7 days Record */

//   static List<ProfitRecord> last7DaysRecords(
//     List<ProfitRecord> records,
//   ) {
//     final now = DateTime.now();
//     final start = DateTime(now.year, now.month, now.day)
//         .subtract(const Duration(days: 6));

//     return records.where((r) {
//       final d = DateTime(r.date.year, r.date.month, r.date.day);
//       return !d.isBefore(start);
//     }).toList();
//   }

//   /* Map Last 7 days Record */

//   static List<double> profitByWeekdayLast7Days(
//     List<ProfitRecord> records,
//   ) {
//     final data = List<double>.filled(7, 0);

//     for (final r in records) {
//       final index = r.date.weekday - 1; // Mon=0
//       data[index] = r.profit; // overwrite, not accumulate
//     }

//     return data;
//   }
// }

import '../models/profit_record.dart';

class ChartUtils {
  /// ---- Date Helpers ----
  static List<String> weekdayLabels() =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static List<ProfitRecord> last7DaysRecords(
    List<ProfitRecord> records,
  ) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6));

    return records.where((r) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      return !d.isBefore(start);
    }).toList();
  }

  /// ---- Charts Logic ----

  /// Daily Profit (1 per day)
  static List<double> profitByWeekday(
    List<ProfitRecord> records,
  ) {
    final data = List<double>.filled(7, 0);

    for (final r in records) {
      final index = r.date.weekday - 1;
      data[index] = r.profit; // overwrite
    }
    return data;
  }

  /// Daily Egg Production (1 per day)
  static List<double> eggProductionByWeekday(
    List<ProfitRecord> records,
  ) {
    final data = List<double>.filled(7, 0);

    for (final r in records) {
      final index = r.date.weekday - 1;
      data[index] = r.eggsProduced.toDouble(); // ✅ correct
    }
    return data;
  }

  /// Egg Sales (NOT daily → accumulate)
  static List<double> eggSalesByWeekday(
    List<ProfitRecord> records,
  ) {
    final data = List<double>.filled(7, 0);

    for (final r in records) {
      final index = r.date.weekday - 1;
      data[index] += r.eggIncome; // accumulate
    }
    return data;
  }
}
