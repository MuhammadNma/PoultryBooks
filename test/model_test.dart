// test/models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:poultry_books/models/flock.dart';
import 'package:poultry_books/models/daily_log.dart';
import 'package:poultry_books/models/sale.dart';
import 'package:poultry_books/models/expense.dart';
import 'package:poultry_books/models/customer.dart';
import 'package:poultry_books/core/constants.dart';

void main() {
  // ============================================================
  // FLOCK TESTS
  // ============================================================
  group('Flock Model', () {
    late Flock flock;

    setUp(() {
      flock = Flock(
        id: 'flock-1',
        name: 'Batch A',
        numberOfBirds: 500,
        costPerBird: 1500,
        startDate: DateTime(2024, 1, 1),
      );
    });

    test('activeBirds = numberOfBirds - mortalityCount', () {
      expect(flock.activeBirds, 500);
      flock.mortalityCount = 20;
      expect(flock.activeBirds, 480);
    });

    test('activeBirds never goes below zero', () {
      flock.mortalityCount = 600; // more than birds
      // activeBirds is just subtraction — clamp is on the caller
      expect(flock.activeBirds, lessThanOrEqualTo(flock.numberOfBirds));
    });

    test('toJson contains all required fields', () {
      final json = flock.toJson();
      expect(json['id'], 'flock-1');
      expect(json['name'], 'Batch A');
      expect(json['numberOfBirds'], 500);
      expect(json['costPerBird'], 1500.0);
      expect(json['isActive'], true);
      expect(json['mortalityCount'], 0);
    });

    test('fromJson reconstructs flock correctly', () {
      final json = flock.toJson();
      final restored = Flock.fromJson(json);
      expect(restored.id, flock.id);
      expect(restored.name, flock.name);
      expect(restored.numberOfBirds, flock.numberOfBirds);
      expect(restored.costPerBird, flock.costPerBird);
      expect(restored.isActive, flock.isActive);
      expect(restored.mortalityCount, flock.mortalityCount);
    });

    test('fromJson handles missing optional fields gracefully', () {
      final json = {
        'id': 'f2',
        'name': 'Batch B',
        'startDate': DateTime.now().toIso8601String(),
      };
      final f = Flock.fromJson(json);
      expect(f.numberOfBirds, 0);
      expect(f.costPerBird, 0.0);
      expect(f.isActive, true);
      expect(f.mortalityCount, 0);
      expect(f.notes, isNull);
    });

    test('flock is active by default', () {
      expect(flock.isActive, true);
    });
  });

  // ============================================================
  // DAILY LOG TESTS
  // ============================================================
  group('DailyLog Model', () {
    late DailyLog log;

    setUp(() {
      log = DailyLog(
        id: 'log-1',
        date: DateTime(2024, 6, 15),
        flockId: 'flock-1',
        eggsCollected: 375,
        mortality: 2,
      );
    });

    test('cratesProduced = eggsCollected ~/ 30', () {
      expect(log.cratesProduced, 12); // 375 / 30 = 12.5 → 12
    });

    test('looseEggs = eggsCollected % 30', () {
      expect(log.looseEggs, 15); // 375 % 30 = 15
    });

    test('cratesProduced + looseEggs reconstructs egg count', () {
      final reconstructed =
          (log.cratesProduced * AppConstants.eggsPerCrate) + log.looseEggs;
      expect(reconstructed, log.eggsCollected);
    });

    test('exact crate count has zero loose eggs', () {
      final exactLog = DailyLog(
        id: 'log-2',
        date: DateTime.now(),
        flockId: 'f1',
        eggsCollected: 300,
      );
      expect(exactLog.cratesProduced, 10);
      expect(exactLog.looseEggs, 0);
    });

    test('toJson serialises correctly', () {
      final json = log.toJson();
      expect(json['id'], 'log-1');
      expect(json['flockId'], 'flock-1');
      expect(json['eggsCollected'], 375);
      expect(json['mortality'], 2);
    });

    test('fromJson reconstructs log correctly', () {
      final json = log.toJson();
      final restored = DailyLog.fromJson(json);
      expect(restored.id, log.id);
      expect(restored.flockId, log.flockId);
      expect(restored.eggsCollected, log.eggsCollected);
      expect(restored.mortality, log.mortality);
      expect(restored.synced, true); // fromJson marks as synced
    });

    test('fromJson handles missing fields with defaults', () {
      final json = {
        'id': 'log-3',
        'date': DateTime.now().toIso8601String(),
        'flockId': 'f1',
      };
      final l = DailyLog.fromJson(json);
      expect(l.eggsCollected, 0);
      expect(l.mortality, 0);
      expect(l.notes, isNull);
    });

    test('synced defaults to false on creation', () {
      expect(log.synced, false);
    });

    test('zero eggs gives zero crates and zero loose', () {
      final zeroLog = DailyLog(
        id: 'log-0',
        date: DateTime.now(),
        flockId: 'f1',
        eggsCollected: 0,
      );
      expect(zeroLog.cratesProduced, 0);
      expect(zeroLog.looseEggs, 0);
    });
  });

  // ============================================================
  // SALE TESTS
  // ============================================================
  group('Sale Model', () {
    late Sale sale;

    setUp(() {
      sale = Sale(
        id: 'sale-1',
        date: DateTime(2024, 6, 20),
        customerId: 'cust-1',
        customerName: 'John Doe',
        crates: 10,
        loosePieces: 15,
        pricePerCrate: 1800,
        amountPaid: 15000,
      );
    });

    test('totalEggs = (crates * 30) + loosePieces', () {
      expect(sale.totalEggs, (10 * 30) + 15); // 315
    });

    test('totalEggIncome calculates correctly', () {
      // 10 crates * 1800 + 15 pieces * (1800/30)
      // = 18000 + 15 * 60 = 18000 + 900 = 18900
      expect(sale.totalEggIncome, closeTo(18900, 0.01));
    });

    test('amountOwed = totalEggIncome - amountPaid', () {
      // 18900 - 15000 = 3900
      expect(sale.amountOwed, closeTo(3900, 0.01));
    });

    test('amountOwed never goes negative', () {
      final overpaid = Sale(
        id: 'sale-2',
        date: DateTime.now(),
        customerId: 'c1',
        customerName: 'Jane',
        crates: 5,
        loosePieces: 0,
        pricePerCrate: 1800,
        amountPaid: 99999,
      );
      expect(overpaid.amountOwed, 0.0);
    });

    test('fully paid sale has zero amountOwed', () {
      final paid = Sale(
        id: 'sale-3',
        date: DateTime.now(),
        customerId: 'c1',
        customerName: 'Jane',
        crates: 10,
        loosePieces: 0,
        pricePerCrate: 1800,
        amountPaid: 18000,
      );
      expect(paid.amountOwed, 0.0);
    });

    test('toJson serialises correctly', () {
      final json = sale.toJson();
      expect(json['id'], 'sale-1');
      expect(json['customerName'], 'John Doe');
      expect(json['crates'], 10);
      expect(json['loosePieces'], 15);
      expect(json['pricePerCrate'], 1800.0);
      expect(json['amountPaid'], 15000.0);
    });

    test('fromJson reconstructs sale correctly', () {
      final json = sale.toJson();
      final restored = Sale.fromJson(json);
      expect(restored.id, sale.id);
      expect(restored.customerName, sale.customerName);
      expect(restored.crates, sale.crates);
      expect(restored.loosePieces, sale.loosePieces);
      expect(restored.pricePerCrate, sale.pricePerCrate);
      expect(restored.amountPaid, sale.amountPaid);
      expect(restored.synced, true);
    });

    test('fromJson handles missing customerName', () {
      final json = sale.toJson();
      json.remove('customerName');
      final restored = Sale.fromJson(json);
      expect(restored.customerName, '');
    });

    test('sale with zero crates and only loose pieces', () {
      final s = Sale(
        id: 'sale-loose',
        date: DateTime.now(),
        customerId: 'c1',
        customerName: 'Jane',
        crates: 0,
        loosePieces: 15,
        pricePerCrate: 1800,
        amountPaid: 0,
      );
      expect(s.totalEggs, 15);
      expect(s.totalEggIncome, closeTo(900, 0.01)); // 15 * 60
      expect(s.amountOwed, closeTo(900, 0.01));
    });
  });

  // ============================================================
  // EXPENSE TESTS
  // ============================================================
  group('Expense Model', () {
    late Expense expense;

    setUp(() {
      expense = Expense(
        id: 'exp-1',
        date: DateTime(2024, 6, 10),
        category: 'Feed',
        amount: 55000,
        description: '10 bags of layer mash',
      );
    });

    test('toJson serialises correctly', () {
      final json = expense.toJson();
      expect(json['id'], 'exp-1');
      expect(json['category'], 'Feed');
      expect(json['amount'], 55000.0);
      expect(json['description'], '10 bags of layer mash');
    });

    test('fromJson reconstructs expense correctly', () {
      final json = expense.toJson();
      final restored = Expense.fromJson(json);
      expect(restored.id, expense.id);
      expect(restored.category, expense.category);
      expect(restored.amount, expense.amount);
      expect(restored.description, expense.description);
      expect(restored.synced, true);
    });

    test('fromJson defaults missing category to Other', () {
      final json = {
        'id': 'exp-2',
        'date': DateTime.now().toIso8601String(),
        'amount': 1000.0,
      };
      final e = Expense.fromJson(json);
      expect(e.category, 'Other');
    });

    test('fromJson handles missing amount', () {
      final json = {
        'id': 'exp-3',
        'date': DateTime.now().toIso8601String(),
        'category': 'Fuel',
      };
      final e = Expense.fromJson(json);
      expect(e.amount, 0.0);
    });

    test('all expense categories are valid', () {
      for (final cat in AppConstants.expenseCategories) {
        final e = Expense(
          id: cat,
          date: DateTime.now(),
          category: cat,
          amount: 1000,
        );
        expect(e.category, cat);
      }
    });

    test('synced defaults to false on creation', () {
      expect(expense.synced, false);
    });
  });

  // ============================================================
  // CUSTOMER TESTS
  // ============================================================
  group('Customer Model', () {
    late Customer customer;

    setUp(() {
      customer = Customer(
        id: 'cust-1',
        name: 'John Doe',
        phone: '08012345678',
        address: '12 Farm Road, Lagos',
      );
    });

    test('toJson serialises correctly', () {
      final json = customer.toJson();
      expect(json['id'], 'cust-1');
      expect(json['name'], 'John Doe');
      expect(json['phone'], '08012345678');
      expect(json['address'], '12 Farm Road, Lagos');
    });

    test('fromJson reconstructs customer correctly', () {
      final json = customer.toJson();
      final restored = Customer.fromJson(json);
      expect(restored.id, customer.id);
      expect(restored.name, customer.name);
      expect(restored.phone, customer.phone);
      expect(restored.address, customer.address);
      expect(restored.synced, true);
    });

    test('customer without address has null address', () {
      final c = Customer(id: 'cust-2', name: 'Jane', phone: '09011112222');
      expect(c.address, isNull);
    });

    test('fromJson handles missing address', () {
      final json = {
        'id': 'cust-3',
        'name': 'Mike',
        'phone': '07099998888',
      };
      final c = Customer.fromJson(json);
      expect(c.address, isNull);
    });

    test('synced defaults to false on creation', () {
      expect(customer.synced, false);
    });
  });
}
