import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlumberPage extends StatefulWidget {
  @override
  _PlumberPageState createState() => _PlumberPageState();
}

class _PlumberPageState extends State<PlumberPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plumbers Available'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Center(child: Text('Plumbers list will appear here')),
    );
  }
}