import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

/// AuthGate
/// Manages user session state and routes to appropriate screen
/// Shows AuthScreen if not authenticated, HomeScreen if authenticated
/// 
/// Note: Data clearing is handled by AuthService before any sign-in/sign-up
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in, show home screen
          return const HomeScreen();
        } else {
          // User is not signed in, show auth screen
          return const AuthScreen();
        }
      },
    );
  }
}
