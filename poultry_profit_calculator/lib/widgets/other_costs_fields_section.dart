import 'package:flutter/material.dart';
import '../controllers/input_controllers.dart';
import 'number_field.dart';
import '../core/strings.dart';

class OtherCostsFieldsSection extends StatelessWidget {
  final InputControllers inputs;
  const OtherCostsFieldsSection({Key? key, required this.inputs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumberField(
            controller: inputs.medication, label: AppStrings.medication),
        NumberField(
            controller: inputs.supplements, label: AppStrings.supplements),
        NumberField(
            controller: inputs.electricity, label: AppStrings.electricity),
        NumberField(controller: inputs.water, label: AppStrings.water),
        NumberField(controller: inputs.labor, label: AppStrings.labor),
        NumberField(controller: inputs.packaging, label: AppStrings.packaging),
        NumberField(controller: inputs.transport, label: AppStrings.transport),
      ],
    );
  }
}
