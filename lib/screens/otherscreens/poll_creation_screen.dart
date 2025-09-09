

// poll_creation_screen.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class PollCreationScreen extends StatefulWidget {
//   const PollCreationScreen({super.key});

//   @override
//   State<PollCreationScreen> createState() => _PollCreationScreenState();
// }

// class _PollCreationScreenState extends State<PollCreationScreen> {
//   final TextEditingController _questionController = TextEditingController();
//   final List<TextEditingController> optionControllers = List.generate(
//     4, (index) => TextEditingController(),
//   ); 

//   bool isLoading = false;

//   Future<Position?> getLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) return null;
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//       if (permission == LocationPermission.deniedForever ||
//           permission == LocationPermission.denied)
//         return null;

//       return await Geolocator.getCurrentPosition();
//     } catch (_) {
//       return null;
//     }
//   }

//   Future<void> createPoll() async {
//     final question = _questionController.text.trim();
//     final options = optionControllers
//         .map((c) => c.text.trim())
//         .where((t) => t.isNotEmpty)
//         .toList();

//     if (question.isEmpty || options.length < 2) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Enter question and at least 2 options.")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     final position = await getLocation();
//     final geo = position != null
//         ? GeoPoint(position.latitude, position.longitude)
//         : null;

//     await FirebaseFirestore.instance.collection('polls').add({
//       'question': question,
//       'options': options,
//       'votes': List.generate(options.length, (_) => 0),
//       'voters': [],
//       'timestamp': Timestamp.now(),
//       'uid': FirebaseAuth.instance.currentUser!.uid,
//       'geo': geo,
//     });

//     setState(() => isLoading = false);
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Poll")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: _questionController,
//               decoration: const InputDecoration(labelText: "Poll Question"),
//             ),
//             const SizedBox(height: 12),
//             ...List.generate(
//               4,
//               (i) => Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: TextField(
//                   controller: optionControllers[i],
//                   decoration: InputDecoration(labelText: "Option ${i + 1}"),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: isLoading ? null : createPoll,
//               child: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Submit Poll"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class PollCreationScreen extends StatefulWidget {
//   const PollCreationScreen({super.key});

//   @override
//   State<PollCreationScreen> createState() => _PollCreationScreenState();
// }

// class _PollCreationScreenState extends State<PollCreationScreen> {
//   final TextEditingController questionController = TextEditingController();
//   final List<TextEditingController> optionControllers =
//       List.generate(4, (_) => TextEditingController());

//   bool isSubmitting = false;

//   @override
//   void dispose() {
//     questionController.dispose();
//     for (var controller in optionControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _createPoll() async {
//     final question = questionController.text.trim();
//     final options = optionControllers.map((c) => c.text.trim()).toList();

//     if (question.isEmpty || options.any((o) => o.isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all fields")),
//       );
//       return;
//     }

//     setState(() => isSubmitting = true);

//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         await Geolocator.openLocationSettings();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Enable location services first")),
//         );
//         setState(() => isSubmitting = false);
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Location permission denied")),
//           );
//           setState(() => isSubmitting = false);
//           return;
//         }
//       }

//       final pos = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);

//       final uid = FirebaseAuth.instance.currentUser?.uid;

//       final pollData = {
//         'question': question,
//         'options': options,
//         'votes': List.filled(4, 0),
//         'timestamp': Timestamp.now(),
//         'uid': uid,
//         'geo': GeoPoint(pos.latitude, pos.longitude),
//         'voted': {}, // For tracking votes
//       };

//       await FirebaseFirestore.instance.collection('polls').add(pollData);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Poll created successfully")),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Poll")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: questionController,
//               decoration: const InputDecoration(labelText: "Poll Question"),
//             ),
//             const SizedBox(height: 16),
//             for (int i = 0; i < 4; i++)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: TextField(
//                   controller: optionControllers[i],
//                   decoration: InputDecoration(labelText: "Option ${i + 1}"),
//                 ),
//               ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: isSubmitting ? null : _createPoll,
//               icon: const Icon(Icons.poll),
//               label: const Text("Submit Poll"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:local_buzz_app/screens/home_feed_screen.dart';
// //import 'package:local_buzz_app/screens/home_feed_screen.dart';
// //import 'package:local_buzz_app/screens/home_feed_screen.dart';

// class PollCreationScreen extends StatefulWidget {
//   const PollCreationScreen({super.key});

//   @override
//   State<PollCreationScreen> createState() => _PollCreationScreenState();
// }

// class _PollCreationScreenState extends State<PollCreationScreen> {
//   final TextEditingController questionController = TextEditingController();
//   final List<TextEditingController> optionControllers = List.generate(4, (_) => TextEditingController());
//   bool isSubmitting = false;

//   @override
//   void dispose() {
//     questionController.dispose();
//     for (var c in optionControllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }

// //   
// Future<void> createPoll() async {
//   final question = questionController.text.trim();
//   final options = optionControllers.map((c) => c.text.trim()).toList();

//   if (question.isEmpty || options.any((o) => o.isEmpty)) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Please fill all fields")),
//     );
//     return;
//   }

//   setState(() => isSubmitting = true);

//   try {
//     final pos = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
//     final place = placemarks.isNotEmpty ? placemarks.first : null;
//     final locationName = place != null
//         ? "${place.locality}, ${place.country}"
//         : "Unknown";

//     final uid = FirebaseAuth.instance.currentUser?.uid;

//     final poll = {
//       'question': question,
//       'options': options,
//       'votes': List.generate(options.length, (_) => 0),
//       'timestamp': Timestamp.now(),
//       'uid': uid,
//       'geo': GeoPoint(pos.latitude, pos.longitude),
//       'location': locationName,
//       'voted': {},
//     };

//     await FirebaseFirestore.instance.collection('polls').add(poll);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Poll submitted!")),
//     );
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const HomeFeedScreen()),
//     );
      
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: $e")),
//     );
//   } finally {
//     setState(() => isSubmitting = false);
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Poll")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: questionController,
//               decoration: const InputDecoration(labelText: "Poll Question"),
//             ),
//             const SizedBox(height: 12),
//             for (int i = 0; i < optionControllers.length; i++)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: TextField(
//                   controller: optionControllers[i],
//                   decoration: InputDecoration(labelText: "Option ${i + 1}"),
//                 ),
//               ),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//               onPressed: isSubmitting ? null : createPoll,
//               icon: const Icon(Icons.poll),
//               label: isSubmitting ? const Text("Submitting...") : const Text("Submit Poll"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// } 




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:local_buzz_app/screens/home_feed_screen.dart';

// class PollCreationScreen extends StatefulWidget {
//   const PollCreationScreen({super.key});

//   @override
//   State<PollCreationScreen> createState() => _PollCreationScreenState();
// }

// class _PollCreationScreenState extends State<PollCreationScreen> {
//   final TextEditingController questionController = TextEditingController();
//   final List<TextEditingController> optionControllers =
//       List.generate(4, (_) => TextEditingController());

//   bool isSubmitting = false;

//   @override
//   void dispose() {
//     questionController.dispose();
//     for (var c in optionControllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> createPoll() async {
//     final question = questionController.text.trim();
//     final options = optionControllers.map((c) => c.text.trim()).toList();

//     if (question.isEmpty || options.any((o) => o.isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all fields")),
//       );
//       return;
//     }

//     setState(() => isSubmitting = true);

//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       final placemarks = await placemarkFromCoordinates(
//         pos.latitude,
//         pos.longitude,
//       );
//       final place = placemarks.isNotEmpty ? placemarks.first : null;
//       final locationName =
//           place != null ? "${place.locality}, ${place.country}" : "Unknown";

//       final uid = FirebaseAuth.instance.currentUser?.uid;

//       final poll = {
//         'question': question,
//         'options': options,
//         'votes': List.generate(options.length, (_) => 0),
//         'timestamp': Timestamp.now(),
//         'uid': uid,
//         'geo': GeoPoint(pos.latitude, pos.longitude),
//         'location': locationName,
//         'voted': {},
//       };

//       await FirebaseFirestore.instance.collection('polls').add(poll);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Poll submitted!")),
//       );

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomeFeedScreen()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error: $e")),
//       );
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Poll")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Poll Question",
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: questionController,
//                   decoration: InputDecoration(
//                     hintText: "Enter your poll question",
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     filled: true,
//                     fillColor: const Color.fromARGB(255, 116, 112, 112),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   "Options",
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 const SizedBox(height: 8),
//                 for (int i = 0; i < optionControllers.length; i++)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: TextField(
//                       controller: optionControllers[i],
//                       decoration: InputDecoration(
//                         hintText: "Option ${i + 1}",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         filled: true,
//                       //  fillColor: Colors.grey[100],
//                       fillColor: const Color.fromARGB(255, 116, 112, 112),
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.poll),
//                     label: isSubmitting
//                         ? const Text("Submitting...")
//                         : const Text("Submit Poll",style: TextStyle(color: Colors.white),),
//                     onPressed: isSubmitting ? null : createPoll,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       textStyle: const TextStyle(fontSize: 16),
//                       backgroundColor: Color.fromARGB(255, 116, 112, 112),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
                        
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_buzz_app/screens/home_feed_screen.dart';

class PollCreationScreen extends StatefulWidget {
  const PollCreationScreen({super.key});

  @override
  State<PollCreationScreen> createState() => _PollCreationScreenState();
}

class _PollCreationScreenState extends State<PollCreationScreen> {
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers =
      List.generate(4, (_) => TextEditingController());

  bool isSubmitting = false;
  String? locationText = "Fetching location...";

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  Future<void> fetchLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final locationName =
          place != null ? "${place.locality}, ${place.country}" : "Unknown";

      setState(() {
        locationText = locationName;
      });
    } catch (e) {
      setState(() {
        locationText = "Location not available";
      });
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    for (var c in optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> createPoll() async {
    final question = questionController.text.trim();
    final options = optionControllers.map((c) => c.text.trim()).toList();

    if (question.isEmpty || options.any((o) => o.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final locationName =
          place != null ? "${place.locality}, ${place.country}" : "Unknown";

      final uid = FirebaseAuth.instance.currentUser?.uid;

      final poll = {
        'question': question,
        'options': options,
        'votes': List.generate(options.length, (_) => 0),
        'timestamp': Timestamp.now(),
        'uid': uid,
        'geo': GeoPoint(pos.latitude, pos.longitude),
        'location': locationName,
        'voted': {},
      };

      await FirebaseFirestore.instance.collection('polls').add(poll);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Poll submitted!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeFeedScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Poll")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Poll Question",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    hintText: "Enter your poll question",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 116, 112, 112),
                  ),
                ),
                if (locationText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                    child: Text(
                      "📍 $locationText",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 20),
                const Text(
                  "Options",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < optionControllers.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: optionControllers[i],
                      decoration: InputDecoration(
                        hintText: "Option ${i + 1}",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 116, 112, 112),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.poll),
                    label: isSubmitting
                        ? const Text("Submitting...")
                        : const Text("Submit Poll", style: TextStyle(color: Colors.white)),
                    onPressed: isSubmitting ? null : createPoll,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: const Color.fromARGB(255, 116, 112, 112),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}