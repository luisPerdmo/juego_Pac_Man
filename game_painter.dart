import 'dart:math';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'game_map.dart';
import 'ghost.dart';

class ScorePopup {
  final double x;
  final double y;
  final int points;
  int ticksLeft;

  ScorePopup({
    required this.x,
    required this.y,
    required this.points,
  }) : ticksLeft = kPopupMs ~/ kTickMs;
}

class GamePainter extends CustomPainter {
  final double pacmanX;
  final double pacmanY;
  final String direction;
  final List<Ghost> ghosts;
  final List<ScorePopup> popups;

  final bool showGhosts;

  final double? deathProgress;

  final bool showReady;

  GamePainter({
    required this.pacmanX,
    required this.pacmanY,
    required this.direction,
    required this.ghosts,
    this.popups = const [],
    this.showGhosts = true,
    this.deathProgress,
    this.showReady = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / GameMap.width;
    final cellHeight = size.height / GameMap.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black,
    );

    for (int y = 0; y < GameMap.height; y++) {
      for (int x = 0; x < GameMap.width; x++) {
        final rect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );

        switch (GameMap.layout[y][x]) {
          case 1:
            final wallPaint = Paint()..color = kWallColor;
            canvas.drawRect(rect, wallPaint);

            final borderPaint = Paint()..color = kWallBorderColor;
            canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, 2), borderPaint);
            canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, 2, rect.height), borderPaint);
            break;

          case 2:
            canvas.drawCircle(
              rect.center,
              cellWidth * 0.1,
              Paint()..color = kDotColor,
            );
            break;

          case 3:
            canvas.drawCircle(
              rect.center,
              cellWidth * 0.2,
              Paint()..color = kPowerDotColor,
            );
            final glowPaint = Paint()
              ..color = kPowerDotColor.withAlpha(77)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
            canvas.drawCircle(rect.center, cellWidth * 0.25, glowPaint);
            break;

          case 4:
            canvas.drawRect(
              Rect.fromLTWH(rect.left, rect.center.dy - 2, rect.width, 4),
              Paint()..color = kDoorColor,
            );
            break;
        }
      }
    }

    if (showGhosts) {
      for (final ghost in ghosts) {
        _drawGhost(canvas, ghost, cellWidth, cellHeight);
      }
    }

    _drawPacman(canvas, cellWidth, cellHeight);

    for (final popup in popups) {
      _drawPopup(canvas, popup, cellWidth, cellHeight);
    }

    if (showReady) {
      _drawReady(canvas, cellWidth, cellHeight);
    }
  }

  void _drawPacman(Canvas canvas, double cellWidth, double cellHeight) {
    final pacRect = Rect.fromLTWH(
      pacmanX * cellWidth,
      pacmanY * cellHeight,
      cellWidth,
      cellHeight,
    );

    final pacPaint = Paint()..color = kPacmanColor;

    if (deathProgress != null) {
      final half = deathProgress!.clamp(0.0, 1.0) * pi;
      final sweep = 2 * pi - 2 * half;
      if (sweep > 0.01) {
        canvas.drawArc(pacRect, (3 * pi) / 2 + half, sweep, true, pacPaint);
      }
      return;
    }

    double time = DateTime.now().millisecondsSinceEpoch / 200.0;
    double mouthAngle = 0.3 + sin(time) * 0.2;

    double startAngle = 0;
    double sweepAngle = 2 * pi;

    switch (direction) {
      case 'right':
        startAngle = mouthAngle;
        sweepAngle = 2 * pi - (mouthAngle * 2);
        break;
      case 'left':
        startAngle = pi + mouthAngle;
        sweepAngle = 2 * pi - (mouthAngle * 2);
        break;
      case 'up':
        startAngle = (3 * pi) / 2 + mouthAngle;
        sweepAngle = 2 * pi - (mouthAngle * 2);
        break;
      case 'down':
        startAngle = pi / 2 + mouthAngle;
        sweepAngle = 2 * pi - (mouthAngle * 2);
        break;
    }

    canvas.drawArc(pacRect, startAngle, sweepAngle, true, pacPaint);

    final eyePaint = Paint()..color = kEyeColor;
    final eyePosition = Offset(
      pacRect.center.dx + cellWidth * 0.2,
      pacRect.center.dy - cellHeight * 0.15,
    );

    canvas.drawCircle(eyePosition, cellWidth * 0.1, eyePaint);
  }

  void _drawReady(Canvas canvas, double cellWidth, double cellHeight) {
    final painter = TextPainter(
      text: TextSpan(
        text: 'READY!',
        style: TextStyle(
          color: Colors.yellow,
          fontSize: cellHeight * 0.6,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final center = Offset(
      (GameMap.level.houseX + 0.5) * cellWidth,
      (GameMap.level.houseY + 1.5) * cellHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: painter.width + 14,
          height: painter.height + 6,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black,
    );

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _drawPopup(Canvas canvas, ScorePopup popup, double cellWidth, double cellHeight) {
    final painter = TextPainter(
      text: TextSpan(
        text: '${popup.points}',
        style: TextStyle(
          color: Colors.cyanAccent,
          fontSize: cellHeight * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final center = Offset(
      (popup.x + 0.5) * cellWidth,
      (popup.y + 0.5) * cellHeight,
    );
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _drawGhost(Canvas canvas, Ghost ghost, double cellWidth, double cellHeight) {
    double bob = 0;
    if (ghost.phase == HousePhase.waiting) {
      final t = DateTime.now().millisecondsSinceEpoch / 150.0;
      bob = sin(t + ghost.x * 2) * cellHeight * 0.06;
    }

    final rect = Rect.fromLTWH(
      ghost.x * cellWidth,
      ghost.y * cellHeight + bob,
      cellWidth,
      cellHeight,
    );

    if (ghost.isEaten) {
      _drawGhostEyes(canvas, ghost, rect, cellWidth, cellHeight);
      return;
    }

    final Color bodyColor;
    if (ghost.isFrightened) {
      bodyColor = ghost.isFlashing ? kFrightenedFlashColor : kFrightenedColor;
    } else {
      bodyColor = ghost.color;
    }

    final bodyPaint = Paint()..color = bodyColor;
    final path = Path();

    final left = rect.left + rect.width * 0.05;
    final right = rect.right - rect.width * 0.05;
    final top = rect.top + rect.height * 0.1;
    final bottom = rect.bottom - rect.height * 0.05;
    final radius = (right - left) / 2;

    path.moveTo(left, bottom);
    path.lineTo(left, top + radius);
    path.arcToPoint(
      Offset(right, top + radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(right, bottom);

    const waveCount = 4;
    final waveWidth = (right - left) / waveCount;
    for (int i = 0; i < waveCount; i++) {
      final waveTop = bottom - rect.height * 0.12;
      final xStart = right - waveWidth * i;
      final xMid = xStart - waveWidth / 2;
      final xEnd = xStart - waveWidth;
      path.quadraticBezierTo(xMid, waveTop, xEnd, bottom);
    }

    path.close();
    canvas.drawPath(path, bodyPaint);

    if (ghost.isFrightened) {
      _drawFrightenedFace(canvas, ghost, rect, cellWidth, cellHeight);
    } else {
      _drawGhostEyes(canvas, ghost, rect, cellWidth, cellHeight);
    }
  }

  void _drawGhostEyes(
    Canvas canvas,
    Ghost ghost,
    Rect rect,
    double cellWidth,
    double cellHeight,
  ) {
    final eyeWhitePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.blue.shade900;

    final leftEyeCenter = Offset(rect.center.dx - cellWidth * 0.15, rect.center.dy - cellHeight * 0.05);
    final rightEyeCenter = Offset(rect.center.dx + cellWidth * 0.15, rect.center.dy - cellHeight * 0.05);
    final eyeRadius = cellWidth * 0.13;

    canvas.drawCircle(leftEyeCenter, eyeRadius, eyeWhitePaint);
    canvas.drawCircle(rightEyeCenter, eyeRadius, eyeWhitePaint);

    Offset pupilOffset;
    switch (ghost.direction) {
      case 'right':
        pupilOffset = Offset(eyeRadius * 0.4, 0);
        break;
      case 'left':
        pupilOffset = Offset(-eyeRadius * 0.4, 0);
        break;
      case 'up':
        pupilOffset = Offset(0, -eyeRadius * 0.4);
        break;
      case 'down':
        pupilOffset = Offset(0, eyeRadius * 0.4);
        break;
      default:
        pupilOffset = Offset.zero;
    }

    canvas.drawCircle(leftEyeCenter + pupilOffset, eyeRadius * 0.5, pupilPaint);
    canvas.drawCircle(rightEyeCenter + pupilOffset, eyeRadius * 0.5, pupilPaint);
  }

  void _drawFrightenedFace(
    Canvas canvas,
    Ghost ghost,
    Rect rect,
    double cellWidth,
    double cellHeight,
  ) {
    final faceColor = ghost.isFlashing ? Colors.red : const Color(0xFFFFCCAA);
    final facePaint = Paint()..color = faceColor;

    final eyeY = rect.center.dy - cellHeight * 0.1;
    canvas.drawCircle(
      Offset(rect.center.dx - cellWidth * 0.15, eyeY),
      cellWidth * 0.06,
      facePaint,
    );
    canvas.drawCircle(
      Offset(rect.center.dx + cellWidth * 0.15, eyeY),
      cellWidth * 0.06,
      facePaint,
    );

    final mouthPaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final mouth = Path();
    final mouthY = rect.center.dy + cellHeight * 0.15;
    final mouthLeft = rect.center.dx - cellWidth * 0.25;
    final step = cellWidth * 0.5 / 6;
    mouth.moveTo(mouthLeft, mouthY);
    for (int i = 1; i <= 6; i++) {
      mouth.lineTo(
        mouthLeft + step * i,
        mouthY + (i.isOdd ? -cellHeight * 0.06 : cellHeight * 0.06),
      );
    }
    canvas.drawPath(mouth, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true;
  }
}