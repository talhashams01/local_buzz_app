

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:local_buzz_app/screens/login_screen.dart';

class PrivateProfileScreen extends StatelessWidget {
  const PrivateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUserData(),
      child: const PrivateProfileBody(),
    );
  }
}

class PrivateProfileBody extends StatelessWidget {
  const PrivateProfileBody({super.key});

  void showEditDialog(BuildContext context, String field, String initialValue) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $field"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<UserProvider>(context, listen: false)
                    .updateField(field, controller.text.trim(), context);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account permanently?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete account: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = provider.userData;

        return Scaffold(
          appBar: AppBar(
            title: const Text("My Profile"),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.settings),
            //     onPressed: () {},
            //   ),
            // ],
          ),
          body: userData == null
              ? const Center(child: Text("Failed to load profile."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text("Full Name"),
                            subtitle: Text(userData['name'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => showEditDialog(context, 'name', userData['name'] ?? ''),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.alternate_email),
                            title: const Text("Username"),
                            subtitle: Text(userData['username'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => showEditDialog(context, 'username', userData['username'] ?? ''),
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: const Text("Email"),
                            subtitle: Text(userData['email'] ?? ''),
                          ),
                          const Divider(),
                          ListTile(
                            leading: const Icon(Icons.lock),
                            title: const Text("Change Password"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () async {
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: userData['email']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Password reset email sent.")),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: ${e.toString()}")),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text("Sign Out"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 165, 157, 157),
                              foregroundColor: Colors.black,
                              minimumSize: const Size.fromHeight(45),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => deleteAccount(context),
                            child: const Text("Delete Account", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class UserProvider extends ChangeNotifier {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isLoading = true;
  Map<String, dynamic>? userData;

  Future<void> loadUserData() async {
    if (currentUser == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    if (doc.exists) userData = doc.data();
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateField(String field, String value, BuildContext context) async {
    if (currentUser == null) return;
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
      field: value,
      if (field == 'name') 'nameLower': value.toLowerCase(),
    });
    await loadUserData();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$field updated')));
  }
}