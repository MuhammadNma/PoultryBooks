// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

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
//           email: emailCtrl.text.trim(), password: passwordCtrl.text.trim());

//       // Save extra fields to Firestore under 'users/{uid}'
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(cred.user!.uid)
//           .set({
//         'name': nameCtrl.text.trim(),
//         'farmName': farmNameCtrl.text.trim(),
//         'email': emailCtrl.text.trim(),
//       });
//     } on FirebaseAuthException catch (e) {
//       _showError(_friendlyMessage(e));
//     } catch (_) {
//       _showError('Something went wrong.');
//     }

//     setState(() => loading = false);
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   String _friendlyMessage(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'weak-password':
//         return 'Password must be at least 6 characters.';
//       case 'email-already-in-use':
//         return 'Email is already registered.';
//       default:
//         return e.message ?? 'Signup failed.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign Up')),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Card(
//             elevation: 4,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(mainAxisSize: MainAxisSize.min, children: [
//                   TextFormField(
//                     controller: nameCtrl,
//                     decoration: const InputDecoration(
//                         labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
//                     validator: (v) =>
//                         v!.isEmpty ? 'Full name is required' : null,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: farmNameCtrl,
//                     decoration: const InputDecoration(
//                         labelText: 'Farm Name', prefixIcon: Icon(Icons.home)),
//                     validator: (v) =>
//                         v!.isEmpty ? 'Farm name is required' : null,
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: emailCtrl,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: const InputDecoration(
//                         labelText: 'Email', prefixIcon: Icon(Icons.email)),
//                     validator: (v) {
//                       if (v == null || v.isEmpty) return 'Email required';
//                       if (!v.contains('@')) return 'Enter valid email';
//                       return null;
//                     },
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
//                     validator: (v) {
//                       if (v == null || v.isEmpty) return 'Password required';
//                       if (v.length < 6) return 'Minimum 6 characters';
//                       return null;
//                     },
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
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      /// 🔹 Save to Firestore (cloud)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': nameCtrl.text.trim(),
        'farmName': farmNameCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      /// 🔹 Save locally (Hive settings)
      final updated = widget.settingsController.settings.copyWith(
        farmName: farmNameCtrl.text.trim(),
      );
      await widget.settingsController.save(updated);
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyMessage(e));
    } catch (_) {
      _showError('Something went wrong.');
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
                          ? const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)
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
