// lib/providers/flock_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/flock.dart';
import '../core/constants.dart';

class FlockProvider extends ChangeNotifier {
  Box<Flock>? _box;

  List<Flock> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()..sort((a, b) => b.startDate.compareTo(a.startDate));
  }
  List<Flock> get active => all.where((f) => f.isActive).toList();

  Future<void> init(String uid) async {
    _box = await Hive.openBox<Flock>('${AppConstants.flockBox}$uid');
    notifyListeners();
  }

  Future<void> add(Flock f)    async { await _box!.put(f.id, f); notifyListeners(); }
  Future<void> update(Flock f) async { await _box!.put(f.id, f); notifyListeners(); }
  Future<void> delete(String id) async { await _box!.delete(id); notifyListeners(); }

  Flock? getById(String id) => _box?.get(id);

  Future<void> addMortality(String flockId, int count) async {
    final f = _box?.get(flockId);
    if (f == null) return;
    f.mortalityCount += count;
    await f.save();
    notifyListeners();
  }
}
