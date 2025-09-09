import 'package:flutter/material.dart';

class ReadDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReadDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final text = data['text'] ?? '';
    final location = data['location'] ?? '';
    final timestamp = data['timestamp']?.toDate();
    final formattedDate = timestamp != null
        ? "${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute}"
        : "Unknown date";

    return Scaffold(
      appBar: AppBar(title: const Text("Post Detail")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(location, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Text(formattedDate, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}