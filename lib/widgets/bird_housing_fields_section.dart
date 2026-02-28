import 'package:flutter/material.dart';
import 'number_field.dart';
import '../controllers/input_controllers.dart';

class BirdHousingFieldsSection extends StatelessWidget {
  final InputControllers inputs;
  const BirdHousingFieldsSection({Key? key, required this.inputs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bird & Housing', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        NumberField(controller: inputs.numberOfBirds, label: 'Number of Birds'),
        NumberField(controller: inputs.costPerBird, label: 'Cost per Bird'),
        NumberField(
            controller: inputs.layingPeriodDays, label: 'Laying Period (days)'),
        NumberField(controller: inputs.housingCost, label: 'Housing Cost'),
        NumberField(
            controller: inputs.housingLifespan,
            label: 'Housing Lifespan (days)'),
        NumberField(controller: inputs.equipmentCost, label: 'Equipment Cost'),
        NumberField(
            controller: inputs.equipmentLifespan,
            label: 'Equipment Lifespan (days)'),
        NumberField(controller: inputs.mortalityCost, label: 'Mortality Cost'),
      ],
    );
  }
}
