import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/service/otp_service.dart';
import '../../../core/errors/failures.dart';

class OtpController extends ChangeNotifier {
  final OtpService _otpService;

  OtpController({OtpService? otpService}) 
    : _otpService = otpService ?? OtpService();

  String _otpCode = "";
  String get otpCode => _otpCode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Failure? _error;
  Failure? get error => _error;

  int _countdown = 0;
  int get countdown => _countdown;
  
  bool get canResend => _countdown == 0;

  Timer? _timer;
  
  String? _verificationId;

  /// Handles 6-digit OTP input
  void setOtpCode(String code) {
    if (code.length <= 6) {
      _otpCode = code;
      _error = null; // Clear error when user types
      notifyListeners();
    }
  }

  /// Implements 60-second countdown timer for Resend OTP
  void startCountdown() {
    _countdown = 60;
    _error = null;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  /// Sends OTP using the OtpService via Firebase Phone Auth
  Future<void> sendOtp(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _otpService.sendOtpPhone(
      phoneNumber: phoneNumber,
      onCodeSent: (String verificationId) {
        _verificationId = verificationId;
        _isLoading = false;
        startCountdown();
      },
      onError: (String errorMessage) {
        _isLoading = false;
        _error = InvalidOtpFailure(errorMessage);
        notifyListeners();
      },
    );
  }

  /// Verifies the 6-digit OTP
  Future<bool> verifyOtp() async {
    if (_otpCode.length != 6) {
      _error = InvalidOtpFailure("OTP must be exactly 6 digits.");
      notifyListeners();
      return false;
    }

    if (_countdown == 0) {
      _error = ExpiredOtpFailure("OTP has expired. Please request a new one.");
      notifyListeners();
      return false;
    }

    if (_verificationId == null) {
      _error = InvalidOtpFailure("Verification ID is missing. Please resend code.");
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _otpService.verifyOtp(
      verificationId: _verificationId!, 
      smsCode: _otpCode,
    );

    _isLoading = false;
    if (success) {
      notifyListeners();
      return true;
    } else {
      _error = InvalidOtpFailure("Invalid OTP entered.");
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
