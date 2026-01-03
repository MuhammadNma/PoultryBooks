// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'navigation/bottom_nav.dart';
// import 'models/customer.dart';
// import 'models/customer_transaction.dart';
// import 'models/profit_record.dart';
// import 'controllers/transaction_controller.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Hive.initFlutter();

//   // Register all adapters only once
//   Hive.registerAdapter(CustomerAdapter());
//   Hive.registerAdapter(CustomerTransactionAdapter());
//   Hive.registerAdapter(ProfitRecordAdapter());

//   // Open boxes once
//   await Hive.openBox<Customer>('customers');
//   await Hive.openBox<CustomerTransaction>('transactions');
//   await Hive.openBox<ProfitRecord>('profit_records');

//   final txController = TransactionController();

//   runApp(PoultryProfitApp(txController: txController));
// }

// class PoultryProfitApp extends StatelessWidget {
//   final TransactionController txController;

//   const PoultryProfitApp({super.key, required this.txController});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // debugShowCheckedModeBanner: false,
//       title: 'Poultry Profit Calculator',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: BottomNavScreen(txController: txController),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'navigation/bottom_nav.dart';
// import 'models/customer.dart';
// import 'models/customer_transaction.dart';
// import 'models/profit_record.dart';
// import 'controllers/transaction_controller.dart';
// import 'screens/auth/login_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   /// 🔹 Initialize Firebase FIRST
//   await Firebase.initializeApp();

//   /// 🔹 Initialize Hive
//   await Hive.initFlutter();

//   /// 🔹 Register Hive adapters (only once)
//   Hive.registerAdapter(CustomerAdapter());
//   Hive.registerAdapter(CustomerTransactionAdapter());
//   Hive.registerAdapter(ProfitRecordAdapter());

//   /// 🔹 Open Hive boxes
//   await Hive.openBox<Customer>('customers');
//   await Hive.openBox<CustomerTransaction>('transactions');
//   await Hive.openBox<ProfitRecord>('profit_records');

//   /// 🔹 Controllers
//   final txController = TransactionController();

//   runApp(
//     PoultryProfitApp(
//       txController: txController,
//     ),
//   );
// }

// class PoultryProfitApp extends StatelessWidget {
//   final TransactionController txController;

//   const PoultryProfitApp({
//     super.key,
//     required this.txController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Poultry Profit Calculator',
//       theme: ThemeData(primarySwatch: Colors.blue),

//       /// 🔐 Auth Gate
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           /// Waiting for auth
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }

//           /// Logged in → App
//           if (snapshot.hasData) {
//             return BottomNavScreen(
//               txController: txController,
//             );
//           }

//           /// Not logged in → Login
//           return const LoginScreen();
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/customer.dart';
import 'models/customer_transaction.dart';
import 'models/profit_record.dart';

import 'controllers/transaction_controller.dart';
import 'auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Hive
  await Hive.initFlutter();

  Hive.registerAdapter(CustomerAdapter());
  Hive.registerAdapter(CustomerTransactionAdapter());
  Hive.registerAdapter(ProfitRecordAdapter());

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
      title: 'Poultry Profit Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthGate(txController: txController),
    );
  }
}
