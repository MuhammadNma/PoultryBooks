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
//     final settingsController = SettingsController();

//     return FutureBuilder(
//       future: settingsController.init(),
//       builder: (context, settingsSnap) {
//         if (settingsSnap.connectionState != ConnectionState.done) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         return StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (context, snapshot) {
//             // Loading auth state
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }

//             // ✅ LOGGED IN
//             if (snapshot.hasData) {
//               final user = snapshot.data!;
//               final profitController = ProfitController();
//               final transactionController = TransactionController();

//               return FutureBuilder(
//                 future: profitController.initForUser(user.uid),
//                 builder: (context, initSnap) {
//                   if (initSnap.connectionState != ConnectionState.done) {
//                     return const Scaffold(
//                       body: Center(child: CircularProgressIndicator()),
//                     );
//                   }

//                   return BottomNavScreen(
//                     txController: txController,
//                     profitController: profitController,
//                     settingsController: settingsController,
//                     transactionController: transactionController,
//                   );
//                 },
//               );
//             }

//             // ❌ LOGGED OUT
//             return LoginScreen(
//               settingsController: settingsController,
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

  const AuthGate({
    super.key,
    required this.txController,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 Waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!snapshot.hasData) {
          final settingsController = SettingsController();
          return LoginScreen(
            settingsController: settingsController,
          );
        }

        // ✅ Logged in
        final user = snapshot.data!;
        final profitController = ProfitController();
        final settingsController = SettingsController();

        return FutureBuilder(
          future: Future.wait([
            profitController.initForUser(user.uid),
            txController.initForUser(user.uid),
            settingsController.initForUser(user.uid),
          ]),
          builder: (context, initSnap) {
            if (initSnap.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

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
