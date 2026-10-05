import 'dart:math';
import 'package:flutter/material.dart';

class LivesDisplay extends StatelessWidget {
  final int lives;

  const LivesDisplay({super.key, required this.lives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < lives; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(painter: _MiniPacmanPainter()),
            ),
          ),
        if (lives == 0)
          const Text(
            '—',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
      ],
    );
  }
}

class _MiniPacmanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..color = Colors.yellow;

    const mouthAngle = 0.45;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      mouthAngle,
      2 * pi - (mouthAngle * 2),
      true,
      paint,
    );

    canvas.drawCircle(
      Offset(center.dx + radius * 0.05, center.dy - radius * 0.45),
      radius * 0.14,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniPacmanPainter oldDelegate) => false;
}