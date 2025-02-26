import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../Widget/theme.dart';
import 'ShopDetailScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedVillage = 'All'; // Default selection
  List<String> villages = [];
  List<Map<String, dynamic>> allShops = [];
  List<Map<String, dynamic>> filteredShops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopData();
  }

  Future<void> _fetchShopData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('shops').get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          allShops = [];
          filteredShops = [];
          isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> shops = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'shopImage': doc['image'] ?? 'default_image_url',
          'shopName': doc['name'] ?? 'Unknown Shop',
          'villageName': doc['village'] ?? 'Unknown Village',
          'fertilizerStatus': doc['fertilizerStatus'] ?? 'Unknown',
        };
      }).toList();

      Set<String> villageSet =
          shops.map((shop) => shop['villageName'] as String).toSet();
      List<String> sortedVillages = villageSet.toList()..sort();
      villages = ['All', ...sortedVillages];

      setState(() {
        allShops = shops;
        filteredShops = allShops;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        allShops = [];
        filteredShops = [];
        isLoading = false;
      });
    }
  }

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchShopData,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildVillageFilter(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shops (${filteredShops.length})',
                      style: AppTheme.titleStyle,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            isLoading
                ? SliverToBoxAdapter(child: _buildShimmerEffect())
                : filteredShops.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmptyState(),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final shop = filteredShops[index];
                            return _buildShopCard(
                              shop['id'] as String,
                              shop['shopImage'] as String,
                              shop['shopName'] as String,
                              shop['villageName'] as String,
                              shop['fertilizerStatus'] as String,
                            );
                          },
                          childCount: filteredShops.length,
                        ),
                      ),
            SliverPadding(padding: const EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            'Farmzo',
            style: AppTheme.headingStyle,
          ),
        ],
      ),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // Add notification action
          },
        ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDarkColor, AppTheme.primaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
    );
  }

  Widget _buildVillageFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_searching,
                color: AppTheme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Filter by Location',
                style: AppTheme.subtitleStyle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
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
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: village == selectedVillage
                            ? AppTheme.primaryColor
                            : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppTheme.primaryColor),
                style: const TextStyle(fontSize: 16, color: Colors.black),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: AppTheme.primaryLightColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(
              Icons.store_outlined,
              size: 70,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'No shops found',
            style: AppTheme.titleStyle,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              selectedVillage == 'All'
                  ? 'There are no shops available at the moment'
                  : 'No shops found in $selectedVillage',
              style: AppTheme.captionStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _fetchShopData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
            style: AppTheme.primaryButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 250,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopCard(String shopId, String shopImage, String shopName,
      String villageName, String fertilizerStatus) {
    final bool isFertilizerAvailable = fertilizerStatus == 'Available';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: AppTheme.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Add navigation to shop details
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ShopDetailScreen(shopId: shopId)));
            },
            splashColor: AppTheme.primaryColor.withOpacity(0.1),
            highlightColor: AppTheme.primaryColor.withOpacity(0.05),
            child: Column(
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'shop-$shopId',
                      child: CachedNetworkImage(
                        imageUrl: shopImage,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            color: AppTheme.cardColor,
                            width: double.infinity,
                            height: 180,
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Container(
                            width: double.infinity,
                            height: 180,
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.storefront,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No Image',
                                    style: AppTheme.captionStyle,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFertilizerAvailable
                              ? AppTheme.primaryColor
                              : AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isFertilizerAvailable
                                  ? AppTheme.primaryColor.withOpacity(0.3)
                                  : AppTheme.errorColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFertilizerAvailable
                                  ? Icons.check_circle_outline
                                  : Icons.do_not_disturb,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              fertilizerStatus,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              villageName,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shopName,
                              style: AppTheme.titleStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.5',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(120 reviews)',
                                  style: AppTheme.captionStyle,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderScreen(
                                shopId: shopId,
                                shopName: shopName,
                              ),
                            ),
                          );
                        },
                        style: AppTheme.primaryButtonStyle,
                        child: const Text('Buy now'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
