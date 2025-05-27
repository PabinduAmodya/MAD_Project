import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_service_app/screens/login.dart'; // Update import for login screen

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  _UserRegisterScreenState createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  bool isLoading = false; // Track loading state

  // Function to handle user registration
Future<void> registerUser(BuildContext context) async {
  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final phoneNo =phoneNoController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty || phoneNo.isEmpty) {
    _showSnackBar("All fields are required");
    return;
  }

  final url = Uri.parse('http://10.0.2.2:5000/api/users/register');

  setState(() {
    isLoading = true;
  });

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phoneNo' : phoneNo
      }),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 201 && responseData['error'] == null) {
      _showSnackBar(responseData['message']); // Show success message
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      String errorMessage = responseData['error'] ?? "Unknown error occurred";
      _showSnackBar("Registration failed: $errorMessage");
    }
  } catch (error) {
    _showSnackBar("An error occurred: $error");
  } finally {
    setState(() {
      isLoading = false;
    });
  }
  
}


