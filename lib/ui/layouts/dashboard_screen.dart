import 'package:flutter/material.dart';
import '../../features/dashboard/logic/dashboard_controller.dart';
import '../components/stats_card.dart';
import '../components/map_placeholder_card.dart';
import '../components/workout_card.dart';
import '../components/bottom_nav_bar.dart';
import 'add_activity_screen.dart';
import 'abs_workout_screen.dart';
import 'chest_workout_screen.dart';
import 'arm_workout_screen.dart';
import 'leg_workout_screen.dart';
import 'activity_list_screen.dart';
import 'settings_screen.dart';
import 'jogging_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;
  int _bottomNavIndex = 0;
  String _selectedCategory = 'All Workouts';

  // Workout items tagged by category
  final List<Map<String, dynamic>> _workoutItems = [
    {
      'title': 'Abs\nWorkout',
      'subtitle': '10x Plank Crunches',
      'imagePath': 'assets/illustration/plank.webp',
      'category': 'Core',
      'screen': const AbsWorkoutScreen(),
    },
    {
      'title': 'Chest\nWorkout',
      'subtitle': 'Beginner Push Ups\nDiamond Push Up',
      'imagePath': 'assets/illustration/pushup.webp',
      'category': 'Upper Body',
      'screen': const ChestWorkoutScreen(),
    },
    {
      'title': 'Arm\nWorkout',
      'subtitle': 'Bicep Curl\nTricep Dip',
      'imagePath': 'assets/illustration/pushup.webp',
      'category': 'Upper Body',
      'screen': const ArmWorkoutScreen(),
    },
    {
      'title': 'Leg\nWorkout',
      'subtitle': 'Squat & Lunge\nCalf Raise',
      'imagePath': 'assets/illustration/plank.webp',
      'category': 'Lower Body',
      'screen': const LegWorkoutScreen(),
    },
    {
      'title': 'Jogging\n/ Lari',
      'subtitle': 'Track rute & kalori real-time',
      'imagePath': 'assets/illustration/plank.webp',
      'category': 'Cardio',
      'screen': const JoggingScreen(),
    },
  ];

  List<Map<String, dynamic>> get _scheduledWorkouts {
    // If no workouts assigned today, return empty
    if (_controller.todayWorkouts.isEmpty) return [];
    
    // Create a set of assigned workout category names, in lowercase for loose matching
    final assignedNames = _controller.todayWorkouts
        .map((w) => (w.idJenisAktifitas ?? '').toLowerCase())
        .toSet();

    // Filter our hardcoded cards by checking if their titles match the assigned names
    return _workoutItems.where((item) {
      final title = (item['title'] as String).replaceAll('\n', ' ').toLowerCase();
      return assignedNames.any((assigned) => assigned.contains(title) || title.contains(assigned));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _controller = DashboardController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToWorkout(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) {
      _controller.fetchTodayCalories();
      _controller.fetchTodayWorkouts();
    });
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
                padding: const EdgeInsets.all(16.0),
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
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Text(
                              'Hi ${_controller.username}',
                              style: const TextStyle(
                                color: Color(0xFFC6FF00),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Time
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Text(
                          _controller.getFormattedDateTime(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Stats + Map
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              StatsCard(
                                title: 'Steps',
                                value: '${_controller.currentSteps}/2000',
                                backgroundColor: const Color(0xFFC6FF00),
                                titleColor: Colors.black,
                                valueColor: Colors.black,
                                iconPath: 'assets/icon/step.png',
                                customProgress: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final progress = (_controller.currentSteps / 2000).clamp(0.0, 1.0);
                                    return Stack(
                                      children: [
                                        Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        Container(
                                          height: 8,
                                          width: constraints.maxWidth * progress,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Dynamic Calorie Card
                              AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final cal = _controller.todayCalories;
                                  return StatsCard(
                                    title: 'Kalori Terbakar',
                                    value: '${cal.toInt()} kkal',
                                    backgroundColor: Colors.white,
                                    titleColor: Colors.grey,
                                    valueColor: Colors.black,
                                    iconPath: 'assets/icon/stat.png',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 220,
                            child: MapPlaceholderCard(),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Daily Plan
                    const Text(
                      'Jadwal Latihan Hari Ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Workout Cards — Only showing scheduled workouts
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final scheduled = _scheduledWorkouts;
                        if (scheduled.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'Tidak ada jadwal latihan hari ini.\nTambahkan di layar Add Activity!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54, fontSize: 14),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: scheduled.map((workout) => WorkoutCard(
                            title: workout['title'],
                            subtitle: workout['subtitle'],
                            imagePath: workout['imagePath'],
                            onTap: () => _navigateToWorkout(workout['screen'] as Widget),
                          )).toList(),
                        );
                      }
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Nav
            CustomBottomNavBar(
              selectedIndex: _bottomNavIndex,
              onItemTapped: (index) {
                if (index == 0) {
                  setState(() => _bottomNavIndex = 0);
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddActivityScreen(
                        initialNavIndex: 1,
                        onNavTapped: (i) {
                          Navigator.pop(context);
                          if (i != 1) setState(() => _bottomNavIndex = i);
                        },
                      ),
                    ),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActivityListScreen(
                        initialNavIndex: 2,
                        onNavTapped: (i) {
                          Navigator.pop(context);
                          setState(() => _bottomNavIndex = i);
                        },
                      ),
                    ),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        initialNavIndex: 3,
                        onNavTapped: (i) {
                          Navigator.pop(context);
                          setState(() => _bottomNavIndex = i);
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = label);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC6FF00) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFC6FF00) : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}