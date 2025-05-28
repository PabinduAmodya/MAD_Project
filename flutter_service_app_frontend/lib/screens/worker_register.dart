import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WorkerRegisterScreen extends StatefulWidget {
  const WorkerRegisterScreen({super.key});

  @override
  _WorkerRegisterScreenState createState() => _WorkerRegisterScreenState();
}

class _WorkerRegisterScreenState extends State<WorkerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController yearsExperienceController = TextEditingController();

  final List<String> workTypes = ["Plumber", "Electrician", "Carpenter", "Mechanic", "Painter", "Mason", "Welder", "Cleaner"];
  String? selectedWorkType;
  String? workTypeError;
   // Email validation regex
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Phone number validation (basic check for 10 digits)
  bool isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  // Validate all fields before registration
  bool validateAllFields() {
    bool isValid = _formKey.currentState!.validate();
    
    // Validate work type separately since it's not part of the form
    if (selectedWorkType == null || selectedWorkType!.isEmpty) {
      setState(() {
        workTypeError = 'Please select a work type';
      });
      isValid = false;
    } else {
      setState(() {
        workTypeError = null;
      });
    }

    return isValid;
  }

  Future<void> registerWorker() async {
    // Validate all fields first
    if (!validateAllFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    const String apiUrl = 'http://10.0.2.2:5000/api/users/register';
     // Construct request body
    Map<String, dynamic> workerData = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "role": "worker",
      "workType": selectedWorkType,
      "location": locationController.text.trim(),
      "yearsOfExperience": yearsExperienceController.text.trim(),
      "phoneNo": phoneNoController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(workerData),
      );

      if (response.statusCode == 201) {
        // Successful registration
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration Successful!'),
            backgroundColor: Colors.green,
          ),
        );



