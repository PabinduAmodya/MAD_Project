// worker_info_screen.dart (Initial Commit)
import 'package:flutter/material.dart';

class WorkerInfoScreen extends StatefulWidget {
  final Map<String, dynamic> workerData;

  const WorkerInfoScreen({super.key, required this.workerData});

  @override
  State<WorkerInfoScreen> createState() => _WorkerInfoScreenState();
}

class _WorkerInfoScreenState extends State<WorkerInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.yellow[700],
                      child: Text(
                        widget.workerData['name'].toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 70, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.workerData['name'],
                      style: const TextStyle(fontSize: 28, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.workerData['specialization'] ?? 'Professional',
                      style: TextStyle(color: Colors.yellow[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add to worker_info_screen.dart
// Helper Widgets
Widget _buildSectionCard({required String title, required Widget content}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20)),
        const SizedBox(height: 15),
        content,
      ],
    ),
  );
}

Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
  return Row(
    children: [
      Icon(icon, color: Colors.yellow[700]),
      const SizedBox(width: 15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    ],
  );
}

// Add to build method after profile header
_buildSectionCard(
  title: "Professional Overview",
  content: Column(
    children: [
      Text(widget.workerData['about'] ?? "No description", 
           style: TextStyle(color: Colors.grey[300])),
      const SizedBox(height: 20),
      _buildInfoRow(
        icon: Icons.phone_outlined,
        label: "Phone",
        value: widget.workerData['phoneNo'],
      ),
      _buildInfoRow(
        icon: Icons.location_on_outlined,
        label: "Location",
        value: widget.workerData['location'],
      ),
    ],
  ),
),