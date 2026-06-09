// Lokasi: lib/features/profile/logic/profile_account_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/service/auth_service.dart';
import '../../../core/service/otp_service.dart';
import '../../../core/errors/failures.dart';

class ProfileAccountController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final OtpService _otpService = OtpService();

  bool _isEmailLoading = false;
  bool _isPasswordLoading = false;
  bool _needsReauth = false;
  bool _isReauthLoading = false;

  bool _passwordOtpSent = false;
  bool _isPasswordOtpLoading = false;
  int _passwordOtpCountdown = 0;
  String? _passwordOtpError;
  Timer? _passwordOtpTimer;

  String? _emailError;
  String? _passwordError;
  String? _reauthError;
  String? _emailSuccessMessage;
  String? _passwordSuccessMessage;

  bool get isEmailLoading => _isEmailLoading;
  bool get isPasswordLoading => _isPasswordLoading;
  bool get needsReauth => _needsReauth;
  bool get isReauthLoading => _isReauthLoading;

  bool get passwordOtpSent => _passwordOtpSent;
  bool get isPasswordOtpLoading => _isPasswordOtpLoading;
  int get passwordOtpCountdown => _passwordOtpCountdown;
  String? get passwordOtpError => _passwordOtpError;
  bool get canResendPasswordOtp => _passwordOtpCountdown == 0;

  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get reauthError => _reauthError;
  String? get emailSuccessMessage => _emailSuccessMessage;
  String? get passwordSuccessMessage => _passwordSuccessMessage;

  String get signInProvider => _authService.signInProvider;

  void clearMessages() {
    _emailError = null;
    _passwordError = null;
    _reauthError = null;
    _passwordOtpError = null;
    _emailSuccessMessage = null;
    _passwordSuccessMessage = null;
    _needsReauth = false;
    _isReauthLoading = false;
    _passwordOtpSent = false;
    _isPasswordOtpLoading = false;
    _passwordOtpCountdown = 0;
    _passwordOtpTimer?.cancel();
    notifyListeners();
  }

  bool validateEmailFormat(String email) {
    final emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    return emailRegExp.hasMatch(email);
  }

  bool validatePasswordStrength(String password) {
    // Firebase requires at least 6 characters
    return password.length >= 6;
  }

  Future<bool> changeEmail(String newEmail) async {
    clearMessages();
    
    if (newEmail.trim().isEmpty) {
      _emailError = 'Email tidak boleh kosong.';
      notifyListeners();
      return false;
    }

    if (!validateEmailFormat(newEmail.trim())) {
      _emailError = 'Format email tidak valid.';
      notifyListeners();
      return false;
    }

    _isEmailLoading = true;
    notifyListeners();

    try {
      await _authService.updateEmail(newEmail.trim());
      _emailSuccessMessage = 'Email verifikasi telah dikirim ke email baru. Silakan periksa kotak masuk Anda.';
      _isEmailLoading = false;
      _needsReauth = false;
      notifyListeners();
      return true;
    } on RequiresRecentLoginFailure catch (e) {
      _needsReauth = true;
      _emailError = e.message;
    } on AuthFailure catch (e) {
      _emailError = e.message;
    } catch (e) {
      _emailError = 'Gagal memperbarui email: $e';
    }

    _isEmailLoading = false;
    notifyListeners();
    return false;
  }

  void startPasswordOtpCountdown() {
    _passwordOtpCountdown = 60;
    _passwordOtpError = null;
    notifyListeners();
    _passwordOtpTimer?.cancel();
    _passwordOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_passwordOtpCountdown > 0) {
        _passwordOtpCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<bool> sendPasswordOtp(String newPassword, String confirmPassword) async {
    _passwordError = null;
    _passwordOtpError = null;
    _passwordSuccessMessage = null;

    if (newPassword.isEmpty) {
      _passwordError = 'Kata sandi tidak boleh kosong.';
      notifyListeners();
      return false;
    }

    if (!validatePasswordStrength(newPassword)) {
      _passwordError = 'Kata sandi minimal harus 6 karakter.';
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      _passwordError = 'Konfirmasi kata sandi tidak cocok.';
      notifyListeners();
      return false;
    }

    final email = _authService.currentUserEmail;
    if (email == null) {
      _passwordError = 'Gagal mendapatkan email pengguna.';
      notifyListeners();
      return false;
    }

    _isPasswordOtpLoading = true;
    notifyListeners();

    final completer = Completer<bool>();
    await _otpService.sendOtpEmail(
      email: email,
      isPasswordChange: true,
      onCodeSent: () {
        _isPasswordOtpLoading = false;
        _passwordOtpSent = true;
        startPasswordOtpCountdown();
        notifyListeners();
        completer.complete(true);
      },
      onError: (String errorMessage) {
        _isPasswordOtpLoading = false;
        _passwordOtpError = errorMessage;
        notifyListeners();
        completer.complete(false);
      },
    );

    return completer.future;
  }

  Future<bool> verifyAndChangePassword(String otpCode, String newPassword, String confirmPassword) async {
    _passwordError = null;
    _passwordOtpError = null;
    _passwordSuccessMessage = null;

    final email = _authService.currentUserEmail;
    if (email == null) {
      _passwordError = 'Gagal mendapatkan email pengguna.';
      notifyListeners();
      return false;
    }

    if (otpCode.length != 6) {
      _passwordOtpError = 'Kode OTP harus terdiri dari 6 digit.';
      notifyListeners();
      return false;
    }

    _isPasswordLoading = true;
    notifyListeners();

    final isOtpValid = await _otpService.verifyOtp(email: email, code: otpCode);
    if (!isOtpValid) {
      _isPasswordLoading = false;
      _passwordOtpError = 'Kode OTP tidak valid.';
      notifyListeners();
      return false;
    }

    final success = await changePassword(newPassword, confirmPassword);
    
    if (success) {
      _passwordOtpTimer?.cancel();
      _passwordOtpCountdown = 0;
      _passwordOtpSent = false;
    }
    
    return success;
  }

  Future<bool> changePassword(String newPassword, String confirmPassword) async {
    _isPasswordLoading = true;
    notifyListeners();

    try {
      await _authService.updatePassword(newPassword);
      _passwordSuccessMessage = 'Kata sandi berhasil diperbarui.';
      _isPasswordLoading = false;
      _needsReauth = false;
      notifyListeners();
      return true;
    } on RequiresRecentLoginFailure catch (e) {
      _needsReauth = true;
      _passwordError = e.message;
    } on AuthFailure catch (e) {
      _passwordError = e.message;
    } catch (e) {
      _passwordError = 'Gagal memperbarui kata sandi: $e';
    }

    _isPasswordLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> verifyAndRetryEmail(String? currentPassword, String newEmail) async {
    _isReauthLoading = true;
    _reauthError = null;
    notifyListeners();

    try {
      await _authService.reauthenticate(currentPassword);
      _needsReauth = false;
      _isReauthLoading = false;
      notifyListeners();
      
      // Retry email update
      return await changeEmail(newEmail);
    } on AuthFailure catch (e) {
      _reauthError = e.message;
    } catch (e) {
      _reauthError = 'Gagal memverifikasi ulang: $e';
    }

    _isReauthLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> verifyAndRetryPassword(String? currentPassword, String newPassword, String confirmPassword) async {
    _isReauthLoading = true;
    _reauthError = null;
    notifyListeners();

    try {
      await _authService.reauthenticate(currentPassword);
      _needsReauth = false;
      _isReauthLoading = false;
      notifyListeners();
      
      // Retry password update
      return await changePassword(newPassword, confirmPassword);
    } on AuthFailure catch (e) {
      _reauthError = e.message;
    } catch (e) {
      _reauthError = 'Gagal memverifikasi ulang: $e';
    }

    _isReauthLoading = false;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _passwordOtpTimer?.cancel();
    super.dispose();
  }
}
