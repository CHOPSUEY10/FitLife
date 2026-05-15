import 'package:flutter/material.dart';
import '../../core/service/phone_prefs_service.dart';
import '../../features/sign_in/logic/otp_controller.dart';
import '../components/otp_input_field.dart';
import 'auth_wrapper.dart';
import 'onboarding_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final OtpController _otpController = OtpController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialOtp();
    });
  }

  Future<void> _sendInitialOtp() async {
    await _otpController.sendOtp(widget.phoneNumber);
    if (!mounted) return;
    _showErrorIfNeeded();
  }

  void _showErrorIfNeeded() {
    if (_otpController.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_otpController.error!.message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleVerify() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    final success = await _otpController.verifyOtp();
    if (!mounted) return;

    if (success) {
      // Persist OTP verification and clear the pending phone
      await PhonePrefsService.setOtpVerified();
      await PhonePrefsService.clearPhone();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verification successful!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // AuthWrapper now reads isOtpVerified flag → routes to OnboardingScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } else {
      _showErrorIfNeeded();
    }
  }

  Future<void> _handleResend() async {
    await _otpController.sendOtp(widget.phoneNumber);
    if (!mounted) return;
    
    if (_otpController.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP has been resent!"),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showErrorIfNeeded();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/background/registerBg.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Foreground Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListenableBuilder(
                  listenable: _otpController,
                  builder: (context, _) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Image.asset(
                          'assets/icon/fitlife.png',
                          width: 120,
                          height: 120,
                        ),
                        const SizedBox(height: 32),
                        
                        // Title
                        const Text(
                          "OTP Verification",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Subtitle
                        Text(
                          "Enter the 6-digit code sent to\n${widget.phoneNumber}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // 6-digit Input Field
                        OtpInputField(
                          length: 6,
                          onChanged: (value) {
                            _otpController.setOtpCode(value);
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        // Timer & Resend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _otpController.countdown > 0 
                                  ? "Resend code in ${_otpController.countdown}s"
                                  : "Didn't receive the code?",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (_otpController.canResend) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _otpController.isLoading ? null : _handleResend,
                                child: const Text(
                                  "Resend",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 40),
                        
                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _otpController.isLoading || _otpController.otpCode.length != 6
                                ? null
                                : _handleVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _otpController.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Verify",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
