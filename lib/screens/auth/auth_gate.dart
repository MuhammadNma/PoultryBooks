// lib/screens/auth/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/flock_provider.dart';
import '../../providers/daily_log_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/settings_provider.dart';
import '../onboarding/onboarding_screen.dart';
import '../main_shell.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        // Still waiting for Firebase to respond
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }
        // Not logged in — always show login first
        if (!snap.hasData || snap.data == null) {
          return const LoginScreen();
        }
        // Logged in — initialise providers then decide where to go
        return _InitApp(user: snap.data!);
      },
    );
  }
}

class _InitApp extends StatefulWidget {
  final User user;
  const _InitApp({required this.user});
  @override
  State<_InitApp> createState() => _InitAppState();
}

class _InitAppState extends State<_InitApp> {
  bool _done = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final uid = widget.user.uid;
      await Future.wait([
        context.read<FlockProvider>().init(uid),
        context.read<DailyLogProvider>().init(uid),
        context.read<SaleProvider>().init(uid),
        context.read<ExpenseProvider>().init(uid),
        context.read<CustomerProvider>().init(uid),
        context.read<SettingsProvider>().init(uid),
      ]);
      if (mounted) setState(() => _done = true);
    } catch (e) {
      debugPrint('Init error: $e');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Something went wrong loading your data.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _done = false;
                    });
                    _init();
                  },
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async => await FirebaseAuth.instance.signOut(),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_done) return const _Loading();

    // Only show onboarding if the user hasn't completed it yet
    final onboarded = context.watch<SettingsProvider>().onboardingComplete;
    return onboarded ? const MainShell() : const OnboardingScreen();
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading PoultryBooks…'),
            ],
          ),
        ),
      );
}
