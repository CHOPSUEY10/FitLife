import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'add_activity_screen.dart';
import 'activity_list_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialNavIndex;

  const MainScreen({
    super.key,
    this.initialNavIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    DashboardScreen(),
    AddActivityScreen(),
    ActivityListScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialNavIndex;
  }

  void _onNavTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0518), // Match bgColor
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemTapped: _onNavTapped,
      ),
    );
  }
}
