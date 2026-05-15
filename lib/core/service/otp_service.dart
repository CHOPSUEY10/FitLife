// Lokasi: lib/core/service/otp_service.dart
//
// Set kProductionMode = true when you are ready to use real Firebase SMS.
// Requires Firebase Blaze plan (billing enabled).
// For development, keep it false — OTP is always "123456".

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

const bool kProductionMode = false;
const String _mockOtpCode = "123456";

class OtpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sends an OTP to the provided phone number.
  /// In mock mode: simulates a 1.5s delay and triggers [onCodeSent] immediately.
  /// In production mode: calls Firebase Phone Auth via real SMS.
  Future<void> sendOtpPhone({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    if (!kProductionMode) {
      // --- MOCK MODE ---
      await Future.delayed(const Duration(milliseconds: 1500));
      // Use a constant mock verificationId
      onCodeSent('mock_verification_id');
      return;
    }

    // --- PRODUCTION MODE (Firebase SMS) ---
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution on Android — no action needed here
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed.');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Verifies the OTP code.
  /// In mock mode: accepts only "123456".
  /// In production mode: validates against Firebase using [verificationId].
  Future<bool> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    if (!kProductionMode) {
      // --- MOCK MODE ---
      await Future.delayed(const Duration(milliseconds: 1000));
      return smsCode == _mockOtpCode;
    }

    // --- PRODUCTION MODE (Firebase SMS) ---
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }
}

