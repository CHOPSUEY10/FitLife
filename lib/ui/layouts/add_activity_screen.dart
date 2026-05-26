import 'package:flutter/material.dart';
import '../../core/database/local_db_helper.dart';
import '../../core/enums/schedule_enum.dart';
import '../../core/models/aktifitas_harian_model.dart';
import '../components/bottom_nav_bar.dart';
import '../components/profile_avatar.dart';

class AddActivityScreen extends StatefulWidget {
  final int initialNavIndex;
  final Function(int)? onNavTapped;

  const AddActivityScreen({
    Key? key,
    this.initialNavIndex = 1,
    this.onNavTapped,
  }) : super(key: key);

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  int _bottomNavIndex = 1;
  String _username = 'User';

  JadwalAktivitas? _selectedSchedule;
  String? _selectedMuscleGroup;
  List<String> _muscleGroupOptions = [];

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialNavIndex;
    _fetchUsername();
    _fetchMuscleGroups();
  }

  Future<void> _fetchMuscleGroups() async {
    final groups = await LocalDBHelper.instance.getWorkoutCategories();
    if (mounted) {
      setState(() {
        _muscleGroupOptions = groups;
      });
    }
  }

  Future<void> _fetchUsername() async {
    final userMetrics = await LocalDBHelper.instance.getUserMetrics();
    if (userMetrics != null && userMetrics.nama != null && userMetrics.nama!.isNotEmpty) {
      setState(() => _username = userMetrics.nama!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<JadwalAktivitas> _getAvailableSchedules() {
    final hour = DateTime.now().hour;
    return JadwalAktivitas.values.where((opt) {
      switch (opt) {
        case JadwalAktivitas.pagi: return hour < 9;
        case JadwalAktivitas.siang: return hour < 13;
        case JadwalAktivitas.sore: return hour < 17;
        case JadwalAktivitas.malam: return hour < 21;
      }
    }).toList();
  }

  void _showSchedulePicker() {
    final availableSchedules = _getAvailableSchedules();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1630),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          if (availableSchedules.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('Tidak ada jadwal tersedia hari ini.', style: TextStyle(color: Colors.white54))),
            )
          else
            ...availableSchedules.map((opt) => ListTile(
              title: Text(opt.label, style: const TextStyle(color: Colors.white)),
              trailing: _selectedSchedule == opt ? const Icon(Icons.check, color: Color(0xFFC6FF00)) : null,
              onTap: () {
                setState(() => _selectedSchedule = opt);
                Navigator.pop(ctx);
              },
            )),
        ],
      ),
    );
  }

  void _showMuscleGroupPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1630),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          ..._muscleGroupOptions.map((opt) => ListTile(
            title: Text(opt, style: const TextStyle(color: Colors.white)),
            trailing: _selectedMuscleGroup == opt ? const Icon(Icons.check, color: Color(0xFFC6FF00)) : null,
            onTap: () {
              setState(() => _selectedMuscleGroup = opt);
              Navigator.pop(ctx);
            },
          )),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (_selectedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jadwal terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedMuscleGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih aktivitas terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    // Check if an activity already exists for today
    final existingActivities = await LocalDBHelper.instance.getAktifitasHarianByDate(today);

    if (existingActivities.isNotEmpty) {
      if (!mounted) return;
      final existingActivity = existingActivities.first;
      
      // Show confirmation dialog to replace or delete
      final bool? shouldReplace = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1630),
          title: const Text('Jadwal Sudah Ada', style: TextStyle(color: Colors.white)),
          content: Text(
            'Anda sudah menjadwalkan ${existingActivity.idJenisAktifitas} untuk hari ini. Apakah Anda ingin menggantinya?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC6FF00), foregroundColor: Colors.black),
              child: const Text('Ganti Aktivitas'),
            ),
          ],
        ),
      );

      if (shouldReplace != true) return; // User cancelled

      final model = AktifitasHarianModel(
        idAktifitasHarian: existingActivity.idAktifitasHarian,
        tanggal: today,
        idJenisAktifitas: _selectedMuscleGroup!,
        totalKalori: existingActivity.totalKalori, // keep existing burned calories if any
        durasiLatihan: existingActivity.durasiLatihan,
        pace: existingActivity.pace,
        jarakTempuh: existingActivity.jarakTempuh,
      );
      await LocalDBHelper.instance.updateAktifitasHarian(model);
    } else {
      final model = AktifitasHarianModel(
        tanggal: today,
        idJenisAktifitas: _selectedMuscleGroup!,
        totalKalori: 0,
        durasiLatihan: 0,
      );
      await LocalDBHelper.instance.insertAktifitasHarian(model);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas berhasil disimpan!'), backgroundColor: Color(0xFFC6FF00)),
      );
      setState(() {
        _selectedSchedule = null;
        _selectedMuscleGroup = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const ProfileAvatar(
                          radius: 16,
                          iconSize: 20,
                        ),
                        const SizedBox(width: 8),
                        Text('Hi $_username', style: const TextStyle(color: Color(0xFFC6FF00), fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text('Add Activities', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Green card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFFC6FF00), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pilih Jadwal
                          const Text('Pilih Jadwal', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          _buildDropdownField(value: _selectedSchedule?.label, hint: '', onTap: _showSchedulePicker),
                          const SizedBox(height: 16),

                          // Pilih Aktivitas
                          const Text('Pilih Aktivitas', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          _buildDropdownField(value: _selectedMuscleGroup, hint: 'Pilih Bagian Otot', onTap: _showMuscleGroupPicker),
                          const SizedBox(height: 24),

                          // Simpan
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: const Text('Simpan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Nav
            CustomBottomNavBar(
              selectedIndex: _bottomNavIndex,
              onItemTapped: (index) {
                if (widget.onNavTapped != null) {
                  widget.onNavTapped!(index);
                } else {
                  setState(() => _bottomNavIndex = index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({required String? value, required String hint, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Expanded(child: Text(value ?? hint, style: TextStyle(fontSize: 13, color: value != null ? Colors.black : Colors.grey))),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

}