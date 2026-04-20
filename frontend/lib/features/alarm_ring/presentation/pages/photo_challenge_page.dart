import 'package:flutter/material.dart';

import '../widgets/alarm_challenge_shell.dart';

class PhotoChallengePage extends StatelessWidget {
  const PhotoChallengePage({super.key, this.ringVolume = 0.8});

  final double ringVolume;

  @override
  Widget build(BuildContext context) {
    return AlarmChallengeShell(
      ringVolume: ringVolume,
      icon: Icons.camera_alt_rounded,
      title: 'Фото',
      subtitle: 'Сделайте контрольное фото, чтобы подтвердить пробуждение.',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AlarmChallengeShell.cardSoft,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AlarmChallengeShell.border),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.camera_enhance_rounded,
                  size: 42,
                  color: Colors.white,
                ),
                SizedBox(height: 12),
                Text(
                  'На этом этапе подтверждение работает без камеры. Нажмите кнопку ниже, чтобы завершить задачу.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AlarmChallengeShell.muted,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AlarmChallengeButton(
            label: 'Подтвердить',
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
