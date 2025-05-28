import 'package:flutter/material.dart';

class AllServicesScreen extends StatelessWidget {
    const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> services = [
      {"icon": Icons.plumbing, "title": "Plumber"},
      {"icon": Icons.electrical_services, "title": "Electrician"},
      {"icon": Icons.carpenter, "title": "Carpenter"},
      {"icon": Icons.car_repair, "title": "Mechanic"},     
      {"icon": Icons.brush, "title": "Painter"},
      {"icon": Icons.home_repair_service, "title": "Mason"},
      {"icon": Icons.build_circle, "title": "Welder"},
      {"icon": Icons.cleaning_services, "title": "Cleaner"}
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("All Services", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.yellow[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 columns
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            return _buildServiceTile(
              context, 
              services[index]["icon"], 
              services[index]["title"]
            );
          },
        ),
      ),
    );
  }
}