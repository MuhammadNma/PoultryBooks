// lib/providers/expense_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';
import '../core/constants.dart';

class ExpenseProvider extends ChangeNotifier {
  Box<Expense>? _box;
  Box? _deletedBox;

  List<Expense> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> init(String uid) async {
    _box = await Hive.openBox<Expense>(
        '${AppConstants.expenseBox}$uid');
    _deletedBox = await Hive.openBox(
        '${AppConstants.expenseBox}deleted_$uid');
    notifyListeners();
  }

  Future<void> add(Expense e) async {
    await _box!.put(e.id, e);
    notifyListeners();
  }

  Future<void> update(Expense updated) async {
    final existing = _box!.get(updated.id);
    if (existing != null) {
      existing.date        = updated.date;
      existing.category    = updated.category;
      existing.amount      = updated.amount;
      existing.description = updated.description;
      existing.flockId     = updated.flockId;
      existing.synced      = false;
      await existing.save();
    } else {
      await _box!.put(updated.id, updated);
    }
    notifyListeners();
  }

  Future<void> delete(Expense e) async {
    await _deletedBox?.put(e.id, true);
    await e.delete();
    notifyListeners();
  }

  bool isDeleted(String id) => _deletedBox?.get(id) == true;

  List<Expense> forMonth(int year, int month) =>
      all.where((e) =>
          e.date.year == year && e.date.month == month).toList();

  double totalForMonth(int year, int month) =>
      forMonth(year, month).fold(0.0, (s, e) => s + e.amount);

  Map<String, double> byCategory(int year, int month) {
    final map = <String, double>{};
    for (final e in forMonth(year, month)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  List<Expense> get unsynced => all.where((e) => !e.synced).toList();
}
