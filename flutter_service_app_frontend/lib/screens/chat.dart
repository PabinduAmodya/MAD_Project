import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String userToken;

  const ChatScreen({
    Key? key, 
    required this.workerId, 
    required this.workerName,
    required this.userToken
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = [];
  String? _chatId;
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  Future<void> _getCurrentUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentUserId = prefs.getString('user_id');
      });
      _startChat();
    } catch (e) {
      _showErrorSnackBar('Error retrieving user ID: $e');
    }
  }
  Future<void> _startChat() async {
    if (_currentUserId == null) {
      _showErrorSnackBar('User ID not found');
      return;
    }

    try {
      debugPrint('Starting Chat with:');
      debugPrint('Worker ID: ${widget.workerId}');
      debugPrint('Worker Name: ${widget.workerName}');
      debugPrint('Current User ID: $_currentUserId');

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/chats/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userToken}'
        },
        body: json.encode({
          'workerId': widget.workerId,
          'userId': _currentUserId
        }),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        setState(() {
          _chatId = responseBody['chatId'];
          _isLoading = false;
        });
        _fetchMessages();
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to start chat: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error starting chat: $e');
    }
  }
