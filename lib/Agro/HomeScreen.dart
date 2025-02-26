import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AgroHome extends StatefulWidget {
  const AgroHome({super.key});

  @override
  State<AgroHome> createState() => _AgroHomeState();
}

class _AgroHomeState extends State<AgroHome> {
  Map<String, dynamic>? shopData;
  bool _isLoading = true;
  int _selectedIndex = 0;
  String fertilizerStatus = 'Available';

  @override
  void initState() {
    super.initState();
    _fetchShopData();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
    ));
  }

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
            fertilizerStatus = shopData?['fertilizerStatus'] ?? 'Available';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            shopData = null;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFertilizerStatusCard() {
    final isAvailable = fertilizerStatus == 'Available';
    final statusColor = isAvailable ? Colors.green : Colors.red;
    final lightStatusColor = isAvailable ? Colors.green[50] : Colors.red[50];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              lightStatusColor ?? Colors.white,
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isAvailable ? Icons.check_circle : Icons.cancel,
                    color: statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Fertilizer Availability",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 2),
                  color: lightStatusColor,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: fertilizerStatus,
                      items: <String>['Available', 'Out of Stock']
                          .map<DropdownMenuItem<String>>((String value) {
                        final isSelected = value == fertilizerStatus;
                        final itemColor = value == 'Available'
                            ? Colors.green[800]
                            : Colors.red[800];
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(
                                value == 'Available'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: itemColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: itemColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue == fertilizerStatus) return;

                        setState(() {
                          fertilizerStatus = newValue!;
                        });

                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          try {
                            final querySnapshot = await FirebaseFirestore
                                .instance
                                .collection('shops')
                                .where('userUID', isEqualTo: user.uid)
                                .get();

                            if (querySnapshot.docs.isNotEmpty) {
                              String shopId = querySnapshot.docs.first.id;
                              await FirebaseFirestore.instance
                                  .collection('shops')
                                  .doc(shopId)
                                  .update({
                                'fertilizerStatus': fertilizerStatus,
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Fertilizer status updated to $fertilizerStatus'),
                                  backgroundColor: statusColor,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            print("Error updating fertilizer status: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Failed to update status. Please try again.'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      style: TextStyle(color: statusColor),
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: statusColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: Colors.green[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  "Shop Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  "${shopData?['village'] ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (shopData?['phone'] != null) ...[
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "${shopData?['phone']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : shopData == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_rounded,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      "No shop found",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Please contact administrator",
                      style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    floating: false,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        "${shopData?['name'] ?? 'My Shop'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                      background: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ).createShader(
                              Rect.fromLTRB(0, 0, rect.width, rect.height));
                        },
                        blendMode: BlendMode.darken,
                        child: shopData?['image'] != null
                            ? Image.network(
                                shopData?['image'],
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.green[100],
                                child: Icon(
                                  Icons.store,
                                  size: 80,
                                  color: Colors.green[300],
                                ),
                              ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _logout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShopInfoCard(),
                          _buildFertilizerStatusCard(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
  }

  Widget _buildOrdersTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text(
            "Orders",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          floating: true,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.green),
              onPressed: () {
                // Refresh orders functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Refreshing orders...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        // Placeholder for empty orders
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "No orders yet",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Orders will appear here",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false, // Allow content to extend behind the status bar
        child: _selectedIndex == 0 ? _buildOrdersTab() : _buildHomeTab(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.store),
                label: 'Shop',
              ),
            ],
            selectedItemColor: Colors.green[700],
            unselectedItemColor: Colors.grey[500],
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
