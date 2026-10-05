import 'package:flutter/material.dart';
import 'arcade_dialog.dart';
import 'constants.dart';

void showLoseDialog(BuildContext context, int score, VoidCallback onRetry) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(200),
    builder: (BuildContext context) {
      return ArcadeDialog(
        title: 'GAME OVER',
        titleColor: kWallBorderColor,
        score: score,
        buttonLabel: 'REINTENTAR',
        buttonIcon: Icons.refresh,
        buttonColor: kWallColor,
        buttonBorderColor: kWallBorderColor,
        onPressed: () {
          Navigator.of(context).pop();
          onRetry();
        },
      );
    },
  );
}