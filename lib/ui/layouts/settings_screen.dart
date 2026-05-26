import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import '../components/profile_avatar.dart';
import '../../features/dashboard/logic/settings_controller.dart';
import 'add_activity_screen.dart';
import 'activity_list_screen.dart';
import 'settings_profil_screen.dart';
import 'settings_data_fisik_screen.dart';
import 'settings_tujuan_screen.dart';
import 'settings_preferensi_screen.dart';
import 'settings_waktu_luang_screen.dart';
import 'settings_level_aktifitas_screen.dart';
import 'settings_target_harian_screen.dart';
import 'settings_notifikasi_screen.dart';
import 'settings_umum_screen.dart';

class SettingsScreen extends StatefulWidget {
  final int initialNavIndex;
  final Function(int)? onNavTapped;

  const SettingsScreen({
    Key? key,
    this.initialNavIndex = 3,
    this.onNavTapped,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  late int _bottomNavIndex;
  String _activeItem = '';
  late final SettingsController _controller;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _sections = [
    {'title': 'Identitas dan Tujuan', 'items': ['Profil', 'Data Fisik', 'Tujuan']},
    {'title': 'Personalisasi Aktivitas', 'items': ['Preferensi Aktivitas', 'Waktu Luang', 'Level Aktivitas']},
    {'title': 'Kontrol & Sistem', 'items': ['Target harian', 'Notifikasi', 'Pengaturan Umum']},
  ];

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialNavIndex;
    _controller = SettingsController();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadAll();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleNavTap(int index) {
    if (index == 3) return;
    if (widget.onNavTapped != null) {
      widget.onNavTapped!(index);
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => AddActivityScreen(initialNavIndex: 1, onNavTapped: (i) => Navigator.pop(context)),
      ));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ActivityListScreen()));
    } else {
      Navigator.pop(context);
    }
  }

  void _navigateToSubScreen(String label) async {
    setState(() => _activeItem = label);
    Widget screen;
    switch (label) {
      case 'Profil':
        screen = const SettingsProfilScreen();
        break;
      case 'Data Fisik':
        screen = const SettingsDataFisikScreen();
        break;
      case 'Tujuan':
        screen = const SettingsTujuanScreen();
        break;
      case 'Preferensi Aktivitas':
        screen = const SettingsPreferensiScreen();
        break;
      case 'Waktu Luang':
        screen = const SettingsWaktuLuangScreen();
        break;
      case 'Level Aktivitas':
        screen = const SettingsLevelAktifitasScreen();
        break;
      case 'Target harian':
        screen = const SettingsTargetHarianScreen();
        break;
      case 'Notifikasi':
        screen = const SettingsNotifikasiScreen();
        break;
      case 'Pengaturan Umum':
        screen = const SettingsUmumScreen();
        break;
      default:
        return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (result == true) {
      // Reload settings details
      _loadData();
    }
    setState(() => _activeItem = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: limeGreen))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 28),
                          const Text('Pengaturan', style: TextStyle(color: white, fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          ..._sections.map(_buildSection),
                          const SizedBox(height: 16),
                          _buildFooter(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),
            CustomBottomNavBar(selectedIndex: _bottomNavIndex, onItemTapped: _handleNavTap),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final displayNama = _controller.nama.isNotEmpty ? _controller.nama : 'User';
    return Row(
      children: [
        const ProfileAvatar(radius: 22, iconSize: 24),
        const SizedBox(width: 12),
        Text('Hi $displayNama', style: const TextStyle(color: limeGreen, fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section['title'] as String, style: const TextStyle(color: grey, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.3)),
        const SizedBox(height: 10),
        ...(section['items'] as List<String>).map(_buildSettingItem),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSettingItem(String label) {
    final isActive = _activeItem == label;
    return GestureDetector(
      onTap: () => _navigateToSubScreen(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? limeGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? limeGreen : borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: isActive ? Colors.black : white, fontSize: 15, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
            Icon(Icons.chevron_right, color: isActive ? Colors.black : grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, color: grey.withOpacity(0.6), size: 14),
          const SizedBox(width: 6),
          Text('Fitlifeo 1.0-release', style: TextStyle(color: grey.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }
}