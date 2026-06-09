import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database/local_db_helper.dart';
import '../../core/models/aktifitas_harian_model.dart';
import '../components/profile_avatar.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({Key? key}) : super(key: key);

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);

  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String _username = 'User';

  List<AktifitasHarianModel> _dailyActivities = [];
  Set<int> _activeDays = {};

  double get _burnedCalories => _dailyActivities.fold(0.0, (sum, item) => sum + (item.totalKalori ?? 0));

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchMonthData();
    _fetchDailyActivities();
  }

  Future<void> _fetchUsername() async {
    final userMetrics = await LocalDBHelper.instance.getUserMetrics();
    if (userMetrics != null && userMetrics.nama != null && userMetrics.nama!.isNotEmpty) {
      if (mounted) {
        setState(() => _username = userMetrics.nama!);
      }
    }
  }

  Future<void> _fetchMonthData() async {
    final dates = await LocalDBHelper.instance.getAktifitasDatesForMonth(_focusedMonth.year, _focusedMonth.month);
    if (mounted) {
      setState(() {
        _activeDays = dates.map((d) => d.day).toSet();
      });
    }
  }

  Future<void> _fetchDailyActivities() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final activities = await LocalDBHelper.instance.getAktifitasHarianByDate(dateStr);
    if (mounted) {
      setState(() {
        _dailyActivities = activities;
      });
    }
  }

  int get _daysInMonth =>
      DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);

  int get _firstWeekdayOfMonth {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    return (first.weekday - 1) % 7;
  }

  String get _monthLabel {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    const Text('Jadwal Latihan', style: TextStyle(color: white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildCalendarCard(),
                    const SizedBox(height: 24),
                    const Text('Daftar Aktivitas', style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    if (_dailyActivities.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('Tidak ada jadwal untuk hari ini.', style: TextStyle(color: Colors.white54))))
                    else
                      ..._dailyActivities.map(_buildActivityItem),
                    const SizedBox(height: 24),
                    _buildCaloriSection(),
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
    return Row(
      children: [
        const ProfileAvatar(radius: 22, iconSize: 24),
        const SizedBox(width: 12),
        Text('Hi $_username', style: const TextStyle(color: limeGreen, fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCalendarCard() {
    const dayLabels = ['MON','TUE','WED','THU','FRI','SAT','SUN'];
    return Container(
      decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));
                  _fetchMonthData();
                },
                child: const Icon(Icons.chevron_left, color: Colors.black54),
              ),
              Text(_monthLabel, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
              GestureDetector(
                onTap: () {
                  setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));
                  _fetchMonthData();
                },
                child: const Icon(Icons.chevron_right, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayLabels.map((d) => SizedBox(width: 32, child: Text(d, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.w600)))).toList(),
          ),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final totalCells = _firstWeekdayOfMonth + _daysInMonth;
    final rows = (totalCells / 7).ceil();
    return Column(
      children: List.generate(rows, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (col) {
            final dayNumber = row * 7 + col - _firstWeekdayOfMonth + 1;
            if (dayNumber < 1 || dayNumber > _daysInMonth) return const SizedBox(width: 32, height: 32);
            
            final isSelected = dayNumber == _selectedDate.day && _focusedMonth.month == _selectedDate.month && _focusedMonth.year == _selectedDate.year;
            final hasSchedule = _activeDays.contains(dayNumber);
            
            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber));
                _fetchDailyActivities();
              },
              child: Container(
                width: 32, height: 32,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? limeGreen : (hasSchedule ? limeGreen.withOpacity(0.3) : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$dayNumber', 
                    style: TextStyle(
                      color: isSelected ? Colors.black : (hasSchedule ? limeGreen : Colors.black87), 
                      fontWeight: (isSelected || hasSchedule) ? FontWeight.bold : FontWeight.normal, 
                      fontSize: 13,
                    )
                  )
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildActivityItem(AktifitasHarianModel activity) {
    IconData iconData = Icons.fitness_center;
    if (activity.idJenisAktifitas?.toLowerCase().contains('lari') == true || 
        activity.idJenisAktifitas?.toLowerCase().contains('cardio') == true) {
      iconData = Icons.directions_run;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A3E))),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: limeGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(iconData, color: limeGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(activity.idJenisAktifitas ?? 'Aktivitas', style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${activity.durasiLatihan ?? 0} min', style: const TextStyle(color: grey, fontSize: 12)),
            ]),
          ),
          Text('${(activity.totalKalori ?? 0).toInt()} kkal', style: const TextStyle(color: grey, fontSize: 13)),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
            onPressed: () => _confirmDeleteActivity(activity),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteActivity(AktifitasHarianModel activity) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1630),
        title: const Text('Hapus Aktivitas', style: TextStyle(color: Colors.white)),
        content: const Text('Apakah Anda yakin ingin menghapus aktivitas ini?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && activity.idAktifitasHarian != null) {
      await LocalDBHelper.instance.deleteAktifitasHarian(activity.idAktifitasHarian!);
      _fetchDailyActivities(); // Refresh the list
      _fetchMonthData(); // Refresh the calendar dots
    }
  }

  Widget _buildCaloriSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kalori Terbakar', style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A3E))),
          child: Text('${_burnedCalories.toInt()} kkal', style: const TextStyle(color: limeGreen, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}