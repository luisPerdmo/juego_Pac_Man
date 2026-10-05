import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'game_map.dart';
import 'game_painter.dart';
import 'ghost.dart';
import 'levels.dart';
import 'score_display.dart';
import 'win_dialog.dart';
import 'lose_dialog.dart';
import 'sound_manager.dart';

enum GamePhase { ready, playing, dying, paused, over }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const String _startDirection = 'left';

  late double pacmanX;
  late double pacmanY;

  int levelIndex = 0;

  bool get _isLastLevel => levelIndex >= kLevels.length - 1;

  int score = 0;
  int lives = kStartingLives;
  String direction = _startDirection;
  String? pendingDirection;
  late Timer gameTimer;
  late final FocusNode _focusNode;
  late List<Ghost> ghosts;
  int _ticks = 0;

  GamePhase _phase = GamePhase.ready;

  GamePhase _phaseBeforePause = GamePhase.ready;

  int _phaseTicks = kReadyMs ~/ kTickMs;

  int _deathTicks = 0;

  static const int _freezeTicks = kDeathFreezeMs ~/ kTickMs;
  static const int _deathAnimTicks = kDeathAnimMs ~/ kTickMs;

  int _dotsSinceRelease = 0;

  int _ticksSinceDot = 0;

  int _ghostCombo = 0;
  final List<ScorePopup> _popups = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    SoundManager.instance.init();
    GameMap.loadLevel(kLevels[levelIndex]);
    pacmanX = GameMap.level.pacStartX.toDouble();
    pacmanY = GameMap.level.pacStartY.toDouble();
    _spawnGhosts();
    startGame();
  }

  void _spawnGhosts() {
    _ticks = 0;
    _ghostCombo = 0;
    _dotsSinceRelease = 0;
    _ticksSinceDot = 0;
    _popups.clear();

    final level = GameMap.level;
    final houseX = level.houseX;
    final houseY = level.houseY;
    final mapW = level.width;
    final mapH = level.height;

    ghosts = [
      Ghost(
        x: houseX.toDouble(),
        y: level.exitY.toDouble(),
        color: kGhostColors[0],
        type: GhostType.blinky,
        scatterX: mapW - 2,
        scatterY: 1,
        direction: 'left',
      ),
      Ghost(
        x: houseX.toDouble(),
        y: houseY.toDouble(),
        color: kGhostColors[1],
        type: GhostType.pinky,
        scatterX: 1,
        scatterY: 1,
        direction: 'up',
        startInHouse: true,
        releaseDotLimit: level.releaseDotLimits[1],
      ),
      Ghost(
        x: houseX - 1.0,
        y: houseY.toDouble(),
        color: kGhostColors[2],
        type: GhostType.inky,
        scatterX: mapW - 2,
        scatterY: mapH - 2,
        direction: 'up',
        startInHouse: true,
        releaseDotLimit: level.releaseDotLimits[2],
      ),
      Ghost(
        x: houseX + 1.0,
        y: houseY.toDouble(),
        color: kGhostColors[3],
        type: GhostType.clyde,
        scatterX: 1,
        scatterY: mapH - 2,
        direction: 'up',
        startInHouse: true,
        releaseDotLimit: level.releaseDotLimits[3],
      ),
    ];
  }

  Ghost? get _blinky {
    for (final g in ghosts) {
      if (g.type == GhostType.blinky) return g;
    }
    return null;
  }

  void startGame() {
    gameTimer = Timer.periodic(
      const Duration(milliseconds: kTickMs),
      (timer) {
        if (!mounted) return;
        _tick();
      },
    );
  }

  @override
  void dispose() {
    gameTimer.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _resetRound() {
    pacmanX = GameMap.level.pacStartX.toDouble();
    pacmanY = GameMap.level.pacStartY.toDouble();
    direction = _startDirection;
    pendingDirection = null;
    _spawnGhosts();
    _phase = GamePhase.ready;
    _phaseTicks = kReadyMs ~/ kTickMs;
    _deathTicks = 0;
  }

  void resetGame() {
    setState(() {
      score = 0;
      lives = kStartingLives;
      levelIndex = 0;
      GameMap.loadLevel(kLevels[levelIndex]);
      _resetRound();
    });
  }

  void _nextLevel() {
    setState(() {
      levelIndex++;
      GameMap.loadLevel(kLevels[levelIndex]);
      _resetRound();
    });
  }

  void togglePause() {
    setState(() {
      if (_phase == GamePhase.paused) {
        _phase = _phaseBeforePause;
      } else if (_phase == GamePhase.ready || _phase == GamePhase.playing) {
        _phaseBeforePause = _phase;
        _phase = GamePhase.paused;
      }
    });
  }

  void _toggleSound() {
    setState(() {
      SoundManager.instance.toggleMute();
    });
  }

  String _opposite(String dir) {
    switch (dir) {
      case 'up':
        return 'down';
      case 'down':
        return 'up';
      case 'left':
        return 'right';
      default:
        return 'left';
    }
  }

  bool get _chasing {
    final level = GameMap.level;
    return (_ticks * kTickMs) % (level.scatterMs + level.chaseMs) >=
        level.scatterMs;
  }

  bool _canMove(double x, double y, String dir) {
    int gx = x.round();
    int gy = y.round();
    switch (dir) {
      case 'right':
        gx += 1;
        break;
      case 'left':
        gx -= 1;
        break;
      case 'up':
        gy -= 1;
        break;
      case 'down':
        gy += 1;
        break;
    }
    return !GameMap.isWall(gx, gy);
  }

  void _eatDotAt(int gx, int gy) {
    if (gy < 0 || gy >= GameMap.height || gx < 0 || gx >= GameMap.width) return;
    final cell = GameMap.layout[gy][gx];
    if (cell == 2) {
      GameMap.layout[gy][gx] = 0;
      score += kNormalDotPoints;
      _onDotEaten();
      SoundManager.instance.playChomp();
    } else if (cell == 3) {
      GameMap.layout[gy][gx] = 0;
      score += kPowerDotPoints;
      _onDotEaten();
      SoundManager.instance.playPowerPellet();
      _activateFrightenedMode();
    }
  }

  void _onDotEaten() {
    _dotsSinceRelease++;
    _ticksSinceDot = 0;
  }

  void _updateHouse() {
    _ticksSinceDot++;

    Ghost? next;
    for (final g in ghosts) {
      if (g.phase == HousePhase.waiting) {
        next = g;
        break;
      }
    }
    if (next == null) return;

    final byDots = _dotsSinceRelease >= next.releaseDotLimit;
    final byTimeout = _ticksSinceDot * kTickMs >= kDotTimeoutMs;

    if (byDots || byTimeout) {
      next.release();
      _dotsSinceRelease = 0;
      _ticksSinceDot = 0;
    }
  }

  void _activateFrightenedMode() {
    _ghostCombo = 0;
    for (final ghost in ghosts) {
      ghost.frighten();
    }
  }

  bool _checkWin() {
    for (int y = 0; y < GameMap.height; y++) {
      for (int x = 0; x < GameMap.width; x++) {
        final c = GameMap.layout[y][x];
        if (c == 2 || c == 3) return false;
      }
    }
    return true;
  }

  bool _checkCollision() {
    bool caught = false;

    for (final ghost in ghosts) {
      if (ghost.phase == HousePhase.waiting) continue;

      final dx = ghost.x - pacmanX;
      final dy = ghost.y - pacmanY;
      final distance = (dx * dx + dy * dy);
      if (distance >= kCollisionThreshold * kCollisionThreshold) continue;

      if (ghost.isFrightened) {
        final points = kGhostEatBasePoints * (1 << _ghostCombo);
        _ghostCombo++;
        score += points;
        _popups.add(ScorePopup(x: ghost.x, y: ghost.y, points: points));
        ghost.eat();
      } else if (!ghost.isEaten) {
        caught = true;
      }
    }

    return caught;
  }

  void _movePacman() {
    if (pendingDirection != null && pendingDirection == _opposite(direction)) {
      direction = pendingDirection!;
      pendingDirection = null;
    }

    final alignedX = (pacmanX - pacmanX.roundToDouble()).abs() < 0.001;
    final alignedY = (pacmanY - pacmanY.roundToDouble()).abs() < 0.001;
    final aligned = alignedX && alignedY;

    if (aligned) {
      pacmanX = pacmanX.roundToDouble();
      pacmanY = pacmanY.roundToDouble();

      if (pendingDirection != null && _canMove(pacmanX, pacmanY, pendingDirection!)) {
        direction = pendingDirection!;
        pendingDirection = null;
      }

      if (!_canMove(pacmanX, pacmanY, direction)) {
        return;
      }
    }

    switch (direction) {
      case 'right':
        pacmanX += kPacmanSpeed;
        break;
      case 'left':
        pacmanX -= kPacmanSpeed;
        break;
      case 'up':
        pacmanY -= kPacmanSpeed;
        break;
      case 'down':
        pacmanY += kPacmanSpeed;
        break;
    }

    _eatDotAt(pacmanX.round(), pacmanY.round());
  }

  void _updatePopups() {
    for (final p in _popups) {
      p.ticksLeft--;
    }
    _popups.removeWhere((p) => p.ticksLeft <= 0);
  }

  void _tick() {
    switch (_phase) {
      case GamePhase.ready:
        _readyTick();
        break;
      case GamePhase.playing:
        _playTick();
        break;
      case GamePhase.dying:
        _dyingTick();
        break;
      case GamePhase.paused:
        break;
      case GamePhase.over:
        break;
    }
  }

  void _readyTick() {
    setState(() {
      _updatePopups();
      _phaseTicks--;
      if (_phaseTicks <= 0) {
        _phase = GamePhase.playing;
      }
    });
  }

  void _playTick() {
    bool won = false;

    setState(() {
      if (!ghosts.any((g) => g.isFrightened)) {
        _ticks++;
      }

      _movePacman();
      _updateHouse();

      final chase = _chasing;
      final blinky = _blinky;
      for (final ghost in ghosts) {
        ghost.move(
          pacX: pacmanX,
          pacY: pacmanY,
          pacDirection: direction,
          chase: chase,
          blinky: blinky,
        );
      }

      _updatePopups();

      if (_checkCollision()) {
        _phase = GamePhase.dying;
        _deathTicks = 0;
        pendingDirection = null;
        SoundManager.instance.playDeath();
        return;
      }

      if (_checkWin()) {
        _phase = GamePhase.over;
        won = true;
      }
    });

    if (won && mounted) {
      if (_isLastLevel) {
        showWinDialog(context, score, resetGame);
      } else {
        showLevelCompleteDialog(context, score, levelIndex + 1, _nextLevel);
      }
    }
  }

  void _dyingTick() {
    bool gameOver = false;

    setState(() {
      _deathTicks++;
      _updatePopups();

      if (_deathTicks >= _freezeTicks + _deathAnimTicks) {
        lives--;
        if (lives <= 0) {
          lives = 0;
          _phase = GamePhase.over;
          gameOver = true;
        } else {
          _resetRound();
        }
      }
    });

    if (gameOver && mounted) {
      showLoseDialog(context, score, resetGame);
    }
  }

  double? get _deathProgress {
    if (_phase != GamePhase.dying || _deathTicks < _freezeTicks) return null;
    return ((_deathTicks - _freezeTicks) / _deathAnimTicks).clamp(0.0, 1.0);
  }

  bool get _ghostsVisible =>
      !(_phase == GamePhase.dying && _deathTicks >= _freezeTicks);

  void changeDirection(String newDirection) {
    pendingDirection = newDirection;
  }

  String get _statusText {
    switch (_phase) {
      case GamePhase.paused:
        return '⏸️ Pausa';
      case GamePhase.over:
        return '⏸️ Juego pausado';
      default:
        return '🎮 Nivel ${levelIndex + 1} · ${GameMap.level.name}';
    }
  }

  Color get _statusColor {
    switch (_phase) {
      case GamePhase.paused:
      case GamePhase.over:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is! KeyDownEvent) return;

        if (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.keyP) {
          if (_phase == GamePhase.paused ||
              _phase == GamePhase.ready ||
              _phase == GamePhase.playing) {
            togglePause();
          }
          return;
        }

        final acceptsInput =
            _phase == GamePhase.ready || _phase == GamePhase.playing;
        if (!acceptsInput) return;

        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          changeDirection('right');
        } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          changeDirection('left');
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          changeDirection('up');
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          changeDirection('down');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            ScoreDisplay(score: score, lives: lives),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: GameMap.width * 30.0,
                  ),
                  child: AspectRatio(
                    aspectRatio: GameMap.width / GameMap.height,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                              painter: GamePainter(
                                pacmanX: pacmanX,
                                pacmanY: pacmanY,
                                direction: direction,
                                ghosts: ghosts,
                                popups: _popups,
                                showGhosts: _ghostsVisible,
                                deathProgress: _deathProgress,
                                showReady: _phase == GamePhase.ready,
                              ),
                            ),
                            if (_phase == GamePhase.paused) _PauseMenu(
                              onResume: togglePause,
                              onReset: resetGame,
                              muted: SoundManager.instance.muted,
                              onToggleSound: _toggleSound,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Flechas para mover · Espacio o P para pausar',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _statusText,
                    style: TextStyle(color: _statusColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onReset;
  final bool muted;
  final VoidCallback onToggleSound;

  const _PauseMenu({
    required this.onResume,
    required this.onReset,
    required this.muted,
    required this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(170),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⏸ PAUSA',
              style: TextStyle(
                color: kWallBorderColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            _MenuButton(
              icon: Icons.play_arrow,
              label: 'Continuar',
              onTap: onResume,
            ),
            const SizedBox(height: 12),
            _MenuButton(
              icon: muted ? Icons.volume_off : Icons.volume_up,
              label: muted ? 'Sonido: OFF' : 'Sonido: ON',
              onTap: onToggleSound,
            ),
            const SizedBox(height: 12),
            _MenuButton(
              icon: Icons.refresh,
              label: 'Reiniciar',
              onTap: onReset,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 190,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: kWallColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kWallBorderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: kWallBorderColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: kWallBorderColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}