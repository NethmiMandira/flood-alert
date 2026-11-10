import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

// Decides which screen to show based on the login state.
// It listens to the auth stream, so login, register and logout
// switch screens automatically.
class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authChanges,
      builder: (context, snapshot) {
        // Waiting for Firebase to restore the saved session
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged in -> Home, otherwise -> Login
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}