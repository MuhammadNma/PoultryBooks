// lib/core/constants.dart
class AppConstants {
  static const int eggsPerCrate = 30;
  static const String currencySymbol = '₦';

  // Hive box prefixes (per user)
  static const String flockBox    = 'flocks_';
  static const String dailyLogBox = 'daily_logs_';
  static const String saleBox     = 'sales_';
  static const String expenseBox  = 'expenses_';
  static const String customerBox = 'customers_';
  static const String settingsBox = 'settings_';

  // Hive type IDs
  static const int flockTypeId    = 0;
  static const int dailyLogTypeId = 1;
  static const int saleTypeId     = 2;
  static const int expenseTypeId  = 3;
  static const int customerTypeId = 4;

  static const List<String> expenseCategories = [
    'Feed', 'Medication', 'Fuel', 'Salary', 'Crates', 'Repairs', 'Other',
  ];
}
