// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';

// class CreatePostScreen extends StatefulWidget {
//   const CreatePostScreen({super.key});

//   @override
//   State<CreatePostScreen> createState() => _CreatePostScreenState();
// }

// class _CreatePostScreenState extends State<CreatePostScreen> {
//   final TextEditingController _textController = TextEditingController();
//   bool isPosting = false;

//   Future<Position?> _getLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return null;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.deniedForever) return null;
//     }

//     return await Geolocator.getCurrentPosition();
//   }

//   Future<void> submitPost() async {
//     final content = _textController.text.trim();
//     if (content.isEmpty) return;

//     setState(() => isPosting = true);

//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     final position = await _getLocation();

//     final postData = {
//       'uid': user.uid,
//       'text': content,
//       'timestamp': FieldValue.serverTimestamp(),
//       'likes': [],
//       'comments': [],
//       'reposts': 0,
//       'geo': position != null
//           ? {
//               'lat': position.latitude,
//               'lng': position.longitude,
//             }
//           : null,
//     };

//     try {
//       await FirebaseFirestore.instance.collection('reads').add(postData);
//       _textController.clear();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Read posted successfully!")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     }

//     setState(() => isPosting = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("New Read"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: _textController,
//               maxLines: 6,
//               maxLength: 280,
//               decoration: InputDecoration(
//                 hintText: "What's on your mind?",
//                 fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
//                 filled: true,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.send),
//               label: isPosting
//                   ? const CircularProgressIndicator()
//                   : const Text("Post Read"),
//               onPressed: isPosting ? null : submitPost,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:local_buzz_app/bottomnav.dart';

// class CreateReadScreen extends StatefulWidget {
//   const CreateReadScreen({super.key});

//   @override
//   State<CreateReadScreen> createState() => _CreateReadScreenState();
// }

// class _CreateReadScreenState extends State<CreateReadScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _textController = TextEditingController();
//   bool isLoading = false;
//   String? currentLocation;

//   @override
//   void initState() {
//     super.initState();
//     fetchLocation();
//   }

//   Future<void> fetchLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.deniedForever ||
//           permission == LocationPermission.denied) {
//         setState(() => currentLocation = 'Location unavailable');
//         return;
//       }

//       final position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       final placemarks =
//           await placemarkFromCoordinates(position.latitude, position.longitude);

//       final place = placemarks.first;
//       setState(() {
//         currentLocation =
//             "${place.locality}, ${place.subAdministrativeArea}, ${place.country}";
//       });
//     } catch (e) {
//       setState(() => currentLocation = 'Failed to get location');
//     }
//   }

  
//   Future<void> submitRead() async {
//   if (!_formKey.currentState!.validate()) return;

//   setState(() => isLoading = true);

//   try {
//     final uid = FirebaseAuth.instance.currentUser!.uid;

//     await FirebaseFirestore.instance.collection('reads').add({
//       'uid': uid,
//       'text': _textController.text.trim(),
//       'location': currentLocation ?? 'Unknown',
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     setState(() => isLoading = false);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Read posted successfully!")),
//     );

//     // ✅ Navigate to BottomNavScreen instead of popping
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const BottomNavScreen()),
//     );

//   } catch (e) {
//     setState(() => isLoading = false);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Failed to post.")),
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Create Read"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _textController,
//                 maxLines: 5,
//                 maxLength: 280,
//                 decoration: const InputDecoration(
//                   hintText: "What's on your mind?",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Post cannot be empty' : null,
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   const Icon(Icons.location_on, color: Colors.grey),
//                   const SizedBox(width: 5),
//                   Text(
//                     currentLocation ?? "Getting location...",
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               ElevatedButton(
//                 onPressed: isLoading ? null : submitRead,
//                 child: isLoading
//                     ? const CircularProgressIndicator()
//                     : const Text("Post Read"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



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