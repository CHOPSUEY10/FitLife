import 'package:flutter/material.dart';
import '../../features/dashboard/logic/settings_controller.dart';

class SettingsUmumScreen extends StatefulWidget {
  const SettingsUmumScreen({Key? key}) : super(key: key);

  @override
  State<SettingsUmumScreen> createState() => _SettingsUmumScreenState();
}

class _SettingsUmumScreenState extends State<SettingsUmumScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  late final SettingsController _controller;
  String _unitBerat = 'kg';
  String _unitTinggi = 'cm';
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
        _unitBerat = _controller.unitBerat;
        _unitTinggi = _controller.unitTinggi;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    await _controller.savePengaturanUmum(
      bahasaBaru: _controller.bahasa, // Keep old language
      unitBeratBaru: _unitBerat,
      unitTinggiBaru: _unitTinggi,
      malam: _controller.modeMalam, // Keep old modeMalam
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan Umum berhasil diperbarui'),
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
          'Pengaturan Umum',
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
                          'Sesuaikan unit pengukuran aplikasi.',
                          style: TextStyle(color: grey, fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        _buildDropdownTile(
                          title: 'Unit Berat Badan',
                          subtitle: 'Pilih satuan untuk berat badan.',
                          value: _unitBerat,
                          items: ['kg', 'lbs'],
                          onChanged: (val) {
                            if (val != null) setState(() => _unitBerat = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownTile(
                          title: 'Unit Tinggi Badan',
                          subtitle: 'Pilih satuan untuk tinggi badan.',
                          value: _unitTinggi,
                          items: ['cm', 'inch'],
                          onChanged: (val) {
                            if (val != null) setState(() => _unitTinggi = val);
                          },
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

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Theme(
            data: Theme.of(context).copyWith(
              canvasColor: cardColor,
            ),
            child: DropdownButton<String>(
              value: value,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: limeGreen),
              style: const TextStyle(color: limeGreen, fontSize: 15, fontWeight: FontWeight.bold),
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
