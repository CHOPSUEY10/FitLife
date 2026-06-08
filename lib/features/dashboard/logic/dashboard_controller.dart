import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/database/local_db_helper.dart';
import '../../../core/models/aktifitas_harian_model.dart';
import '../../../core/models/target_harian_model.dart';
import '../../workout/logic/workout_logic.dart';
import '../../step_tracker/logic/step_tracker_logic.dart';

class DashboardController extends ChangeNotifier {
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  String _username = 'User';
  double _todayCalories = 0.0;
  List<AktifitasHarianModel> _todayWorkouts = [];
  
  int _targetLangkah = 8000;
  double _targetKalori = 500.0;

  final StepTrackerLogic _stepTracker = StepTrackerLogic();
  int _currentSteps = 0;
  StreamSubscription<int>? _stepSubscription;

  DateTime get currentDateTime => _currentDateTime;
  String get username => _username;
  double get todayCalories => _todayCalories;
  List<AktifitasHarianModel> get todayWorkouts => _todayWorkouts;
  int get currentSteps => _currentSteps;
  
  int get targetLangkah => _targetLangkah;
  double get targetKalori => _targetKalori;

  DashboardController() {
    _startTimer();
    _fetchUsername();
    fetchTodayCalories();
    fetchTodayWorkouts();
    fetchTargetHarian();
    _initStepTracker();
  }

  void _initStepTracker() {
    _stepTracker.startTracking();
    _stepSubscription = _stepTracker.stepStream.listen((steps) {
      _currentSteps = steps;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stepSubscription?.cancel();
    _stepTracker.stopTracking();
    super.dispose();
  }

  Future<void> _fetchUsername() async {
    final userMetrics = await LocalDBHelper.instance.getUserMetrics();
    if (userMetrics != null && userMetrics.nama != null && userMetrics.nama!.isNotEmpty) {
      _username = userMetrics.nama!;
      notifyListeners();
    }
  }

  /// Fetch today's total calories from the database and notify listeners
  Future<void> fetchTodayCalories() async {
    final logic = WorkoutLogic();
    _todayCalories = await logic.getTodayCalories();
    notifyListeners();
  }

  /// Fetch today's assigned workouts from the database
  Future<void> fetchTodayWorkouts() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    _todayWorkouts = await LocalDBHelper.instance.getAktifitasHarianByDate(today);
    notifyListeners();
  }

  /// Fetch dynamic workout target harian from SQLite database
  Future<void> fetchTargetHarian() async {
    try {
      final target = await LocalDBHelper.instance.getTargetHarian();
      _targetLangkah = target.targetLangkah;
      _targetKalori = target.targetKalori;
      notifyListeners();
    } catch (e) {
      debugPrint('DashboardController fetchTargetHarian error: $e');
    }
  }

  /// Refresh all data displayed on dashboard
  Future<void> refreshData() async {
    await _fetchUsername();
    await fetchTodayCalories();
    await fetchTodayWorkouts();
    await fetchTargetHarian();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDateTime = DateTime.now();
      notifyListeners();
    });
  }

  String getFormattedDateTime() {
    // Format: "Sabtu 14 Feb - 08:45"
    final List<String> days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu'
    ];
    final List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    String dayName = days[_currentDateTime.weekday % 7];
    String day = _currentDateTime.day.toString().padLeft(2, '0');
    String monthName = months[_currentDateTime.month - 1];
    String hour = _currentDateTime.hour.toString().padLeft(2, '0');
    String minute = _currentDateTime.minute.toString().padLeft(2, '0');

    return '$dayName $day $monthName - $hour:$minute';
  }

}
