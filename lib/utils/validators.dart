String? validateNumber(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter a value';
  return double.tryParse(value.replaceAll(',', '').trim()) == null
      ? 'Not a valid number'
      : null;
}
