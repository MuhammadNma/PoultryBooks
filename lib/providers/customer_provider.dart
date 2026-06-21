// lib/providers/customer_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../core/constants.dart';

class CustomerProvider extends ChangeNotifier {
  Box<Customer>? _box;
  Box? _deletedBox; // persists IDs of locally-deleted customers

  List<Customer> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> init(String uid) async {
    _box = await Hive.openBox<Customer>('${AppConstants.customerBox}$uid');
    _deletedBox = await Hive.openBox('${AppConstants.customerBox}deleted_$uid');
    notifyListeners();
  }

  Future<void> add(Customer c) async {
    await _box!.put(c.id, c);
    notifyListeners();
  }

  Future<void> update(Customer c) async {
    await _box!.put(c.id, c);
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

  Customer? getById(String id) => _box?.get(id);

  List<Customer> get unsynced => all.where((c) => !c.synced).toList();
}
