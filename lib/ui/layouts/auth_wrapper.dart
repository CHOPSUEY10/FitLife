import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/database/local_db_helper.dart';
import 'home_screen.dart'; // Placeholder for DashboardScreen
import 'splash_screen.dart';
import 'email_verification_screen.dart';
import 'onboarding_screen.dart';
import 'dashboard_screen.dart'; // Use the real DashboardScreen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0518),
            body: Center(child: CircularProgressIndicator(color: Color(0xFFBEFF5D))),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          
          // Force verification if they signed up with email/password
          // Google Sign-In automatically verifies emails, so it will pass this.
          if (!user.emailVerified) {
            return const EmailVerificationScreen();
          }

          // Email is verified, check if they completed onboarding
          return FutureBuilder(
            future: LocalDBHelper.instance.getUserMetrics(),
            builder: (context, dbSnapshot) {
              if (dbSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF0A0518),
                  body: Center(child: CircularProgressIndicator(color: Color(0xFFBEFF5D))),
                );
              }
              if (dbSnapshot.data != null) {
                // Completed onboarding
                return const DashboardScreen();
              } else {
                // Needs onboarding
                return const OnboardingScreen();
              }
            },
          );
        }

        // Not logged in, route to Splash/Login
        return const SplashScreen();
      },
    );
  }
}
