import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpPrefsService {
  static const String _otpVerifiedKey = 'is_email_otp_verified';
  static const String _pendingEmailKey = 'pending_verification_email';

  /// Sets the OTP verification status for the current active user email.
  static Future<void> setOtpVerified(bool verified) async {
    final prefs = await SharedPreferences.getInstance();
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    await prefs.setBool('${_otpVerifiedKey}_$email', verified);
  }

  /// Checks if the current active user email has verified their OTP.
  static Future<bool> isOtpVerified() async {
    final prefs = await SharedPreferences.getInstance();
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    if (email.isEmpty) return false;
    return prefs.getBool('${_otpVerifiedKey}_$email') ?? false;
  }

  static Future<void> savePendingEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEmailKey, email);
  }

  static Future<String?> getPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingEmailKey);
  }

  /// Clears the verification status and pending email for the active email.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    await prefs.remove('${_otpVerifiedKey}_$email');
    await prefs.remove(_pendingEmailKey);
  }
}
