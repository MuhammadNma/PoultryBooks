import '../models/profit_record.dart';

class AppState {
  double profit = 0.0;
  double eggIncome = 0.0;
  double feedCost = 0.0;
  double totalVariableCost = 0.0;
  double fixedCostPerDay = 0.0;

  final List<ProfitRecord> history = [];

  void save(
      double profit, double eggIncome, double feedCost, double fixedCost) {
    final rec = ProfitRecord(
      date: DateTime.now(),
      profit: profit,
      eggIncome: eggIncome,
      feedCost: feedCost,
      fixedCostPerDay: fixedCost,
    );
    history.insert(0, rec);
  }

  void clear() {
    profit = 0.0;
    eggIncome = 0.0;
    feedCost = 0.0;
    totalVariableCost = 0.0;
    fixedCostPerDay = 0.0;
    history.clear();
  }
}
