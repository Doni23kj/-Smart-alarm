import 'dart:async';

import 'package:just_audio/just_audio.dart';

class VolumeFadeInController {
  VolumeFadeInController({AudioPlayer? player, Duration? stepDuration})
    : _player = player ?? AudioPlayer(),
      _stepDuration = stepDuration ?? const Duration(milliseconds: 450);

  final AudioPlayer _player;
  final Duration _stepDuration;
  Timer? _timer;

  AudioPlayer get player => _player;

  Future<void> startFadeIn({
    required String assetPath,
    double startVolume = 0.05,
    double targetVolume = 1.0,
    int steps = 12,
  }) async {
    await stop();
    await _player.setVolume(startVolume);
    await _player.setAsset(assetPath);
    await _player.setLoopMode(LoopMode.one);
    await _player.play();

    var currentStep = 0;
    final volumeDelta = (targetVolume - startVolume) / steps;

    _timer = Timer.periodic(_stepDuration, (timer) async {
      currentStep += 1;
      final nextVolume = (startVolume + (volumeDelta * currentStep)).clamp(
        0.0,
        1.0,
      );
      await _player.setVolume(nextVolume);
      if (currentStep >= steps) {
        timer.cancel();
      }
    });
  }

  Future<void> stop() async {
    _timer?.cancel();
    await _player.stop();
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _player.dispose();
  }
}
