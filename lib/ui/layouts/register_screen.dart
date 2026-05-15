import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/service/auth_service.dart';
import '../../core/service/phone_prefs_service.dart';
import '../components/auth_text_field.dart';
import '../components/glass_container.dart';
import 'login_screen.dart';
import 'auth_wrapper.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _iAgree = false;
  bool _isLoading = false;

  void _registerWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _registerManually() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields')));
      return;
    }
    // Basic phone format validation
    final phone = _phoneController.text.trim();
    if (!phone.startsWith('+') || phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid phone number with country code (e.g. +628123456789)')));
      return;
    }
    if (!_iAgree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must agree to the terms')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null && mounted) {
        // Persist phone number so AuthWrapper can retrieve it on app restart
        await PhonePrefsService.savePhone(_phoneController.text.trim());
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              phoneNumber: _phoneController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/registerBg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/icon/fitlife.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 32),
                    
                    // Glass Container Form
                    GlassContainer(
                      child: Column(
                        children: [
                          Text(
                            'Register',
                            style: GoogleFonts.allerta(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          AuthTextField(hint: 'Username', controller: _usernameController),
                          AuthTextField(hint: 'Email', controller: _emailController),
                          AuthTextField(hint: 'Phone Number (+628...)', controller: _phoneController, keyboardType: TextInputType.phone),
                          AuthTextField(hint: 'Password', isPassword: true, controller: _passwordController),
                          
                          // I Agree
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _iAgree,
                                  onChanged: (val) {
                                    setState(() => _iAgree = val ?? false);
                                  },
                                  fillColor: WidgetStateProperty.resolveWith((states) => Colors.white),
                                  checkColor: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'I Agree',
                                style: GoogleFonts.allerta(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: _isLoading ? null : _registerManually,
                              child: _isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(
                                    'Register',
                                    style: GoogleFonts.allerta(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Google Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                              label: Text(
                                'Continue with Google',
                                style: GoogleFonts.allerta(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              onPressed: _registerWithGoogle,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Navigate to Login
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              "Already have an account? Login",
                              style: GoogleFonts.allerta(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
