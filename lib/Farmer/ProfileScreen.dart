import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Agro/ShopData.dart';
import '../Authentication/LoginScreen.dart';
import '../Widget/theme.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isShopOwner = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  void _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() => _user = user);

        // Check if user is a shop owner
        if (user.email != null) {
          final query = await FirebaseFirestore.instance
              .collection('shops')
              .where('email', isEqualTo: user.email)
              .get();

          setState(() => _isShopOwner = query.docs.isNotEmpty);
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Logout', style: AppTheme.titleStyle),
            content: Text('Are you sure you want to logout?',
                style: AppTheme.bodyStyle),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Logout',
                    style: TextStyle(color: AppTheme.errorColor)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_user != null)
            IconButton(
              icon: Icon(Icons.refresh, color: AppTheme.primaryColor),
              onPressed: _fetchUserData,
              tooltip: 'Refresh profile',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _user == null
              ? _buildNotLoggedInView()
              : _buildProfileView(),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Not logged in',
            style: AppTheme.titleStyle,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            ),
            style: AppTheme.primaryButtonStyle,
            icon: const Icon(Icons.login),
            label: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Profile Header
          _buildProfileHeader(),
          const SizedBox(height: 32),

          // Shop Status Card
          _buildShopStatusCard(),
          const SizedBox(height: 32),

          // Settings List
          _buildSettingsList(),

          const SizedBox(height: 40),

          // App Version
          _buildAppVersionFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Hero(
          tag: 'profile-avatar',
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryLightColor,
            backgroundImage: _user?.photoURL != null
                ? NetworkImage(_user!.photoURL!)
                : const AssetImage("assets/default_profile.png")
                    as ImageProvider,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _user?.displayName ?? "User",
          style: AppTheme.titleStyle.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _user?.email ?? "",
          style: AppTheme.captionStyle.copyWith(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildShopStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryLightColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isShopOwner ? Icons.store : Icons.person,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isShopOwner ? 'Shop Owner' : 'Customer',
                style: AppTheme.subtitleStyle.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isShopOwner
                ? 'Manage your shop details and inventory'
                : 'Register your shop to start selling on Farmzo',
            style: AppTheme.bodyStyle,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddShopdata(shopId: '')),
              ),
              style: AppTheme.primaryButtonStyle.copyWith(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              icon: Icon(_isShopOwner ? Icons.edit : Icons.add_business),
              label: Text(_isShopOwner ? 'Manage Shop' : 'Register Shop'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            Icons.help_outline,
            'Help & Support',
            'Get assistance with the app',
            () {},
          ),
          _divider(),
          _buildSettingItem(
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'Read our privacy policy',
            () {},
          ),
          _divider(),
          _buildSettingItem(
            Icons.info_outline,
            'About Farmzo',
            'Learn more about our mission',
            () {},
          ),
          _divider(),
          _buildSettingItem(
            Icons.logout,
            'Logout',
            'Sign out from your account',
            _logout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      IconData icon, String title, String subtitle, VoidCallback onTap,
      {bool isLogout = false}) {
    final Color iconColor =
        isLogout ? AppTheme.errorColor : AppTheme.primaryColor;
    final Color textColor = isLogout ? AppTheme.errorColor : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.captionStyle.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppVersionFooter() {
    return Column(
      children: [
        Text(
          'Farmzo v1.0.0',
          style: AppTheme.captionStyle.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Growing agriculture, digitally',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 0.5, indent: 60);
  }
}
