import 'package:flutter/material.dart';
import '../../features/workout/logic/workout_logic.dart';

class ArmWorkoutScreen extends StatefulWidget {
  const ArmWorkoutScreen({Key? key}) : super(key: key);

  @override
  State<ArmWorkoutScreen> createState() => _ArmWorkoutScreenState();
}

class _ArmWorkoutScreenState extends State<ArmWorkoutScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isResting = false;
  bool _workoutStarted = false;
  int _restCountdown = 15;

  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _exercises = [
    {
      'name': 'Bicep Curl',
      'reps': '12 Reps',
      'duration': 35,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Berdiri tegak, tekuk siku angkat beban ke bahu, turunkan perlahan.',
      'tip': 'Jaga siku tetap di samping tubuh',
    },
    {
      'name': 'Tricep Dip',
      'reps': '10 Reps',
      'duration': 40,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Tangan di kursi di belakang, turunkan tubuh dengan menekuk siku.',
      'tip': 'Turun sampai siku 90 derajat',
    },
    {
      'name': 'Hammer Curl',
      'reps': '12 Reps',
      'duration': 35,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Seperti bicep curl tapi dengan posisi tangan netral.',
      'tip': 'Kontrol gerakan naik dan turun',
    },
    {
      'name': 'Overhead Tricep Ext.',
      'reps': '10 Reps',
      'duration': 40,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Angkat beban di atas kepala, tekuk siku ke belakang lalu luruskan.',
      'tip': 'Jaga lengan atas tetap di posisi',
    },
    {
      'name': 'Chin Up',
      'reps': '8 Reps',
      'duration': 45,
      'image': 'assets/illustration/pushup.webp',
      'description': 'Gantung di palang, telapak menghadap wajah, tarik tubuh ke atas.',
      'tip': 'Fokus pada kontraksi bisep',
    },
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 35));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
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
      setState(() { _isResting = true; _restCountdown = 15; });
      _runRestCountdown();
    } else {
      _onWorkoutFinished();
    }
  }

  void _runRestCountdown() async {
    for (int i = 15; i >= 0; i--) {
      if (!mounted) return;
      setState(() => _restCountdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() { _isResting = false; _currentIndex++; _workoutStarted = false; });
    _progressController.reset();
  }

  void _onWorkoutFinished() async {
    final totalMin = _exercises.fold<int>(0, (s, e) => s + (e['duration'] as int)) ~/ 60 + 1;
    final logic = WorkoutLogic();
    final cal = await logic.saveWorkoutRecord(idJenisAktifitas: 'arm_workout', durasiLatihan: totalMin);
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
            const Text('Kerja bagus! Kamu berhasil menyelesaikan semua latihan Arm Workout.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
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
        const Expanded(child: Text('Arm Workout', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF1A1630), borderRadius: BorderRadius.circular(20)), child: Text('${_currentIndex + 1}/${_exercises.length}', style: const TextStyle(color: Color(0xFFC6FF00), fontSize: 13, fontWeight: FontWeight.bold))),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _currentIndex / _exercises.length, minHeight: 6, backgroundColor: const Color(0xFF2A2545), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC6FF00))))),
      const SizedBox(height: 20),
      Expanded(flex: 4, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
        width: double.infinity, decoration: BoxDecoration(color: const Color(0xFFC6FF00), borderRadius: BorderRadius.circular(24)),
        child: Stack(children: [
          Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)), child: Text('Gerakan ${_currentIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
          Center(child: Padding(padding: const EdgeInsets.only(top: 20), child: Image.asset(exercise['image'], height: 200, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, size: 100, color: Colors.black26)))),
          if (_workoutStarted) Positioned(bottom: 0, left: 0, right: 0, child: AnimatedBuilder(animation: _progressController, builder: (_, __) => ClipRRect(borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)), child: LinearProgressIndicator(value: _progressController.value, minHeight: 8, backgroundColor: Colors.black12, valueColor: const AlwaysStoppedAnimation<Color>(Colors.black))))),
        ]),
      ))),
      const SizedBox(height: 20),
      Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise['name'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(exercise['reps'], style: const TextStyle(color: Color(0xFFC6FF00), fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1A1630), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.timer_outlined, color: Color(0xFFC6FF00), size: 16), const SizedBox(width: 4), Text('${exercise['duration']}s', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))])),
        ]),
        const SizedBox(height: 12),
        Text(exercise['description'], style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1A1630), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFC6FF00).withOpacity(0.3))), child: Row(children: [const Icon(Icons.lightbulb_outline, color: Color(0xFFC6FF00), size: 16), const SizedBox(width: 8), Expanded(child: Text(exercise['tip'], style: const TextStyle(color: Colors.white70, fontSize: 12)))])),
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
