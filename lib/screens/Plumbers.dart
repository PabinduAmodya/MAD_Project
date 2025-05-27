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
class _PlumberPageState extends State<PlumberPage> {
  bool isLoading = true;
  List<dynamic> allPlumbers = [];
  List<dynamic> filteredPlumbers = [];

  Future<void> fetchPlumbers() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/workers'));
      if (response.statusCode == 200) {
        List<dynamic> workers = json.decode(response.body);
        allPlumbers = workers.where((worker) => worker['workType'] == 'Plumber').toList();
        filteredPlumbers = List.from(allPlumbers);
      } else {
        throw Exception('Failed to load workers');
      }
    } catch (error) {
      print('Error fetching plumbers: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPlumbers();
  }
}


Expanded(
  child: isLoading
      ? Center(child: CircularProgressIndicator())
      : filteredPlumbers.isEmpty
          ? Center(child: Text('No plumbers available at the moment'))
          : ListView.builder(
              itemCount: filteredPlumbers.length,
              itemBuilder: (context, index) {
                final plumber = filteredPlumbers[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.yellow[700],
                      child: Icon(Icons.plumbing, color: Colors.white),
                    ),
                    title: Text(
                      plumber['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Location: ${plumber['location']}'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                );
              },
            ),
)