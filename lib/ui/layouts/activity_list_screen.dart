import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'add_activity_screen.dart';
import 'settings_screen.dart';

class ActivityListScreen extends StatefulWidget {
  final int initialNavIndex;
  final Function(int)? onNavTapped;

  const ActivityListScreen({
    Key? key,
    this.initialNavIndex = 2,
    this.onNavTapped,
  }) : super(key: key);

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);

  late int _bottomNavIndex;
  DateTime _focusedMonth = DateTime(2024, 10);
  DateTime _selectedDate = DateTime(2024, 10, 18);

  final List<Map<String, dynamic>> _activities = [
    {'name': 'Lari Maraton', 'duration': '45 min', 'calories': '210 kkal', 'icon': Icons.directions_run},
    {'name': 'Push Up', 'duration': '21 min', 'calories': '128 kkal', 'icon': Icons.fitness_center},
    {'name': 'Pull Up', 'duration': '21 min', 'calories': '129 kkal', 'icon': Icons.accessibility_new},
  ];

  final double _burnedCalories = 645;
  final double _targetCalories = 1000;

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialNavIndex;
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

  void _handleNavTap(int index) {
    if (index == 2) return;
    if (widget.onNavTapped != null) { widget.onNavTapped!(index); return; }
    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => AddActivityScreen(initialNavIndex: 1, onNavTapped: (i) => Navigator.pop(context)),
      ));
    } else if (index == 3) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
    } else {
      Navigator.pop(context);
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
                    ..._activities.map(_buildActivityItem),
                    const SizedBox(height: 24),
                    _buildCaloriSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            CustomBottomNavBar(selectedIndex: _bottomNavIndex, onItemTapped: _handleNavTap),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(radius: 22, backgroundColor: Colors.grey[800], child: const Icon(Icons.person, color: white, size: 24)),
        const SizedBox(width: 12),
        const Text('Hi Gibran', style: TextStyle(color: limeGreen, fontSize: 18, fontWeight: FontWeight.w600)),
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
              GestureDetector(onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)), child: const Icon(Icons.chevron_left, color: Colors.black54)),
              Text(_monthLabel, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
              GestureDetector(onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)), child: const Icon(Icons.chevron_right, color: Colors.black54)),
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
            return GestureDetector(
              onTap: () => setState(() => _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber)),
              child: Container(
                width: 32, height: 32,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: isSelected ? const BoxDecoration(color: limeGreen, shape: BoxShape.circle) : null,
                child: Center(child: Text('$dayNumber', style: TextStyle(color: isSelected ? Colors.black : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13))),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A3E))),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: limeGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(activity['icon'] as IconData, color: limeGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(activity['name'] as String, style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w600)),
              Text(activity['duration'] as String, style: const TextStyle(color: grey, fontSize: 12)),
            ]),
          ),
          Text(activity['calories'] as String, style: const TextStyle(color: grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCaloriSection() {
    final progress = _burnedCalories / _targetCalories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kalori Terbakar', style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A3E))),
          child: Column(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFF333355), valueColor: const AlwaysStoppedAnimation<Color>(limeGreen), minHeight: 12)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_burnedCalories.toInt()} / ${_targetCalories.toInt()} kkal', style: const TextStyle(color: grey, fontSize: 12)),
                  Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(color: limeGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}