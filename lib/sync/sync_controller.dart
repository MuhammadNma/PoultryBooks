import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

import '../models/customer.dart';
import '../models/customer_transaction.dart';
import '../models/profit_record.dart';

class SyncController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncAll(String uid) async {
    if (!await _hasInternet()) return;

    await _uploadCustomers(uid);
    await _uploadTransactions(uid);
    await _uploadProfits(uid);
  }

  Future<void> _uploadCustomers(String uid) async {
    final box = Hive.box<Customer>('customers');
    for (final c in box.values) {
      await _db
          .collection('users/$uid/customers')
          .doc(c.id)
          .set(c.toJson());
    }
  }

  Future<void> _uploadTransactions(String uid) async {
    final box = Hive.box<CustomerTransaction>('transactions');
    for (final t in box.values) {
      await _db
          .collection('users/$uid/transactions')
          .doc(t.id)
          .set(t.toJson());
    }
  }

  Future<void> _uploadProfits(String uid) async {
    final box = Hive.box<ProfitRecord>('profit_records');
    for (final p in box.values) {
      await _db
          .collection('users/$uid/profits')
          .doc(p.date.toIso8601String())
          .set(p.toJson());
    }
  }

  /// DOWNLOAD (ON LOGIN)
  Future<void> downloadAll(String uid) async {
    await _download<Customer>(
      path: 'users/$uid/customers',
      box: Hive.box<Customer>('customers'),
      fromJson: Customer.fromJson,
    );

    await _download<CustomerTransaction>(
      path: 'users/$uid/transactions',
      box: Hive.box<CustomerTransaction>('transactions'),
      fromJson: CustomerTransaction.fromJson,
    );

    await _download<ProfitRecord>(
      path: 'users/$uid/profits',
      box: Hive.box<ProfitRecord>('profit_records'),
      fromJson: ProfitRecord.fromJson,
    );
  }

  Future<void> _download<T>({
    required String path,
    required Box<T> box,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final snapshot = await _db.collection(path).get();
    await box.clear();
    for (final doc in snapshot.docs) {
      box.put(doc.id, fromJson(doc.data()));
    }
  }
}
