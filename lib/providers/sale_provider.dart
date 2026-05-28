// lib/providers/sale_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/sale.dart';
import '../core/constants.dart';

class SaleProvider extends ChangeNotifier {
  Box<Sale>? _box;

  List<Sale> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> init(String uid) async {
    _box = await Hive.openBox<Sale>('${AppConstants.saleBox}$uid');
    notifyListeners();
  }

  Future<void> add(Sale s)    async { await _box!.put(s.id, s); notifyListeners(); }
  Future<void> update(Sale s) async { await s.save(); notifyListeners(); }
  Future<void> delete(Sale s) async { await s.delete(); notifyListeners(); }

  List<Sale> forMonth(int year, int month) =>
      all.where((s) => s.date.year == year && s.date.month == month).toList();

  List<Sale> forCustomer(String customerId) =>
      all.where((s) => s.customerId == customerId).toList();

  double totalIncomeForMonth(int year, int month) =>
      forMonth(year, month).fold(0.0, (s, e) => s + e.totalEggIncome);

  double totalOwingForCustomer(String customerId) =>
      forCustomer(customerId).fold(0.0, (s, e) => s + e.amountOwed);

  double get totalOwingAllCustomers =>
      all.fold(0.0, (s, e) => s + e.amountOwed);

  int totalEggsSold() => all.fold(0, (s, e) => s + e.totalEggs);
  int totalEggsSoldInMonth(int year, int month) =>
      forMonth(year, month).fold(0, (s, e) => s + e.totalEggs);

  List<Sale> get unsynced => all.where((s) => !s.synced).toList();
}
