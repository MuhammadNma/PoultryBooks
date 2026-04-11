import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/profit_record.dart';

class ProfitController {
  Box<ProfitRecord>? _box;
  String? _currentUserId;

  /// 🔑 Initialize controller for a specific user
  Future<void> initForUser(String userId) async {
    // Prevent reopening same box
    if (_currentUserId == userId && _box != null) return;

    // Close previous box if switching users
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }

    _currentUserId = userId;
    _box = await Hive.openBox<ProfitRecord>('profit_records_$userId');
  }

  /// 🔒 Safety guard
  void _ensureInitialized() {
    if (_box == null || !_box!.isOpen) {
      debugPrint('⚠️ ProfitController used before initialization');
      throw Exception(
        'ProfitController not initialized. '
        'Call initForUser(userId) after login.',
      );
    }
  }

  /// ---------------- GETTERS ----------------

  List<ProfitRecord> get records {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList().reversed.toList();
  }

  ProfitRecord? get lastRecord {
    if (_box == null || !_box!.isOpen || _box!.isEmpty) return null;
    return records.first;
  }

  /// ---------------- CRUD ----------------

  Future<void> addRecord(ProfitRecord record) async {
    _ensureInitialized();
    await _box!.add(record);
  }

  bool isSavedForToday(DateTime date) {
    _ensureInitialized();
    return _box!.values.any(
      (r) =>
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day,
    );
  }

  ProfitRecord? getRecordByDate(DateTime date) {
    _ensureInitialized();
    try {
      return _box!.values.firstWhere(
        (r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteByDate(DateTime date) async {
    _ensureInitialized();

    final key = _box!.keys.firstWhere(
      (k) {
        final r = _box!.get(k);
        return r != null &&
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day;
      },
      orElse: () => null,
    );

    if (key != null) {
      await _box!.delete(key);
    }
  }

  Future<void> deleteRecord(ProfitRecord record) async {
    await deleteByDate(record.date);
  }

  /// ---------------- CLEANUP ----------------

  /// Call on logout if you want to be explicit
  Future<void> dispose() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
    _box = null;
    _currentUserId = null;
  }
}
