import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final TextEditingController pinController = TextEditingController();
  String error = '';

  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_pin', pin);
  }

  void handleSubmit() async {
    final pin = pinController.text.trim();
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() => error = "Enter a valid 4-digit PIN");
      return;
    }
    await savePin(pin);
    Navigator.pop(context); // Go back to Settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PIN set successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set PIN")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Enter a 4-digit PIN to secure your app",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "PIN",
                errorText: error.isNotEmpty ? error : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleSubmit,
              child: const Text("Save PIN"),
            ),
          ],
        ),
      ),
    );
  }
}