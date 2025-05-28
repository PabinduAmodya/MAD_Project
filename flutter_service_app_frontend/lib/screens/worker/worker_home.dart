import 'package:flutter/material.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  _WorkerHomeScreenState createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
      bool isAvailable = true;
  String? authToken;
  String? workerId;
  String? workerName;
  bool _isLoading = true;
  
  // Add these variables for reviews and ratings
  double workerRating = 0.0;
  int reviewsCount = 0;
  List<dynamic> reviews = [];
  bool _isLoadingReviews = true;
  String reviewError = "";
  
  // Add notification count variable
  int notificationCount = 2; // Mock count, replace with actual count from API

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('auth_token');
      workerId = prefs.getString('user_id');
      workerName = prefs.getString('username');
      _isLoading = false;

      // Debug prints
      print('Auth Token: $authToken');
      print('Worker ID: $workerId');
      print('Worker Name: $workerName');
    });
    
    // After loading user data, fetch reviews
    if (workerId != null && authToken != null) {
      fetchWorkerReviews();
      // In a real app, you would also fetch notification count here
      // fetchNotificationCount();
    }
  }
}