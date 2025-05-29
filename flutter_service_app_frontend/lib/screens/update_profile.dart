import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isUpdating = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  // User data
  String? workerId;
  String? authToken;
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _workTypeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
@override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      workerId = prefs.getString('user_id');
      authToken = prefs.getString('auth_token');
    });

    if (workerId == null || authToken == null) {
      _showError('User not authenticated');
      return;
    }

    try {
      // Fetch current worker data
      final response = await _dio.get(
        'http://10.0.2.2:5000/api/workers/$workerId',
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phoneNo'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _workTypeController.text = userData['workType'] ?? '';
          _experienceController.text = userData['yearsOfExperience']?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        _showError('Failed to load profile data');
      }
    } catch (e) {
      _showError('Error loading profile: ${e.toString()}');
    }
  }
    Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }
 Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      try {
        final updateData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phoneNo': _phoneController.text,
          'location': _locationController.text,
          'workType': _workTypeController.text,
          'yearsOfExperience': int.tryParse(_experienceController.text) ?? 0,
        };

        final response = await _dio.put(
          'http://10.0.2.2:5000/api/workers/$workerId',
          data: updateData,
          options: Options(headers: {'Authorization': 'Bearer $authToken'}),
        );

        if (response.statusCode == 200) {
          // Update successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Update local storage if needed
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', _nameController.text);
          
          // Return to previous screen with success
          Navigator.pop(context, true);
        } else {
          _showError('Failed to update profile');
        }
      } catch (e) {
        _showError('Error updating profile: ${e.toString()}');
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.yellow[700],
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool multiline = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: multiline ? 4 : 1,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.yellow[700]),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.yellow[700]!.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.yellow[700]!),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
@override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _workTypeController.dispose();
    _experienceController.dispose();
    super.dispose();
  }
}
