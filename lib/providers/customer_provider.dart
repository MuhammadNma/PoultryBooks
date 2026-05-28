// lib/providers/customer_provider.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../core/constants.dart';

class CustomerProvider extends ChangeNotifier {
  Box<Customer>? _box;

  List<Customer> get all {
    if (_box == null || !_box!.isOpen) return [];
    return _box!.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> init(String uid) async {
    _box = await Hive.openBox<Customer>('${AppConstants.customerBox}$uid');
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

  Future<void> delete(String id) async {
    await _box!.delete(id);
    notifyListeners();
  }

  Customer? getById(String id) => _box?.get(id);

  List<Customer> get unsynced => all.where((c) => !c.synced).toList();
}
