


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:local_buzz_app/bottomnav.dart';

class CreateReadScreen extends StatefulWidget {
  const CreateReadScreen({super.key});

  @override
  State<CreateReadScreen> createState() => _CreateReadScreenState();
}

class _CreateReadScreenState extends State<CreateReadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  bool isLoading = false;
  String? currentLocation;
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  Future<void> fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => currentLocation = 'Location unavailable');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.first;
      setState(() {
        currentPosition = position;
        currentLocation =
            "${place.locality}, ${place.subAdministrativeArea}, ${place.country}";
      });
    } catch (e) {
      setState(() => currentLocation = 'Failed to get location');
    }
  }

 
  Future<void> submitRead() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => isLoading = true);

  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    await FirebaseFirestore.instance.collection('reads').add({
      'uid': uid,
      'text': _textController.text.trim(),
      'location': currentLocation ?? 'Unknown',
      'geo': GeoPoint(position.latitude, position.longitude),
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Read posted successfully!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNavScreen()),
    );
  } catch (e) {
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to post.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Read"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _textController,
                maxLines: 5,
                maxLength: 280,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Post cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    currentLocation ?? "Getting location...",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: isLoading ? null : submitRead,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Post Read"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}