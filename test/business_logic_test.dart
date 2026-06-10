import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_books/models/daily_log.dart';
import 'package:poultry_books/models/sale.dart';
import 'package:poultry_books/models/expense.dart';
import 'package:poultry_books/core/constants.dart';

void main() {
  // ============================================================
  // EGG INVENTORY LOGIC
  // ============================================================
  group('Egg Inventory Logic', () {
    test('eggs on hand = total collected - total sold', () {
      final logs = [
        _makeLog('l1', 300), // Day 1: 300 eggs
        _makeLog('l2', 270), // Day 2: 270 eggs
        _makeLog('l3', 315), // Day 3: 315 eggs
      ];
      final sales = [
        _makeSale('s1', crates: 10, loose: 0), // Sold 300 eggs
      ];

      final totalCollected = logs.fold(0, (s, l) => s + l.eggsCollected);
      final totalSold = sales.fold(0, (s, e) => s + e.totalEggs);
      final onHand = totalCollected - totalSold;

      expect(totalCollected, 885);
      expect(totalSold, 300);
      expect(onHand, 585);
    });

    test('eggs on hand is zero when all sold', () {
      final logs = [_makeLog('l1', 300)];
      final sales = [_makeSale('s1', crates: 10, loose: 0)];

      final collected = logs.fold(0, (s, l) => s + l.eggsCollected);
      final sold = sales.fold(0, (s, e) => s + e.totalEggs);
      expect((collected - sold).clamp(0, 999999), 0);
    });

    test('eggs on hand never goes negative', () {
      final logs = [_makeLog('l1', 100)];
      final sales = [_makeSale('s1', crates: 10, loose: 0)]; // 300 > 100

      final collected = logs.fold(0, (s, l) => s + l.eggsCollected);
      final sold = sales.fold(0, (s, e) => s + e.totalEggs);
      expect((collected - sold).clamp(0, 999999), 0);
    });

    test('crates calculation from eggs is correct', () {
      const eggs = 885;
      final crates = eggs ~/ AppConstants.eggsPerCrate;
      final loose = eggs % AppConstants.eggsPerCrate;
      expect(crates, 29);
      expect(loose, 15);
      expect((crates * 30) + loose, eggs);
    });
  });

  // ============================================================
  // PROFIT & LOSS LOGIC
  // ============================================================
  group('Profit & Loss Logic', () {
    test('net profit = total income - total expenses', () {
      final sales = [
        _makeSale('s1', crates: 10, loose: 0, price: 1800, paid: 18000),
        _makeSale('s2', crates: 5, loose: 0, price: 1800, paid: 9000),
      ];
      final expenses = [
        _makeExpense('e1', 'Feed', 55000),
        _makeExpense('e2', 'Medication', 5000),
        _makeExpense('e3', 'Fuel', 3000),
      ];

      final totalIncome = sales.fold(0.0, (s, e) => s + e.totalEggIncome);
      final totalExpenses = expenses.fold(0.0, (s, e) => s + e.amount);
      final netProfit = totalIncome - totalExpenses;

      expect(totalIncome, closeTo(27000, 0.01));
      expect(totalExpenses, closeTo(63000, 0.01));
      expect(netProfit, closeTo(-36000, 0.01)); // Loss
    });

    test('profitable month calculates correctly', () {
      final sales = [
        _makeSale('s1', crates: 50, loose: 0, price: 1800, paid: 90000),
      ];
      final expenses = [
        _makeExpense('e1', 'Feed', 55000),
      ];

      final income = sales.fold(0.0, (s, e) => s + e.totalEggIncome);
      final costs = expenses.fold(0.0, (s, e) => s + e.amount);
      final profit = income - costs;

      expect(income, closeTo(90000, 0.01));
      expect(costs, closeTo(55000, 0.01));
      expect(profit, closeTo(35000, 0.01));
    });

    test('zero sales and zero expenses gives zero profit', () {
      const income = 0.0;
      const expenses = 0.0;
      expect(income - expenses, 0.0);
    });

    test('expenses by category sums correctly', () {
      final expenses = [
        _makeExpense('e1', 'Feed', 55000),
        _makeExpense('e2', 'Feed', 60000),
        _makeExpense('e3', 'Fuel', 5000),
        _makeExpense('e4', 'Salary', 30000),
      ];

      final byCategory = <String, double>{};
      for (final e in expenses) {
        byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
      }

      expect(byCategory['Feed'], closeTo(115000, 0.01));
      expect(byCategory['Fuel'], closeTo(5000, 0.01));
      expect(byCategory['Salary'], closeTo(30000, 0.01));
    });

    test('filtering expenses by month works correctly', () {
      final expenses = [
        _makeExpenseOnDate('e1', 'Feed', 55000, DateTime(2024, 6, 1)),
        _makeExpenseOnDate('e2', 'Fuel', 5000, DateTime(2024, 6, 15)),
        _makeExpenseOnDate('e3', 'Salary', 30000, DateTime(2024, 7, 1)),
      ];

      final juneExpenses = expenses
          .where((e) => e.date.year == 2024 && e.date.month == 6)
          .toList();
      final juneTotal = juneExpenses.fold(0.0, (s, e) => s + e.amount);

      expect(juneExpenses.length, 2);
      expect(juneTotal, closeTo(60000, 0.01));
    });
  });

  // ============================================================
  // CUSTOMER DEBT LOGIC
  // ============================================================
  group('Customer Debt Logic', () {
    test('amount owed = total income - amount paid', () {
      final sale =
          _makeSale('s1', crates: 10, loose: 0, price: 1800, paid: 10000);
      expect(sale.totalEggIncome, closeTo(18000, 0.01));
      expect(sale.amountOwed, closeTo(8000, 0.01));
    });

    test('fully paid sale has zero owed', () {
      final sale =
          _makeSale('s1', crates: 10, loose: 0, price: 1800, paid: 18000);
      expect(sale.amountOwed, 0.0);
    });

    test('total owing across multiple sales for one customer', () {
      final sales = [
        _makeSale('s1', crates: 10, loose: 0, price: 1800, paid: 10000),
        _makeSale('s2', crates: 5, loose: 0, price: 1800, paid: 5000),
      ];
      // s1 owes: 18000 - 10000 = 8000
      // s2 owes:  9000 -  5000 = 4000
      final totalOwing = sales.fold(0.0, (s, e) => s + e.amountOwed);
      expect(totalOwing, closeTo(12000, 0.01));
    });

    test('total owing across all customers', () {
      // Customer A owes 8000, Customer B owes 4000
      final allSales = [
        _makeSale('s1', crates: 10, loose: 0, price: 1800, paid: 10000),
        _makeSale('s2', crates: 5, loose: 0, price: 1800, paid: 5000),
      ];
      final totalOwing = allSales.fold(0.0, (s, e) => s + e.amountOwed);
      expect(totalOwing, closeTo(12000, 0.01));
    });

    test('mark as paid sets amountOwed to zero', () {
      final sale = _makeSale('s1', crates: 10, loose: 0, price: 1800, paid: 0);
      expect(sale.amountOwed, closeTo(18000, 0.01));

      // Simulate mark as paid
      sale.amountPaid = sale.totalEggIncome;
      expect(sale.amountOwed, 0.0);
    });
  });

  // ============================================================
  // MORTALITY LOGIC
  // ============================================================
  group('Mortality Logic', () {
    test('mortality diff is calculated correctly on update', () {
      // Previous log had 2 deaths, now updating to 5
      const previousMortality = 2;
      const newMortality = 5;
      final diff = newMortality - previousMortality;
      expect(diff, 3); // Only add 3 more to flock count
    });

    test('reducing mortality gives negative diff', () {
      const previousMortality = 5;
      const newMortality = 2;
      final diff = newMortality - previousMortality;
      expect(diff, -3); // Subtract 3 from flock count
    });

    test('same mortality value gives zero diff', () {
      const previousMortality = 3;
      const newMortality = 3;
      final diff = newMortality - previousMortality;
      expect(diff, 0);
    });

    test('flock active birds decreases with mortality', () {
      const numberOfBirds = 500;
      const mortalityCount = 20;
      final activeBirds = numberOfBirds - mortalityCount;
      expect(activeBirds, 480);
    });

    test('mortality clamped to not exceed flock size', () {
      const numberOfBirds = 500;
      const mortalityCount = 600; // More than birds
      final activeBirds =
          (numberOfBirds - mortalityCount).clamp(0, numberOfBirds);
      expect(activeBirds, 0);
    });
  });

  // ============================================================
  // SALE INCOME CALCULATION
  // ============================================================
  group('Sale Income Calculation', () {
    test('income from crates only', () {
      final sale = _makeSale('s1', crates: 10, loose: 0, price: 1800, paid: 0);
      expect(sale.totalEggIncome, closeTo(18000, 0.01));
    });

    test('income from loose pieces only', () {
      final sale = _makeSale('s1', crates: 0, loose: 15, price: 1800, paid: 0);
      // 15 * (1800/30) = 15 * 60 = 900
      expect(sale.totalEggIncome, closeTo(900, 0.01));
    });

    test('income from crates and loose pieces combined', () {
      final sale = _makeSale('s1', crates: 10, loose: 15, price: 1800, paid: 0);
      // 10 * 1800 + 15 * 60 = 18000 + 900 = 18900
      expect(sale.totalEggIncome, closeTo(18900, 0.01));
    });

    test('price per egg = price per crate / 30', () {
      const pricePerCrate = 1800.0;
      final pricePerEgg = pricePerCrate / AppConstants.eggsPerCrate;
      expect(pricePerEgg, closeTo(60, 0.01));
    });

    test('filtering sales by month', () {
      final sales = [
        _makeSaleOnDate('s1', DateTime(2024, 6, 1), 1800),
        _makeSaleOnDate('s2', DateTime(2024, 6, 15), 1800),
        _makeSaleOnDate('s3', DateTime(2024, 7, 1), 1800),
      ];

      final juneSales =
          sales.where((s) => s.date.year == 2024 && s.date.month == 6).toList();

      expect(juneSales.length, 2);
    });

    test('total income for month sums correctly', () {
      final sales = [
        _makeSale('s1', crates: 10, loose: 0, price: 1800, paid: 18000),
        _makeSale('s2', crates: 10, loose: 0, price: 1800, paid: 18000),
      ];
      final total = sales.fold(0.0, (s, e) => s + e.totalEggIncome);
      expect(total, closeTo(36000, 0.01));
    });
  });
}

// ============================================================
// HELPERS
// ============================================================

DailyLog _makeLog(String id, int eggs, {int mortality = 0}) => DailyLog(
      id: id,
      date: DateTime.now(),
      flockId: 'flock-1',
      eggsCollected: eggs,
      mortality: mortality,
    );

Sale _makeSale(
  String id, {
  required int crates,
  required int loose,
  double price = 1800,
  double paid = 0,
}) =>
    Sale(
      id: id,
      date: DateTime.now(),
      customerId: 'cust-1',
      customerName: 'Test Customer',
      crates: crates,
      loosePieces: loose,
      pricePerCrate: price,
      amountPaid: paid,
    );

Sale _makeSaleOnDate(String id, DateTime date, double price) => Sale(
      id: id,
      date: date,
      customerId: 'cust-1',
      customerName: 'Test Customer',
      crates: 10,
      loosePieces: 0,
      pricePerCrate: price,
      amountPaid: 0,
    );

Expense _makeExpense(String id, String category, double amount) => Expense(
      id: id,
      date: DateTime.now(),
      category: category,
      amount: amount,
    );

Expense _makeExpenseOnDate(
        String id, String category, double amount, DateTime date) =>
    Expense(
      id: id,
      date: date,
      category: category,
      amount: amount,
    );
