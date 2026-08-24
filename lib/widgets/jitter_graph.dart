import 'dart:math';
import 'package:flutter/material.dart';

class JitterGraphWidget extends StatelessWidget {
  final List<double> pingHistory;
  final double currentJitter;
  final double packetLoss;

  const JitterGraphWidget({
    super.key,
    required this.pingHistory,
    required this.currentJitter,
    required this.packetLoss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10131E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E2438)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.show_chart_rounded, color: Color(0xFF00FF88), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Real-Time Gaming Stability & Jitter',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildMetricBadge('Jitter: ${currentJitter.toStringAsFixed(1)} ms', const Color(0xFF00D4FF)),
                  const SizedBox(width: 8),
                  _buildMetricBadge('Loss: ${packetLoss.toStringAsFixed(0)}%',
                      packetLoss > 0 ? const Color(0xFFFF3366) : const Color(0xFF00FF88)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _WaveformPainter(pingHistory: pingHistory),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> pingHistory;

  _WaveformPainter({required this.pingHistory});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0A0C14);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw Grid Lines
    final gridPaint = Paint()
      ..color = const Color(0xFF161B2B)
      ..strokeWidth = 1.0;

    for (double y = 0; y <= size.height; y += size.height / 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x <= size.width; x += size.width / 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    if (pingHistory.isEmpty) return;

    final maxVal = max(pingHistory.reduce(max), 150.0);
    final minVal = 0.0;
    final range = maxVal - minVal;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < pingHistory.length; i++) {
      final x = (i / (pingHistory.length - 1 > 0 ? pingHistory.length - 1 : 1)) * size.width;
      final normalized = (pingHistory[i] - minVal) / (range > 0 ? range : 1.0);
      final y = size.height - (normalized * (size.height - 12)) - 6;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw Gradient Area
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00FF88).withOpacity(0.25),
          const Color(0xFF00D4FF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw Glowing Line
    final linePaint = Paint()
      ..color = const Color(0xFF00FF88)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}
