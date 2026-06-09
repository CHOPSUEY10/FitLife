import 'package:flutter/material.dart';
import '../components/profile_avatar.dart';
import '../../features/dashboard/logic/settings_controller.dart';
import '../../core/service/auth_service.dart';
import 'profile_account_screen.dart';
import 'settings_data_fisik_screen.dart';
import 'settings_waktu_luang_screen.dart';
import 'settings_level_aktifitas_screen.dart';
import 'settings_target_harian_screen.dart';
import 'settings_notifikasi_screen.dart';
import 'settings_umum_screen.dart';
import 'auth_wrapper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);
  static const Color cardColor = Color(0xFF1A1A2E);

  String _activeItem = '';
  late final SettingsController _controller;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _sections = [
    {'title': 'Identitas dan Tujuan', 'items': ['Profil', 'Data Fisik']},
    {'title': 'Personalisasi Aktivitas', 'items': ['Waktu Luang', 'Level Aktivitas']},
    {'title': 'Kontrol & Sistem', 'items': ['Target harian', 'Notifikasi', 'Pengaturan Umum']},
    {'title': 'Sesi Akun', 'items': ['Keluar']},
  ];

  @override
  void initState() {
    super.initState();
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

  void _navigateToSubScreen(String label) async {
    if (_activeItem.isNotEmpty) return; // Prevent double taps
    setState(() => _activeItem = label);

    if (label == 'Keluar') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: cardColor,
          title: const Text('Keluar Akun', style: TextStyle(color: white, fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?', style: TextStyle(color: grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal', style: TextStyle(color: grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await AuthService().signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          setState(() => _activeItem = '');
        }
      }
      return;
    }

    Widget screen;
    switch (label) {
      case 'Profil':
        screen = const ProfileAccountScreen();
        break;
      case 'Data Fisik':
        screen = const SettingsDataFisikScreen();
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
    if (mounted) {
      setState(() => _activeItem = '');
    }
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
    final isLogout = label == 'Keluar';
    return GestureDetector(
      onTap: () => _navigateToSubScreen(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isActive ? (isLogout ? Colors.redAccent : limeGreen) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? (isLogout ? Colors.redAccent : limeGreen) : borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : (isLogout ? Colors.redAccent : white),
                fontSize: 15,
                fontWeight: (isActive || isLogout) ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Icon(
              isLogout ? Icons.logout : Icons.chevron_right,
              color: isActive ? Colors.black : (isLogout ? Colors.redAccent : grey),
              size: 20,
            ),
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