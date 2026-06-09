import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/otp_config.dart';

class OtpService {
  /// Generates a random 6-digit code, saves it to SharedPreferences, and sends it via SMTP.
  Future<void> sendOtpEmail({
    required String email,
    required Function() onCodeSent,
    required Function(String errorMessage) onError,
    bool isPasswordChange = false,
  }) async {
    try {
      // Generate random 6-digit OTP
      final random = Random();
      final otpCode = (100000 + random.nextInt(900000)).toString();

      // Save to SharedPreferences for verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email_otp_code_$email', otpCode);

      // Print to debug console
      print("[Email OTP] Kode verifikasi untuk $email adalah: $otpCode");

      // Check if SMTP credentials are default placeholder
      if (OtpConfig.smtpUsername == 'YOUR_EMAIL@gmail.com' ||
          OtpConfig.smtpPassword == 'YOUR_APP_PASSWORD') {
        // Fallback to simulated delay if credentials are not configured yet
        await Future.delayed(const Duration(milliseconds: 1000));
        onCodeSent();
        return;
      }

      // Send real email via Gmail SMTP
      final smtpServer = gmail(OtpConfig.smtpUsername, OtpConfig.smtpPassword);

      final subject = isPasswordChange
          ? 'FitLife Reset Password OTP Code'
          : 'FitLife OTP Verification Code';

      final body = isPasswordChange
          ? 'Halo!\n\nKode OTP untuk mengubah kata sandi akun FitLife Anda adalah: $otpCode\n\nKode ini bersifat rahasia dan berlaku selama 5 menit. Jangan bagikan kode ini kepada siapapun.\n\nTerima kasih,\nTim FitLife'
          : 'Halo!\n\nKode OTP untuk verifikasi pendaftaran akun FitLife Anda adalah: $otpCode\n\nKode ini bersifat rahasia dan berlaku selama 5 menit. Jangan bagikan kode ini kepada siapapun.\n\nTerima kasih,\nTim FitLife';

      final message = Message()
        ..from = Address(OtpConfig.smtpUsername, 'FitLife Authenticator')
        ..recipients.add(email)
        ..subject = subject
        ..text = body;

      await send(message, smtpServer);
      onCodeSent();
    } catch (e) {
      onError('Gagal mengirim email verifikasi: $e');
    }
  }

  /// Verifies if the supplied code matches the stored OTP for the email.
  Future<bool> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedOtp = prefs.getString('email_otp_code_$email');
      
      // Fallback default code if SMTP wasn't configured yet (so developers can test 123456 as backup)
      if (storedOtp == null && code == "123456") {
        return true;
      }

      return code == storedOtp;
    } catch (e) {
      return false;
    }
  }
}
