// lib/screens/signup_screen.dart
// import 'package:flutter/material.dart';
// import 'package:local_buzz_app/services/auth_services.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPassController = TextEditingController();

//   void signUp() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isLoading = true);
//     final message = await AuthService().signUpWithEmail(
//       name: nameController.text.trim(),
//       username: usernameController.text.trim(),
//       phone: phoneController.text.trim(),
//       email: emailController.text.trim(),
//       password: passwordController.text.trim(),
//     );
//     setState(() => isLoading = false);

//     if (message == null) {
//       Navigator.pop(context); // Back to login
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Sign Up')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: 'Name'),
//                 validator: (value) => value!.isEmpty ? 'Enter your name' : null,
//               ),
//               TextFormField(
//                 controller: usernameController,
//                 decoration: const InputDecoration(labelText: 'Username'),
//                 validator: (value) => value!.isEmpty ? 'Enter username' : null,
//               ),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(labelText: 'Phone'),
//                 keyboardType: TextInputType.phone,
//                 validator: (value) => value!.length < 10 ? 'Enter valid phone' : null,
//               ),
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
//               TextFormField(
//                 controller: confirmPassController,
//                 decoration: const InputDecoration(labelText: 'Confirm Password'),
//                 obscureText: true,
//                 validator: (value) =>
//                     value != passwordController.text ? 'Passwords do not match' : null,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: isLoading ? null : signUp,
//                 child: isLoading
//                     ? const CircularProgressIndicator()
//                     : const Text('Create Account'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:local_buzz_app/bottomnav.dart';
import 'package:local_buzz_app/services/auth_services.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassController = TextEditingController();

  void signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final message = await AuthService().signUpWithEmail(
      name: nameController.text.trim(),
      username: usernameController.text.trim(),
      phone: phoneController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    setState(() => isLoading = false);

    if (message == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BottomNavScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
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
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: nameController,
                    decoration: _inputStyle("Full Name", Icons.person),
                    validator: (value) => value!.isEmpty ? "Enter your name" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: usernameController,
                    decoration: _inputStyle("Username", Icons.alternate_email),
                    validator: (value) => value!.isEmpty ? "Enter a username" : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: phoneController,
                    decoration: _inputStyle("Phone", Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.length < 10 ? "Enter valid phone" : null,
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: confirmPassController,
                    decoration: _inputStyle("Confirm Password", Icons.lock_outline),
                    obscureText: true,
                    validator: (value) => value != passwordController.text
                        ? "Passwords do not match"
                        : null,
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: isLoading ? null : signUp,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text("Create Account"),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Already have an account? Login",
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