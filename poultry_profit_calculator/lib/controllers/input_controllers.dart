import 'package:flutter/material.dart';

class InputControllers {
  final crates = TextEditingController();
  final cratePrice = TextEditingController();
  final eggPieces = TextEditingController();
  final feedBagCost = TextEditingController();
  final feedBagSize = TextEditingController();
  final feedEaten = TextEditingController();

  // Advanced: Bird & Housing
  final numberOfBirds = TextEditingController();
  final costPerBird = TextEditingController();
  final layingPeriodDays = TextEditingController();
  final housingCost = TextEditingController();
  final housingLifespan = TextEditingController();
  final equipmentCost = TextEditingController();
  final equipmentLifespan = TextEditingController();
  final mortalityCost = TextEditingController();

  // Advanced: Other costs
  final medication = TextEditingController();
  final supplements = TextEditingController();
  final electricity = TextEditingController();
  final water = TextEditingController();
  final labor = TextEditingController();
  final packaging = TextEditingController();
  final transport = TextEditingController();

  void clear() {
    for (final c in [
      crates,
      eggPieces,
      feedEaten,
      medication,
      supplements,
      electricity,
      water,
      labor,
      packaging,
      transport,
      numberOfBirds,
      costPerBird,
      layingPeriodDays,
      housingCost,
      housingLifespan,
      equipmentCost,
      equipmentLifespan,
      mortalityCost,
    ]) {
      c.clear();
    }
  }

  void dispose() {
    for (var c in [
      crates,
      cratePrice,
      eggPieces,
      feedBagCost,
      feedBagSize,
      feedEaten,
      numberOfBirds,
      costPerBird,
      layingPeriodDays,
      housingCost,
      housingLifespan,
      equipmentCost,
      equipmentLifespan,
      mortalityCost,
      medication,
      supplements,
      electricity,
      water,
      labor,
      packaging,
      transport
    ]) {
      c.dispose();
    }
  }
}
