import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_books/utils/formatters.dart';

void main() {
  // ============================================================
  // MONEY FORMATTING
  // ============================================================
  group('formatMoney', () {
    test('formats zero correctly', () {
      expect(formatMoney(0), '₦0.00');
    });

    test('formats small amounts correctly', () {
      expect(formatMoney(500), '₦500.00');
    });

    test('formats thousands with comma separator', () {
      expect(formatMoney(1800), '₦1,800.00');
    });

    test('formats large amounts with commas', () {
      expect(formatMoney(125500), '₦125,500.00');
    });

    test('formats decimal amounts correctly', () {
      expect(formatMoney(1800.50), '₦1,800.50');
    });

    test('always shows two decimal places', () {
      expect(formatMoney(5000), '₦5,000.00');
    });

    test('formats very large amounts correctly', () {
      expect(formatMoney(1000000), '₦1,000,000.00');
    });
  });

  // ============================================================
  // COMPACT MONEY (should now show full amount)
  // ============================================================
  group('formatMoneyCompact', () {
    test('shows full amount for thousands', () {
      expect(formatMoneyCompact(1800), '₦1,800.00');
    });

    test('shows full amount for large numbers', () {
      expect(formatMoneyCompact(125500), '₦125,500.00');
    });

    test('shows full amount for millions', () {
      expect(formatMoneyCompact(1000000), '₦1,000,000.00');
    });

    test('matches formatMoney output', () {
      final amounts = [0.0, 500.0, 1800.0, 55000.0, 500000.0];
      for (final a in amounts) {
        expect(formatMoneyCompact(a), formatMoney(a));
      }
    });
  });

  // ============================================================
  // EGG FORMATTING
  // ============================================================
  group('formatEggs', () {
    test('zero eggs', () {
      expect(formatEggs(0), '0 pcs');
    });

    test('less than one crate shows pieces only', () {
      expect(formatEggs(15), '15 pcs');
    });

    test('exactly one crate shows crate only', () {
      expect(formatEggs(30), '1 crates');
    });

    test('exact multiple of 30 shows crates only', () {
      expect(formatEggs(300), '10 crates');
    });

    test('crates with loose pieces shows both', () {
      expect(formatEggs(375), '12 crates + 15 pcs');
    });

    test('29 pieces shows pieces only', () {
      expect(formatEggs(29), '29 pcs');
    });

    test('31 eggs shows 1 crate + 1 piece', () {
      expect(formatEggs(31), '1 crates + 1 pcs');
    });
  });

  // ============================================================
  // DATE FORMATTING
  // ============================================================
  group('formatDate', () {
    test('formats date correctly', () {
      final date = DateTime(2024, 6, 15);
      expect(formatDate(date), '15 Jun 2024');
    });

    test('formats single digit day with padding', () {
      final date = DateTime(2024, 1, 5);
      expect(formatDate(date), '05 Jan 2024');
    });
  });

  group('formatDateShort', () {
    test('formats short date correctly', () {
      final date = DateTime(2024, 6, 15);
      expect(formatDateShort(date), '15 Jun');
    });
  });

  group('formatMonthYear', () {
    test('formats month and year correctly', () {
      final date = DateTime(2024, 6, 15);
      expect(formatMonthYear(date), 'June 2024');
    });
  });

  // ============================================================
  // PARSE AMOUNT
  // ============================================================
  group('parseAmount', () {
    test('parses plain number', () {
      expect(parseAmount('1800'), 1800.0);
    });

    test('parses number with commas', () {
      expect(parseAmount('1,800'), 1800.0);
    });

    test('parses decimal number', () {
      expect(parseAmount('1800.50'), 1800.50);
    });

    test('parses number with spaces', () {
      expect(parseAmount(' 5000 '), 5000.0);
    });

    test('returns zero for empty string', () {
      expect(parseAmount(''), 0.0);
    });

    test('returns zero for invalid string', () {
      expect(parseAmount('abc'), 0.0);
    });
  });

  // ============================================================
  // IS SAME DAY
  // ============================================================
  group('isSameDay', () {
    test('same date returns true', () {
      final a = DateTime(2024, 6, 15, 10, 0);
      final b = DateTime(2024, 6, 15, 22, 30);
      expect(isSameDay(a, b), true);
    });

    test('different day returns false', () {
      final a = DateTime(2024, 6, 15);
      final b = DateTime(2024, 6, 16);
      expect(isSameDay(a, b), false);
    });

    test('different month returns false', () {
      final a = DateTime(2024, 6, 15);
      final b = DateTime(2024, 7, 15);
      expect(isSameDay(a, b), false);
    });

    test('different year returns false', () {
      final a = DateTime(2024, 6, 15);
      final b = DateTime(2025, 6, 15);
      expect(isSameDay(a, b), false);
    });

    test('today is same as today', () {
      final now = DateTime.now();
      expect(isSameDay(now, now), true);
    });
  });
}
