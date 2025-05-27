import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookWorkerScreen extends StatefulWidget {
  final Map<String, dynamic> workerData;
  final String userToken;

  const BookWorkerScreen({
    super.key,
    required this.workerData,
    required this.userToken,
  });

  @override
  _BookWorkerScreenState createState() => _BookWorkerScreenState();
}

class _BookWorkerScreenState extends State<BookWorkerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPhoneController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Worker"),
        backgroundColor: Colors.yellow[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking Appointment with ${widget.workerData['name']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Basic form fields will be added in next commits
          ],
        ),

        // Add to _BookWorkerScreenState class
Widget _buildTextField(TextEditingController controller, String label,
    {bool isDate = false, int maxLines = 1, TextInputType? keyboardType}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType ?? (isDate ? TextInputType.datetime : TextInputType.text),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    maxLines: maxLines,
    onTap: isDate
        ? () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (pickedDate != null) {
              controller.text = pickedDate.toIso8601String().split('T')[0];
            }
          }
        : null,
  );
}

// Update build method to include form fields
@override
Widget build(BuildContext context) {
  return Scaffold(
    // ... existing scaffold code ...
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... existing title code ...
          _buildTextField(_userNameController, "Your Name"),
          const SizedBox(height: 16),
          _buildTextField(_userPhoneController, "Your Phone Number", 
              keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _buildTextField(_titleController, "Title"),
          const SizedBox(height: 16),
          _buildTextField(_descriptionController, "Description", maxLines: 4),
          const SizedBox(height: 16),
          _buildTextField(_deadlineController, "Deadline (YYYY-MM-DD)", isDate: true),
          const SizedBox(height: 24),
          // Submit button will be added in next commit
        ],
      ),
    ),
  );
}
      ),
    );
  }
}

// Add these imports at the top
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Add to _BookWorkerScreenState class
final LatLng _initialCenter = LatLng(37.7749, -122.4194); // San Francisco by default
LatLng _selectedLocation = LatLng(37.7749, -122.4194);
final MapController _mapController = MapController();

void _handleTap(TapPosition tapPosition, LatLng point) {
  setState(() {
    _selectedLocation = point;
    _locationController.text = "${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}";
  });
}

// Add this widget to the build method's Column children
Container(
  height: 300,
  padding: const EdgeInsets.only(bottom: 8.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
        child: Text("Select Location", style: TextStyle(fontSize: 16)),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _initialCenter,
                  zoom: 13.0,
                  onTap: _handleTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    '© OpenStreetMap contributors',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

// Add location text field below the map
TextField(
  controller: _locationController,
  decoration: const InputDecoration(
    labelText: "Selected Location",
    border: OutlineInputBorder(),
    hintText: "Tap on the map to select a location",
  ),
  readOnly: true,
),


// Add to _BookWorkerScreenState class
Future<void> _submitBookingRequest() async {
  if (_titleController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _locationController.text.isEmpty ||
      _deadlineController.text.isEmpty ||
      _userNameController.text.isEmpty ||
      _userPhoneController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All fields are required!")),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  final Uri apiUrl = Uri.parse('http://10.0.2.2:5000/api/requests');
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${widget.userToken}',
  };

  final Map<String, dynamic> requestBody = {
    'workerId': widget.workerData['id'],
    'userName': _userNameController.text,
    'userPhone': _userPhoneController.text,
    'title': _titleController.text,
    'description': _descriptionController.text,
    'location': _locationController.text,
    'deadline': _deadlineController.text,
    'coordinates': {
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude
    },
  };

  try {
    final response = await http.post(
      apiUrl,
      headers: headers,
      body: json.encode(requestBody),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Work request sent successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      final errorData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: ${errorData['error']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
    );
  }

  setState(() {
    _isLoading = false;
  });
}

// Add submit button to build method
_isLoading
    ? const Center(child: CircularProgressIndicator())
    : ElevatedButton(
        onPressed: _submitBookingRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[700],
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text("Submit Booking Request",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
