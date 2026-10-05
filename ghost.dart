import 'dart:math';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'game_map.dart';

enum GhostType { blinky, pinky, inky, clyde }

enum GhostState { normal, frightened, eaten }

enum HousePhase { waiting, leaving, active }

class Ghost {
  double x;
  double y;
  String direction;
  final Color color;
  final GhostType type;

  final int scatterX;
  final int scatterY;

  int get homeX => GameMap.level.houseX;
  int get homeY => GameMap.level.houseY;

  GhostState state = GhostState.normal;
  HousePhase phase;

  final int releaseDotLimit;

  int frightenedTicks = 0;

  int _prevX;
  int _prevY;
  int _nextX;
  int _nextY;

  final Random _random = Random();

  Ghost({
    required this.x,
    required this.y,
    required this.color,
    required this.type,
    required this.scatterX,
    required this.scatterY,
    this.direction = 'left',
    bool startInHouse = false,
    this.releaseDotLimit = 0,
  })  : phase = startInHouse ? HousePhase.waiting : HousePhase.active,
        _prevX = x.round(),
        _prevY = y.round(),
        _nextX = x.round(),
        _nextY = y.round();

  static const Map<String, List<int>> _vectors = {
    'up': [0, -1],
    'left': [-1, 0],
    'down': [0, 1],
    'right': [1, 0],
  };

  static const Map<String, String> _opposites = {
    'up': 'down',
    'down': 'up',
    'left': 'right',
    'right': 'left',
  };

  bool get isFrightened => state == GhostState.frightened;
  bool get isEaten => state == GhostState.eaten;

  bool get isFlashing =>
      isFrightened &&
      frightenedTicks * kTickMs < kFlashMs &&
      (frightenedTicks ~/ 10).isEven;

  void release() {
    if (phase == HousePhase.waiting) {
      phase = HousePhase.leaving;
    }
  }

  void frighten() {
    if (state == GhostState.eaten) return;
    final wasFrightened = state == GhostState.frightened;
    state = GhostState.frightened;
    frightenedTicks = GameMap.level.frightenedMs ~/ kTickMs;
    if (!wasFrightened && phase == HousePhase.active) _reverse();
  }

  void eat() {
    state = GhostState.eaten;
    frightenedTicks = 0;
    phase = HousePhase.active;
  }

  void _reverse() {
    direction = _opposites[direction]!;
    final tx = _prevX;
    final ty = _prevY;
    _prevX = _nextX;
    _prevY = _nextY;
    _nextX = tx;
    _nextY = ty;
  }

  double get _speed {
    switch (state) {
      case GhostState.frightened:
        return GameMap.level.frightenedSpeed;
      case GhostState.eaten:
        return kEatenSpeed;
      case GhostState.normal:
        return GameMap.level.ghostSpeed;
    }
  }

  bool _blocked(int x, int y) {
    if (GameMap.isSolid(x, y)) return true;
    if (GameMap.isDoor(x, y)) {
      return !(state == GhostState.eaten || phase == HousePhase.leaving);
    }
    return false;
  }

  void move({
    required double pacX,
    required double pacY,
    required String pacDirection,
    required bool chase,
    Ghost? blinky,
  }) {
    if (state == GhostState.frightened) {
      frightenedTicks--;
      if (frightenedTicks <= 0) {
        state = GhostState.normal;
      }
    }

    if (phase == HousePhase.waiting) return;

    double remaining = _speed;
    int guard = 0;

    while (remaining > 1e-9 && guard++ < 4) {
      final dx = _nextX - x;
      final dy = _nextY - y;
      final dist = dx.abs() + dy.abs();

      if (dist <= remaining + 1e-9) {
        x = _nextX.toDouble();
        y = _nextY.toDouble();
        remaining -= dist;

        if (state == GhostState.eaten &&
            x.round() == homeX &&
            y.round() == homeY) {
          state = GhostState.normal;
          phase = HousePhase.leaving;
        }

        if (!_chooseNext(pacX, pacY, pacDirection, chase, blinky)) return;
      } else {
        x += dx.sign * remaining;
        y += dy.sign * remaining;
        remaining = 0;
      }
    }
  }

  (int, int) _targetTile(
    double pacX,
    double pacY,
    String pacDirection,
    bool chase,
    Ghost? blinky,
  ) {
    if (!chase) return (scatterX, scatterY);

    final px = pacX.round();
    final py = pacY.round();
    final v = _vectors[pacDirection] ?? const [0, 0];

    switch (type) {
      case GhostType.blinky:
        return (px, py);

      case GhostType.pinky:
        return (px + v[0] * 2, py + v[1] * 2);

      case GhostType.inky:
        final pivotX = px + v[0] * 2;
        final pivotY = py + v[1] * 2;
        final b = blinky ?? this;
        final bx = b.x.round();
        final by = b.y.round();
        return (pivotX * 2 - bx, pivotY * 2 - by);

      case GhostType.clyde:
        final dx = (x.round() - px).toDouble();
        final dy = (y.round() - py).toDouble();
        final d2 = dx * dx + dy * dy;
        if (d2 > kClydeShyTiles * kClydeShyTiles) return (px, py);
        return (scatterX, scatterY);
    }
  }

  String? _bfsDirectionHome(int sx, int sy) {
    if (sx == homeX && sy == homeY) return null;

    final visited = <int>{sy * GameMap.width + sx};
    final queue = <(int, int, String)>[];

    for (final entry in _vectors.entries) {
      final nx = sx + entry.value[0];
      final ny = sy + entry.value[1];
      if (_blocked(nx, ny)) continue;
      visited.add(ny * GameMap.width + nx);
      queue.add((nx, ny, entry.key));
    }

    while (queue.isNotEmpty) {
      final (cx, cy, firstDir) = queue.removeAt(0);
      if (cx == homeX && cy == homeY) return firstDir;

      for (final entry in _vectors.entries) {
        final nx = cx + entry.value[0];
        final ny = cy + entry.value[1];
        if (_blocked(nx, ny)) continue;
        final key = ny * GameMap.width + nx;
        if (visited.contains(key)) continue;
        visited.add(key);
        queue.add((nx, ny, firstDir));
      }
    }
    return null;
  }

  bool _chooseNext(
    double pacX,
    double pacY,
    String pacDirection,
    bool chase,
    Ghost? blinky,
  ) {
    final cx = x.round();
    final cy = y.round();
    _prevX = cx;
    _prevY = cy;

    if (phase == HousePhase.leaving) {
      final houseX = GameMap.level.houseX;
      final exitY = GameMap.level.exitY;
      if (cx == houseX && cy <= exitY) {
        phase = HousePhase.active;
      } else {
        final String dir;
        if (cx != houseX) {
          dir = cx < houseX ? 'right' : 'left';
        } else {
          dir = 'up';
        }
        direction = dir;
        final v = _vectors[dir]!;
        _nextX = cx + v[0];
        _nextY = cy + v[1];
        return true;
      }
    }

    final options = <String>[];
    for (final entry in _vectors.entries) {
      if (entry.key == _opposites[direction]) continue;
      if (_blocked(cx + entry.value[0], cy + entry.value[1])) continue;
      options.add(entry.key);
    }

    String? best;

    if (state == GhostState.eaten) {
      best = _bfsDirectionHome(cx, cy);
    }

    if (best == null && options.isNotEmpty) {
      if (state == GhostState.frightened) {
        best = options[_random.nextInt(options.length)];
      } else {
        final (tx, ty) = _targetTile(pacX, pacY, pacDirection, chase, blinky);
        double bestDist = double.infinity;
        for (final dir in options) {
          final v = _vectors[dir]!;
          final ddx = (cx + v[0] - tx).toDouble();
          final ddy = (cy + v[1] - ty).toDouble();
          final d = ddx * ddx + ddy * ddy;
          if (d < bestDist) {
            bestDist = d;
            best = dir;
          }
        }
      }
    }

    if (best == null) {
      final back = _opposites[direction]!;
      final v = _vectors[back]!;
      if (_blocked(cx + v[0], cy + v[1])) return false;
      best = back;
    }

    direction = best;
    final v = _vectors[best]!;
    _nextX = cx + v[0];
    _nextY = cy + v[1];
    return true;
  }
}