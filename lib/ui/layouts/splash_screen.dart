import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../core/database/local_db_helper.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkRouting();
  }

  void _checkRouting() async {
    // Wait for the splash screen duration
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      // AuthWrapper handles the authenticated state and onboarding checks.
      // If we are seeing the SplashScreen, the user is NOT authenticated.
      // Therefore, always route them to LoginScreen to begin.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0518),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using fitlife.png as the icon
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                'assets/icon/fitlife.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'FitLife',
              style: GoogleFonts.coda(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

