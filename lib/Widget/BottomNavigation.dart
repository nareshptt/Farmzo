import 'package:farmzo/Widget/theme.dart';
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
  late ProfileScreen profile;
  late NotificationScreen notifications;

  @override
  void initState() {
    super.initState();

    // Initialize screens
    homepage = HomeScreen();
    profile = ProfileScreen();
    notifications = NotificationScreen();

    // Set up pages list with initialized screens
    pages = [homepage, notifications, profile];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  0.05), // Using the same shadow opacity as in AppTheme
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            backgroundColor:
                AppTheme.cardColor, // Using cardColor from AppTheme
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications_active_rounded),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: currentIndex,
            selectedItemColor:
                AppTheme.primaryColor, // Using primaryColor from AppTheme
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: AppTheme.captionStyle.copyWith(
              // Using captionStyle from AppTheme with modifications
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme
                  .primaryColor, // Ensuring selected text is primary color
            ),
            unselectedLabelStyle: AppTheme.captionStyle.copyWith(
              // Using captionStyle from AppTheme with modifications
              fontWeight: FontWeight.normal,
              fontSize: 10,
            ),
            showUnselectedLabels: true,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
