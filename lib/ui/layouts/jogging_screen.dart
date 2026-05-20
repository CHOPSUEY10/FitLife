import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../features/workout/logic/workout_logic.dart';
import '../../features/marathon/logic/location_logic.dart';

class JoggingScreen extends StatefulWidget {
  const JoggingScreen({Key? key}) : super(key: key);

  @override
  State<JoggingScreen> createState() => _JoggingScreenState();
}

class _JoggingScreenState extends State<JoggingScreen> {
  static const Color bgColor = Color(0xFF0F0C1B);
  static const Color cardColor = Color(0xFF1A1A2E);
  static const Color limeGreen = Color(0xFFC6FF00);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF888888);

  final MapController _mapController = MapController();
  final List<LatLng> _routePoints = [];
  LatLng? _currentPosition;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _hasPermission = false;

  double _distanceMeters = 0;
  int _durationSeconds = 0;
  double _calories = 0;
  double _avgPace = 0;

  final LocationLogic _locationLogic = LocationLogic();

  StreamSubscription<LatLng>? _positionStream;
  Timer? _durationTimer;
  LatLng? _lastPosition;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await _locationLogic.checkAndRequestPermission();
    if (hasPermission) {
      setState(() => _hasPermission = true);
      await _initCurrentLocation();
    }
  }

  Future<void> _initCurrentLocation() async {
    final latLng = await _locationLogic.getCurrentLocation();
    if (latLng != null) {
      setState(() => _currentPosition = latLng);
      _mapController.move(latLng, 16);
    }
  }

  void _startRun() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _durationSeconds++);
    });

    _positionStream = _locationLogic.getLocationStream(distanceFilter: 5)
        .listen((LatLng newPoint) {
      setState(() {
        _currentPosition = newPoint;
        _routePoints.add(newPoint);
        if (_lastPosition != null) {
          final dist = _locationLogic.calculateDistance(_lastPosition!, newPoint);
          _distanceMeters += dist;
          _calories = _distanceMeters / 1000 * 60;
        }
        if (_distanceMeters > 0 && _durationSeconds > 0) {
          _avgPace = (_durationSeconds / 60) / (_distanceMeters / 1000);
        }
        _lastPosition = newPoint;
      });
      _mapController.move(newPoint, _mapController.camera.zoom);
    });
  }

  void _pauseRun() {
    setState(() => _isPaused = true);
    _positionStream?.pause();
    _durationTimer?.cancel();
  }

  void _resumeRun() {
    setState(() => _isPaused = false);
    _positionStream?.resume();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _durationSeconds++);
    });
  }

  void _stopRun() async {
    _positionStream?.cancel();
    _durationTimer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    // Save workout record to DB
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
    // Update displayed calories with DB-computed value
    if (savedCal > 0) {
      setState(() => _calories = savedCal);
    }

    if (!mounted) return;
    _showResultDialog();
  }

  void _resetRun() {
    setState(() {
      _routePoints.clear();
      _distanceMeters = 0;
      _durationSeconds = 0;
      _calories = 0;
      _avgPace = 0;
      _lastPosition = null;
      _isRunning = false;
      _isPaused = false;
    });
  }

  String get _formattedDuration {
    final h = _durationSeconds ~/ 3600;
    final m = (_durationSeconds % 3600) ~/ 60;
    final s = _durationSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _formattedDistance {
    if (_distanceMeters < 1000) return '${_distanceMeters.toStringAsFixed(0)} m';
    return '${(_distanceMeters / 1000).toStringAsFixed(2)} km';
  }

  String get _formattedPace {
    if (_avgPace == 0) return "--'--\"";
    final min = _avgPace.floor();
    final sec = ((_avgPace - min) * 60).round();
    return "$min'${sec.toString().padLeft(2, '0')}\"";
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: limeGreen, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Lari Selesai! 🎉',
                style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Kerja bagus! Terus semangat.', style: TextStyle(color: grey, fontSize: 13)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0F0C1B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _resultRow('Jarak', _formattedDistance, Icons.straighten),
                    const Divider(color: Color(0xFF2A2A3E), height: 20),
                    _resultRow('Durasi', _formattedDuration, Icons.timer_outlined),
                    const Divider(color: Color(0xFF2A2A3E), height: 20),
                    _resultRow('Kalori', '${_calories.toStringAsFixed(0)} kkal', Icons.local_fire_department_outlined),
                    const Divider(color: Color(0xFF2A2A3E), height: 20),
                    _resultRow('Avg Pace', '$_formattedPace /km', Icons.speed),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: limeGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: limeGreen, size: 16),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: grey, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildMap()),
            _buildStatsBar(),
            _buildControls(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A3E)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Jogging / Lari',
            style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isRunning && !_isPaused ? limeGreen.withOpacity(0.15) : cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isRunning && !_isPaused ? limeGreen : const Color(0xFF2A2A3E),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isRunning && !_isPaused ? limeGreen : grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isRunning && !_isPaused
                      ? 'Live'
                      : _isPaused
                      ? 'Paused'
                      : 'Ready',
                  style: TextStyle(
                    color: _isRunning && !_isPaused ? limeGreen : grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (!_hasPermission) {
      return Container(
        color: cardColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, color: grey, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Izin lokasi diperlukan',
                style: TextStyle(color: white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: limeGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: _checkPermission,
                child: const Text('Izinkan Lokasi'),
              ),
            ],
          ),
        ),
      );
    }

    final center = _currentPosition ?? const LatLng(-6.2088, 106.8456);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.marathontracker',
        ),
        if (_routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                color: limeGreen,
                strokeWidth: 5,
              ),
            ],
          ),
        if (_currentPosition != null)
          MarkerLayer(
            markers: [
              if (_routePoints.isNotEmpty)
                Marker(
                  point: _routePoints.first,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.circle, color: Colors.white, size: 12),
                  ),
                ),
              Marker(
                point: _currentPosition!,
                width: 40,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: limeGreen.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: limeGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: limeGreen.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A3E)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Jarak', _formattedDistance, Icons.straighten),
          _divider(),
          _statItem('Waktu', _formattedDuration, Icons.timer_outlined),
          _divider(),
          _statItem('Kalori', '${_calories.toStringAsFixed(0)} kkal', Icons.local_fire_department_outlined),
          _divider(),
          _statItem('Pace', '$_formattedPace/km', Icons.speed),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: limeGreen, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: grey, fontSize: 10)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 36, color: const Color(0xFF2A2A3E));
  }

  Widget _buildControls() {
    if (!_isRunning) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: limeGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _hasPermission ? _startRun : _checkPermission,
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'Mulai Lari',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPaused ? limeGreen : const Color(0xFF2A2A3E),
                foregroundColor: _isPaused ? Colors.black : white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isPaused ? _resumeRun : _pauseRun,
              icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 24),
              label: Text(
                _isPaused ? 'Lanjut' : 'Pause',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                foregroundColor: white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _stopRun,
              icon: const Icon(Icons.stop_rounded, size: 24),
              label: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}