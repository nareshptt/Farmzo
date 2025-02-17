import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          return BottomNavigation(); // User is logged in → Show Home
        } else {
          return LoginScreen(); // User not logged in → Show Login
        }
      },
    );
  }
}
