import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import '/main.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Add this print statement
        print('Auth State: ${snapshot.hasData ? 'Logged In' : 'Logged Out'}');
        if (snapshot.hasData) {
          print('User ID: ${snapshot.data?.uid}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const MainScreen();  // Make sure this is MainScreen, not HomePage
        }

        return const LoginPage();
      },
    );
  }
}