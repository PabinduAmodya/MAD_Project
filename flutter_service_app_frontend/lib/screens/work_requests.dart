import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class WorkRequestsPage extends StatefulWidget {
  final String userToken;

  const WorkRequestsPage({super.key, required this.userToken});

  @override
  _WorkRequestsPageState createState() => _WorkRequestsPageState();
}

class _WorkRequestsPageState extends State<WorkRequestsPage> {
  List<dynamic> workRequests = [];
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchWorkRequests();
  }

  Future<void> fetchWorkRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      var response = await Dio().get(
        'http://10.0.2.2:5000/api/requests/user',
        options: Options(headers: {'Authorization': 'Bearer ${widget.userToken}'}),
      );

      if (response.statusCode == 200) {
        // Properly handle the response depending on what the API returns
        if (response.data is List) {
          setState(() {
            workRequests = response.data;
            isLoading = false;
          });
        } else if (response.data is Map) {
          // If the API returns a map with a data field containing the array
          if (response.data['data'] != null && response.data['data'] is List) {
            setState(() {
              workRequests = response.data['data'];
              isLoading = false;
            });
          } else {
            // If there's a message in the response, use it
            setState(() {
              errorMessage = response.data['message'] ?? response.data['error'] ?? "No work requests available.";
              isLoading = false;
            });
          }
        } else {
          setState(() {
            workRequests = []; // Empty list if format is unexpected
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = response.data['error'] ?? "Failed to load work requests.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

   // Function to submit a review
  Future<void> submitReview(String workerId, double rating, String comment) async {
    try {
      var response = await Dio().post(
        'http://10.0.2.2:5000/api/reviews/$workerId',
        data: {
          'rating': rating,
          'comment': comment,
        },
        options: Options(headers: {'Authorization': 'Bearer ${widget.userToken}'}),
      );

      if (response.statusCode == 201) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review submitted successfully!')),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['error'] ?? 'Failed to submit review')),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: ${e.toString()}')),
      );
    }
  }


