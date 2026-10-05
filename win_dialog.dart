import 'package:flutter/material.dart';
import 'arcade_dialog.dart';
import 'constants.dart';

void showWinDialog(BuildContext context, int score, VoidCallback onPlayAgain) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(200),
    builder: (BuildContext context) {
      return ArcadeDialog(
        title: '¡GANASTE!',
        titleColor: kWallBorderColor,
        score: score,
        buttonLabel: 'JUGAR DE NUEVO',
        buttonIcon: Icons.play_arrow,
        buttonColor: kWallColor,
        buttonBorderColor: kWallBorderColor,
        onPressed: () {
          Navigator.of(context).pop();
          onPlayAgain();
        },
      );
    },
  );
}
void showLevelCompleteDialog(
  BuildContext context,
  int score,
  int level,
  VoidCallback onNext,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(200),
    builder: (BuildContext context) {
      return ArcadeDialog(
        title: '¡NIVEL $level\nSUPERADO!',
        titleColor: kWallBorderColor,
        score: score,
        scoreLabel: 'PUNTAJE',
        buttonLabel: 'SIGUIENTE NIVEL',
        buttonIcon: Icons.skip_next,
        buttonColor: kWallColor,
        buttonBorderColor: kWallBorderColor,
        onPressed: () {
          Navigator.of(context).pop();
          onNext();
        },
      );
    },
  );
}