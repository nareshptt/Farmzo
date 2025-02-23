import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Agro/HomeScreen.dart';
import '../Authentication/LoginScreen.dart';
import 'BottomNavigation.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ); // Show loading while checking auth status
        }

        if (snapshot.hasData && snapshot.data != null) {
          User? user = snapshot.data;

          // Check if the user is a shop owner
          return FutureBuilder<bool>(
            future: _checkIfUserIsShopOwner(
                user!.uid), // Check if the current user is a shop owner
            builder: (context, shopSnapshot) {
              if (shopSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (shopSnapshot.data == true) {
                return AgroHome(); // If the user is a shop owner, show AgroHome
              } else {
                return BottomNavigation(); // If not a shop owner, show BottomNavigation
              }
            },
          );
        } else {
          return LoginScreen(); // If no user is logged in, show LoginScreen
        }
      },
    );
  }

  // Function to check if the current user is a shop owner by comparing userUID
  Future<bool> _checkIfUserIsShopOwner(String userUID) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .where('userUID',
              isEqualTo:
                  userUID) // Ensure the shop document has a userUID field
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user is a shop owner: $e');
      return false;
    }
  }
}
