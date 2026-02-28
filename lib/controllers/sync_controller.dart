// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'transaction_controller.dart';
// import 'profit_controller.dart';
// import '../models/customer.dart';
// import '../models/customer_transaction.dart';
// import '../models/profit_record.dart';

// class SyncController {
//   final TransactionController txController;
//   final ProfitController profitController;

//   final FirebaseFirestore firestore = FirebaseFirestore.instance;

//   SyncController({
//     required this.txController,
//     required this.profitController,
//   });

//   String get uid => FirebaseAuth.instance.currentUser!.uid;

//   /// Upload all local data to Firestore
//   Future<void> uploadAll() async {
//     await _uploadCustomers();
//     await _uploadTransactions();
//     await _uploadProfits();
//   }

//   /// Download all Firestore data to Hive
//   Future<void> downloadAll() async {
//     await _downloadCustomers();
//     await _downloadTransactions();
//     await _downloadProfits();
//   }

//   Future<void> _uploadCustomers() async {
//     final customers = txController.customers;
//     for (var c in customers) {
//       await firestore
//           .collection('users')
//           .doc(uid)
//           .collection('customers')
//           .doc(c.id)
//           .set(c.toJson());
//     }
//   }

//   Future<void> _uploadTransactions() async {
//     final allTxs = txController.txBox.values.toList();
//     for (var tx in allTxs) {
//       await firestore
//           .collection('users')
//           .doc(uid)
//           .collection('transactions')
//           .doc(tx.id)
//           .set(tx.toJson());
//     }
//   }

//   Future<void> _uploadProfits() async {
//     final profits = profitController.records;
//     for (var p in profits) {
//       await firestore
//           .collection('users')
//           .doc(uid)
//           .collection('profits')
//           .doc(p.id)
//           .set(p.toJson());
//     }
//   }

//   Future<void> _downloadCustomers() async {
//     final snapshot = await firestore
//         .collection('users')
//         .doc(uid)
//         .collection('customers')
//         .get();

//     for (var doc in snapshot.docs) {
//       final customer = Customer.fromJson(doc.data());
//       txController.customersBox.put(customer.id, customer);
//     }
//   }

//   Future<void> _downloadTransactions() async {
//     final snapshot = await firestore
//         .collection('users')
//         .doc(uid)
//         .collection('transactions')
//         .get();

//     for (var doc in snapshot.docs) {
//       final tx = CustomerTransaction.fromJson(doc.data());
//       txController.txBox.put(tx.id, tx);
//     }
//   }

//   Future<void> _downloadProfits() async {
//     final snapshot = await firestore
//         .collection('users')
//         .doc(uid)
//         .collection('profits')
//         .get();

//     for (var doc in snapshot.docs) {
//       final profit = ProfitRecord.fromJson(doc.data());
//       profitController._box.put(profit.id, profit);
//     }
//   }
// }
