import 'package:flutter/material.dart';

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