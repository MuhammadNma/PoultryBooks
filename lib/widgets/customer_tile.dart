// import 'package:flutter/material.dart';
// import '../models/customer.dart';

// class CustomerTile extends StatelessWidget {
//   final Customer customer;
//   const CustomerTile({Key? key, required this.customer}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final bal = customer.totalPaid - customer.totalSpent;
//     final owes = bal < 0;
//     return Card(
//       child: ListTile(
//         title: Text(customer.name),
//         subtitle: Text(customer.phone),
//         trailing: Text(
//           '₦${(bal).toStringAsFixed(2)}',
//           style: TextStyle(
//               color: owes ? Colors.red : Colors.green,
//               fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../controllers/transaction_controller.dart';
import '../models/customer.dart';
import '../models/customer_transaction.dart';
import '../models/profit_record.dart';
import '../navigation/bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(CustomerTransactionAdapter());
  Hive.registerAdapter(ProfitRecordAdapter());

  // Open boxes
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<CustomerTransaction>('transactions');
  await Hive.openBox<ProfitRecord>('profit_records');

  final txController = TransactionController();

  runApp(PoultryProfitApp(txController: txController));
}

class PoultryProfitApp extends StatelessWidget {
  final TransactionController txController;
  const PoultryProfitApp({super.key, required this.txController});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poultry Profit Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BottomNavScreen(txController: txController),
    );
  }
}
