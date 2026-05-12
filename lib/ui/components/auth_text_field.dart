import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;

  const AuthTextField({
    super.key,
    required this.hint,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: GoogleFonts.allerta(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.allerta(color: Colors.grey, fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
