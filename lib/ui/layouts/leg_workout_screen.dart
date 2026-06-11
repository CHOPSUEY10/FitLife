import 'package:flutter/material.dart';
import '../../features/workout/logic/workout_logic.dart';
import '../../features/workout/logic/workout_generator.dart';
import '../../features/dashboard/logic/settings_controller.dart';

class LegWorkoutScreen extends StatefulWidget {
  const LegWorkoutScreen({super.key});

  @override
  State<LegWorkoutScreen> createState() => _LegWorkoutScreenState();
}

class _LegWorkoutScreenState extends State<LegWorkoutScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isResting = false;
  bool _workoutStarted = false;
  int _restCountdown = 15;

  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late List<Map<String, dynamic>> _exercises = [];
  late final SettingsController _settingsController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsController();
    _initWorkoutData();
  }

  Future<void> _initWorkoutData() async {
    // 1. Tunggu loading data preferensi user dari database / shared_prefs
    await _settingsController.loadAll();
    
    // 2. Generate workout berdasarkan level aktivitas dan waktu luang
    if (mounted) {
      setState(() {
        _exercises = WorkoutGenerator.generateWorkout(
          'leg', 
          _settingsController.levelAktivitas, 
          _settingsController.waktuLuang
        );
        
        // 3. Inisialisasi controller animasi berdasarkan durasi gerakan pertama
        _progressController = AnimationController(
          vsync: this, 
          duration: Duration(seconds: _exercises.isNotEmpty ? _exercises[0]['duration'] : 40)
        );
        
        _pulseController = AnimationController(
          vsync: this, 
          duration: const Duration(milliseconds: 900)
        )..repeat(reverse: true);
        
        _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
        );
        
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() => _workoutStarted = true);
    _progressController.duration = Duration(seconds: _exercises[_currentIndex]['duration']);
    _progressController.forward(from: 0);
  }

  void _nextExercise() {
    if (_currentIndex < _exercises.length - 1) {
      int restTime = _exercises[_currentIndex]['restDuration'] ?? 15;
      setState(() { _isResting = true; _restCountdown = restTime; });
      _runRestCountdown();
    } else {
      _onWorkoutFinished();
    }
  }

  void _runRestCountdown() async {
    for (int i = _restCountdown; i >= 0; i--) {
      if (!mounted) return;
      setState(() => _restCountdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() { _isResting = false; _currentIndex++; _workoutStarted = false; });
    _progressController.reset();
  }

  void _onWorkoutFinished() async {
    int totalSec = 0;
    for (int i = 0; i < _exercises.length; i++) {
      totalSec += _exercises[i]['duration'] as int;
      if (i < _exercises.length - 1) {
        totalSec += (_exercises[i]['restDuration'] as int?) ?? 15;
      }
    }
    final totalMin = (totalSec / 60.0).ceil();
    final logic = WorkoutLogic();
    final cal = await logic.saveWorkoutRecord(idJenisAktifitas: 'leg_workout', durasiLatihan: totalMin);
    if (!mounted) return;
    _showFinishDialog(cal, totalMin);
  }

  void _showFinishDialog(double cal, int dur) {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1630),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72, decoration: const BoxDecoration(color: Color(0xFFC6FF00), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.black, size: 40)),
            const SizedBox(height: 20),
            const Text('Latihan Selesai!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Kerja bagus! Kamu berhasil menyelesaikan semua latihan Leg Workout.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
            Row(children: [
              _buildStatBadge('${_exercises.length}', 'Gerakan'),
              const SizedBox(width: 10),
              _buildStatBadge('~${cal.toInt()}', 'Kalori'),
              const SizedBox(width: 10),
              _buildStatBadge('${dur}m', 'Durasi'),
            ]),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC6FF00), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: const Text('Kembali ke Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String value, String label) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF2A2545), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: const TextStyle(color: Color(0xFFC6FF00), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0C1B),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFC6FF00))),
      );
    }
    if (_exercises.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0C1B),
        body: Center(child: Text('Tidak ada gerakan tersedia', style: TextStyle(color: Colors.white))),
      );
    }

    final exercise = _exercises[_currentIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C1B),
      body: SafeArea(child: _isResting ? _buildRestScreen() : _buildWorkoutScreen(exercise)),
    );
  }

  Widget _buildRestScreen() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('Istirahat', style: TextStyle(color: Colors.white60, fontSize: 16)),
      const SizedBox(height: 20),
      ScaleTransition(scale: _pulseAnimation, child: Container(
        width: 160, height: 160,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFC6FF00), width: 4)),
        alignment: Alignment.center,
        child: Text('$_restCountdown', style: const TextStyle(color: Color(0xFFC6FF00), fontSize: 64, fontWeight: FontWeight.bold)),
      )),
      const SizedBox(height: 24),
      const Text('Berikutnya:', style: TextStyle(color: Colors.white60, fontSize: 14)),
      const SizedBox(height: 8),
      Text(_exercises[_currentIndex + 1]['name'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      Text(_exercises[_currentIndex + 1]['reps'], style: const TextStyle(color: Color(0xFFC6FF00), fontSize: 16)),
    ]);
  }

  Widget _buildWorkoutScreen(Map<String, dynamic> exercise) {
    return Column(children: [
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFF1A1630), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16))),
        const Expanded(child: Text('Leg Workout', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1A1630), borderRadius: BorderRadius.circular(20)), child: Text('${_currentIndex + 1}/${_exercises.length}', style: const TextStyle(color: Color(0xFFC6FF00), fontSize: 13, fontWeight: FontWeight.bold))),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _currentIndex / _exercises.length, minHeight: 6, backgroundColor: const Color(0xFF2A2545), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC6FF00))))),
      const SizedBox(height: 20),
      Expanded(flex: 4, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
        width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFC6FF00), borderRadius: BorderRadius.circular(24)),
        child: Stack(children: [
          Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: Text('Gerakan ${_currentIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
          Center(child: Padding(padding: const EdgeInsets.only(top: 20), child: Image.asset(exercise['image'], height: 200, fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.fitness_center, size: 100, color: Colors.black26)))),
          if (_workoutStarted) Positioned(bottom: 0, left: 0, right: 0, child: AnimatedBuilder(animation: _progressController, builder: (_, _) => ClipRRect(borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)), child: LinearProgressIndicator(value: _progressController.value, minHeight: 8, backgroundColor: Colors.black12, valueColor: const AlwaysStoppedAnimation<Color>(Colors.black))))),
        ]),
      ))),
      const SizedBox(height: 20),
      Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(exercise['reps'], style: const TextStyle(color: Color(0xFFC6FF00), fontSize: 14, fontWeight: FontWeight.w600)),
          ])),
          const SizedBox(width: 12),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1A1630), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.timer_outlined, color: Color(0xFFC6FF00), size: 16), const SizedBox(width: 4), AnimatedBuilder(animation: _progressController, builder: (context, child) { int remaining = _workoutStarted ? (exercise['duration'] * (1 - _progressController.value)).ceil() : exercise['duration']; return Text('${remaining}s', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)); })])),
        ]),
        const SizedBox(height: 12),
        Text(exercise['description'], style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1A1630), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFC6FF00).withValues(alpha: 0.3))), child: Row(children: [const Icon(Icons.lightbulb_outline, color: Color(0xFFC6FF00), size: 16), const SizedBox(width: 8), Expanded(child: Text(exercise['tip'], style: const TextStyle(color: Colors.white70, fontSize: 12)))])),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_exercises.length, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: i == _currentIndex ? 20 : 8, height: 8, decoration: BoxDecoration(color: i <= _currentIndex ? const Color(0xFFC6FF00) : const Color(0xFF2A2545), borderRadius: BorderRadius.circular(4))))),
        const SizedBox(height: 16),
        Row(children: [
          if (_workoutStarted) ...[
            Expanded(child: OutlinedButton(onPressed: () { _progressController.reset(); setState(() => _workoutStarted = false); }, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF2A2545)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Reset'))),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: ElevatedButton(onPressed: _nextExercise, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC6FF00), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: Text(_currentIndex == _exercises.length - 1 ? 'Selesai ✓' : 'Lanjut →', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)))),
          ] else
            Expanded(child: ElevatedButton(onPressed: _startExercise, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC6FF00), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0), child: const Text('Mulai Latihan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
        ]),
        const SizedBox(height: 16),
      ]))),
    ]);
  }
}
