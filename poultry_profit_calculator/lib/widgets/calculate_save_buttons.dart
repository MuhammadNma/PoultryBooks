import 'package:flutter/material.dart';

class CalculateSaveButtons extends StatelessWidget {
  final VoidCallback onCalculate;
  final VoidCallback onSave;

  const CalculateSaveButtons({
    super.key,
    required this.onCalculate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onCalculate,
          child: const Text('Calculate'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onSave,
          child: const Text('Save Today\'s Profit'),
        ),
      ],
    );
  }
}
