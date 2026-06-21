// lib/providers/flock_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/flock.dart';
import '../core/constants.dart';

class FlockProvider extends ChangeNotifier {
  Box<Flock>? _box;
  Box? _deletedBox; // persists IDs of locally-deleted flocks

  List<Flock> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  List<Flock> get active => all.where((f) => f.isActive).toList();

  /// Flocks that have been modified locally and not yet pushed to Firestore.
  List<Flock> get unsynced => all.where((f) => !f.synced).toList();

  Future<void> init(String uid) async {
    _box = await Hive.openBox<Flock>('${AppConstants.flockBox}$uid');
    _deletedBox = await Hive.openBox('${AppConstants.flockBox}deleted_$uid');
    notifyListeners();
  }

  Future<void> add(Flock f) async {
    f.synced = false;
    await _box!.put(f.id, f);
    notifyListeners();
  }

  Future<void> update(Flock f) async {
    f.synced = false;
    await _box!.put(f.id, f);
    notifyListeners();
  }

  /// Removes locally and records the ID so sync can delete from Firestore.
  Future<void> delete(String id) async {
    await _deletedBox?.put(id, true);
    await _box?.delete(id);
    notifyListeners();
  }

  /// True when this ID was deleted locally and must be removed from Firestore.
  bool isDeleted(String id) => _deletedBox?.get(id) == true;

  Flock? getById(String id) => _box?.get(id);

  Future<void> addMortality(String flockId, int count) async {
    final f = _box?.get(flockId);
    if (f == null) return;
    f.mortalityCount += count;
    f.synced = false;
    await f.save();
    notifyListeners();
  }
}
