import 'package:flutter/material.dart';
import '../controllers/input_controllers.dart';
import 'number_field.dart';
import '../core/strings.dart';

class AdvancedFieldsSection extends StatelessWidget {
  final InputControllers inputs;
  const AdvancedFieldsSection({Key? key, required this.inputs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumberField(
            controller: inputs.numberOfBirds, label: AppStrings.numberOfBirds),
        NumberField(
            controller: inputs.costPerBird, label: AppStrings.costPerBird),
        NumberField(
            controller: inputs.layingPeriodDays,
            label: AppStrings.layingPeriod),
        NumberField(
            controller: inputs.housingCost, label: AppStrings.housingCost),
        NumberField(
            controller: inputs.housingLifespan,
            label: AppStrings.housingLifespan),
        NumberField(
            controller: inputs.equipmentCost, label: AppStrings.equipmentCost),
        NumberField(
            controller: inputs.equipmentLifespan,
            label: AppStrings.equipmentLifespan),
        NumberField(
            controller: inputs.mortalityCost, label: AppStrings.mortalityCost),
      ],
    );
  }
}
