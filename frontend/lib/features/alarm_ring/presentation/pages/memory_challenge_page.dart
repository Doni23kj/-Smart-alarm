import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/alarm_challenge_shell.dart';

class MemoryChallengePage extends StatefulWidget {
  const MemoryChallengePage({super.key, this.ringVolume = 0.8});

  final double ringVolume;

  @override
  State<MemoryChallengePage> createState() => _MemoryChallengePageState();
}

class _MemoryChallengePageState extends State<MemoryChallengePage> {
  late List<int> numbers;
  final TextEditingController controller = TextEditingController();
  String? errorText;
  bool hidden = false;

  @override
  void initState() {
    super.initState();
    _generateNumbers();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => hidden = true);
    });
  }

  void _generateNumbers() {
    final random = Random();
    numbers = List.generate(4, (_) => random.nextInt(9));
  }

  void _check() {
    final answer = controller.text.trim();
    final correct = numbers.join();

    if (answer == correct) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      errorText = 'Неверно. Попробуйте ещё раз.';
      controller.clear();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlarmChallengeShell(
      ringVolume: widget.ringVolume,
      icon: Icons.psychology_alt_rounded,
      title: 'Память',
      subtitle: 'Запомните цифры и введите их по памяти.',
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Container(
              key: ValueKey(hidden),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: AlarmChallengeShell.cardSoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AlarmChallengeShell.border),
              ),
              child: Text(
                hidden ? 'Введите цифры по памяти' : numbers.join(' '),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          AlarmChallengeField(
            controller: controller,
            hintText: 'Например: 1234',
            errorText: errorText,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (errorText != null) {
                setState(() => errorText = null);
              }
            },
            onSubmitted: (_) => _check(),
          ),
          const SizedBox(height: 18),
          AlarmChallengeButton(label: 'Проверить', onTap: _check),
        ],
      ),
    );
  }
}
