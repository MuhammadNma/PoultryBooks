// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const ListTile(
//             title: Text(
//               'Account',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),

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
//                 // AuthGate handles navigation automatically
//               }
//             },
//           ),

//           const Divider(),

//           // Placeholder for future settings
//           const ListTile(
//             leading: Icon(Icons.info_outline),
//             title: Text('More settings coming soon'),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import 'pricing_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller;

  const SettingsScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // const ListTile(
          //   title: Text(
          //     'Account',
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),

          ListTile(
            leading: const Icon(Icons.price_change),
            title: const Text('Pricing Defaults'),
            subtitle: const Text('Set crate & feed prices'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PricingSettingsScreen(controller: controller),
                ),
              );
            },
          ),

          const Divider(),

          // Placeholder for future settings
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('More settings coming soon'),
          ),

          const Divider(),

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
                // AuthGate handles navigation automatically
              }
            },
          ),
        ],
      ),
    );
  }
}
