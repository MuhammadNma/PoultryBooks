// lib/providers/daily_log_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/daily_log.dart';
import '../core/constants.dart';
import '../utils/formatters.dart';

class DailyLogProvider extends ChangeNotifier {
  Box<DailyLog>? _box;
  Box? _deletedBox;

  List<DailyLog> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> init(String uid) async {
    _box = await Hive.openBox<DailyLog>('${AppConstants.dailyLogBox}$uid');
    _deletedBox = await Hive.openBox('${AppConstants.dailyLogBox}deleted_$uid');
    notifyListeners();
  }

  Future<void> add(DailyLog log) async {
    await _box!.put(log.id, log);
    notifyListeners();
  }

  Future<void> update(DailyLog log) async {
    await log.save();
    notifyListeners();
  }

  Future<void> delete(DailyLog log) async {
    await _deletedBox?.put(log.id, true);
    await log.delete();
    notifyListeners();
  }

  bool isDeleted(String id) => _deletedBox?.get(id) == true;

  DailyLog? getForDate(DateTime date, String flockId) {
    try {
      return all
          .firstWhere((l) => isSameDay(l.date, date) && l.flockId == flockId);
    } catch (_) {
      return null;
    }
  }

  List<DailyLog> forMonth(int year, int month, {String? flockId}) => all
      .where((l) =>
          l.date.year == year &&
          l.date.month == month &&
          (flockId == null || l.flockId == flockId))
      .toList();

  /// Total eggs collected across all time.
  int get totalCollected => all.fold(0, (s, l) => s + l.eggsCollected);

  /// Eggs on hand = collected - sold + net adjustments (losses/corrections).
  /// [netAdjustment] comes from EggAdjustmentProvider.netAdjustment.
  int totalEggsOnHand(int totalSoldEggs, {int netAdjustment = 0}) {
    final onHand = totalCollected - totalSoldEggs + netAdjustment;
    return onHand.clamp(0, 999999);
  }

  List<DailyLog> get unsynced => all.where((l) => !l.synced).toList();
}
