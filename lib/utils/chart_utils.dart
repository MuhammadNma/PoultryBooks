// import '../models/profit_record.dart';

// class ChartUtils {
//   /// ---- Date Helpers ----
//   static List<String> weekdayLabels() =>
//       const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

//   /// ---- New Week Logic ----
//   static List<ProfitRecord> currentWeekRecords(
//     List<ProfitRecord> records,
//   ) {
//     final now = DateTime.now();

//     // Find Monday of this week
//     final startOfWeek = now.subtract(
//       Duration(days: now.weekday - 1),
//     );

//     final start = DateTime(
//       startOfWeek.year,
//       startOfWeek.month,
//       startOfWeek.day,
//     );

//     final end = start.add(const Duration(days: 7));

//     return records.where((r) {
//       final d = DateTime(r.date.year, r.date.month, r.date.day);
//       return !d.isBefore(start) && d.isBefore(end);
//     }).toList();
//   }

//   /// Daily Profit (1 per day)
//   static List<double> profitByWeekday(
//     List<ProfitRecord> records,
//   ) {
//     final data = List<double>.filled(7, 0);

//     for (final r in records) {
//       final index = r.date.weekday - 1;
//       data[index] = r.profit; // overwrite
//     }
//     return data;
//   }

//   /// Daily Egg Production (1 per day)
//   static List<double> eggProductionByWeekday(
//     List<ProfitRecord> records,
//   ) {
//     final data = List<double>.filled(7, 0);

//     for (final r in records) {
//       final index = r.date.weekday - 1;
//       data[index] = r.eggsProduced.toDouble(); // ✅ correct
//     }
//     return data;
//   }

//   /// Egg Sales (NOT daily → accumulate)
//   static List<double> eggSalesByWeekday(
//     List<ProfitRecord> records,
//   ) {
//     final data = List<double>.filled(7, 0);

//     for (final r in records) {
//       final index = r.date.weekday - 1;
//       data[index] += r.eggIncome; // accumulate
//     }
//     return data;
//   }
// }

import '../models/profit_record.dart';

class ChartUtils {
  /// ---- Date Helpers ----
  static List<String> weekdayLabels() =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /* ============================================================
     WEEK FILTERING
     ============================================================ */

  /// Current week (kept for backward compatibility)
  static List<ProfitRecord> currentWeekRecords(
    List<ProfitRecord> records,
  ) {
    return recordsForWeek(records, 0);
  }

  /// NEW: Get records for any week offset
  /// 0  = current week
  /// -1 = last week
  /// -2 = two weeks ago
  static List<ProfitRecord> recordsForWeek(
    List<ProfitRecord> records,
    int weekOffset,
  ) {
    final now = DateTime.now();

    // Monday of this week
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    ).add(Duration(days: weekOffset * 7));

    final end = start.add(const Duration(days: 7));

    return records.where((r) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      return !d.isBefore(start) && d.isBefore(end);
    }).toList();
  }

  /// NEW: Week label (for scrollable selector)
  static String weekLabel(int weekOffset) {
    final now = DateTime.now();

    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    ).add(Duration(days: weekOffset * 7));

    final end = start.add(const Duration(days: 6));

    return '${start.day} ${_monthShort(start.month)} - '
        '${end.day} ${_monthShort(end.month)}';
  }

  static String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  /* ============================================================
     CHART DATA GENERATION
     ============================================================ */

  /// Daily Profit (1 per day — overwrite)
  static List<double> profitByWeekday(
    List<ProfitRecord> records,
  ) {
    final data = List<double>.filled(7, 0);

    for (final r in records) {
      final index = r.date.weekday - 1;
      if (index >= 0 && index < 7) {
        data[index] = r.profit;
      }
    }
    return data;
  }

  /// Daily Egg Production (1 per day — overwrite)
  static List<double> eggProductionByWeekday(
    List<ProfitRecord> records,
  ) {
    final data = List<double>.filled(7, 0);

    for (final r in records) {
      final index = r.date.weekday - 1;
      if (index >= 0 && index < 7) {
        data[index] = r.eggsProduced.toDouble();
      }
    }
    return data;
  }

  /// Egg Sales (can have multiple entries per day — accumulate)
  static List<double> eggSalesByWeekday(
    List<ProfitRecord> records,
  ) {
    final data = List<double>.filled(7, 0);

    for (final r in records) {
      final index = r.date.weekday - 1;
      if (index >= 0 && index < 7) {
        data[index] += r.eggIncome;
      }
    }
    return data;
  }
}
