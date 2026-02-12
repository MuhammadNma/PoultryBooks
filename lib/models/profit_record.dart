// import 'package:hive/hive.dart';

// part 'profit_record.g.dart';

// @HiveType(typeId: 2)
// class ProfitRecord extends HiveObject {
//   @HiveField(0)
//   final DateTime date;

//   @HiveField(1)
//   final double profit;

//   @HiveField(2)
//   final double eggIncome;

//   @HiveField(3)
//   final double feedCost;

//   @HiveField(4)
//   final double fixedCostPerDay;

//   @HiveField(5)
//   final int eggsProduced;

//   /// ✅ NEW — sync flag
//   @HiveField(6)
//   bool synced;

//   ProfitRecord({
//     required this.date,
//     required this.profit,
//     required this.eggIncome,
//     required this.feedCost,
//     required this.fixedCostPerDay,
//     int? eggsProduced,
//     this.synced = false,
//   }) : eggsProduced = eggsProduced ?? 0;

//   /// 🔁 JSON (for Firestore)
//   Map<String, dynamic> toJson() => {
//         'date': date.toIso8601String(),
//         'profit': profit,
//         'eggIncome': eggIncome,
//         'feedCost': feedCost,
//         'fixedCostPerDay': fixedCostPerDay,
//         'eggsProduced': eggsProduced,
//       };

//   factory ProfitRecord.fromJson(Map<String, dynamic> json) => ProfitRecord(
//         date: DateTime.parse(json['date']),
//         profit: (json['profit'] ?? 0).toDouble(),
//         eggIncome: (json['eggIncome'] ?? 0).toDouble(),
//         feedCost: (json['feedCost'] ?? 0).toDouble(),
//         fixedCostPerDay: (json['fixedCostPerDay'] ?? 0).toDouble(),
//         eggsProduced: (json['eggsProduced'] ?? 0),
//         synced: true, // 👈 cloud data is already synced
//       );
// }

import 'package:hive/hive.dart';

part 'profit_record.g.dart';

@HiveType(typeId: 2)
class ProfitRecord extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double profit;

  @HiveField(2)
  final double eggIncome;

  @HiveField(3)
  final double feedCost;

  @HiveField(4)
  final double fixedCostPerDay;

  @HiveField(5)
  final int eggsProduced;

  /// ✅ nullable internally
  @HiveField(6)
  bool? synced;

  ProfitRecord({
    required this.date,
    required this.profit,
    required this.eggIncome,
    required this.feedCost,
    required this.fixedCostPerDay,
    int? eggsProduced,
    bool? synced,
  })  : eggsProduced = eggsProduced ?? 0,
        synced = synced ?? false;

  /// 🔁 JSON (Firestore)
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'profit': profit,
        'eggIncome': eggIncome,
        'feedCost': feedCost,
        'fixedCostPerDay': fixedCostPerDay,
        'eggsProduced': eggsProduced,
      };

  factory ProfitRecord.fromJson(Map<String, dynamic> json) => ProfitRecord(
        date: DateTime.parse(json['date']),
        profit: (json['profit'] ?? 0).toDouble(),
        eggIncome: (json['eggIncome'] ?? 0).toDouble(),
        feedCost: (json['feedCost'] ?? 0).toDouble(),
        fixedCostPerDay: (json['fixedCostPerDay'] ?? 0).toDouble(),
        eggsProduced: (json['eggsProduced'] ?? 0),
        synced: true,
      );

  /// Safe getter
  bool get isSynced => synced ?? false;
}
