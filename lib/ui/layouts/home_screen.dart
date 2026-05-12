import 'package:flutter/material.dart';
import '../../core/service/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0518),
      appBar: AppBar(
        title: const Text('Home Screen', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AuthService().signOut();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome! You are logged in.',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
