import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/database/local_db_helper.dart';
import '../../core/service/phone_prefs_service.dart';
import 'home_screen.dart';
import 'splash_screen.dart';
import 'otp_verification_screen.dart';
import 'onboarding_screen.dart';
import 'dashboard_screen.dart';

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
          return FutureBuilder<bool>(
            future: PhonePrefsService.isOtpVerified(),
            builder: (context, otpSnapshot) {
              if (otpSnapshot.connectionState == ConnectionState.waiting) {
                return _loadingScaffold();
              }

              final otpVerified = otpSnapshot.data ?? false;

              // OTP not yet completed → show OTP screen with saved phone
              if (!otpVerified) {
                return FutureBuilder<String?>(
                  future: PhonePrefsService.getPhone(),
                  builder: (context, phoneSnapshot) {
                    if (phoneSnapshot.connectionState == ConnectionState.waiting) {
                      return _loadingScaffold();
                    }
                    final phone = phoneSnapshot.data ?? '';
                    return OtpVerificationScreen(phoneNumber: phone);
                  },
                );
              }

              // OTP verified → check if onboarding is done
              return FutureBuilder(
                future: LocalDBHelper.instance.getUserMetrics(),
                builder: (context, dbSnapshot) {
                  if (dbSnapshot.connectionState == ConnectionState.waiting) {
                    return _loadingScaffold();
                  }
                  if (dbSnapshot.data != null) {
                    return const DashboardScreen();
                  } else {
                    return const OnboardingScreen();
                  }
                },
              );
            },
          );
        }

        // ── Not signed in ────────────────────────────────────────────────────
        return const SplashScreen();
      },
    );
  }

  Widget _loadingScaffold() {
    return const Scaffold(
      backgroundColor: Color(0xFF0A0518),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFBEFF5D))),
    );
  }
}
