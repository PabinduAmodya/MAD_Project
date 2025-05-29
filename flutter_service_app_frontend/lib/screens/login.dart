import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_service_app/screens/home.dart';
import 'package:flutter_service_app/screens/worker/worker_home.dart';
import 'package:flutter_service_app/screens/admin/admin_home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_type.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      String? role = prefs.getString('user_role');
      if (role == 'user') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else if (role == 'worker') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerHomeScreen()));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHomeScreen()));
      }
    }
  }
  
Future<void> loginUser(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final url = Uri.parse('http://10.0.2.2:5000/api/users/login');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_role', data['user']['role']);
        await prefs.setString('user_id', data['user']['id']);
        await prefs.setString('name', data['user']['name']);

        _showSnackBar("Login successful!");

        switch (data['user']['role']) {
          case 'user':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
            break;
          case 'worker':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerHomeScreen()));
            break;
          case 'admin':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHomeScreen()));
            break;
        }
      } else {
        final data = json.decode(response.body);
        _showSnackBar("Login failed: ${data['error'] ?? 'Invalid credentials'}");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.yellow[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
       title: const Text("Login", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
  ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
