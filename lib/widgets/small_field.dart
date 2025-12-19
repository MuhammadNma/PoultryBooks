import 'package:flutter/material.dart';

class SmallField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const SmallField({Key? key, required this.controller, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
            labelText: label,
            isDense: true,
            border: const OutlineInputBorder()),
        validator: (value) => (value == null || value.trim().isEmpty)
            ? null
            : (double.tryParse(value.replaceAll(',', '').trim()) == null
                ? 'Invalid'
                : null),
      ),
    );
  }
}
