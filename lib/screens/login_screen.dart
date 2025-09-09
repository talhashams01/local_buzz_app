


// lib/screens/login_screen.dart
// import 'package:flutter/material.dart';
// //import 'package:firebase_auth/firebase_auth.dart';
// import 'package:local_buzz_app/screens/home_screen.dart';
// import 'package:local_buzz_app/screens/signup_screen.dart';
// import 'package:local_buzz_app/services/auth_services.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;

//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   void login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);
//     final message = await AuthService().loginWithEmail(
//       email: emailController.text.trim(),
//       password: passwordController.text.trim(),
//     );
//     setState(() => isLoading = false);

//     if (message == null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   void loginWithGoogle() async {
//     setState(() => isLoading = true);
//     final user = await AuthService().signInWithGoogle();
//     setState(() => isLoading = false);

//     if (user != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) =>  HomeScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: 'Email'),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) => !value!.contains('@') ? 'Enter valid email' : null,
//               ),
//               TextFormField(
//                 controller: passwordController,
//                 decoration: const InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 validator: (value) => value!.length < 6 ? 'Password too short' : null,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: isLoading ? null : login,
//                 child: isLoading
//                     ? const CircularProgressIndicator()
//                     : const Text('Login'),
//               ),
//               const SizedBox(height: 20),
//               Row(children: const [Expanded(child: Divider()), Text(" OR "), Expanded(child: Divider())]),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: isLoading ? null : loginWithGoogle,
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 child: const Text('Continue with Google'),
//               ),
//               const SizedBox(height: 10),
//               TextButton(
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
//                 },
//                 child: const Text("Don't have an account? Sign up"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/bottomnav.dart';
// //import 'package:local_buzz_app/screens/home_screen.dart';
// import 'package:local_buzz_app/screens/signup_screen.dart';
// import 'package:local_buzz_app/services/auth_services.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;

//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   void login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);
//     final message = await AuthService().loginWithEmail(
//       email: emailController.text.trim(),
//       password: passwordController.text.trim(),
//     );
//     setState(() => isLoading = false);

//     if (message == null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => BottomNavScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   void loginWithGoogle() async {
//     setState(() => isLoading = true);
//     final user = await AuthService().signInWithGoogle();
//     setState(() => isLoading = false);

//     if (user != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => BottomNavScreen()),
//       );
//     }
//   }

//   void showForgotPasswordDialog() {
//     showDialog(
//       context: context,
//       builder: (_) => const ForgotPasswordDialog(),
//     );
//   }

//   InputDecoration _inputStyle(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon),
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.teal, Colors.teal],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   const Text(
//                     'Welcome Back!',
//                     style: TextStyle(
//                       fontSize: 28,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                   TextFormField(
//                     controller: emailController,
//                     decoration: _inputStyle("Email", Icons.email),
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) => !value!.contains('@') ? "Enter valid email" : null,
//                   ),
//                   const SizedBox(height: 15),
//                   TextFormField(
//                     controller: passwordController,
//                     decoration: _inputStyle("Password", Icons.lock),
//                     obscureText: true,
//                     validator: (value) => value!.length < 6 ? "Password too short" : null,
//                   ),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: showForgotPasswordDialog,
//                       child: const Text(
//                         "Forgot Password?",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.teal,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     onPressed: isLoading ? null : login,
//                     child: isLoading
//                         ? const CircularProgressIndicator()
//                         : const Text("Login"),
//                   ),
//                   const SizedBox(height: 15),
//                   Row(
//                     children: const [
//                       Expanded(child: Divider(color: Colors.white)),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 8),
//                         child: Text("OR", style: TextStyle(color: Colors.white)),
//                       ),
//                       Expanded(child: Divider(color: Colors.white)),
//                     ],
//                   ),
//                   const SizedBox(height: 15),
//                   ElevatedButton.icon(
//                     onPressed: isLoading ? null : loginWithGoogle,
//                     icon: const Icon(Icons.g_mobiledata),
//                     label: const Text("Sign in with Google"),
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       //backgroundColor: Colors.redAccent,
//                       foregroundColor: Colors.orange,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (_) => const SignupScreen()));
//                     },
//                     child: const Text(
//                       "Don't have an account? Sign up",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ForgotPasswordDialog extends StatefulWidget {
//   const ForgotPasswordDialog({super.key});

//   @override
//   State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
// }

// class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
//   final emailController = TextEditingController();
//   bool isSending = false;
//   String? message;

//   Future<void> sendResetEmail() async {
//     setState(() {
//       isSending = true;
//       message = null;
//     });

//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(
//         email: emailController.text.trim(),
//       );
//       setState(() {
//         message = "Reset link sent to your email.";
//       });
//     } catch (e) {
//       setState(() {
//         message = "Failed to send reset link. Check email.";
//       });
//     }

//     setState(() => isSending = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text("Reset Password"),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: emailController,
//             keyboardType: TextInputType.emailAddress,
//             decoration: const InputDecoration(
//               labelText: "Enter your email",
//               prefixIcon: Icon(Icons.email),
//             ),
//           ),
//           const SizedBox(height: 10),
//           if (message != null)
//             Text(
//               message!,
//               style: TextStyle(
//                 color: message!.contains("sent") ? Colors.green : Colors.red,
//               ),
//             ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: isSending ? null : () => Navigator.pop(context),
//           child: const Text("Cancel"),
//         ),
//         ElevatedButton(
//           onPressed: isSending ? null : sendResetEmail,
//           child: isSending
//               ? const SizedBox(
//                   width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
//               : const Text("Send"),
//         ),
//       ],
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:local_buzz_app/bottomnav.dart';
import 'package:local_buzz_app/screens/signup_screen.dart';
import 'package:local_buzz_app/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final message = await AuthService().loginWithEmail(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    setState(() => isLoading = false);

    if (message == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // void loginWithGoogle() async {
  //   setState(() => isLoading = true);
  //    await AuthService().signInWithGoogle(context);
  //   setState(() => isLoading = false);

  //   if (user != null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const BottomNavScreen()),
  //     );
  //   } else {
  //     //setState(() => isLoading = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Google sign-in failed")),
  //     );
  //   }
  // }
  // void loginWithGoogle() async {
  // setState(() => isLoading = true);

  // final User? user = await AuthService().signInWithGoogle(context);

  // setState(() => isLoading = false);

  // if (user != null) {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (_) => const BottomNavScreen()),
  //   );
  // } else {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("Google sign-in failed or cancelled")),
  //   );
  // }
//}
void loginWithGoogle() async {
  setState(() => isLoading = true);
  await AuthService().signInWithGoogle(context);
  setState(() => isLoading = false);
}

  void showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (_) => const ForgotPasswordDialog(),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    decoration: _inputStyle("Email", Icons.email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => !value!.contains('@') ? "Enter valid email" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    decoration: _inputStyle("Password", Icons.lock),
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? "Password too short" : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: showForgotPasswordDialog,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Login"),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text("OR", style: TextStyle(color: Colors.white)),
                      ),
                      Expanded(child: Divider(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : loginWithGoogle,
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text("Sign in with Google"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      foregroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()));
                    },
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final emailController = TextEditingController();
  bool isSending = false;
  String? message;

  Future<void> sendResetEmail() async {
    setState(() {
      isSending = true;
      message = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      setState(() {
        message = "Reset link sent to your email.";
      });
    } catch (e) {
      setState(() {
        message = "Failed to send reset link. Check email.";
      });
    }

    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Reset Password"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Enter your email",
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 10),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                color: message!.contains("sent") ? Colors.green : Colors.red,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isSending ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isSending ? null : sendResetEmail,
          child: isSending
              ? const SizedBox(
                  width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Send"),
        ),
      ],
    );
  }
}