import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/database/local_db_helper.dart';
import '../../core/service/otp_prefs_service.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';
import 'otp_verification_screen.dart';
import '../../core/service/firebase_sync_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── Loading ──────────────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingScaffold();
        }

        // ── Signed in ────────────────────────────────────────────────────────
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          final isEmailUser = user.providerData.any((info) => info.providerId == 'password');
          
          if (isEmailUser) {
            return FutureBuilder<bool>(
              future: OtpPrefsService.isOtpVerified(),
              builder: (context, otpSnapshot) {
                if (otpSnapshot.connectionState == ConnectionState.waiting) {
                  return _loadingScaffold();
                }
                final isVerified = otpSnapshot.data ?? false;
                if (!isVerified) {
                  return OtpVerificationScreen(email: user.email ?? '');
                }
                
                return _buildDbMetricsCheck();
              },
            );
          }

          return _buildDbMetricsCheck();
        }

        // ── Not signed in ────────────────────────────────────────────────────
        return const SplashScreen();
      },
    );
  }

  Widget _buildDbMetricsCheck() {
    return FutureBuilder<bool>(
      future: _checkAndRestoreData(),
      builder: (context, dbSnapshot) {
        if (dbSnapshot.connectionState == ConnectionState.waiting) {
          return _loadingScaffold();
        }
        if (dbSnapshot.data == true) {
          return const MainScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }

  Future<bool> _checkAndRestoreData() async {
    final localUser = await LocalDBHelper.instance.getUserMetrics();
    if (localUser != null && localUser.tinggiBadan != null) {
      return true;
    }
    // Attempt to restore from Firestore
    return await FirebaseSyncService.instance.restoreUserData();
  }

  Widget _loadingScaffold() {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0518),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFBEFF5D))),
    );
  }
}
