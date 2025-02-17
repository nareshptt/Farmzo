import 'package:flutter/material.dart';

import '../Farmer/HomeScreen.dart';
import '../Farmer/NotificationScreen.dart';
import '../Farmer/ProfileScreen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentIndex = 0;

  late List<Widget> pages;
  late HomeScreen homepage;
  late ProfileScreen profile; // Initialize ProfileScreen type
  late NotificationScreen notifications; // Initialize NotificationScreen type

  @override
  void initState() {
    super.initState();

    // Initialize screens
    homepage = HomeScreen();
    profile = ProfileScreen(); // Initialize ProfileScreen
    notifications = NotificationScreen(); // Initialize NotificationScreen

    // Set up pages list with initialized screens
    pages = [homepage, notifications, profile];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'હોમ', // Home in Gujarati
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_rounded),
            label: 'સૂચનાઓ', // Notifications in Gujarati
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'પ્રોફાઇલ', // Profile in Gujarati
          ),
        ],
        currentIndex: currentIndex, // Highlight the selected tab
        selectedItemColor: Colors.blue[600],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        }, // Handle tab selection
      ),
    );
  }
}
