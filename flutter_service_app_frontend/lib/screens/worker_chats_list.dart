import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_service_app/screens/chat.dart';

class WorkerChatsList extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String userToken;

  const WorkerChatsList({
    Key? key, 
    required this.workerId, 
    required this.workerName,
    required this.userToken
  }) : super(key: key);

  @override
  _WorkerChatsListState createState() => _WorkerChatsListState();
}

class _WorkerChatsListState extends State<WorkerChatsList> {
  List<dynamic> _chatsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkerChats();
  }

  Future<void> _fetchWorkerChats() async {
    try {
      print('Fetching chats for Worker ID: ${widget.workerId}');
      print('Using Token: ${widget.userToken}');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/chats/worker/${widget.workerId}'),
        headers: {
          'Authorization': 'Bearer ${widget.userToken}'
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _chatsList = (json.decode(response.body) as List).map((chat) => {
            'userId': chat['userId'] ?? '',
            'userName': chat['userName'] ?? 'Unknown User',
            'lastMessage': chat['lastMessage'] ?? 'No messages',
            'timestamp': chat['timestamp'] ?? DateTime.now().toIso8601String()
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to fetch chats: ${response.body}');
      }
    } catch (e) {
      print('Network Error: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error fetching chats: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  void _navigateToChat(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          workerId: widget.workerId, 
          workerName: userName,
          userToken: widget.userToken,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        title: Text(
          'My Chats', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
        ? Center(
            child: CircularProgressIndicator(
              color: Colors.yellow[700],
            ),
          )
        : _chatsList.isEmpty
          ? Center(
              child: Text(
                'No chats available',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
