// Lokasi: lib/core/service/phone_prefs_service.dart
// Persists the user's phone number and OTP verification status locally.

import 'package:shared_preferences/shared_preferences.dart';

class PhonePrefsService {
  static const _phoneKey = 'pending_verification_phone';
  static const _otpVerifiedKey = 'is_otp_verified';

  // ─── Phone Number ───────────────────────────────────────────────────────────

  /// Save the phone number before navigating to OTP screen.
  static Future<void> savePhone(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, phoneNumber);
  }

  /// Read the stored phone number (returns null if not set).
  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  /// Clear the phone number once verification is complete.
  static Future<void> clearPhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_phoneKey);
  }

  // ─── OTP Verification Status ────────────────────────────────────────────────

  /// Mark OTP as successfully verified.
  static Future<void> setOtpVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_otpVerifiedKey, true);
  }

  /// Returns true if the user has completed OTP verification.
  static Future<bool> isOtpVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_otpVerifiedKey) ?? false;
  }

  /// Clear verification status (e.g. on sign-out).
  static Future<void> clearOtpVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_otpVerifiedKey);
  }

  /// Clear all prefs (call on sign-out).
  static Future<void> clearAll() async {
    await clearPhone();
    await clearOtpVerified();
  }
}

