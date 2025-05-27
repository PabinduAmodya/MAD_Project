import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookWorkerScreen extends StatefulWidget {
  final Map<String, dynamic> workerData;
  final String userToken;

  const BookWorkerScreen({
    super.key,
    required this.workerData,
    required this.userToken,
  });

  @override
  _BookWorkerScreenState createState() => _BookWorkerScreenState();
}

class _BookWorkerScreenState extends State<BookWorkerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Worker"),
        backgroundColor: Colors.yellow[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking Appointment with ${widget.workerData['name']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Basic form fields will be added in next commits
          ],
        ),

        // Add to _BookWorkerScreenState class
Widget _buildTextField(TextEditingController controller, String label,
    {bool isDate = false, int maxLines = 1, TextInputType? keyboardType}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType ?? (isDate ? TextInputType.datetime : TextInputType.text),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    maxLines: maxLines,
    onTap: isDate
        ? () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null) {
              controller.text = pickedDate.toIso8601String().split('T')[0];
            }
          }
        : null,
  );
}

// Update build method to include form fields
@override
Widget build(BuildContext context) {
  return Scaffold(
    // ... existing scaffold code ...
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... existing title code ...
          _buildTextField(_userNameController, "Your Name"),
          const SizedBox(height: 16),
          _buildTextField(_userPhoneController, "Your Phone Number", 
              keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField(_titleController, "Title"),
          const SizedBox(height: 16),
          _buildTextField(_descriptionController, "Description", maxLines: 4),
          const SizedBox(height: 16),
          _buildTextField(_deadlineController, "Deadline (YYYY-MM-DD)", isDate: true),
          const SizedBox(height: 24),
          // Submit button will be added in next commit
        ],
      ),
    ),
  );
}
      ),
    );
  }
}
