// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final emailCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();

//   bool isLogin = true;
//   bool loading = false;
//   bool obscurePassword = true;

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     FocusScope.of(context).unfocus();
//     setState(() => loading = true);

//     try {
//       if (isLogin) {
//         await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: emailCtrl.text.trim(),
//           password: passwordCtrl.text.trim(),
//         );
//       } else {
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: emailCtrl.text.trim(),
//           password: passwordCtrl.text.trim(),
//         );
//       }
//       // 🚫 DO NOT NAVIGATE — AuthGate handles it
//     } on FirebaseAuthException catch (e) {
//       _showError(_friendlyMessage(e));
//     } catch (_) {
//       _showError('Something went wrong. Please try again.');
//     }

//     if (!mounted) return;
//     setState(() => loading = false);
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   String _friendlyMessage(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'user-not-found':
//         return 'No account found with this email.';
//       case 'wrong-password':
//         return 'Incorrect password.';
//       case 'email-already-in-use':
//         return 'This email is already registered.';
//       case 'weak-password':
//         return 'Password must be at least 6 characters.';
//       case 'invalid-email':
//         return 'Please enter a valid email address.';
//       default:
//         return e.message ?? 'Authentication failed.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isLogin ? 'Login' : 'Create Account'),
//         centerTitle: true,
//       ),
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
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.lock_outline,
//                       size: 48,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     const SizedBox(height: 16),

//                     /// EMAIL
//                     TextFormField(
//                       controller: emailCtrl,
//                       keyboardType: TextInputType.emailAddress,
//                       textInputAction: TextInputAction.next,
//                       decoration: const InputDecoration(
//                         labelText: 'Email',
//                         prefixIcon: Icon(Icons.email),
//                       ),
//                       validator: (v) {
//                         if (v == null || v.trim().isEmpty) {
//                           return 'Email is required';
//                         }
//                         if (!v.contains('@')) {
//                           return 'Enter a valid email';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 12),

//                     /// PASSWORD
//                     TextFormField(
//                       controller: passwordCtrl,
//                       obscureText: obscurePassword,
//                       textInputAction: TextInputAction.done,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         prefixIcon: const Icon(Icons.lock),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             obscurePassword
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                           ),
//                           onPressed: () {
//                             setState(
//                               () => obscurePassword = !obscurePassword,
//                             );
//                           },
//                         ),
//                       ),
//                       validator: (v) {
//                         if (v == null || v.isEmpty) {
//                           return 'Password is required';
//                         }
//                         if (v.length < 6) {
//                           return 'Minimum 6 characters';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 20),

//                     /// SUBMIT BUTTON
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: loading ? null : _submit,
//                         child: loading
//                             ? const SizedBox(
//                                 height: 18,
//                                 width: 18,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : Text(isLogin ? 'Login' : 'Create Account'),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     /// TOGGLE LOGIN / REGISTER
//                     TextButton(
//                       onPressed: loading
//                           ? null
//                           : () => setState(() => isLogin = !isLogin),
//                       child: Text(
//                         isLogin
//                             ? 'Create a new account'
//                             : 'Already have an account?',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'signup_screen.dart';
// import 'forgot_password_screen.dart';

// class LoginScreen extends StatefulWidget {
//    LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final emailCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();
//   bool loading = false;
//   bool obscurePassword = true;

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     FocusScope.of(context).unfocus();
//     setState(() => loading = true);

//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: emailCtrl.text.trim(),
//         password: passwordCtrl.text.trim(),
//       );
//     } on FirebaseAuthException catch (e) {
//       _showError(_friendlyMessage(e));
//     } catch (_) {
//       _showError('Something went wrong. Please try again.');
//     }

//     setState(() => loading = false);
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   String _friendlyMessage(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'user-not-found':
//         return 'No account found with this email.';
//       case 'wrong-password':
//         return 'Incorrect password.';
//       case 'invalid-email':
//         return 'Enter a valid email.';
//       default:
//         return e.message ?? 'Authentication failed.';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login'), centerTitle: true),
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
//                     controller: emailCtrl,
//                     keyboardType: TextInputType.emailAddress,
//                     decoration: const InputDecoration(
//                       labelText: 'Email',
//                       prefixIcon: Icon(Icons.email),
//                     ),
//                     validator: (v) {
//                       if (v == null || v.isEmpty) return 'Email is required';
//                       if (!v.contains('@')) return 'Enter a valid email';
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
//                       if (v == null || v.isEmpty) return 'Password is required';
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
//                           : const Text('Login'),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const SignupScreen(settingsController: null,)),
//                           );
//                         },
//                         child: const Text('Create Account'),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const ForgotPasswordScreen()),
//                           );
//                         },
//                         child: const Text('Forgot Password?'),
//                       ),
//                     ],
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poultry_profit_calculator/controllers/settings_controller.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final SettingsController settingsController;
  LoginScreen({super.key, required this.settingsController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyMessage(e));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _friendlyMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Enter a valid email.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // EMAIL
                    TextFormField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Email is required';
                        }
                        if (!v.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // PASSWORD
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(
                              () => obscurePassword = !obscurePassword,
                            );
                          },
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // LOGIN BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ACTIONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignupScreen(
                                  settingsController: widget.settingsController,
                                ),
                              ),
                            );
                          },
                          child: const Text('Create Account'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
