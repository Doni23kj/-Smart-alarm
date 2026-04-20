import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/alarm_audio_service.dart';

class ShakeChallengePage extends StatefulWidget {
  const ShakeChallengePage({super.key, this.ringVolume = 0.8});

  final double ringVolume;

  @override
  State<ShakeChallengePage> createState() => _ShakeChallengePageState();
}

class _ShakeChallengePageState extends State<ShakeChallengePage> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    unawaited(AlarmAudioService.instance.start(volume: widget.ringVolume));
  }

  @override
  void dispose() {
    unawaited(AlarmAudioService.instance.stop());
    super.dispose();
  }

  void _increment() {
    setState(() {
      count++;
    });

    if (count >= 10) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7FB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.vibration,
                    size: 72,
                    color: Color(0xFF7B4DFF),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Встряска',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Нажми $count / 10',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _increment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B4DFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Имитация встряски'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
