import 'package:flutter/material.dart';
import '../../features/dashboard/logic/settings_controller.dart';

class SettingsWaktuLuangScreen extends StatefulWidget {
  const SettingsWaktuLuangScreen({Key? key}) : super(key: key);

  @override
  State<SettingsWaktuLuangScreen> createState() => _SettingsWaktuLuangScreenState();
}

class _SettingsWaktuLuangScreenState extends State<SettingsWaktuLuangScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  late final SettingsController _controller;
  String _selectedWaktu = '30 - 45 menit';
  bool _isLoading = true;

  final List<Map<String, String>> _options = [
    {
      'label': 'Sangat Singkat (< 15 menit)',
      'value': '< 15 menit',
      'icon': '⚡',
      'desc': 'Cocok untuk latihan intensitas tinggi (HIIT) cepat.'
    },
    {
      'label': 'Singkat (15 - 30 menit)',
      'value': '15 - 30 menit',
      'icon': '⏱️',
      'desc': 'Ideal untuk pemanasan cepat atau workout terfokus.'
    },
    {
      'label': 'Sedang (30 - 45 menit)',
      'value': '30 - 45 menit',
      'icon': '⏳',
      'desc': 'Waktu standar untuk latihan rutin harian yang seimbang.'
    },
    {
      'label': 'Lama (45 - 60 menit)',
      'value': '45 - 60 menit',
      'icon': '⏰',
      'desc': 'Cocok untuk latihan beban penuh atau kardio lengkap.'
    },
    {
      'label': 'Sangat Lama (> 60 menit)',
      'value': '> 60 menit',
      'icon': '🏆',
      'desc': 'Sempurna untuk sesi marathon atau ketahanan otot mendalam.'
    },
  ];

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
        _selectedWaktu = _controller.waktuLuang;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    await _controller.saveWaktuLuang(_selectedWaktu);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilihan Waktu Luang berhasil diperbarui'),
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
          'Waktu Luang Latihan',
          style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: limeGreen))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _options.length,
                    itemBuilder: (context, index) {
                      final opt = _options[index];
                      final isSelected = _selectedWaktu == opt['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedWaktu = opt['value']!;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? limeGreen.withValues(alpha: 0.1) : cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? limeGreen : borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                opt['icon']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt['label']!,
                                      style: TextStyle(
                                        color: isSelected ? limeGreen : white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      opt['desc']!,
                                      style: const TextStyle(color: grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: limeGreen),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).size.height * 0.25),
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
                        'Simpan Waktu Luang',
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
}
