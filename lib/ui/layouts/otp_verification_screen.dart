import 'package:flutter/material.dart';
import '../../core/service/otp_prefs_service.dart';
import '../../features/sign_in/logic/otp_controller.dart';
import '../components/otp_input_field.dart';
import 'auth_wrapper.dart';
import 'login_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
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
    await _otpController.sendOtp(widget.email);
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
    FocusScope.of(context).unfocus();

    final success = await _otpController.verifyOtp(widget.email);
    if (!mounted) return;

    if (success) {
      await OtpPrefsService.setOtpVerified(true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Verifikasi berhasil!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthWrapper()),
        (route) => false,
      );
    } else {
      _showErrorIfNeeded();
    }
  }

  Future<void> _handleResend() async {
    await _otpController.sendOtp(widget.email);
    if (!mounted) return;
    
    if (_otpController.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kode OTP baru telah dikirim!"),
          backgroundColor: Colors.blueAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showErrorIfNeeded();
    }
  }

  Future<void> _cancelAndLogout() async {
    await OtpPrefsService.clearAll();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
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
                        // Logo
                        Image.asset(
                          'assets/icon/fitlife.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 32),
                        
                        // Title
                        const Text(
                          "Verifikasi OTP",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Subtitle
                        Text(
                          "Masukkan 6 digit kode OTP yang dikirim ke email Anda:\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
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
                        
                        // Timer & Resend (using Wrap to prevent horizontal overflow)
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _otpController.countdown > 0 
                                  ? "Kirim ulang kode dalam ${_otpController.countdown}s"
                                  : "Tidak menerima kode?",
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            if (_otpController.canResend) ...[
                              GestureDetector(
                                onTap: _otpController.isLoading ? null : _handleResend,
                                child: const Text(
                                  "Kirim Ulang",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
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
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _otpController.isLoading || _otpController.otpCode.length != 6
                                ? null
                                : _handleVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC6FF00), // Lime Green
                              foregroundColor: Colors.black,
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
                                      color: Colors.black,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "Verifikasi",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Back Button
                        TextButton(
                          onPressed: _cancelAndLogout,
                          child: const Text(
                            "Kembali ke Login",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
