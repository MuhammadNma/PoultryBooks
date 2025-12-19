import 'package:flutter/material.dart';

class AdvancedToggle extends StatelessWidget {
  final String title;
  final bool value;
  final VoidCallback onChanged;

  const AdvancedToggle({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      value: value,
      onChanged: (_) => onChanged(),
    );
  }
}
