import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AgroHome extends StatefulWidget {
  const AgroHome({super.key});

  @override
  State<AgroHome> createState() => _AgroHomeState();
}

class _AgroHomeState extends State<AgroHome> {
  Map<String, dynamic>? shopData;
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchShopData();
  }

  // Fetch shop data from Firestore based on the current user's UID
  Future<void> _fetchShopData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('shops')
            .where('userUID', isEqualTo: user.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            shopData = querySnapshot.docs.first.data();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            shopData = null; // No shop found for the user
          });
        }
      }
    } catch (e) {
      print('Error fetching shop data: $e');
      setState(() {
        _isLoading = false;
        shopData = null;
      });
    }
  }

  // Handle tab changes in the BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Handle user logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut(); // Log the user out
    Navigator.pushReplacementNamed(
        context, '/login'); // Navigate to login screen
  }

  // Home tab UI (Shop Details)
  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : shopData == null
              ? Center(
                  child: Text("No shop found for this user",
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop Name
                      Text(
                        "${shopData?['name'] ?? 'N/A'}",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      SizedBox(height: 15),

                      // Shop Image (if available)
                      shopData?['image'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                shopData?['image'],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                  child: Text("No Image Available",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54))),
                            ),
                      SizedBox(height: 20),

                      // Shop Location
                      Text("Location: ${shopData?['village'] ?? 'N/A'}",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[700])),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  // Orders tab UI (Placeholder for now)
  Widget _buildOrdersTab() {
    return Center(
      child: Text("Orders Page",
          style: TextStyle(fontSize: 24, color: Colors.black87)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false, // This removes the back button
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Shop Details", style: TextStyle(fontSize: 24)),
          ],
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildOrdersTab()
          : _buildHomeTab(), // Display Home tab on the right side
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Shop',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 5,
      ),
    );
  }
}
