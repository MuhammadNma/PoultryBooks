// lib/providers/egg_adjustment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/egg_adjustment.dart';
import '../core/constants.dart';

class EggAdjustmentProvider extends ChangeNotifier {
  Box<EggAdjustment>? _box;
  Box? _deletedBox;

  List<EggAdjustment> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  List<EggAdjustment> get unsynced => all.where((a) => !a.synced).toList();

  /// Net effect of all adjustments on eggs-on-hand.
  /// Losses are negative, stock corrections are signed.
  int get netAdjustment => all.fold(0, (sum, a) => sum + a.signedEffect);

  Future<void> init(String uid) async {
    _box = await Hive.openBox<EggAdjustment>(
        '${AppConstants.eggAdjustmentBox}$uid');
    _deletedBox =
        await Hive.openBox('${AppConstants.eggAdjustmentBox}deleted_$uid');
    notifyListeners();
  }

  /// Record eggs lost (breakage, spoilage, home use, etc.)
  Future<void> recordLoss({
    required int eggs,
    required String reason,
    DateTime? date,
  }) async {
    final adj = EggAdjustment(
      id: const Uuid().v4(),
      date: date ?? DateTime.now(),
      eggs: eggs,
      typeStr: 'loss',
      reason: reason,
      synced: false,
    );
    await _box!.put(adj.id, adj);
    notifyListeners();
  }

  /// Correct stock to match a physical count.
  /// [actualOnHand] is what the farmer physically counted.
  /// [currentOnHand] is what the app currently shows.
  /// The difference is stored as a signed correction.
  Future<void> correctStock({
    required int actualOnHand,
    required int currentOnHand,
    required String reason,
    DateTime? date,
  }) async {
    final difference = actualOnHand - currentOnHand;
    // Store absolute value; sign is encoded in typeStr context via signedEffect
    // For corrections we store the difference directly as signed eggs.
    final adj = EggAdjustment(
      id: const Uuid().v4(),
      date: date ?? DateTime.now(),
      eggs: difference, // can be negative (overcount) or positive (undercount)
      typeStr: 'stockCorrection',
      reason: reason,
      synced: false,
    );
    await _box!.put(adj.id, adj);
    notifyListeners();
  }

  Future<void> add(EggAdjustment adj) async {
    await _box!.put(adj.id, adj);
    notifyListeners();
  }

  Future<void> delete(EggAdjustment adj) async {
    await _deletedBox?.put(adj.id, true);
    await adj.delete();
    notifyListeners();
  }

  bool isDeleted(String id) => _deletedBox?.get(id) == true;

  EggAdjustment? getById(String id) => _box?.get(id);
}
