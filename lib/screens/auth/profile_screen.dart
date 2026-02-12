// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       body: user == null
//           ? const Center(child: Text('No user logged in'))
//           : ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 const Text(
//                   'Account Information',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _infoTile('Email', user.email ?? '—'),
//                 // _infoTile('User ID', user.uid),
//                 _infoTile(
//                   'Account Created',
//                   user.metadata.creationTime
//                           ?.toLocal()
//                           .toString()
//                           .split('.')[0] ??
//                       '—',
//                 ),
//                 const SizedBox(height: 24),
//                 const Divider(),
//                 const Padding(
//                   padding: EdgeInsets.only(top: 12),
//                   child: Text(
//                     'More profile features coming soon',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _infoTile(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 13, color: Colors.grey),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../controllers/settings_controller.dart';

// class ProfileScreen extends StatefulWidget {
//   final SettingsController settingsController;

//   const ProfileScreen({super.key, required this.settingsController});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   late TextEditingController farmNameCtrl;

//   @override
//   void initState() {
//     super.initState();
//     farmNameCtrl = TextEditingController(
//         text: widget.settingsController.settings.farmName ?? '');
//   }

//   void _saveFarmName() async {
//     final updatedSettings = widget.settingsController.settings
//         .copyWith(farmName: farmNameCtrl.text.trim());
//     await widget.settingsController.save(updatedSettings);

//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Farm name updated')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       body: user == null
//           ? const Center(child: Text('No user logged in'))
//           : ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 // ===== Account Information =====
//                 const Text(
//                   'Account Information',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _infoTile('Email', user.email ?? '—'),
//                 _infoTile(
//                   'Account Created',
//                   user.metadata.creationTime
//                           ?.toLocal()
//                           .toString()
//                           .split('.')[0] ??
//                       '—',
//                 ),
//                 const SizedBox(height: 24),
//                 const Divider(),

//                 // ===== Farm Name Editor =====
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Farm Information',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: farmNameCtrl,
//                   decoration: const InputDecoration(
//                     labelText: 'Farm Name',
//                     prefixIcon: Icon(Icons.home_filled),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _saveFarmName,
//                     child: const Text('Save Farm Name'),
//                   ),
//                 ),

//                 const SizedBox(height: 24),
//                 const Divider(),
//                 const Padding(
//                   padding: EdgeInsets.only(top: 12),
//                   child: Text(
//                     'More profile features coming soon',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _infoTile(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 13, color: Colors.grey),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/settings_controller.dart';

class ProfileScreen extends StatefulWidget {
  final SettingsController settingsController;
  const ProfileScreen({super.key, required this.settingsController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  late TextEditingController farmNameCtrl;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    farmNameCtrl = TextEditingController();
    _loadFarmName();
  }

  Future<void> _loadFarmName() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    final cloudName = doc.data()?['farmName'];
    final localName = widget.settingsController.settings.farmName;

    farmNameCtrl.text = cloudName ?? localName ?? '';
  }

  Future<void> _saveFarmName() async {
    if (user == null) return;
    setState(() => loading = true);

    final name = farmNameCtrl.text.trim();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'farmName': name});

    await widget.settingsController.save(
      widget.settingsController.settings.copyWith(farmName: name),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm name updated')),
      );
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Account', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _infoTile('Email', user!.email ?? '—'),
          _infoTile(
            'Created',
            user!.metadata.creationTime?.toLocal().toString().split('.')[0] ??
                '—',
          ),
          const Divider(height: 32),
          const Text('Farm Information',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: farmNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Farm Name',
              prefixIcon: Icon(Icons.home_work),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: loading ? null : _saveFarmName,
            child: loading
                ? const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)
                : const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
