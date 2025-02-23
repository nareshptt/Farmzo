import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Agro/ShopData.dart';
import '../Authentication/LoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isShopOwner = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
      });
      await _checkIfUserIsShopOwner(user.email);
    }
  }

  Future<void> _checkIfUserIsShopOwner(String? email) async {
    if (email != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _isShopOwner = true;
        });
      }
    }
  }

  Future<void> _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen())); // Navigate to LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00A86B), Color(0xFF007F5F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _user == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    _buildProfileHeader(screenWidth),
                    const SizedBox(height: 20),
                    Expanded(child: _buildProfileOptions()),
                  ],
                ),
        ),
      ),
    );
  }

  // Enhanced Profile Header
  Widget _buildProfileHeader(double screenWidth) {
    return Center(
      child: Column(
        children: [
          // Profile Picture with Gradient Border
          CircleAvatar(
            radius: screenWidth * 0.2, // Responsive size
            backgroundImage: _user?.photoURL != null
                ? NetworkImage(_user!.photoURL!)
                : AssetImage("assets/default_profile.png") as ImageProvider,
            backgroundColor: Colors.green[200],
          ),
          const SizedBox(height: 10),
          // User Name with larger font and bold style
          Text(
            _user?.displayName ?? "વપરાશકર્તા",
            style: TextStyle(
              fontSize: screenWidth * 0.06, // Responsive text size
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          if (_user?.phoneNumber != null)
            Text(
              _user!.phoneNumber!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  // Profile options with ListTiles
  Widget _buildProfileOptions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildOptionTile(Icons.help_outline, "સહાય અને સપોર્ટ", () {}),
        // Conditionally render "Order" or "Your Shop" based on if the user is a shop owner
        _buildOptionTile(
          _isShopOwner ? Icons.store : Icons.shopping_cart,
          _isShopOwner ? "તમારો દુકાન" : "તમારા ઓર્ડર્સ",
          () {
            if (_isShopOwner) {
              // Navigate to ShopScreen when the user is a shop owner
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddShopdata(shopId: '')));
            } else {
              // Navigate to Orders
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddShopdata(shopId: '')));
            }
          },
        ),
        _buildOptionTile(
          Icons.logout,
          "લૉગઆઉટ",
          _logout,
          isLogout: true, // Customization for logout
        ),
      ],
    );
  }

  // Build each profile option
  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap,
      {bool isLogout = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: isLogout ? Colors.redAccent : Colors.white, // Highlight logout
      child: ListTile(
        leading:
            Icon(icon, color: isLogout ? Colors.white : Colors.green, size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500, // Bold font weight for title
            color: isLogout ? Colors.white : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
