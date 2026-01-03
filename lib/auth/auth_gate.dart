import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/auth/login_screen.dart';
import '../navigation/bottom_nav.dart';
import '../controllers/transaction_controller.dart';

class AuthGate extends StatelessWidget {
  final TransactionController txController;

  const AuthGate({super.key, required this.txController});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Waiting for Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User logged in
        if (snapshot.hasData) {
          return BottomNavScreen(txController: txController);
        }

        // User logged out
        return const LoginScreen();
      },
    );
  }
}
