import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/database/local_db_helper.dart';

class DashboardController extends ChangeNotifier {
  late Timer _timer;
  DateTime _currentDateTime = DateTime.now();
  String _username = 'User';

  DateTime get currentDateTime => _currentDateTime;
  String get username => _username;

  DashboardController() {
    _startTimer();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final userMetrics = await LocalDBHelper.instance.getUserMetrics();
    if (userMetrics != null && userMetrics.nama != null && userMetrics.nama!.isNotEmpty) {
      _username = userMetrics.nama!;
      notifyListeners();
    }
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
