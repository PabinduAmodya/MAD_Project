import 'package:flutter/material.dart';
import 'package:flutter_service_app/screens/login.dart';
import 'package:flutter_service_app/screens/worker/worker_notifications_page.dart'; 
import 'package:flutter_service_app/screens/worker/worker_chats_list.dart';

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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildDashboardButton({
    required IconData icon, 
    required String label, 
    required VoidCallback onPressed,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.9),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

   Widget _buildAvailabilityToggle() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAvailable ? 'Available for Work' : 'Not Available',
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAvailable 
                    ? 'You are visible to customers' 
                    : 'You are hidden from new requests',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Switch(
            value: isAvailable,
            onChanged: (bool value) {
              setState(() {
                isAvailable = value;
              });
              // TODO: Implement backend update for worker availability
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? 'You are now available' : 'You are now unavailable'),
                  backgroundColor: Colors.yellow[700],
                ),
              );
            },
            activeColor: Colors.green,
            activeTrackColor: Colors.green.withOpacity(0.3),
            inactiveThumbColor: Colors.red,
            inactiveTrackColor: Colors.red.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

    Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow[700]!, Colors.amber[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  workerName != null && workerName!.isNotEmpty 
                      ? workerName![0].toUpperCase() 
                      : 'W',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workerName ?? 'Worker',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.star, 
                label: _isLoadingReviews ? "..." : workerRating.toStringAsFixed(1),
                sublabel: 'Rating'
              ),
              _buildStatItem(
                icon: Icons.rate_review, 
                label: _isLoadingReviews ? "..." : reviewsCount.toString(),
                sublabel: 'Reviews'
              ),
              _buildStatItem(
                icon: Icons.access_time,
                label: '100%',
                sublabel: 'On time'
              ),
            ],
          ),
        ],
      ),
    );
  }

}