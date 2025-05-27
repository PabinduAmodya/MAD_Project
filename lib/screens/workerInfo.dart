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