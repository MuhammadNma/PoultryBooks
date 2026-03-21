// import 'package:flutter/material.dart';
// import 'dashboard/dashboard_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeIn,
//     );

//     _controller.forward();

//     _navigate();
//   }

//   void _navigate() async {
//     await Future.delayed(const Duration(seconds: 2));

//     if (!mounted) return;

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const DashboardScreenPlaceholder()),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1B5E20), // deep farm green
//       body: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               /// APP ICON
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(28),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 12,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(28),
//                   child: Image.asset(
//                     'assets/icon.png', // 👈 your edited icon here
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               /// APP NAME
//               const Text(
//                 'Poultry Books',
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               /// TAGLINE
//               const Text(
//                 'Track • Analyze • Grow',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.white70,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Temporary placeholder (replace with your actual DashboardScreen)
// class DashboardScreenPlaceholder extends StatelessWidget {
//   const DashboardScreenPlaceholder({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: Text('Dashboard')),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../auth/auth_gate.dart';
import '../controllers/transaction_controller.dart';

class SplashScreen extends StatefulWidget {
  final TransactionController txController;

  const SplashScreen({super.key, required this.txController});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _goNext();
  }

  void _goNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AuthGate(txController: widget.txController),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ICON
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// TITLE
              const Text(
                'Poultry Books',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              /// TAGLINE
              const Text(
                'Track • Analyze • Grow',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
