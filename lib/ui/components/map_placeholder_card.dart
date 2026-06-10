import 'package:flutter/material.dart';
import '../../features/marathon/data/marathon_repository.dart';

class MapPlaceholderCard extends StatefulWidget {
  const MapPlaceholderCard({Key? key}) : super(key: key);

  @override
  State<MapPlaceholderCard> createState() => _MapPlaceholderCardState();
}

class _MapPlaceholderCardState extends State<MapPlaceholderCard> {
  String _durasi = '0m';
  String _jarak = '0.0 KM';
  String _pace = '0 m/km';

  @override
  void initState() {
    super.initState();
    _fetchCardioData();
  }

  Future<void> _fetchCardioData() async {
    final repo = MarathonRepository();
    final cardio = await repo.getCardioData();
    if (cardio != null && mounted) {
      setState(() {
        _durasi = '${cardio.durasi ?? 0}m';
        _jarak = '${cardio.jarakTempuh ?? 0.0} KM';
        _pace = '${cardio.pace ?? 0} m/km';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  // Mock map grid lines
                  CustomPaint(
                    size: Size.infinite,
                    painter: _GridPainter(),
                  ),
                  // Mock route line
                  CustomPaint(
                    size: Size.infinite,
                    painter: _RoutePainter(),
                  ),
                  // Pin Icon
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pelacak',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Durasi', _durasi),
                const SizedBox(height: 4),
                _buildInfoRow('Jarak', _jarak),
                const SizedBox(height: 4),
                _buildInfoRow('Pace', _pace),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0;

    // Draw some simple horizontal and vertical lines for map block appearance
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.6), Offset(size.width, size.height * 0.6), paint);
    
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC6FF00) // Lime Green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.3, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.6);
    path.lineTo(size.width * 0.7, size.height * 0.9);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
