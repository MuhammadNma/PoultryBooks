// // lib/providers/flock_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:hive/hive.dart';
// import '../models/flock.dart';
// import '../core/constants.dart';

// class FlockProvider extends ChangeNotifier {
//   Box<Flock>? _box;

//   List<Flock> get flocks {
//     if (_box == null || !_box!.isOpen) return [];
//     return _box!.values.toList()
//       ..sort((a, b) => b.startDate.compareTo(a.startDate));
//   }

//   List<Flock> get activeFlocks => flocks.where((f) => f.isActive).toList();

//   Future<void> initForUser(String userId) async {
//     if (_box != null && _box!.isOpen) await _box!.close();
//     _box = await Hive.openBox<Flock>('${AppConstants.flockBoxPrefix}$userId');
//     notifyListeners();
//   }

//   Future<void> addFlock(Flock flock) async {
//     _ensureReady();
//     await _box!.put(flock.id, flock);
//     notifyListeners();
//   }

//   Future<void> updateFlock(Flock flock) async {
//     _ensureReady();
//     await _box!.put(flock.id, flock);
//     notifyListeners();
//   }

//   Future<void> deleteFlock(String id) async {
//     _ensureReady();
//     await _box!.delete(id);
//     notifyListeners();
//   }

//   Future<void> recordMortality(String flockId, int count) async {
//     _ensureReady();
//     final flock = _box!.get(flockId);
//     if (flock == null) return;
//     flock.mortalityCount += count;
//     await flock.save();
//     notifyListeners();
//   }

//   Flock? getById(String id) => _box?.get(id);

//   Future<void> dispose() async {
//     if (_box != null && _box!.isOpen) await _box!.close();
//     _box = null;
//   }

//   void _ensureReady() {
//     if (_box == null || !_box!.isOpen) {
//       throw Exception('FlockProvider not initialized. Call initForUser first.');
//     }
//   }
// }

// lib/providers/flock_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/flock.dart';
import '../core/constants.dart';

class FlockProvider extends ChangeNotifier {
  Box<Flock>? _box;

  List<Flock> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  List<Flock> get active => all.where((f) => f.isActive).toList();

  Future<void> init(String uid) async {
    _box = await Hive.openBox<Flock>('${AppConstants.flockBox}$uid');
    notifyListeners();
  }

  Future<void> add(Flock f) async {
    await _box!.put(f.id, f);
    notifyListeners();
  }

  Future<void> update(Flock f) async {
    await _box!.put(f.id, f);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box!.delete(id);
    notifyListeners();
  }

  Flock? getById(String id) => _box?.get(id);

  Future<void> addMortality(String flockId, int count) async {
    final f = _box?.get(flockId);
    if (f == null) return;
    f.mortalityCount += count;
    await f.save();
    notifyListeners();
  }
}
