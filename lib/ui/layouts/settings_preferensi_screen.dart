import 'package:flutter/material.dart';
import '../../features/dashboard/logic/settings_controller.dart';

class SettingsPreferensiScreen extends StatefulWidget {
  const SettingsPreferensiScreen({Key? key}) : super(key: key);

  @override
  State<SettingsPreferensiScreen> createState() => _SettingsPreferensiScreenState();
}

class _SettingsPreferensiScreenState extends State<SettingsPreferensiScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);
  static const Color borderColor = Color(0xFF2A2A3E);

  late final SettingsController _controller;
  List<String> _selectedPref = [];
  bool _isLoading = true;

  final List<Map<String, String>> _activities = [
    {'name': 'Latihan Kekuatan', 'icon': '🏋️'},
    {'name': 'Jogging / Lari', 'icon': '🏃'},
    {'name': 'Bersepeda', 'icon': '🚴'},
    {'name': 'Yoga / Fleksibilitas', 'icon': '🧘'},
    {'name': 'HIIT / Kardio Intens', 'icon': '⚡'},
    {'name': 'Peregangan / Santai', 'icon': '🤸'},
    {'name': 'Latihan Perut (Abs)', 'icon': '🔥'},
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
        _selectedPref = List.from(_controller.preferensiAktivitas);
        _isLoading = false;
      });
    }
  }

  void _toggleActivity(String name) {
    setState(() {
      if (_selectedPref.contains(name)) {
        _selectedPref.remove(name);
      } else {
        _selectedPref.add(name);
      }
    });
  }

  Future<void> _save() async {
    if (_selectedPref.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu preferensi aktivitas'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await _controller.savePreferensiAktivitas(_selectedPref);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferensi Aktivitas berhasil disimpan'),
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
          'Preferensi Aktivitas',
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
                          'Pilih aktivitas yang paling Anda sukai atau yang ingin Anda jadwalkan secara rutin.',
                          style: TextStyle(color: grey, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _activities.length,
                          itemBuilder: (context, index) {
                            final act = _activities[index];
                            final isSelected = _selectedPref.contains(act['name']);
                            return GestureDetector(
                              onTap: () => _toggleActivity(act['name']!),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected ? limeGreen.withOpacity(0.15) : cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? limeGreen : borderColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      act['icon']!,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        act['name']!,
                                        style: TextStyle(
                                          color: isSelected ? limeGreen : white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSelected,
                                      activeColor: limeGreen,
                                      checkColor: Colors.black,
                                      side: const BorderSide(color: grey),
                                      onChanged: (_) => _toggleActivity(act['name']!),
                                    ),
                                  ],
                                ),
                              ),
                            );
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
                        'Simpan Preferensi',
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
