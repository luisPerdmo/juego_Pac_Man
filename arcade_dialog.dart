import 'package:flutter/material.dart';

class ArcadeDialog extends StatefulWidget {
  final String title;
  final Color titleColor;
  final int score;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;

  final String scoreLabel;

  final Color buttonColor;
  final Color buttonBorderColor;

  const ArcadeDialog({
    super.key,
    required this.title,
    required this.titleColor,
    required this.score,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
    this.scoreLabel = 'PUNTAJE FINAL',
    Color? buttonColor,
    Color? buttonBorderColor,
  })  : buttonColor = buttonColor ?? const Color(0xFF0D47A1),
        buttonBorderColor = buttonBorderColor ?? Colors.yellow;

  @override
  State<ArcadeDialog> createState() => _ArcadeDialogState();
}

class _ArcadeDialogState extends State<ArcadeDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: widget.titleColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: widget.titleColor.withAlpha(130),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DecorLine(color: widget.titleColor),
            const SizedBox(height: 20),

            FadeTransition(
              opacity: _blinkController.drive(
                Tween(begin: 1.0, end: 0.35),
              ),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.titleColor,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  letterSpacing: 3,
                  shadows: [
                    Shadow(color: widget.titleColor, blurRadius: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              widget.scoreLabel,
              style: const TextStyle(
                color: Color(0xFFFFE082),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.score.toString(),
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 44,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: 2,
                height: 1.0,
                shadows: [
                  Shadow(color: Colors.orange, blurRadius: 14),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: widget.onPressed,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: widget.buttonColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: widget.buttonBorderColor, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.buttonIcon, color: widget.buttonBorderColor, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        widget.buttonLabel,
                        style: TextStyle(
                          color: widget.buttonBorderColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            _DecorLine(color: widget.titleColor),
          ],
        ),
      ),
    );
  }
}

class _DecorLine extends StatelessWidget {
  final Color color;

  const _DecorLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 6.0;
          const gap = 4.0;
          final count = (constraints.maxWidth / (dashWidth + gap)).floor();
          return Row(
            children: List.generate(
              count,
              (i) => Padding(
                padding: const EdgeInsets.only(right: gap),
                child: Container(
                  width: dashWidth,
                  height: 3,
                  color: color.withAlpha(180),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}