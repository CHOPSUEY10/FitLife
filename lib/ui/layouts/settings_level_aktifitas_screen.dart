import 'package:flutter/material.dart';
import '../../features/dashboard/logic/settings_controller.dart';

class SettingsLevelAktifitasScreen extends StatefulWidget {
  const SettingsLevelAktifitasScreen({Key? key}) : super(key: key);

  @override
  State<SettingsLevelAktifitasScreen> createState() => _SettingsLevelAktifitasScreenState();
}

class _SettingsLevelAktifitasScreenState extends State<SettingsLevelAktifitasScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  late final SettingsController _controller;
  String _selectedLevel = 'Pemula';
  bool _isLoading = true;

  final List<Map<String, String>> _levels = [
    {
      'name': 'Pemula',
      'desc': 'Baru memulai perjalanan olahraga atau kembali aktif setelah istirahat lama.',
      'icon': '🌱',
      'intensity': 'Intensitas: Ringan'
    },
    {
      'name': 'Menengah',
      'desc': 'Sudah terbiasa berolahraga 1-3 kali dalam seminggu secara teratur.',
      'icon': '🔥',
      'intensity': 'Intensitas: Sedang'
    },
    {
      'name': 'Mahir / Atlet',
      'desc': 'Berolahraga intensif 4-6 kali seminggu dengan stamina dan kekuatan tinggi.',
      'icon': '⚡',
      'intensity': 'Intensitas: Tinggi'
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
        _selectedLevel = _controller.levelAktivitas;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    await _controller.saveLevelAktivitas(_selectedLevel);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Level Aktivitas berhasil disimpan'),
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
          'Level Aktivitas',
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
                    itemCount: _levels.length,
                    itemBuilder: (context, index) {
                      final lvl = _levels[index];
                      final isSelected = _selectedLevel == lvl['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLevel = lvl['name']!;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isSelected ? limeGreen.withOpacity(0.1) : cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? limeGreen : borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lvl['icon']!,
                                style: const TextStyle(fontSize: 26),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lvl['name']!,
                                      style: TextStyle(
                                        color: isSelected ? limeGreen : white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      lvl['desc']!,
                                      style: const TextStyle(color: grey, fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      lvl['intensity']!,
                                      style: TextStyle(
                                        color: isSelected ? limeGreen.withOpacity(0.8) : limeGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                        'Simpan Pilihan',
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
