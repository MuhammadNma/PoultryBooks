import 'dart:math';

class Calculator {
  static double singleEggPrice(double cratePrice, {int eggsPerCrate = 30}) {
    if (cratePrice <= 0) return 0.0;
    return cratePrice / eggsPerCrate;
  }

  /// Compute daily profit using combined method
  static double calculateDailyProfit({
    required double crates,
    required double cratePrice,
    required double eggPieces,
    required double feedBagCost,
    required double feedBagSizeKg,
    required double feedEatenKg,
    required double medication,
    required double supplements,
    required double electricity,
    required double water,
    required double labor,
    required double packaging,
    required double transport,
    required int numberOfBirds,
    required double costPerBird,
    required int layingPeriodDays,
    required double housingCost,
    required int housingLifespanDays,
    required double equipmentCost,
    required int equipmentLifespanDays,
    required double mortalityCost,
  }) {
    final singleEgg = singleEggPrice(cratePrice);
    final piecesIncome = eggPieces * singleEgg;
    final eggIncome = (crates * cratePrice) + piecesIncome;

    final costPerKg =
        (feedBagSizeKg <= 0) ? 0.0 : (feedBagCost / feedBagSizeKg);
    final feedCost = costPerKg * feedEatenKg;

    final totalVariableCost = feedCost +
        medication +
        supplements +
        electricity +
        water +
        labor +
        packaging +
        transport;

    final birdCostPerDay = (numberOfBirds <= 0)
        ? 0.0
        : ((costPerBird * numberOfBirds) / max(1, layingPeriodDays));
    final housingDep =
        (housingLifespanDays <= 0) ? 0.0 : (housingCost / housingLifespanDays);
    final equipmentDep = (equipmentLifespanDays <= 0)
        ? 0.0
        : (equipmentCost / equipmentLifespanDays);

    final fixedCostPerDay = birdCostPerDay + housingDep + equipmentDep;

    final profit =
        eggIncome - (totalVariableCost + fixedCostPerDay + mortalityCost);

    return profit;
  }
}

/* ===== lib/utils/format.dart ===== */

// File: lib/utils/format.dart

String money(double value, {String symbol = '₦'}) {
  return '${symbol}${value.toStringAsFixed(2)}';
}
