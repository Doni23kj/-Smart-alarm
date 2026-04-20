import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/alarm_challenge_shell.dart';

class LogicChallengePage extends StatefulWidget {
  const LogicChallengePage({super.key, this.ringVolume = 0.8});

  final double ringVolume;

  @override
  State<LogicChallengePage> createState() => _LogicChallengePageState();
}

class _LogicChallengePageState extends State<LogicChallengePage> {
  final TextEditingController _controller = TextEditingController();
  late String _question;
  late String _answer;
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
    final tasks = <Map<String, String>>[
      {'question': 'Что больше: 2, 3, 5, 9?', 'answer': '9'},
      {'question': 'Продолжите ряд: 2, 4, 6, 8, ?', 'answer': '10'},
      {'question': 'Сколько углов у треугольника?', 'answer': '3'},
      {
        'question': 'Что легче: 1 кг ваты или 1 кг железа?',
        'answer': 'одинаково',
      },
    ];

    final task = tasks[Random().nextInt(tasks.length)];
    _question = task['question']!;
    _answer = task['answer']!;
  }

  void _submit() {
    final typed = _controller.text.trim().toLowerCase();
    if (typed == _answer.toLowerCase()) {
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
      icon: Icons.extension_rounded,
      title: 'Логика',
      subtitle: 'Ответьте правильно, чтобы остановить сигнал.',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AlarmChallengeShell.cardSoft,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AlarmChallengeShell.border),
            ),
            child: Text(
              _question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          AlarmChallengeField(
            controller: _controller,
            hintText: 'Введите ответ',
            errorText: _errorText,
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 18),
          AlarmChallengeButton(label: 'Проверить', onTap: _submit),
        ],
      ),
    );
  }
}
