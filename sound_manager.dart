import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  SoundManager._internal();
  static final SoundManager instance = SoundManager._internal();

  bool muted = false;

  Future<void> _play(String assetPath) async {
    if (muted) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(1.0);
      await player.setReleaseMode(ReleaseMode.release);
      player.onPlayerComplete.listen((_) => player.dispose());
      await player.play(AssetSource(assetPath));
    } catch (e) {
      if (kDebugMode) {
        print('SoundManager: no se pudo reproducir "$assetPath" -> $e');
      }
    }
  }

  Future<void> playChomp() => _play('sounds/chomp.wav');
  Future<void> playPowerPellet() => _play('sounds/power_pellet.wav');
  Future<void> playDeath() => _play('sounds/death.wav');

  void toggleMute() {
    muted = !muted;
  }

  Future<void> init() async {}
}