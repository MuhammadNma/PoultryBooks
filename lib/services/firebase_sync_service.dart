// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../controllers/profit_controller.dart';
// import '../models/profit_record.dart';

// class FirebaseProfitSyncService {
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;

//   String get _uid => _auth.currentUser!.uid;

//   /// ⬆ PUSH LOCAL → CLOUD
//   Future<void> pushUnsyncedProfits(ProfitController controller) async {
//     for (final record in controller.records) {
//       if (record.synced) continue;

//       final docId = _docId(record.date);

//       await _firestore
//           .collection('users')
//           .doc(_uid)
//           .collection('profit_records')
//           .doc(docId)
//           .set(record.toJson());

//       record.synced = true;
//       await record.save();
//     }
//   }

//   /// ⬇ PULL CLOUD → LOCAL
//   Future<void> pullMissingProfits(ProfitController controller) async {
//     final snapshot = await _firestore
//         .collection('users')
//         .doc(_uid)
//         .collection('profit_records')
//         .get();

//     for (final doc in snapshot.docs) {
//       final date = DateTime.parse(doc['date']);

//       if (controller.getRecordByDate(date) != null) continue;

//       final record = ProfitRecord.fromJson(doc.data());
//       await controller.addRecord(record);
//     }
//   }

//   Future<void> syncAll(ProfitController controller) async {
//     await pushUnsyncedProfits(controller);
//     await pullMissingProfits(controller);
//   }

//   String _docId(DateTime d) => '${d.year}-${d.month}-${d.day}';
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/transaction_controller.dart';
import '../controllers/profit_controller.dart';
import '../models/customer.dart';
import '../models/customer_transaction.dart';
import '../models/profit_record.dart';

class FirebaseSyncService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  /// =========================
  /// CUSTOMERS
  /// =========================

  Future<void> pushUnsyncedCustomers(TransactionController controller) async {
    for (final customer in controller.customers) {
      if (customer.isSynced) continue;

      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('customers')
          .doc(customer.id)
          .set(customer.toJson());

      customer.synced = true;
      await customer.save();
    }
  }

  Future<void> pullCustomers(TransactionController controller) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('customers')
        .get();

    for (final doc in snapshot.docs) {
      final existing = controller.customersBox.get(doc.id);
      if (existing != null) continue;

      final customer = Customer.fromJson(doc.data());
      await controller.customersBox.put(customer.id, customer);
    }
  }

  /// =========================
  /// TRANSACTIONS
  /// =========================

  Future<void> pushUnsyncedTransactions(
      TransactionController controller) async {
    for (final tx in controller.txBox.values) {
      if (tx.isSynced) continue;

      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('transactions')
          .doc(tx.id)
          .set(tx.toJson());

      tx.synced = true;
      await tx.save();
    }
  }

  Future<void> pullTransactions(TransactionController controller) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .get();

    for (final doc in snapshot.docs) {
      if (controller.txBox.get(doc.id) != null) continue;

      final tx = CustomerTransaction.fromJson(doc.data());
      await controller.txBox.put(tx.id, tx);
    }
  }

  /// =========================
  /// PROFITS (UNCHANGED)
  /// =========================

  Future<void> syncProfits(ProfitController controller) async {
    for (final record in controller.records) {
      if (record.isSynced) continue;

      final docId =
          '${record.date.year}-${record.date.month}-${record.date.day}';

      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('profit_records')
          .doc(docId)
          .set(record.toJson());

      record.synced = true;
      await record.save();
    }
  }

  /// =========================
  /// SYNC EVERYTHING
  /// =========================

  Future<void> syncAll(
    TransactionController txController,
    ProfitController profitController,
  ) async {
    await pushUnsyncedCustomers(txController);
    await pushUnsyncedTransactions(txController);
    await pullCustomers(txController);
    await pullTransactions(txController);
    await syncProfits(profitController);
  }
}
