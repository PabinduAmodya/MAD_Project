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
