// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../screens/auth/login_screen.dart';
// import '../navigation/bottom_nav.dart';
// import '../controllers/transaction_controller.dart';
// import '../controllers/profit_controller.dart';
// import '../controllers/settings_controller.dart';

// class AuthGate extends StatelessWidget {
//   final TransactionController txController;

//   const AuthGate({
//     super.key,
//     required this.txController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // 🔄 Waiting for auth state
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // ❌ Not logged in
//         if (!snapshot.hasData) {
//           final settingsController = SettingsController();
//           return LoginScreen(
//             settingsController: settingsController,
//           );
//         }

//         // ✅ Logged in
//         final user = snapshot.data!;
//         final profitController = ProfitController();
//         final settingsController = SettingsController();

//         return FutureBuilder(
//           future: Future.wait([
//             profitController.initForUser(user.uid),
//             txController.initForUser(user.uid),
//             settingsController.initForUser(user.uid),
//           ]),
//           builder: (context, initSnap) {
//             if (initSnap.connectionState != ConnectionState.done) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }

//             return BottomNavScreen(
//               txController: txController,
//               profitController: profitController,
//               settingsController: settingsController,
//               transactionController: txController,
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/auth/login_screen.dart';
import '../navigation/bottom_nav.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/profit_controller.dart';
import '../controllers/settings_controller.dart';

class AuthGate extends StatelessWidget {
  final TransactionController txController;
  final ProfitController profitController;
  final SettingsController settingsController;

  const AuthGate({
    super.key,
    required this.txController,
    required this.profitController,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        /// ⏳ Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// ❌ Not logged in
        if (!snapshot.hasData) {
          return LoginScreen(
            settingsController: settingsController,
          );
        }

        /// ✅ Logged in
        final user = snapshot.data!;

        return FutureBuilder(
          future: Future.wait([
            profitController.initForUser(user.uid),
            txController.initForUser(user.uid),
            settingsController.initForUser(user.uid),
          ]),
          builder: (context, snap) {
            /// ⛔ VERY IMPORTANT
            if (snap.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            /// ⛔ ALSO HANDLE ERRORS (prevents silent crashes)
            if (snap.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Initialization error: ${snap.error}'),
                ),
              );
            }

            /// ✅ ONLY NOW UI CAN LOAD
            return BottomNavScreen(
              txController: txController,
              profitController: profitController,
              settingsController: settingsController,
              transactionController: txController,
            );
          },
        );
      },
    );
  }
}
