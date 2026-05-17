import 'package:flutter/material.dart';
import '../../features/dashboard/logic/dashboard_controller.dart';
import '../components/stats_card.dart';
import '../components/map_placeholder_card.dart';
import '../components/workout_card.dart';
import '../components/bottom_nav_bar.dart';
import 'add_activity_screen.dart';
import 'abs_workout_screen.dart';
import 'chest_workout_screen.dart';
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
                                value: '999/2000',
                                backgroundColor: const Color(0xFFC6FF00),
                                titleColor: Colors.black,
                                valueColor: Colors.black,
                                iconPath: 'assets/icon/step.png',
                                customProgress: Stack(
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
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              StatsCard(
                                title: 'Kalori Terbakar',
                                value: '645 / 1000\nkkal',
                                backgroundColor: Colors.white,
                                titleColor: Colors.grey,
                                valueColor: Colors.black,
                                iconPath: 'assets/icon/stat.png',
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
                      'Daily Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All Workouts', isSelected: true),
                          _buildFilterChip('Core'),
                          _buildFilterChip('Upper Body'),
                          _buildFilterChip('Lower Body'),
                          _buildFilterChip('Cardio'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Workout Cards
                    WorkoutCard(
                      title: 'Abs\nWorkout',
                      subtitle: '10x Plank Crunches',
                      imagePath: 'assets/illustration/plank.webp',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AbsWorkoutScreen()),
                        );
                      },
                    ),
                    WorkoutCard(
                      title: 'Chest\nWorkout',
                      subtitle: 'Beginner Push Ups\nDiamond Push Up',
                      imagePath: 'assets/illustration/pushup.webp',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChestWorkoutScreen()),
                        );
                      },
                    ),
                    WorkoutCard(
                      title: 'Jogging\n/ Lari',
                      subtitle: 'Track rute & kalori real-time',
                      imagePath: 'assets/illustration/plank.webp',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const JoggingScreen()),
                        );
                      },
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

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
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
    );
  }
}