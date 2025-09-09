import 'package:flutter/material.dart';
import 'package:local_buzz_app/bottomnav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({super.key});

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  final TextEditingController pinController = TextEditingController();
  String error = '';

  Future<void> validatePin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_pin');
    final enteredPin = pinController.text.trim();

    if (enteredPin == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()), // Your real app
      );
    } else {
      setState(() => error = "Incorrect PIN");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your PIN to continue", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: "PIN",
                  errorText: error.isNotEmpty ? error : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: validatePin,
                child: const Text("Unlock"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}