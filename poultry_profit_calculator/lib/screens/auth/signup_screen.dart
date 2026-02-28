// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../controllers/settings_controller.dart';
// import '../../models/app_settings.dart';

// class SignupScreen extends StatefulWidget {
//   final SettingsController settingsController;
//   const SignupScreen({super.key, required this.settingsController});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final nameCtrl = TextEditingController();
//   final farmNameCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();

//   bool loading = false;
//   bool obscurePassword = true;

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     FocusScope.of(context).unfocus();
//     setState(() => loading = true);

//     try {
//       final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailCtrl.text.trim(),
//         password: passwordCtrl.text.trim(),
//       );

//       /// 🔹 Save to Firestore (cloud)
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(cred.user!.uid)
//           .set({
//         'name': nameCtrl.text.trim(),
//         'farmName': farmNameCtrl.text.trim(),
//         'email': emailCtrl.text.trim(),
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       /// 🔹 Save locally (Hive settings)
//       final updated = widget.settingsController.settings.copyWith(
//         farmName: farmNameCtrl.text.trim(),
//       );
//       await widget.settingsController.save(updated);
//     } on FirebaseAuthException catch (e) {
//       _showError(_friendlyMessage(e));
//     } catch (_) {
//       _showError('Something went wrong.');
//     }

//     if (mounted) setState(() => loading = false);
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   String _friendlyMessage(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'weak-password':
//         return 'Password must be at least 6 characters.';
//       case 'email-already-in-use':
//         return 'Email already registered.';
//       default:
//         return e.message ?? 'Signup failed.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Create Account')),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Card(
//             elevation: 3,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(children: [
//                   TextFormField(
//                     controller: nameCtrl,
//                     decoration: const InputDecoration(
//                       labelText: 'Full Name',
//                       prefixIcon: Icon(Icons.person),
//                     ),
//                     validator: (v) => v!.isEmpty ? 'Full name required' : null,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: farmNameCtrl,
//                     decoration: const InputDecoration(
//                       labelText: 'Farm Name',
//                       prefixIcon: Icon(Icons.home_work),
//                     ),
//                     validator: (v) => v!.isEmpty ? 'Farm name required' : null,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: emailCtrl,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email),
//                     ),
//                     validator: (v) =>
//                         v!.contains('@') ? null : 'Enter valid email',
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: passwordCtrl,
//                     obscureText: obscurePassword,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: const Icon(Icons.lock),
//                       suffixIcon: IconButton(
//                         icon: Icon(obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility),
//                         onPressed: () =>
//                             setState(() => obscurePassword = !obscurePassword),
//                       ),
//                     ),
//                     validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: loading ? null : _submit,
//                       child: loading
//                           ? const CircularProgressIndicator(
//                               strokeWidth: 2, color: Colors.white)
//                           : const Text('Create Account'),
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/settings_controller.dart';
import '../../models/app_settings.dart';

class SignupScreen extends StatefulWidget {
  final SettingsController settingsController;
  const SignupScreen({super.key, required this.settingsController});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final farmNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => loading = true);

    try {
      // ✅ Create user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // ✅ Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': nameCtrl.text.trim(),
        'farmName': farmNameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ Initialize settings for this user before saving
      await widget.settingsController.initForUser(uid);

      // ✅ Save locally (Hive settings)
      final updated = widget.settingsController.settings.copyWith(
        farmName: farmNameCtrl.text.trim(),
      );
      await widget.settingsController.save(updated);

      // ✅ SIGN OUT so user returns to login
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // ✅ Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please login.'),
        ),
      );

      // ✅ Go back to login screen
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyMessage(e));
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    }

    if (mounted) setState(() => loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'email-already-in-use':
        return 'Email already registered.';
      case 'invalid-email':
        return 'Enter a valid email.';
      default:
        return e.message ?? 'Signup failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v!.isEmpty ? 'Full name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: farmNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Farm Name',
                      prefixIcon: Icon(Icons.home_work),
                    ),
                    validator: (v) => v!.isEmpty ? 'Farm name required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (v) =>
                        v!.contains('@') ? null : 'Enter valid email',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => obscurePassword = !obscurePassword),
                      ),
                    ),
                    validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Create Account'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
