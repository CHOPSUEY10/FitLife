import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'failures.dart';

class ErrorInterpreter {
  static const Map<String, String> _firebaseAuthMessages = {
    'user-not-found': "Akun tidak ditemukan. Silakan periksa kembali email Anda.",
    'wrong-password': "Password yang Anda masukkan salah. Silakan coba lagi.",
    'invalid-email': "Format email tidak valid. Pastikan Anda memasukkan email yang benar.",
    'user-disabled': "Akun ini telah dinonaktifkan. Silakan hubungi tim dukungan.",
    'email-already-in-use': "Email ini sudah terdaftar. Silakan gunakan email lain atau langsung masuk.",
    'weak-password': "Password terlalu lemah. Gunakan minimal 6 karakter.",
    'invalid-credential': "Email atau password yang Anda masukkan tidak valid.",
    'network-request-failed': "Koneksi internet bermasalah. Pastikan Anda terhubung ke internet.",
    'too-many-requests': "Terlalu banyak percobaan yang gagal. Silakan coba lagi nanti.",
  };

  static const Map<String, String> _commonErrorKeywords = {
    'user-not-found': "Akun tidak ditemukan. Silakan periksa kembali email Anda.",
    'login-error': "Password yang Anda masukkan salah. Silakan coba lagi.",
    'invalid-email': "Format email tidak valid. Pastikan Anda memasukkan email yang benar.",
    'user-disabled': "Akun ini telah dinonaktifkan. Silakan hubungi tim dukungan.",
    'email-already-in-use': "Email ini sudah terdaftar. Silakan gunakan email lain atau langsung masuk.",
    'weak-password': "Password terlalu lemah. Gunakan minimal 6 karakter.",
    'invalid-credential': "Email atau password yang Anda masukkan tidak valid.",
    'network-request-failed': "Koneksi internet bermasalah. Pastikan Anda terhubung ke internet yang stabil.",
    'socketexception': "Koneksi internet bermasalah. Pastikan Anda terhubung ke internet yang stabil.",
    'too-many-requests': "Terlalu banyak percobaan yang gagal. Silakan coba lagi nanti.",
    'timeout': "Waktu koneksi habis. Silakan periksa internet Anda dan coba lagi.",
    'otp': "Kode OTP tidak valid atau sudah kedaluwarsa.",
  };

  /// Mengubah objek exception atau error kotor menjadi pesan yang ramah pengguna
  static String interpret(dynamic error) {
    if (error == null) return "Terjadi kesalahan yang tidak diketahui.";

    // Jika error adalah Failure dari sistem kita sendiri
    if (error is Failure) {
      return error.message;
    }

    // Jika error adalah Exception langsung dari Firebase Auth
    if (error is FirebaseAuthException) {
      return _getFirebaseAuthMessage(error.code);
    }

    // Jika error adalah Exception dari Platform (misal native Android/iOS)
    if (error is PlatformException) {
      return _getPlatformExceptionMessage(error.code);
    }

    final errorString = error.toString().toLowerCase();
    
    // Parse pesan error umum jika mereka dibungkus dalam Exception generik
    for (final entry in _commonErrorKeywords.entries) {
      if (errorString.contains(entry.key)) {
        return entry.value;
      }
    }

    // Fallback bawaan
    return "Terjadi kesalahan sistem. Silakan coba lagi nanti.";
  }

  static String _getFirebaseAuthMessage(String code) {
    return _firebaseAuthMessages[code] ?? "Terjadi kesalahan saat autentikasi. Silakan coba lagi.";
  }

  static String _getPlatformExceptionMessage(String code) {
    if (code == 'network_error') {
      return "Terjadi masalah jaringan. Periksa koneksi internet Anda.";
    }
    return "Terjadi kesalahan sistem. Silakan coba lagi.";
  }
}
