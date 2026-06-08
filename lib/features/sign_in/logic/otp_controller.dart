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

  void setOtpCode(String code) {
    if (code.length <= 6) {
      _otpCode = code;
      _error = null;
      notifyListeners();
    }
  }

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

  Future<void> sendOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _otpService.sendOtpEmail(
      email: email,
      onCodeSent: () {
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

  Future<bool> verifyOtp(String email) async {
    if (_otpCode.length != 6) {
      _error = InvalidOtpFailure("Kode OTP harus terdiri dari 6 digit.");
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final success = await _otpService.verifyOtp(
      email: email,
      code: _otpCode,
    );

    _isLoading = false;
    if (success) {
      notifyListeners();
      return true;
    } else {
      _error = InvalidOtpFailure("Kode OTP tidak valid.");
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
