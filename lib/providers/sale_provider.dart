// lib/providers/sale_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/sale.dart';
import '../core/constants.dart';

class SaleProvider extends ChangeNotifier {
  Box<Sale>? _box;
  Box? _deletedBox;

  List<Sale> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> init(String uid) async {
    _box = await Hive.openBox<Sale>('${AppConstants.saleBox}$uid');
    _deletedBox = await Hive.openBox(
        '${AppConstants.saleBox}deleted_$uid');
    notifyListeners();
  }

  Future<void> add(Sale s) async {
    await _box!.put(s.id, s);
    notifyListeners();
  }

  Future<void> update(Sale updated) async {
    final existing = _box!.get(updated.id);
    if (existing != null) {
      existing.date          = updated.date;
      existing.customerId    = updated.customerId;
      existing.customerName  = updated.customerName;
      existing.crates        = updated.crates;
      existing.loosePieces   = updated.loosePieces;
      existing.pricePerCrate = updated.pricePerCrate;
      existing.amountPaid    = updated.amountPaid;
      existing.flockId       = updated.flockId;
      existing.notes         = updated.notes;
      existing.isGift        = updated.isGift;
      existing.synced        = false;
      await existing.save();
    } else {
      await _box!.put(updated.id, updated);
    }
    notifyListeners();
  }

  Future<void> delete(Sale s) async {
    await _deletedBox?.put(s.id, true);
    await s.delete();
    notifyListeners();
  }

  bool isDeleted(String id) => _deletedBox?.get(id) == true;

  List<Sale> forMonth(int year, int month) =>
      all.where((s) =>
          s.date.year == year && s.date.month == month).toList();

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
