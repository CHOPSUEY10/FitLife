import 'package:flutter/material.dart';
import '../../features/marathon/data/marathon_repository.dart';

class MapPlaceholderCard extends StatefulWidget {
  const MapPlaceholderCard({super.key});

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
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.only(
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
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.black,
                          size: 16,
                        ),
                        SizedBox(width: 4),
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
      ..strokeWidth = 2.0;

    // Draw a more comprehensive map grid
    final int hLines = 6;
    final int vLines = 6;
    
    for (int i = 1; i < hLines; i++) {
      double y = size.height * (i / hLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    for (int i = 1; i < vLines; i++) {
      double x = size.width * (i / vLines);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC6FF00) // Lime Green
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    // Start point
    final startPoint = Offset(size.width * 0.2, size.height * 0.8);
    path.moveTo(startPoint.dx, startPoint.dy);
    
    // Winding curve points
    path.cubicTo(
      size.width * 0.1, size.height * 0.5, 
      size.width * 0.5, size.height * 0.6, 
      size.width * 0.4, size.height * 0.3
    );
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.1, 
      size.width * 0.6, size.height * 0.15
    );
    path.quadraticBezierTo(
      size.width * 0.9, size.height * 0.2, 
      size.width * 0.8, size.height * 0.5
    );
    
    final endPoint = Offset(size.width * 0.7, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.65, 
      endPoint.dx, endPoint.dy
    );

    canvas.drawPath(path, paint);

    // Draw Start Pin
    final startPinPaint = Paint()..color = Colors.blueAccent..style = PaintingStyle.fill;
    final pinBorderPaint = Paint()..color = Colors.white..strokeWidth = 2.0..style = PaintingStyle.stroke;
    
    canvas.drawCircle(startPoint, 6, startPinPaint);
    canvas.drawCircle(startPoint, 6, pinBorderPaint);

    // Draw End Pin
    final endPinPaint = Paint()..color = Colors.redAccent..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 6, endPinPaint);
    canvas.drawCircle(endPoint, 6, pinBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
