// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import '../controllers/profit_controller.dart';
// import '../controllers/settings_controller.dart';
// import '../controllers/transaction_controller.dart';
// import '../services/firebase_sync_service.dart';
// import 'auth/forgot_password_screen.dart';
// import 'auth/profile_screen.dart';
// import 'pricing_settings_screen.dart';

// class SettingsScreen extends StatefulWidget {
//   final SettingsController controller;
//   final ProfitController profitController;
//   final TransactionController transactionController; // ✅ NEW

//   SettingsScreen({
//     super.key,
//     required this.controller,
//     required this.profitController,
//     required this.transactionController, // ✅ NEW
//   });

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> {
//   bool _syncing = false;

//   Future<void> _syncNow() async {
//     setState(() => _syncing = true);

//     try {
//       final service = FirebaseSyncService();

//       await service.syncAll(
//         widget.transactionController, // ✅ customers & tx
//         widget.profitController, // ✅ profits
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('All data synced successfully')),
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
//           /// ---------------- PROFILE ----------------
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

//           /// ---------------- PRICING ----------------
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
//             subtitle: const Text('Backup & restore all data'),
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

//           /// ---------------- RESET PASSWORD ----------------
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

//           /// ---------------- LOGOUT ----------------
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
  final TransactionController transactionController;

  const SettingsScreen({
    super.key,
    required this.controller,
    required this.profitController,
    required this.transactionController,
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
        widget.transactionController,
        widget.profitController,
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

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// PROFILE
            _SettingsCard(
              icon: Icons.person,
              title: 'Profile',
              subtitle: 'Edit your farm details',
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

            const SizedBox(height: 12),

            /// PRICING
            _SettingsCard(
              icon: Icons.price_change,
              title: 'Pricing Defaults',
              subtitle: 'Set crate & feed prices',
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

            const SizedBox(height: 12),

            /// SYNC
            _SettingsCard(
              icon: Icons.sync,
              title: 'Sync Now',
              subtitle: 'Backup & restore all data',
              onTap: _syncing ? null : _syncNow,
              trailing: _syncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),

            const SizedBox(height: 12),

            /// RESET PASSWORD
            _SettingsCard(
              icon: Icons.lock_reset,
              title: 'Reset Password',
              subtitle: 'Send password reset link',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            /// LOGOUT
            _SettingsCard(
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              iconColor: Colors.red,
              titleColor: Colors.red,
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: (iconColor ?? Colors.blue).withOpacity(0.1),
                child: Icon(icon, color: iconColor ?? Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (onTap != null && trailing == null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
