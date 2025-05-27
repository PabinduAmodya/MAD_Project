import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  final LatLng _initialCenter = LatLng(37.7749, -122.4194);
  LatLng _selectedLocation = LatLng(37.7749, -122.4194);
  final MapController _mapController = MapController();

  void _handleTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _locationController.text =
          "${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}";
    });
  }

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
            _buildTextField(_userNameController, "Your Name"),
            const SizedBox(height: 16),
            _buildTextField(_userPhoneController, "Your Phone Number", keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField(_titleController, "Title"),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, "Description", maxLines: 4),
            const SizedBox(height: 16),
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
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Selected Location",
                border: OutlineInputBorder(),
                hintText: "Tap on the map to select a location",
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(_deadlineController, "Deadline (YYYY-MM-DD)", isDate: true),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isDate = false, int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? (isDate ? TextInputType.datetime : TextInputType.text),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
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
}
