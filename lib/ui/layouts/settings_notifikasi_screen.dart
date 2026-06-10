import 'package:flutter/material.dart';
import '../../features/dashboard/logic/settings_controller.dart';

class SettingsNotifikasiScreen extends StatefulWidget {
  const SettingsNotifikasiScreen({Key? key}) : super(key: key);

  @override
  State<SettingsNotifikasiScreen> createState() => _SettingsNotifikasiScreenState();
}

class _SettingsNotifikasiScreenState extends State<SettingsNotifikasiScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  late final SettingsController _controller;
  bool _notifPengingat = true;
  bool _notifPencapaian = true;
  String _waktuPengingat = '07:00';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _initData();
  }

  Future<void> _initData() async {
    await _controller.loadAll();
    if (mounted) {
      setState(() {
        _notifPengingat = _controller.notifPengingat;
        _notifPencapaian = _controller.notifPencapaian;
        _waktuPengingat = _controller.waktuPengingat;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTime() async {
    final parts = _waktuPengingat.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 7;
    final initialMinute = int.tryParse(parts[1]) ?? 0;
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: limeGreen,
              onPrimary: Colors.black,
              surface: cardColor,
              onSurface: white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _waktuPengingat = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    await _controller.saveNotifikasi(
      pengingat: _notifPengingat,
      pencapaian: _notifPencapaian,
      tips: _controller.notifTips,
      waktu: _waktuPengingat,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan Notifikasi berhasil disimpan'),
          backgroundColor: limeGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: limeGreen))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kelola bagaimana aplikasi memberi tahu Anda tentang jadwal latihan dan sasaran harian.',
                          style: TextStyle(color: grey, fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        _buildSwitchTile(
                          title: 'Pengingat Latihan Harian',
                          subtitle: 'Kirim notifikasi untuk mengingatkan jadwal latihan.',
                          value: _notifPengingat,
                          onChanged: (val) => setState(() => _notifPengingat = val),
                        ),
                        const SizedBox(height: 8),
                        AnimatedOpacity(
                          opacity: _notifPengingat ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          child: IgnorePointer(
                            ignoring: !_notifPengingat,
                            child: GestureDetector(
                              onTap: _selectTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Waktu Pengingat',
                                            style: TextStyle(color: white, fontSize: 15, fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Waktu ideal untuk dikirimkan pengingat.',
                                            style: TextStyle(color: grey, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Row(
                                      children: [
                                        Text(
                                          _waktuPengingat,
                                          style: const TextStyle(color: limeGreen, fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.access_time, color: limeGreen, size: 20),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchTile(
                          title: 'Notifikasi Pencapaian',
                          subtitle: 'Kirim info saat target langkah atau kalori tercapai.',
                          value: _notifPencapaian,
                          onChanged: (val) => setState(() => _notifPencapaian = val),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: limeGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _save,
                      child: const Text(
                        'Simpan Pengaturan',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: limeGreen,
            activeTrackColor: limeGreen.withValues(alpha: 0.3),
            inactiveThumbColor: grey,
            inactiveTrackColor: cardColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
