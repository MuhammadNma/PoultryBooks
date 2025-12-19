import 'package:hive/hive.dart';
import '../models/customer.dart';
import '../models/customer_transaction.dart';

class TransactionController {
  late Box<Customer> customersBox;
  late Box<CustomerTransaction> txBox;

  TransactionController() {
    customersBox = Hive.box<Customer>('customers');
    txBox = Hive.box<CustomerTransaction>('transactions');
  }

  List<Customer> get customers => customersBox.values.toList();

  List<CustomerTransaction> forCustomer(String customerId) {
    return txBox.values.where((tx) => tx.customerId == customerId).toList();
  }

  void addCustomer(Customer customer) {
    customersBox.put(customer.id, customer);
  }

  void updateCustomer(Customer updated) {
    customersBox.put(updated.id, updated);
  }

  void addTransaction(CustomerTransaction tx) {
    txBox.put(tx.id, tx);

    final customer = customersBox.get(tx.customerId);
    if (customer != null) {
      customer.totalSpent += tx.totalAmount;
      customer.totalPaid += tx.amountPaid;
      customer.save();
    }
  }
}
