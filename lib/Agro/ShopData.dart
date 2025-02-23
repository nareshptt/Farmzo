import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmzo/Agro/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // Import to use File

class AddShopdata extends StatefulWidget {
  const AddShopdata({super.key, required String shopId});

  @override
  State<AddShopdata> createState() => _AddShopdataState();
}

class _AddShopdataState extends State<AddShopdata> {
  final _nameController = TextEditingController();
  String? _selectedVillage;
  XFile? _image;
  bool _isUploading = false;
  List<String> _villageNames = []; // List to store village names

  @override
  void initState() {
    super.initState();
    _fetchVillages(); // Fetch villages when the screen is initialized
  }

  // Fetch village names from Firestore
  Future<void> _fetchVillages() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Villages').get();
      setState(() {
        _villageNames =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching village names: $e');
    }
  }

  // Check and request photo permissions
  Future<void> _checkAndRequestPermissions() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isDenied || status.isRestricted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('You need to allow photo access to select an image.'),
      ));
    }
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    await _checkAndRequestPermissions();
    if (await Permission.photos.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage;
        });
      }
    }
  }

  // Upload image to Firebase Storage and get the download URL
  Future<String> _uploadImage() async {
    if (_image == null) return '';
    setState(() {
      _isUploading = true;
    });

    // Convert the picked image to a File object
    File imageFile = File(_image!.path);

    // Create a reference to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('shop_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the image
    await storageRef.putFile(imageFile);

    // Get the download URL
    String downloadURL = await storageRef.getDownloadURL();
    setState(() {
      _isUploading = false;
    });
    return downloadURL;
  }

  // Save the shop data to Firestore
  Future<void> _saveShopData() async {
    if (_nameController.text.isEmpty ||
        _selectedVillage == null ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and select an image.'),
      ));
      return;
    }

    // Upload the image and get the URL
    String imageUrl = await _uploadImage();

    // Get the current user's UID and Email
    String? userUID = FirebaseAuth.instance.currentUser?.uid;
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userUID == null || userEmail == null) {
      // If either UID or email is null, that means the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please log in to save your shop data.'),
      ));
      return;
    }

    // Save the data to Firestore
    await FirebaseFirestore.instance.collection('shops').add({
      'name': _nameController.text,
      'village': _selectedVillage, // Village name from dropdown
      'image': imageUrl,
      'createdAt': Timestamp.now(),
      'userUID': userUID, // Current user's UID
      'userEmail': userEmail, // Current user's Email
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Shop data saved successfully!'),
    ));

    // Clear the fields
    _nameController.clear();
    setState(() {
      _image = null;
      _selectedVillage = null;
    });

    // Navigate to AgroHome and prevent going back
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AgroHome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery for better responsiveness
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Shop Data'),
        backgroundColor: Colors.green, // Green color for the app bar
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Shop Name Input
            _buildTextField(
              controller: _nameController,
              labelText: 'Shop Name',
              hintText: 'Enter the shop name',
              width: screenWidth,
            ),
            const SizedBox(height: 16),

            // Village Name Dropdown
            _buildDropdownField(width: screenWidth),

            const SizedBox(height: 16),

            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: _buildImagePicker(screenWidth),
            ),

            const SizedBox(height: 20),

            // Upload Button
            _buildUploadButton(screenWidth),
          ],
        ),
      ),
    );
  }

  // TextField with Custom Styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required double width,
  }) {
    return Container(
      width: width * 0.9, // Responsive width
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  // Village Dropdown with Custom Styling
  Widget _buildDropdownField({required double width}) {
    return Container(
      width: width * 0.9, // Responsive width
      child: DropdownButtonFormField<String>(
        value: _selectedVillage,
        items: _villageNames.map((village) {
          return DropdownMenuItem<String>(
            value: village,
            child: Text(village),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedVillage = newValue;
          });
        },
        decoration: InputDecoration(
          labelText: 'Select Village',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        isExpanded: true,
      ),
    );
  }

  // Image Picker Section with Responsive Layout
  Widget _buildImagePicker(double width) {
    return Container(
      width: width * 0.50, // Responsive width
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: _image == null
          ? Center(
              child: Icon(
                Icons.camera_alt,
                color: Colors.grey[700],
                size: 40,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                File(_image!.path),
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  // Upload Button with Custom Styling
  Widget _buildUploadButton(double width) {
    return Container(
      width: width * 0.9, // Responsive width
      child: ElevatedButton(
        onPressed: _isUploading ? null : _saveShopData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, // Button color
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isUploading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                'Save Shop Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
