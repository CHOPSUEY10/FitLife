import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/service/auth_service.dart';
import '../components/auth_text_field.dart';
import '../components/glass_container.dart';
import 'register_screen.dart';
import 'auth_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  void _loginWithGoogle() async {
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

  void _loginManually() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
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
                image: AssetImage('assets/background/loginBg.png'),
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
                            'Login',
                            style: GoogleFonts.allerta(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Using email controller here since Firebase expects email
                          AuthTextField(hint: 'Email', controller: _emailController),
                          AuthTextField(hint: 'Password', isPassword: true, controller: _passwordController),
                          
                          // Remember me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (val) {
                                        setState(() => _rememberMe = val ?? false);
                                      },
                                      fillColor: WidgetStateProperty.resolveWith((states) => Colors.white),
                                      checkColor: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: GoogleFonts.allerta(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                              Text(
                                'Forgot Password?',
                                style: GoogleFonts.allerta(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Login Button
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
                              onPressed: _isLoading ? null : _loginManually,
                              child: _isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                                : Text(
                                    'Login',
                                    style: GoogleFonts.allerta(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Google Sign In Button
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
                              onPressed: _loginWithGoogle,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Navigate to Register
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                            child: Text(
                              "Don't have an account? Register",
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
