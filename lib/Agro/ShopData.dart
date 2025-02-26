import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmzo/Agro/HomeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddShopdata extends StatefulWidget {
  const AddShopdata({super.key, required String shopId});

  @override
  State<AddShopdata> createState() => _AddShopdataState();
}

class _AddShopdataState extends State<AddShopdata> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedVillage;
  XFile? _image;
  bool _isUploading = false;
  bool _isLoading = true;
  List<String> _villageNames = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchVillages();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchVillages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Villages').get();
      setState(() {
        _villageNames =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
        _villageNames.sort(); // Sort villages alphabetically
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching village names: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading villages. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isDenied || status.isRestricted) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Permission Required'),
              content: Text(
                  'You need to allow photo access to select an image for your shop.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Open Settings'),
                ),
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            );
          },
        );
      }
    }
  }

  Future<void> _pickImage() async {
    await _checkAndRequestPermissions();
    if (await Permission.photos.isGranted) {
      final ImagePicker picker = ImagePicker();

      // Show action sheet for camera or gallery
      if (mounted) {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Image Source',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImageSourceOption(
                          icon: Icons.camera_alt,
                          title: 'Camera',
                          onTap: () async {
                            Navigator.pop(context);
                            final XFile? photo = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                            );
                            if (photo != null && mounted) {
                              setState(() {
                                _image = photo;
                              });
                            }
                          },
                        ),
                        _buildImageSourceOption(
                          icon: Icons.photo_library,
                          title: 'Gallery',
                          onTap: () async {
                            Navigator.pop(context);
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                            );
                            if (image != null && mounted) {
                              setState(() {
                                _image = image;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.green,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _uploadImage() async {
    if (_image == null) return '';
    setState(() {
      _isUploading = true;
    });

    try {
      File imageFile = File(_image!.path);
      final fileName = 'shop_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef =
          FirebaseStorage.instance.ref().child('shop_images/$fileName');

      // Upload with progress tracking
      final uploadTask = storageRef.putFile(imageFile);

      // Get download URL after upload completes
      await uploadTask;
      String downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return '';
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _saveShopData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a shop image'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      // Upload the image and get the URL
      String imageUrl = await _uploadImage();
      if (imageUrl.isEmpty) return; // Upload failed

      // Get the current user's UID and Email
      String? userUID = FirebaseAuth.instance.currentUser?.uid;
      String? userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userUID == null || userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to save your shop data'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Save the data to Firestore
      await FirebaseFirestore.instance.collection('shops').add({
        'name': _nameController.text.trim(),
        'village': _selectedVillage,
        'phone': _phoneController.text.trim(),
        'image': imageUrl,
        'createdAt': Timestamp.now(),
        'userUID': userUID,
        'userEmail': userEmail,
        'fertilizerStatus': 'Available', // Default status
      });

      // Show a success message and navigate
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shop registered successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Navigate after a short delay to show the success message
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AgroHome()),
            );
          }
        });
      }
    } catch (e) {
      print('Error saving shop data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save shop data. Please try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: Text(
          'Shop Registration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildShopImagePicker(),
                    SizedBox(height: 24),
                    _buildInfoCard(),
                    SizedBox(height: 30),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildShopImagePicker() {
    return Column(
      children: [
        Text(
          'Shop Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: _image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 50,
                        color: Colors.green[700],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add Photo',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(_image!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shop Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 20),

            // Shop Name Field
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _buildInputDecoration(
                labelText: 'Shop Name',
                hintText: 'Enter your shop name',
                prefixIcon: Icons.store,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter shop name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Village Dropdown
            DropdownButtonFormField<String>(
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
              decoration: _buildInputDecoration(
                labelText: 'Village',
                hintText: 'Select village',
                prefixIcon: Icons.location_on,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a village';
                }
                return null;
              },
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.green),
            ),
            SizedBox(height: 16),

            // Phone Number Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter contact number',
                prefixIcon: Icons.phone,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter phone number';
                }
                // Simple phone validation - can be enhanced
                if (value.trim().length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: Colors.green),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _saveShopData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        child: _isUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Uploading...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Register Shop',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
