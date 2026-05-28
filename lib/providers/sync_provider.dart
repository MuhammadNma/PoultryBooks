// lib/providers/sync_provider.dart
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/flock.dart';
import '../models/daily_log.dart';
import '../models/sale.dart';
import '../models/expense.dart';
import '../models/customer.dart';
import 'flock_provider.dart';
import 'daily_log_provider.dart';
import 'sale_provider.dart';
import 'expense_provider.dart';
import 'customer_provider.dart';

enum SyncStatus { idle, syncing, synced, error, offline }

class SyncProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  SyncStatus _status = SyncStatus.idle;
  bool _isOnline = true;
  String? _lastError;

  SyncStatus get status => _status;
  bool get isOnline => _isOnline;
  String? get lastError => _lastError;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference? _col(String name) =>
      _uid == null ? null : _db.collection('users').doc(_uid).collection(name);

  void startMonitoring() {
    Connectivity().onConnectivityChanged.listen((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      notifyListeners();
    });
    Connectivity().checkConnectivity().then((r) {
      _isOnline = r.any((x) => x != ConnectivityResult.none);
      notifyListeners();
    });
  }

  Future<void> syncAll({
    required FlockProvider flocks,
    required DailyLogProvider logs,
    required SaleProvider sales,
    required ExpenseProvider expenses,
    required CustomerProvider customers,
  }) async {
    if (_uid == null) return;
    final conn = await Connectivity().checkConnectivity();
    if (conn.every((r) => r == ConnectivityResult.none)) {
      _isOnline = false;
      _status = SyncStatus.offline;
      notifyListeners();
      return;
    }

    _isOnline = true;
    _status = SyncStatus.syncing;
    _lastError = null;
    notifyListeners();

    try {
      // ---- PUSH ----

      // Flocks
      for (final f in flocks.all) {
        await _col('flocks')?.doc(f.id).set(f.toJson());
      }

      // Daily logs
      for (final l in logs.unsynced) {
        await _col('daily_logs')?.doc(l.id).set(l.toJson());
        l.synced = true;
        await l.save();
      }

      // Sales
      for (final s in sales.unsynced) {
        await _col('sales')?.doc(s.id).set(s.toJson());
        s.synced = true;
        await s.save();
      }

      // Expenses — push updates AND push deletions to Firestore
      for (final e in expenses.unsynced) {
        await _col('expenses')?.doc(e.id).set(e.toJson());
        e.synced = true;
        await e.save();
      }

      // Customers
      for (final c in customers.unsynced) {
        await _col('customers')?.doc(c.id).set(c.toJson());
        c.synced = true;
        await c.save();
      }

      // ---- PULL ----

      // Flocks
      final fs = await _col('flocks')?.get();
      for (final d in fs?.docs ?? []) {
        if (flocks.getById(d.id) == null) {
          await flocks.add(Flock.fromJson(d.data() as Map<String, dynamic>));
        }
      }

      // Daily logs
      final ls = await _col('daily_logs')?.get();
      for (final d in ls?.docs ?? []) {
        final j = d.data() as Map<String, dynamic>;
        if (logs.getForDate(DateTime.parse(j['date']), j['flockId']) == null) {
          await logs.add(DailyLog.fromJson(j));
        }
      }

      // Sales
      final ss = await _col('sales')?.get();
      for (final d in ss?.docs ?? []) {
        if (!sales.all.any((s) => s.id == d.id)) {
          await sales.add(Sale.fromJson(d.data() as Map<String, dynamic>));
        }
      }

      // Expenses — skip any IDs that were deleted locally,
      // and delete them from Firestore too
      final es = await _col('expenses')?.get();
      for (final d in es?.docs ?? []) {
        if (expenses.isDeleted(d.id)) {
          // Delete from Firestore so it doesn't come back
          await _col('expenses')?.doc(d.id).delete();
        } else if (!expenses.all.any((e) => e.id == d.id)) {
          await expenses
              .add(Expense.fromJson(d.data() as Map<String, dynamic>));
        }
      }

      // Customers
      final cs = await _col('customers')?.get();
      for (final d in cs?.docs ?? []) {
        if (customers.getById(d.id) == null) {
          await customers
              .add(Customer.fromJson(d.data() as Map<String, dynamic>));
        }
      }

      _status = SyncStatus.synced;
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
      debugPrint('❌ Sync error: $e');
    }
    notifyListeners();
  }
}
