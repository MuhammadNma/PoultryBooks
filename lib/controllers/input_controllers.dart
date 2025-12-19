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

  void dispose() {
    [
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
    ].forEach((c) => c.dispose());
  }
}
