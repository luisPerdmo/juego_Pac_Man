import 'package:flutter/material.dart';

const Color kWallColor = Color(0xFF1565C0);
const Color kWallBorderColor = Color(0xFF42A5F5);
const Color kDotColor = Colors.yellow;
const Color kPowerDotColor = Colors.orange;
const Color kPacmanColor = Colors.yellow;
const Color kEyeColor = Colors.black;
const Color kDoorColor = Color(0xFFFFB8DE);

const int kTickMs = 16;
const double kPacmanSpeed = 0.05;
const int kNormalDotPoints = 10;
const int kPowerDotPoints = 50;

const int kStartingLives = 3;
const int kReadyMs = 2000;
const int kDeathFreezeMs = 800;
const int kDeathAnimMs = 1400;

const List<Color> kGhostColors = [
  Colors.red,
  Colors.pinkAccent,
  Colors.cyanAccent,
  Color(0xFFFFB851),
];
const double kCollisionThreshold = 0.5;

const int kDotTimeoutMs = 4000;

const double kClydeShyTiles = 5;

const int kFlashMs = 2000;
const double kEatenSpeed = 0.08;
const int kGhostEatBasePoints = 200;
const int kPopupMs = 1000;
const Color kFrightenedColor = Color(0xFF2121DE);
const Color kFrightenedFlashColor = Colors.white;