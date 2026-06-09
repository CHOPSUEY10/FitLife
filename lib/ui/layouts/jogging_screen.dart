import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../features/marathon/logic/jogging_controller.dart';

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
  late final JoggingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = JoggingController();
    _controller.checkPermission().then((_) {
      if (_controller.hasPermission && _controller.currentPosition != null) {
        _mapController.move(_controller.currentPosition!, 16);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startRun() {
    _controller.startRun((LatLng newPoint) {
      if (mounted) {
        _mapController.move(newPoint, _mapController.camera.zoom);
      }
    });
  }

  void _stopRun() async {
    await _controller.stopRun();
    if (!mounted) return;
    _showResultDialog();
  }

  String get _formattedDuration {
    final secs = _controller.durationSeconds;
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    final s = secs % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _formattedDistance {
    final dist = _controller.distanceMeters;
    if (dist < 1000) return '${dist.toStringAsFixed(0)} m';
    return '${(dist / 1000).toStringAsFixed(2)} km';
  }

  String get _formattedPace {
    final pace = _controller.avgPace;
    if (pace == 0) return "--'--\"";
    final min = pace.floor();
    final sec = ((pace - min) * 60).round();
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
                  color: const Color(0xFF0F0C1B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _resultRow('Jarak', _formattedDistance, Icons.straighten),
                    const Divider(color: Color(0xFF2A2A3E), height: 20),
                    _resultRow('Durasi', _formattedDuration, Icons.timer_outlined),
                    const Divider(color: Color(0xFF2A2A3E), height: 20),
                    _resultRow('Kalori', '${_controller.calories.toStringAsFixed(0)} kkal', Icons.local_fire_department_outlined),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
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
      },
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
              color: _controller.isRunning && !_controller.isPaused ? limeGreen.withOpacity(0.15) : cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _controller.isRunning && !_controller.isPaused ? limeGreen : const Color(0xFF2A2A3E),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _controller.isRunning && !_controller.isPaused ? limeGreen : grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _controller.isRunning && !_controller.isPaused
                      ? 'Live'
                      : _controller.isPaused
                      ? 'Paused'
                      : 'Ready',
                  style: TextStyle(
                    color: _controller.isRunning && !_controller.isPaused ? limeGreen : grey,
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
    if (!_controller.hasPermission) {
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
                onPressed: _controller.checkPermission,
                child: const Text('Izinkan Lokasi'),
              ),
            ],
          ),
        ),
      );
    }

    final center = _controller.currentPosition ?? const LatLng(-6.2088, 106.8456);

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
        if (_controller.routePoints.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _controller.routePoints,
                color: limeGreen,
                strokeWidth: 5,
              ),
            ],
          ),
        if (_controller.currentPosition != null)
          MarkerLayer(
            markers: [
              if (_controller.routePoints.isNotEmpty)
                Marker(
                  point: _controller.routePoints.first,
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
                point: _controller.currentPosition!,
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
          _statItem('Kalori', '${_controller.calories.toStringAsFixed(0)} kkal', Icons.local_fire_department_outlined),
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
    if (!_controller.isRunning) {
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
            onPressed: _controller.hasPermission ? _startRun : _controller.checkPermission,
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
                backgroundColor: _controller.isPaused ? limeGreen : const Color(0xFF2A2A3E),
                foregroundColor: _controller.isPaused ? Colors.black : white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _controller.isPaused ? _controller.resumeRun : _controller.pauseRun,
              icon: Icon(_controller.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 24),
              label: Text(
                _controller.isPaused ? 'Lanjut' : 'Pause',
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