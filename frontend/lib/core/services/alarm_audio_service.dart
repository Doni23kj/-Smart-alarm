import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

class AlarmAudioService {
  AlarmAudioService._();

  static final AlarmAudioService instance = AlarmAudioService._();

  final AudioPlayer _player = AudioPlayer();
  Timer? _fallbackTimer;

  Future<void> start({double volume = 0.8}) async {
    final clampedVolume = volume.clamp(0.45, 1.0).toDouble();
    await stop();

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);

      final tonePath = await _ensureToneFile();
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(clampedVolume);
      await _player.setFilePath(tonePath);
      await _player.play();
    } catch (_) {
      _startFallbackAlerts();
    }
  }

  Future<void> stop() async {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    try {
      await _player.stop();
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (_) {
      // Safe fallback: stop shouldn't fail the app flow.
    }
  }

  Future<String> _ensureToneFile() async {
    final file = File('${Directory.systemTemp.path}/smart_alarm_tone.wav');
    if (await file.exists()) return file.path;

    await file.writeAsBytes(_buildWavTone(), flush: true);
    return file.path;
  }

  Uint8List _buildWavTone() {
    const sampleRate = 44100;
    const durationSeconds = 2.4;
    const bytesPerSample = 2;
    final totalSamples = (sampleRate * durationSeconds).round();
    final dataSize = totalSamples * bytesPerSample;
    final byteData = ByteData(44 + dataSize);

    void writeAscii(int offset, String value) {
      for (var i = 0; i < value.length; i++) {
        byteData.setUint8(offset + i, value.codeUnitAt(i));
      }
    }

    writeAscii(0, 'RIFF');
    byteData.setUint32(4, 36 + dataSize, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little);
    byteData.setUint16(22, 1, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * bytesPerSample, Endian.little);
    byteData.setUint16(32, bytesPerSample, Endian.little);
    byteData.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    byteData.setUint32(40, dataSize, Endian.little);

    for (var i = 0; i < totalSamples; i++) {
      final t = i / sampleRate;
      final pulsePhase = (t % 0.6) / 0.6;
      final envelope = pulsePhase < 0.16
          ? pulsePhase / 0.16
          : pulsePhase < 0.52
          ? 1.0
          : (1 - ((pulsePhase - 0.52) / 0.48)).clamp(0.0, 1.0);

      final sweepFrequency = 880 + (sin(2 * pi * 1.7 * t) * 90);
      final main = sin(2 * pi * sweepFrequency * t);
      final upper = 0.55 * sin(2 * pi * (sweepFrequency * 1.5) * t);
      final lower = 0.32 * sin(2 * pi * 660 * t);
      final attack = 0.95 * envelope;
      final sample = ((main + upper + lower) * attack * 0.78).clamp(
        -1.0,
        1.0,
      );
      final pcmValue = (sample * 32767).round();
      byteData.setInt16(44 + i * 2, pcmValue, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }

  void _startFallbackAlerts() {
    _fallbackTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.heavyImpact();
    });
  }
}
