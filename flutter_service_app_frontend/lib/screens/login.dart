import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_service_app/screens/home.dart';
import 'package:flutter_service_app/screens/worker/worker_home.dart';
import 'package:flutter_service_app/screens/admin/admin_home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_type.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      String? role = prefs.getString('user_role');
      if (role == 'user') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      } else if (role == 'worker') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerHomeScreen()));
      } else if (role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHomeScreen()));
      }
    }
  }
  
Future<void> loginUser(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final url = Uri.parse('http://10.0.2.2:5000/api/users/login');

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_role', data['user']['role']);
        await prefs.setString('user_id', data['user']['id']);
        await prefs.setString('name', data['user']['name']);

        _showSnackBar("Login successful!");

        switch (data['user']['role']) {
          case 'user':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
            break;
          case 'worker':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WorkerHomeScreen()));
            break;
          case 'admin':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHomeScreen()));
            break;
        }
      } else {
        final data = json.decode(response.body);
        _showSnackBar("Login failed: ${data['error'] ?? 'Invalid credentials'}");
      }
    } catch (e) {
      _showSnackBar("An error occurred: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.yellow[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
