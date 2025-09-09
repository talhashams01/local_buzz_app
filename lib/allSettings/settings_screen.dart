import 'package:flutter/material.dart';
import 'package:local_buzz_app/allSettings/about_app_screen.dart';
import 'package:local_buzz_app/allSettings/feedback_screen.dart';
import 'package:local_buzz_app/allSettings/how_to_use_app_screen.dart';
import 'package:local_buzz_app/allSettings/privacy_screen.dart';
import 'package:local_buzz_app/allSettings/reset_post_screen.dart';
//import 'package:local_buzz_app/allSettings/block_users_screen.dart';
import 'package:local_buzz_app/allSettings/set_pin_screen.dart';
import 'package:local_buzz_app/screens/otherscreens/fontsize_provider.dart';
import 'package:local_buzz_app/screens/otherscreens/theme_provider.dart';
import 'package:local_buzz_app/screens/private_user_profie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isPinEnabled = false;

  @override
  void initState() {
    super.initState();
    loadPinStatus();
  }

  Future<void> loadPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isPinEnabled = prefs.getString('app_pin') != null;
    });
  }

  // Future<void> disablePin() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('app_pin');
  //   setState(() => isPinEnabled = false);
  // }
  void _confirmAndDisablePin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_pin');
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Current PIN"),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter your current PIN"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim() == savedPin) {
                await prefs.remove('app_pin');
                Navigator.pop(context);
                await loadPinStatus(); // ✅ Update UI after removal
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("PIN disabled")));
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Incorrect PIN")));
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        children: [
          // 🔹 Account Tile
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Text('Account',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: const Color.fromARGB(255, 211, 209, 209)),),
          // ),
          //SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Account"),
            subtitle: const Text("Edit profile and account info"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivateProfileScreen()),
              );
            },
          ),
          const Divider(),
          // SizedBox(height: 8),
          //  Text('Security',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),),
          // SizedBox(height: 8),

          // 🔐 Security / App Lock
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("App Lock (PIN)"),
            subtitle: Text(isPinEnabled ? "Enabled" : "Disabled"),
            trailing: Switch(
              value: isPinEnabled,
              onChanged: (value) async {
                if (value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SetPinScreen()),
                  ).then((_) => loadPinStatus());
                } else {
                  _confirmAndDisablePin(context);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever,),
            title: Text("Reset My Posts"),
            subtitle: Text(
              "Delete all your reads and polls permanently",
              style: TextStyle(color: Colors.grey[600]),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResetPostsScreen()),
              );
            },
          ),
          const Divider(),
          // SizedBox(height: 8),
          //  Text('Preferences',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),),
          // SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Theme"),
            subtitle: const Text("Choose light, dark, or system default"),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ThemeSelectionSheet(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text("Font Size"),
            subtitle: const Text("Adjust text size for Reads"),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Select Font Size"),
                  content: Consumer<FontSizeProvider>(
                    builder: (context, fontProvider, _) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<double>(
                          title: const Text("Small"),
                          value: 14.0,
                          groupValue: fontProvider.fontSize,
                          onChanged: (_) {
                            fontProvider.setSmall();
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile<double>(
                          title: const Text("Medium"),
                          value: 17.0,
                          groupValue: fontProvider.fontSize,
                          onChanged: (_) {
                            fontProvider.setMedium();
                            Navigator.pop(context);
                          },
                        ),
                        RadioListTile<double>(
                          title: const Text("Large"),
                          value: 20.0,
                          groupValue: fontProvider.fontSize,
                          onChanged: (_) {
                            fontProvider.setLarge();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const Divider(),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              'App Info',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 175, 174, 174),
              ),
            ),
          ),
          //SizedBox(height: 8),
          ListTile(
            //tileColor: Colors.grey,
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PolicyScreen(title: "Privacy Policy"),
                ),
              );
            },
          ),
          //const Divider(),
          ListTile(
            leading: const Icon(Icons.rule),
            title: const Text("Terms & Conditions"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PolicyScreen(title: "Terms & Conditions"),
                ),
              );
            },
          ),
          ListTile(
            //tileColor: Colors.grey,
            leading: const Icon(Icons.data_usage_sharp),
            title: const Text("How to use app"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HowToUseAppScreen(title: "How To Use App"),
                ),
              );
            },
          ),

          // const Divider(),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text("Feedback"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
          ),

          // const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About App"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppScreen()),
              );
            },
          ),

          // ✅ You can add more tiles here (Theme, Language, etc.)
        ],
      ),
    );
  }
}

class ThemeSelectionSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    ThemeMode currentMode = themeProvider.themeMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RadioListTile<ThemeMode>(
          title: const Text("Light"),
          value: ThemeMode.light,
          groupValue: currentMode,
          onChanged: (value) {
            themeProvider.setTheme(value!);
            Navigator.pop(context);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text("Dark"),
          value: ThemeMode.dark,
          groupValue: currentMode,
          onChanged: (value) {
            themeProvider.setTheme(value!);
            Navigator.pop(context);
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text("System Default"),
          value: ThemeMode.system,
          groupValue: currentMode,
          onChanged: (value) {
            themeProvider.setTheme(value!);
            Navigator.pop(context);
            // Provider.of<ThemeProvider>(context, listen: false).setTheme(ThemeMode.dark);
          },
        ),
      ],
    );
  }
}
