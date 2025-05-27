import 'package:flutter/material.dart';
import 'package:flutter_service_app/screens/user_register.dart';
import 'package:flutter_service_app/screens/worker_register.dart';
import 'package:flutter_service_app/screens/login.dart'; // Added import for login page

class UserTypeScreen extends StatelessWidget {
  const UserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF121212)], // Dark background gradient
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              children: [
                // App logo or icon
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.handyman,
                        size: 60,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                
                // Title and subtitle
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        "Welcome!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Please select how you want to use the app",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // Buttons section
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Service Provider Option
                      _buildSelectionCard(
                        context: context,
                        icon: Icons.business_center,
                        title: "Service Provider",
                        subtitle: "Offer your services and manage your bookings",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WorkerRegisterScreen()),
                          );
                        },
                      ),
                      
                      SizedBox(height: 20),
