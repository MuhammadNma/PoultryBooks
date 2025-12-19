import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.cardBackground,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
