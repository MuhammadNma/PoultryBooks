import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'navigation/bottom_nav.dart';
import 'models/customer.dart';
import 'models/customer_transaction.dart';
import 'models/profit_record.dart';
import 'controllers/transaction_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register all adapters only once
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(CustomerTransactionAdapter());
  Hive.registerAdapter(ProfitRecordAdapter());

  // Open boxes once
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
      // debugShowCheckedModeBanner: false,
      title: 'Poultry Profit Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BottomNavScreen(txController: txController),
    );
  }
}
