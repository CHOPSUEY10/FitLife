// Lokasi: lib/features/marathon/logic/jogging_controller.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/database/local_db_helper.dart';
import '../../workout/logic/workout_logic.dart';
import 'location_logic.dart';

class JoggingController extends ChangeNotifier {
  final LocationLogic _locationLogic = LocationLogic();
  StreamSubscription<LatLng>? _positionStream;
  Timer? _durationTimer;

  final List<LatLng> _routePoints = [];
  LatLng? _currentPosition;
  LatLng? _lastPosition;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _hasPermission = false;

  double _distanceMeters = 0;
  int _durationSeconds = 0;
  double _calories = 0;
  double _avgPace = 0;
  double _userWeight = 70.0;

  // Getters
  List<LatLng> get routePoints => _routePoints;
  LatLng? get currentPosition => _currentPosition;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  bool get hasPermission => _hasPermission;
  double get distanceMeters => _distanceMeters;
  int get durationSeconds => _durationSeconds;
  double get calories => _calories;
  double get avgPace => _avgPace;

  Future<void> checkPermission() async {
    final permitted = await _locationLogic.checkAndRequestPermission();
    _hasPermission = permitted;
    if (_hasPermission) {
      await initCurrentLocation();
    }
    notifyListeners();
  }

  Future<void> initCurrentLocation() async {
    final latLng = await _locationLogic.getCurrentLocation();
    if (latLng != null) {
      _currentPosition = latLng;
      notifyListeners();
    }
    // Load user weight from DB to keep calorie calculation synchronized
    final user = await LocalDBHelper.instance.getUserMetrics();
    _userWeight = user?.beratBadan ?? 70.0;
  }

  void startRun(Function(LatLng) onPositionUpdated) {
    _isRunning = true;
    _isPaused = false;
    _distanceMeters = 0;
    _durationSeconds = 0;
    _calories = 0;
    _avgPace = 0;
    _routePoints.clear();
    _lastPosition = _currentPosition;
    notifyListeners();

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _durationSeconds++;
      // MET dynamic calorie calculation in real-time
      // Calories = MET (7.0 for jogging) * weight (kg) * duration (hours)
      _calories = 7.0 * _userWeight * (_durationSeconds / 3600.0);
      notifyListeners();
    });

    _positionStream = _locationLogic.getLocationStream(distanceFilter: 5)
        .listen((LatLng newPoint) {
      _currentPosition = newPoint;
      _routePoints.add(newPoint);
      if (_lastPosition != null) {
        final dist = _locationLogic.calculateDistance(_lastPosition!, newPoint);
        _distanceMeters += dist;
      }
      if (_distanceMeters > 0 && _durationSeconds > 0) {
        _avgPace = (_durationSeconds / 60) / (_distanceMeters / 1000);
      }
      _lastPosition = newPoint;
      onPositionUpdated(newPoint);
      notifyListeners();
    });
  }

  void pauseRun() {
    _isPaused = true;
    _positionStream?.pause();
    _durationTimer?.cancel();
    notifyListeners();
  }

  void resumeRun() {
    _isPaused = false;
    _positionStream?.resume();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _durationSeconds++;
      _calories = 7.0 * _userWeight * (_durationSeconds / 3600.0);
      notifyListeners();
    });
    notifyListeners();
  }

  Future<double> stopRun() async {
    _positionStream?.cancel();
    _durationTimer?.cancel();
    _isRunning = false;
    _isPaused = false;
    notifyListeners();

    final durationMinutes = (_durationSeconds / 60).ceil();
    final paceInt = _avgPace > 0 ? _avgPace.round() : null;
    final distanceKm = _distanceMeters / 1000;

    final logic = WorkoutLogic();
    final savedCal = await logic.saveWorkoutRecord(
      idJenisAktifitas: 'jogging',
      durasiLatihan: durationMinutes > 0 ? durationMinutes : 1,
      pace: paceInt,
      jarakTempuh: distanceKm,
    );
    if (savedCal > 0) {
      _calories = savedCal;
    }
    notifyListeners();
    return _calories;
  }

  void resetRun() {
    _routePoints.clear();
    _distanceMeters = 0;
    _durationSeconds = 0;
    _calories = 0;
    _avgPace = 0;
    _lastPosition = null;
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }
}
