// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../controllers/settings_controller.dart';

// class ProfileScreen extends StatefulWidget {
//   final SettingsController settingsController;

//   const ProfileScreen({
//     super.key,
//     required this.settingsController,
//   });

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final _user = FirebaseAuth.instance.currentUser;
//   final _firestore = FirebaseFirestore.instance;

//   late TextEditingController farmNameCtrl;
//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     farmNameCtrl = TextEditingController();
//     _initializeFarmName();
//   }

//   Future<void> _initializeFarmName() async {
//     if (_user == null) return;

//     try {
//       final doc = await _firestore.collection('users').doc(_user!.uid).get();

//       final cloudName = doc.data()?['farmName'];
//       final localName = widget.settingsController.settings.farmName;

//       final finalName = cloudName ?? localName ?? '';

//       farmNameCtrl.text = finalName;

//       // If cloud has value but local doesn't → update local
//       if (cloudName != null &&
//           cloudName != widget.settingsController.settings.farmName) {
//         await widget.settingsController.save(
//           widget.settingsController.settings.copyWith(
//             farmName: cloudName,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error loading farm name: $e");
//     }
//   }

//   Future<void> _saveFarmName() async {
//     if (_user == null) return;

//     final name = farmNameCtrl.text.trim();
//     if (name.isEmpty) return;

//     setState(() => _loading = true);

//     try {
//       /// ✅ SAFE FIRESTORE SAVE (creates doc if not exists)
//       await _firestore.collection('users').doc(_user!.uid).set(
//         {
//           'farmName': name,
//           'updatedAt': FieldValue.serverTimestamp(),
//         },
//         SetOptions(merge: true),
//       );

//       /// ✅ SAVE LOCALLY
//       await widget.settingsController.save(
//         widget.settingsController.settings.copyWith(
//           farmName: name,
//         ),
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Farm name updated successfully')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to update farm name')),
//       );
//     }

//     if (mounted) setState(() => _loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_user == null) {
//       return const Scaffold(
//         body: Center(child: Text('No user logged in')),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           /// ACCOUNT SECTION
//           Text(
//             'Account Information',
//             style: Theme.of(context)
//                 .textTheme
//                 .titleMedium
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           _infoTile('Email', _user!.email ?? '—'),
//           _infoTile(
//             'Created',
//             _user!.metadata.creationTime?.toLocal().toString().split('.')[0] ??
//                 '—',
//           ),

//           const SizedBox(height: 28),

//           /// FARM SECTION
//           Text(
//             'Farm Information',
//             style: Theme.of(context)
//                 .textTheme
//                 .titleMedium
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),

//           TextField(
//             controller: farmNameCtrl,
//             decoration: const InputDecoration(
//               labelText: 'Farm Name',
//               prefixIcon: Icon(Icons.home_work),
//               border: OutlineInputBorder(),
//             ),
//           ),

//           const SizedBox(height: 16),

//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _loading ? null : _saveFarmName,
//               child: _loading
//                   ? const CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     )
//                   : const Text('Save Changes'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _infoTile(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
//           const SizedBox(height: 4),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
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

  const ProfileScreen({
    super.key,
    required this.settingsController,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController farmNameCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    farmNameCtrl = TextEditingController();
    _initializeFarmName();
  }

  Future<void> _initializeFarmName() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      final cloudName = doc.data()?['farmName'];
      final localName = widget.settingsController.settings.farmName;
      final finalName = cloudName ?? localName ?? '';
      farmNameCtrl.text = finalName;

      if (cloudName != null && cloudName != localName) {
        await widget.settingsController.save(
          widget.settingsController.settings.copyWith(farmName: cloudName),
        );
      }
    } catch (e) {
      debugPrint("Error loading farm name: $e");
    }
  }

  Future<void> _saveFarmName() async {
    if (_user == null) return;

    final name = farmNameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);

    try {
      await _firestore.collection('users').doc(_user!.uid).set(
        {
          'farmName': name,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await widget.settingsController.save(
        widget.settingsController.settings.copyWith(farmName: name),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farm name updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update farm name')),
        );
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ACCOUNT SECTION
          _InfoCard(
            title: 'Account Information',
            children: [
              _infoTile('Email', _user!.email ?? '—'),
              _infoTile(
                'Created',
                _user!.metadata.creationTime
                        ?.toLocal()
                        .toString()
                        .split('.')[0] ??
                    '—',
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// FARM SECTION
          _InfoCard(
            title: 'Farm Information',
            children: [
              TextField(
                controller: farmNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Farm Name',
                  prefixIcon: const Icon(Icons.home_work),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveFarmName,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
