// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../controllers/profit_controller.dart';
// import '../controllers/settings_controller.dart';
// import '../services/firebase_sync_service.dart';
// import 'auth/forgot_password_screen.dart';
// import 'auth/profile_screen.dart';
// import 'pricing_settings_screen.dart';

// class SettingsScreen extends StatefulWidget {
//   final SettingsController controller;
//   final ProfitController profitController;

//   // Remove `const` because controller is runtime
//   SettingsScreen({
//     super.key,
//     required this.controller,
//     required this.profitController,
//   });

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _syncing = false;

//   Future<void> _syncNow() async {
//     setState(() => _syncing = true);

//     try {
//       final service = FirebaseProfitSyncService();
//       await service.syncAll(widget.profitController);

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Sync completed successfully')),
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sync failed: $e')),
//       );
//     }

//     if (mounted) setState(() => _syncing = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: ListView(
//         children: [
//           // Example Profile tile
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text('Profile'),
//             subtitle: const Text('Edit your farm details'),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => ProfileScreen(
//                     settingsController: widget.controller,
//                   ),
//                 ),
//               );
//             },
//           ),

//           // Pricing Defaults tile
//           ListTile(
//             leading: const Icon(Icons.price_change),
//             title: const Text('Pricing Defaults'),
//             subtitle: const Text('Set crate & feed prices'),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>
//                       PricingSettingsScreen(controller: widget.controller),
//                 ),
//               );
//             },
//           ),

//           const Divider(),

//           /// ---------------- SYNC ----------------
//           ListTile(
//             leading: const Icon(Icons.sync),
//             title: const Text('Sync Now'),
//             subtitle: const Text('Backup & restore data'),
//             trailing: _syncing
//                 ? const SizedBox(
//                     width: 18,
//                     height: 18,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : null,
//             onTap: _syncing ? null : _syncNow,
//           ),

//           const Divider(),

//           // Reset password tile
//           ListTile(
//             leading: const Icon(Icons.lock_reset),
//             title: const Text('Reset Password'),
//             subtitle: const Text('Send password reset link'),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const ForgotPasswordScreen(),
//                 ),
//               );
//             },
//           ),

//           const Divider(),

//           // Logout tile
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text(
//               'Logout',
//               style: TextStyle(color: Colors.red),
//             ),
//             onTap: () async {
//               final confirm = await showDialog<bool>(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text('Logout'),
//                   content: const Text('Are you sure you want to logout?'),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       child: const Text('Cancel'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       child: const Text('Logout'),
//                     ),
//                   ],
//                 ),
//               );

//               if (confirm == true) {
//                 await FirebaseAuth.instance.signOut();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controllers/profit_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/transaction_controller.dart';
import '../services/firebase_sync_service.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/profile_screen.dart';
import 'pricing_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsController controller;
  final ProfitController profitController;
  final TransactionController transactionController; // ✅ NEW

  SettingsScreen({
    super.key,
    required this.controller,
    required this.profitController,
    required this.transactionController, // ✅ NEW
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _syncing = false;

  Future<void> _syncNow() async {
    setState(() => _syncing = true);

    try {
      final service = FirebaseSyncService();

      await service.syncAll(
        widget.transactionController, // ✅ customers & tx
        widget.profitController, // ✅ profits
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data synced successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    }

    if (mounted) setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          /// ---------------- PROFILE ----------------
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: const Text('Edit your farm details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    settingsController: widget.controller,
                  ),
                ),
              );
            },
          ),

          /// ---------------- PRICING ----------------
          ListTile(
            leading: const Icon(Icons.price_change),
            title: const Text('Pricing Defaults'),
            subtitle: const Text('Set crate & feed prices'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PricingSettingsScreen(controller: widget.controller),
                ),
              );
            },
          ),

          const Divider(),

          /// ---------------- SYNC ----------------
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync Now'),
            subtitle: const Text('Backup & restore all data'),
            trailing: _syncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: _syncing ? null : _syncNow,
          ),

          const Divider(),

          /// ---------------- RESET PASSWORD ----------------
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Reset Password'),
            subtitle: const Text('Send password reset link'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen(),
                ),
              );
            },
          ),

          const Divider(),

          /// ---------------- LOGOUT ----------------
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await FirebaseAuth.instance.signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
