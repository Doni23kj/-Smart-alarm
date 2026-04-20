import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/alarm_challenge_shell.dart';

class MathChallengePage extends StatefulWidget {
  const MathChallengePage({super.key, this.ringVolume = 0.8});

  final double ringVolume;

  @override
  State<MathChallengePage> createState() => _MathChallengePageState();
}

class _MathChallengePageState extends State<MathChallengePage> {
  final _controller = TextEditingController();
  late int _left;
  late int _right;
  late int _extra;
  late int _answer;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _generateTask();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _generateTask() {
    final random = Random();
    _left = 2 + random.nextInt(8);
    _right = 10 + random.nextInt(90);
    _extra = 10 + random.nextInt(40);
    _answer = (_left * _right) + _extra;
  }

  void _submit() {
    final typedAnswer = int.tryParse(_controller.text.trim());
    if (typedAnswer == _answer) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _errorText = 'Неверный ответ. Попробуйте ещё раз.';
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlarmChallengeShell(
      ringVolume: widget.ringVolume,
      icon: Icons.calculate_rounded,
      title: 'Математика',
      subtitle: 'Решите пример, чтобы полностью выключить будильник.',
      child: Column(
        children: [
          Text(
            '$_left × $_right + $_extra',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          AlarmChallengeField(
            controller: _controller,
            hintText: 'Введите ответ',
            errorText: _errorText,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 18),
          AlarmChallengeButton(label: 'Выключить', onTap: _submit),
          const SizedBox(height: 18),
          const ChallengeClockBadge(),
        ],
      ),
    );
  }
}
