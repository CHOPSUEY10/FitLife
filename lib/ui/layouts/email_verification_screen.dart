import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'auth_wrapper.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Start polling to check if the user clicked the verification link in their email
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Refresh the user to get the latest emailVerified status
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        _timer?.cancel();
        if (mounted) {
          // Send them back to the AuthWrapper to handle the next step (Onboarding or Dashboard)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
          );
        }
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification email resent! Please check your inbox.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0518),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_rounded, size: 100, color: Color(0xFFBEFF5D)),
              const SizedBox(height: 30),
              Text(
                'Verify Your Email',
                style: GoogleFonts.coda(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'We have sent a verification link to your email. Please click the link to verify your account.',
                textAlign: TextAlign.center,
                style: GoogleFonts.allerta(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Color(0xFFBEFF5D)),
              const SizedBox(height: 20),
              Text(
                'Waiting for verification...',
                style: GoogleFonts.allerta(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFBEFF5D), side: const BorderSide(color: Color(0xFFBEFF5D)),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
                onPressed: _isResending ? null : _resendVerificationEmail,
                child: _isResending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Resend Email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  );
                },
                child: const Text('Cancel & Logout', style: TextStyle(color: Colors.redAccent)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
