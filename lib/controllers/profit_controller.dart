import 'package:hive/hive.dart';
import '../models/profit_record.dart';

class ProfitController {
  static const _boxName = 'profit_records';

  late Box<ProfitRecord> _box;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _box = await Hive.openBox<ProfitRecord>(_boxName);
    _initialized = true;
  }

  List<ProfitRecord> get records => _box.values.toList().reversed.toList();

  ProfitRecord? get lastRecord {
    if (_box.isEmpty) return null;
    return records.first;
  }

  Future<void> addRecord(ProfitRecord record) async {
    await _box.add(record);
  }

  bool isSavedForToday(DateTime date) {
    return _box.values.any(
      (r) =>
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day,
    );
  }

  ProfitRecord? getRecordByDate(DateTime date) {
    try {
      return _box.values.firstWhere(
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
    final key = _box.keys.firstWhere(
      (k) {
        final r = _box.get(k);
        return r != null &&
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day;
      },
    );

    await _box.delete(key);
  }

  Future<void> deleteRecord(ProfitRecord record) async {
    await deleteByDate(record.date);
  }
}
