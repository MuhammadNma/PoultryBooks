// // lib/core/constants.dart

// class AppConstants {
//   // Eggs
//   static const int eggsPerCrate = 30;

//   // Currency
//   static const String currencySymbol = '₦';

//   // Hive box names (per-user, suffixed with userId)
//   static const String flockBoxPrefix = 'flocks_';
//   static const String profitBoxPrefix = 'profit_records_';
//   static const String inventoryBoxPrefix = 'egg_inventory_';
//   static const String customersBoxPrefix = 'customers_';
//   static const String transactionsBoxPrefix = 'transactions_';
//   static const String settingsBoxPrefix = 'settings_';

//   // Onboarding
//   static const String onboardingKey = 'onboarding_complete';

//   // Hive type IDs
//   static const int flockTypeId = 3;
//   static const int profitRecordTypeId = 2;
//   static const int eggInventoryTypeId = 4;
//   static const int customerTypeId = 0;
//   static const int customerTransactionTypeId = 1;
// }

// lib/core/constants.dart

class AppConstants {
  static const int eggsPerCrate = 30;
  static const String currencySymbol = '₦';

  // Hive box prefixes (per user)
  static const String flockBox = 'flocks_';
  static const String dailyLogBox = 'daily_logs_';
  static const String saleBox = 'sales_';
  static const String expenseBox = 'expenses_';
  static const String customerBox = 'customers_';
  static const String settingsBox = 'settings_';

  // Hive type IDs
  static const int flockTypeId = 0;
  static const int dailyLogTypeId = 1;
  static const int saleTypeId = 2;
  static const int expenseTypeId = 3;
  static const int customerTypeId = 4;

  // Expense categories
  static const List<String> expenseCategories = [
    'Feed',
    'Medication',
    'Fuel',
    'Salary',
    'Crates',
    'Repairs',
    'Other',
  ];
}
