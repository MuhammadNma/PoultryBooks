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

  ProfitRecord({
    required this.date,
    required this.profit,
    required this.eggIncome,
    required this.feedCost,
    required this.fixedCostPerDay,
  });
}
