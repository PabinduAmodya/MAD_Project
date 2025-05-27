import 'package:flutter/material.dart';
import 'package:flutter_service_app/screens/book_worker.dart';
import 'package:flutter_service_app/screens/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart'; // For API calls

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic structure will be expanded in later commits
            ],
          ),
        ),



        // Add to _WorkerInfoScreenState class
Widget _buildProfileHeader() {
  return Center(
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.yellow[700]!.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 80,
            backgroundColor: Colors.yellow[700],
            child: Text(
              widget.workerData['name'].toString().substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 70,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.workerData['name'],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.workerData['specialization'] ?? 'Professional',
          style: TextStyle(
            fontSize: 16,
            color: Colors.yellow[600],
            letterSpacing: 1.1,
          ),
        ),
      ],
    ),
  );
}
      ),
    );
  }
}
