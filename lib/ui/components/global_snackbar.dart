import 'package:flutter/material.dart';

class GlobalSnackBar {
  static void show(BuildContext context, String message, {Color backgroundColor = const Color(0xFFC6FF00)}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Dynamically choose text color for contrast (white text for dark backgrounds, black for light)
    final textColor = backgroundColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

