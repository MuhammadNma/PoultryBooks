// import 'package:hive/hive.dart';
// import '../models/customer.dart';
// import '../models/customer_transaction.dart';

// class TransactionController {
//   late Box<Customer> customersBox;
//   late Box<CustomerTransaction> txBox;

//   String? _currentUserId;

//   TransactionController();

//   /// 🔑 Initialize per user (CALL THIS AFTER LOGIN)
//   Future<void> initForUser(String userId) async {
//     if (_currentUserId == userId &&
//         Hive.isBoxOpen('customers_$userId') &&
//         Hive.isBoxOpen('transactions_$userId')) {
//       return;
//     }

//     _currentUserId = userId;

//     customersBox = await Hive.openBox<Customer>('customers_$userId');

//     txBox = await Hive.openBox<CustomerTransaction>('transactions_$userId');
//   }

//   List<Customer> get customers => customersBox.values.toList();

//   List<CustomerTransaction> forCustomer(String customerId) {
//     return txBox.values.where((tx) => tx.customerId == customerId).toList();
//   }

//   void addCustomer(Customer customer) {
//     customer.synced = false;
//     customersBox.put(customer.id, customer);
//   }

//   void updateCustomer(Customer updated) {
//     updated.synced = false;
//     customersBox.put(updated.id, updated);
//   }

//   void addTransaction(CustomerTransaction tx) {
//     tx.synced = false;
//     txBox.put(tx.id, tx);

//     _recalculateCustomerTotals(tx.customerId);
//   }

//   void updateTransaction(CustomerTransaction updatedTx) {
//   txBox.put(updatedTx.id, updatedTx);

//   _recalculateCustomerTotals(updatedTx.customerId);
// }

//   void recordFullPayment(Customer customer) {
//     final owing = customer.balance.abs();
//     if (owing <= 0) return;

//     final tx = CustomerTransaction(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       customerId: customer.id,
//       crates: 0,
//       pieces: 0,
//       pricePerCrate: 0,
//       totalAmount: 0,
//       amountPaid: owing,
//       date: DateTime.now(),
//     );

//     addTransaction(tx);
//   }

//   void deleteTransaction(CustomerTransaction tx) {
//     txBox.delete(tx.id);

//     _recalculateCustomerTotals(tx.customerId);
//   }

//   void _recalculateCustomerTotals(String customerId) {
//     final customer = customersBox.get(customerId);
//     if (customer == null) return;

//     final transactions = txBox.values.where((t) => t.customerId == customerId);

//     double totalSpent = 0;
//     double totalPaid = 0;

//     for (final tx in transactions) {
//       totalSpent += tx.totalAmount;
//       totalPaid += tx.amountPaid;
//     }

//     customer.totalSpent = totalSpent;
//     customer.totalPaid = totalPaid;
//     customer.synced = false;

//     customer.save();
//   }
// }

import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../models/customer_transaction.dart';

class TransactionController {
  late Box<Customer> customersBox;
  late Box<CustomerTransaction> txBox;

  String? _currentUserId;

  TransactionController();

  /// 🔑 Initialize per user (CALL THIS AFTER LOGIN)
  Future<void> initForUser(String userId) async {
    if (_currentUserId == userId &&
        Hive.isBoxOpen('customers_$userId') &&
        Hive.isBoxOpen('transactions_$userId')) {
      return;
    }

    _currentUserId = userId;

    customersBox = await Hive.openBox<Customer>('customers_$userId');
    txBox = await Hive.openBox<CustomerTransaction>('transactions_$userId');
  }

  List<Customer> get customers => customersBox.values.toList();

  List<CustomerTransaction> forCustomer(String customerId) {
    return txBox.values.where((tx) => tx.customerId == customerId).toList();
  }

  void addCustomer(Customer customer) {
    customer.synced = false;
    customersBox.put(customer.id, customer);
  }

  void updateCustomer(Customer updated) {
    updated.synced = false;
    customersBox.put(updated.id, updated);
  }

  /// ✅ ADD TRANSACTION
  void addTransaction(CustomerTransaction tx) {
    tx.synced = false;
    txBox.put(tx.id, tx);

    _recalculateCustomerTotals(tx.customerId);
  }

  /// ✅ UPDATE TRANSACTION (for editing)
  void updateTransaction(CustomerTransaction tx) {
    tx.synced = false;
    txBox.put(tx.id, tx);

    _recalculateCustomerTotals(tx.customerId);
  }

  void recordFullPayment(Customer customer) {
    final owing = customer.balance.abs();
    if (owing <= 0) return;

    final tx = CustomerTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customer.id,
      crates: 0,
      pieces: 0,
      pricePerCrate: 0,
      totalAmount: 0,
      amountPaid: owing,
      date: DateTime.now(),
    );

    addTransaction(tx);
  }

  /// ✅ DELETE TRANSACTION (safe version)
  void deleteTransaction(CustomerTransaction tx) {
    txBox.delete(tx.id);

    _recalculateCustomerTotals(tx.customerId);
  }

  /// ✅ ALWAYS RECALCULATE TOTALS FROM SCRATCH
  void _recalculateCustomerTotals(String customerId) {
    final customer = customersBox.get(customerId);
    if (customer == null) return;

    final transactions = txBox.values.where((t) => t.customerId == customerId);

    double totalSpent = 0;
    double totalPaid = 0;

    for (final tx in transactions) {
      totalSpent += tx.totalAmount;
      totalPaid += tx.amountPaid;
    }

    customer.totalSpent = totalSpent;
    customer.totalPaid = totalPaid;
    customer.synced = false;

    customer.save();
  }
}
