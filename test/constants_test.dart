import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_books/core/constants.dart';

void main() {
  group('AppConstants', () {
    test('eggsPerCrate is 30', () {
      expect(AppConstants.eggsPerCrate, 30);
    });

    test('currency symbol is Naira', () {
      expect(AppConstants.currencySymbol, '₦');
    });

    test('expense categories contains all 7 required categories', () {
      expect(AppConstants.expenseCategories, contains('Feed'));
      expect(AppConstants.expenseCategories, contains('Medication'));
      expect(AppConstants.expenseCategories, contains('Fuel'));
      expect(AppConstants.expenseCategories, contains('Salary'));
      expect(AppConstants.expenseCategories, contains('Crates'));
      expect(AppConstants.expenseCategories, contains('Repairs'));
      expect(AppConstants.expenseCategories, contains('Other'));
      expect(AppConstants.expenseCategories.length, 7);
    });

    test('all Hive box prefixes are unique', () {
      final prefixes = [
        AppConstants.flockBox,
        AppConstants.dailyLogBox,
        AppConstants.saleBox,
        AppConstants.expenseBox,
        AppConstants.customerBox,
        AppConstants.settingsBox,
      ];
      final unique = prefixes.toSet();
      expect(unique.length, prefixes.length);
    });

    test('all Hive type IDs are unique', () {
      final typeIds = [
        AppConstants.flockTypeId,
        AppConstants.dailyLogTypeId,
        AppConstants.saleTypeId,
        AppConstants.expenseTypeId,
        AppConstants.customerTypeId,
      ];
      final unique = typeIds.toSet();
      expect(unique.length, typeIds.length);
    });
  });
}
