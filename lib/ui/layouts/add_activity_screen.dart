import 'package:flutter/material.dart';
import '../../core/database/local_db_helper.dart';
import '../components/bottom_nav_bar.dart';

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

  String? _selectedSchedule;
  final List<String?> _activities = [null, null, null];
  int _selectedDuration = 1;
  final TextEditingController _customDurationController = TextEditingController();

  final List<String> _scheduleOptions = [
    'Pagi (06:00 - 09:00)',
    'Siang (11:00 - 13:00)',
    'Sore (15:00 - 17:00)',
    'Malam (19:00 - 21:00)',
  ];

  final List<String> _activityOptions = [
    'Lari', 'Bersepeda', 'Renang', 'Push Up',
    'Sit Up', 'Plank', 'Yoga', 'Zumba',
    'Angkat Beban', 'Jalan Kaki',
  ];

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialNavIndex;
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final userMetrics = await LocalDBHelper.instance.getUserMetrics();
    if (userMetrics != null && userMetrics.nama != null && userMetrics.nama!.isNotEmpty) {
      setState(() => _username = userMetrics.nama!);
    }
  }

  @override
  void dispose() {
    _customDurationController.dispose();
    super.dispose();
  }

  void _showSchedulePicker() {
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
          ..._scheduleOptions.map((opt) => ListTile(
            title: Text(opt, style: const TextStyle(color: Colors.white)),
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

  void _showActivityPicker(int index) {
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
          ..._activityOptions.map((opt) => ListTile(
            title: Text(opt, style: const TextStyle(color: Colors.white)),
            trailing: _activities[index] == opt ? const Icon(Icons.check, color: Color(0xFFC6FF00)) : null,
            onTap: () {
              setState(() => _activities[index] = opt);
              Navigator.pop(ctx);
            },
          )),
        ],
      ),
    );
  }

  void _showAllActivities() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1630),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Semua Aktivitas', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
                ),
                itemCount: _activityOptions.length,
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () {
                    int slot = _activities.indexWhere((a) => a == null);
                    if (slot != -1) setState(() => _activities[slot] = _activityOptions[i]);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: const Color(0xFF2A2545), borderRadius: BorderRadius.circular(10)),
                    child: Text(_activityOptions[i], style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    if (_selectedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jadwal terlebih dahulu'), backgroundColor: Colors.red),
      );
      return;
    }
    if (!_activities.any((a) => a != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu aktivitas'), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aktivitas berhasil disimpan!'), backgroundColor: Color(0xFFC6FF00)),
    );
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
                        CircleAvatar(
                          backgroundColor: Colors.grey[800],
                          radius: 16,
                          child: const Icon(Icons.person, size: 20, color: Colors.white),
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
                          _buildDropdownField(value: _selectedSchedule, hint: '', onTap: _showSchedulePicker),
                          const SizedBox(height: 16),

                          // Pilih Aktivitas
                          const Text('Pilih Aktivitas', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          ...List.generate(3, (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildActivityField(i),
                          )),

                          // Lihat Semuanya
                          Center(
                            child: GestureDetector(
                              onTap: _showAllActivities,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                                child: const Text('Lihat Semuanya', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Durasi
                          const Text('Durasi', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildDurationChip('30 Menit', 0),
                              const SizedBox(width: 8),
                              _buildDurationChip('1 Jam', 1),
                              const SizedBox(width: 8),
                              _buildDurationChip('2 Jam', 2),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Atur Sendiri
                          Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                            child: TextField(
                              controller: _customDurationController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13, color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Atur Sendiri',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onTap: () => setState(() => _selectedDuration = 3),
                            ),
                          ),
                          const SizedBox(height: 20),

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

  Widget _buildActivityField(int index) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(child: Text(_activities[index] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black))),
          GestureDetector(
            onTap: () => _showActivityPicker(index),
            child: Container(
              width: 26, height: 26,
              decoration: const BoxDecoration(color: Color(0xFF2DB55D), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(String label, int index) {
    final bool isSelected = _selectedDuration == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = index;
          _customDurationController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.black : Colors.black54, width: 1.5),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}