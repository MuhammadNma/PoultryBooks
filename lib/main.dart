import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/app_theme.dart';
import 'models/customer.dart';
import 'models/customer_transaction.dart';
import 'models/profit_record.dart';

import 'controllers/transaction_controller.dart';
import 'auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(CustomerTransactionAdapter());
  Hive.registerAdapter(ProfitRecordAdapter());

  // Open boxes
  await Hive.openBox<Customer>('customers');
  await Hive.openBox<CustomerTransaction>('transactions');
  await Hive.openBox<ProfitRecord>('profit_records');

  // Initialize controllers
  final txController = TransactionController();

  // Run app
  runApp(PoultryProfitApp(txController: txController));
}

class PoultryProfitApp extends StatelessWidget {
  final TransactionController txController;

  const PoultryProfitApp({super.key, required this.txController});

  @override
  Widget build(BuildContext context) {
    // Wrap in Builder to ensure null-safety defaults
    return Builder(
      builder: (context) {
        return MaterialApp(
          title: 'Poultry Profit Calculator',
          theme: AppTheme.light() ?? ThemeData.light(), // ✅ safe fallback
          debugShowCheckedModeBanner: true,
          home: AuthGate(txController: txController),
        );
      },
    );
  }
}
