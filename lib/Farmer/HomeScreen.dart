import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedVillage = 'All'; // Default selection
  List<String> villages = [];
  List<Map<String, dynamic>> allShops = [];
  List<Map<String, dynamic>> filteredShops = [];

  @override
  void initState() {
    super.initState();
    _fetchShopData();
  }

  // Fetch shop data and village list
  Future<void> _fetchShopData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('shops').get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          allShops = [];
          filteredShops = [];
        });
        return;
      }

      List<Map<String, dynamic>> shops = snapshot.docs.map((doc) {
        return {
          'shopImage': doc['image'] ?? 'default_image_url',
          'shopName': doc['name'] ?? 'Unknown Shop',
          'villageName': doc['village'] ?? 'Unknown Village',
        };
      }).toList();

      // Extract village names for the dropdown
      Set villageSet = shops.map((shop) => shop['villageName']).toSet();
      villages = ['All', ...villageSet.toList()]; // Add 'All' option

      setState(() {
        allShops = shops;
        filteredShops = allShops; // Initially, show all shops
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        allShops = [];
        filteredShops = [];
      });
    }
  }

  // Filter shops based on selected village
  void _filterShops(String village) {
    setState(() {
      selectedVillage = village;
      if (village == 'All') {
        filteredShops = allShops;
      } else {
        filteredShops =
            allShops.where((shop) => shop['villageName'] == village).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.green,
          elevation: 5,
          title: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Farmzo',
              style: GoogleFonts.muktaVaani(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Village Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 4,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: selectedVillage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _filterShops(newValue);
                      }
                    },
                    isExpanded: true,
                    items: villages.map((String village) {
                      return DropdownMenuItem<String>(
                        value: village,
                        child: Text(
                          village,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    underline: Container(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),

              // Display Shop Data with Shimmer Effect
              filteredShops.isEmpty
                  ? _buildShimmerEffect()
                  : _buildShopList(filteredShops),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer effect for loading
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 5,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 4,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.white,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 18,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Building the shop list
  Widget _buildShopList(List<Map<String, dynamic>> shops) {
    return Column(
      children: shops.map((shop) {
        return shopCard(
          shop['shopImage'] as String,
          shop['shopName'] as String,
          shop['villageName'] as String,
        );
      }).toList(),
    );
  }

  // Shop card widget with enhanced UI
  Widget shopCard(String shopImage, String shopName, String villageName) {
    return GestureDetector(
      onTap: () {
        // Add navigation or additional action here
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 4,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18.0),
              child: CachedNetworkImage(
                imageUrl: shopImage,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) {
                  return Icon(
                    Icons.photo,
                    size: 100,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shopName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    villageName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
