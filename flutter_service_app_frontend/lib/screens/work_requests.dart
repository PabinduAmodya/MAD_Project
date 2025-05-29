import 'package:flutter/material.dart';
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

