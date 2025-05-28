import 'package:flutter/material.dart';
import 'package:flutter_service_app/screens/login.dart';
import 'package:flutter_service_app/screens/worker/worker_notifications_page.dart'; 

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  _WorkerHomeScreenState createState() => _WorkerHomeScreenState();
}

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
  
  // Add method to fetch worker's reviews
  Future<void> fetchWorkerReviews() async {
    if (workerId == null) return;
    
    setState(() {
      _isLoadingReviews = true;
      reviewError = "";
    });
    
    try {
      var response = await Dio().get(
        'http://10.0.2.2:5000/api/reviews/$workerId',
        options: Options(headers: {
          'Authorization': 'Bearer $authToken'
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          reviews = response.data;
          _isLoadingReviews = false;
          
          // Calculate average rating (in case it's not returned from API)
          if (reviews.isNotEmpty) {
            double totalRating = 0;
            for (var review in reviews) {
              totalRating += review['rating'] ?? 0;
            }
            workerRating = totalRating / reviews.length;
            reviewsCount = reviews.length;
          }
        });
      } else {
        setState(() {
          reviewError = "Failed to load reviews.";
          _isLoadingReviews = false;
        });
      }
    } catch (e) {
      setState(() {
        reviewError = "Error fetching reviews: ${e.toString()}";
        _isLoadingReviews = false;
      });
    }
  }

  // Add method to navigate to notifications page
  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationPage(),
      ),
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

    void _navigateToWorkRequests() {
    if (workerId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserWorkRequestsPage(workerId: workerId!),
        ),
      );
    } else {
      _showErrorMessage('Unable to load work requests. Please log in again.');
    }
  }

  void _navigateToWorkerChats() {
    if (_isLoading) {
      _showErrorMessage('Loading user data. Please wait.');
      return;
    }

    print('Navigation Data Check:');
    print('Worker ID: $workerId');
    print('Worker Name: $workerName');
    print('Auth Token: $authToken');

    if (workerId != null && authToken != null) {
      // Use a default name if workerName is null
      final displayName = workerName ?? "Worker";
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkerChatsList(
            workerId: workerId!, 
            workerName: displayName,
            userToken: authToken!
          ),
        ),
      );
    } else {
      _showErrorMessage('Unable to load chats. Details missing.');
      print('Navigation failed: workerId=$workerId, workerName=$workerName, authToken=$authToken');
    }
  }

}