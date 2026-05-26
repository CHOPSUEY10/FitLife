import 'package:flutter/material.dart';
import '../../features/dashboard/logic/settings_controller.dart';

class SettingsTujuanScreen extends StatefulWidget {
  const SettingsTujuanScreen({Key? key}) : super(key: key);

  @override
  State<SettingsTujuanScreen> createState() => _SettingsTujuanScreenState();
}

class _SettingsTujuanScreenState extends State<SettingsTujuanScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  late final SettingsController _controller;
  String _selectedTujuan = 'Turun Berat Badan';
  bool _isLoading = true;

  final List<Map<String, String>> _options = [
    {
      'title': 'Turun Berat Badan',
      'desc': 'Fokus membakar kalori dan lemak tubuh secara maksimal.',
      'icon': '🔥',
    },
    {
      'title': 'Naik Massa Otot',
      'desc': 'Latihan beban intensif untuk meningkatkan kekuatan dan volume otot.',
      'icon': '💪',
    },
    {
      'title': 'Menjaga Kebugaran',
      'desc': 'Menjaga kebugaran harian dan kestabilan metabolisme tubuh.',
      'icon': '❤️',
    },
    {
      'title': 'Meningkatkan Stamina / Marathon',
      'desc': 'Fokus pada ketahanan kardiovaskular dan lari jarak jauh.',
      'icon': '🏃',
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
        _selectedTujuan = _controller.tujuan;
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    await _controller.saveTujuan(_selectedTujuan);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tujuan Latihan berhasil diperbarui'),
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
          'Tujuan Latihan',
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
                      final item = _options[index];
                      final isSelected = _selectedTujuan == item['title'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTujuan = item['title']!;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
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
                                item['icon']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title']!,
                                      style: TextStyle(
                                        color: isSelected ? limeGreen : white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['desc']!,
                                      style: const TextStyle(color: grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: limeGreen)
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
