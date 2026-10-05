import 'package:flutter/material.dart';
import 'lives_display.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;
  final int lives;

  const ScoreDisplay({
    super.key,
    required this.score,
    required this.lives,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Center(
        child: _ScoreCard(score: score, lives: lives),
      ),
    );
  }
}

const double _kCardWidth = 260;
const double _kCardHeight = 78;

const double _kColumnWidth = 100;

const double _kLabelBandHeight = 22;

class _ScoreCard extends StatelessWidget {
  final int score;
  final int lives;

  const _ScoreCard({required this.score, required this.lives});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kCardWidth,
      height: _kCardHeight,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[900]!, const Color(0xFF0A1A3A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.withAlpha(90),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HudColumn(
            label: 'SCORE',
            child: Text(
              score.toString(),
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                fontFamily: 'monospace',
                height: 1.0,
                shadows: [
                  Shadow(color: Colors.orange, blurRadius: 10),
                ],
              ),
            ),
          ),
          Container(
            width: 1.5,
            height: _kCardHeight - 24,
            color: Colors.yellow.withAlpha(70),
          ),
          _HudColumn(
            label: 'VIDAS',
            child: LivesDisplay(lives: lives),
          ),
        ],
      ),
    );
  }
}

class _HudColumn extends StatelessWidget {
  final String label;
  final Widget child;

  const _HudColumn({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kColumnWidth,
      height: _kCardHeight - 16,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: _kLabelBandHeight,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFFFE082),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  height: 1.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}