import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

/// StepTrackerLogic manages the user's daily step count.
/// Implemented using the real pedometer sensor.
class StepTrackerLogic {
  final StreamController<int> _stepController = StreamController<int>.broadcast();
  StreamSubscription<StepCount>? _stepCountSubscription;
  int _currentSteps = 0;
  int _initialSteps = -1;

  /// Start tracking steps.
  void startTracking() async {
    bool granted = await _checkPermission();
    if (granted) {
      _initPedometer();
    } else {
      // Provide an initial 0 if permission is denied
      _stepController.add(0);
    }
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  void _initPedometer() {
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
      cancelOnError: true,
    );
  }

  void _onStepCount(StepCount event) {
    if (_initialSteps == -1) {
      _initialSteps = event.steps;
    }
    _currentSteps = event.steps - _initialSteps;
    _stepController.add(_currentSteps);
  }

  void _onStepCountError(error) {
    print('Pedometer Error: $error');
  }

  /// Stop tracking steps.
  void stopTracking() {
    _stepCountSubscription?.cancel();
    _stepController.close();
  }

  /// Returns a stream of the user's current step count.
  Stream<int> get stepStream => _stepController.stream;

  /// Returns the current step count synchronously.
  int get currentSteps => _currentSteps;
}
