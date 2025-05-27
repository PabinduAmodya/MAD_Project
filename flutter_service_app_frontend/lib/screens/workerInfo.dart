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
// Add to _WorkerInfoScreenState class
Widget _buildSectionCard({required String title, required Widget content}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: Colors.yellow[700]!.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        content,
      ],
    ),
  );
}

Widget _buildInfoRow({
  required BuildContext context,
  required IconData icon, 
  required String label, 
  required String value,
}) {
  return Row(
    children: [
      Icon(icon, color: Colors.yellow[700], size: 24),
      const SizedBox(width: 15),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ],
  );
}
// Add to _WorkerInfoScreenState class
List<dynamic> reviews = [];
bool isLoading = true;
String errorMessage = "";

@override
void initState() {
  super.initState();
  fetchWorkerReviews();
}

Future<String?> getUserToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<void> fetchWorkerReviews() async {
  try {
    String? token = await getUserToken();
    var workerId = widget.workerData['id'];
    
    var response = await Dio().get(
      'http://10.0.2.2:5000/api/reviews/$workerId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 200) {
      setState(() {
        reviews = response.data;
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = "Failed to load reviews.";
        isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = "Error fetching reviews: ${e.toString()}";
      isLoading = false;
    });
  }
}

Widget _buildReviewItem(Map<String, dynamic> review) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFF2A2A2A),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          review['userName'] ?? "Anonymous User",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          review['comment'] ?? "No comment provided.",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
