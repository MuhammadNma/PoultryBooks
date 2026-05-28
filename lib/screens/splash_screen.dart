// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'auth/auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted)
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AuthGate()));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.agriculture,
                  size: 56, color: AppTheme.primary)),
          const SizedBox(height: 24),
          const Text('PoultryBooks',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary)),
          const SizedBox(height: 8),
          Text('Your farm. Your numbers.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
          const SizedBox(height: 48),
          const CircularProgressIndicator(
              color: AppTheme.primary, strokeWidth: 2),
        ])),
      );
}
