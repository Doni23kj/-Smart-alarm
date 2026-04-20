import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const _bg = Color(0xFFF8F6F1);
  static const _card = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF252033);
  static const _textSecondary = Color(0xFF9A95A8);
  static const _accent = Color(0xFF4F8CFF);
  static const _purple = Color(0xFF7B61FF);
  static const _border = Color(0xFFE8E2F0);

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final FixedExtentScrollController _secondController;

  int _hours = 0;
  int _minutes = 10;
  int _seconds = 0;
  Duration _selectedDuration = const Duration(minutes: 10);
  Duration _remaining = const Duration(minutes: 10);
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: _hours);
    _minuteController = FixedExtentScrollController(initialItem: _minutes);
    _secondController = FixedExtentScrollController(initialItem: _seconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _applySelection({bool moveWheels = false}) {
    final selected = Duration(
      hours: _hours,
      minutes: _minutes,
      seconds: _seconds,
    );
    setState(() {
      _selectedDuration = selected.inSeconds == 0
          ? const Duration(minutes: 1)
          : selected;
      _remaining = _selectedDuration;
    });

    if (moveWheels) {
      _hourController.animateToItem(
        _hours,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      _minuteController.animateToItem(
        _minutes,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      _secondController.animateToItem(
        _seconds,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }

    if (_remaining.inSeconds == 0) {
      setState(() => _remaining = _selectedDuration);
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remaining = Duration.zero;
          _isRunning = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Таймер завершён')));
        }
        return;
      }

      setState(() => _remaining -= const Duration(seconds: 1));
    });

    setState(() => _isRunning = true);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remaining = _selectedDuration;
    });
  }

  String _format(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopBar(title: 'Таймер'),
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _isRunning
                    ? _RunningTimer(
                        key: const ValueKey('run'),
                        time: _format(_remaining),
                      )
                    : _WheelTimer(
                        key: const ValueKey('wheel'),
                        hourController: _hourController,
                        minuteController: _minuteController,
                        secondController: _secondController,
                        selectedHour: _hours,
                        selectedMinute: _minutes,
                        selectedSecond: _seconds,
                        onHour: (value) {
                          _hours = value;
                          _applySelection();
                        },
                        onMinute: (value) {
                          _minutes = value;
                          _applySelection();
                        },
                        onSecond: (value) {
                          _seconds = value;
                          _applySelection();
                        },
                      ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _resetTimer,
                    style: TextButton.styleFrom(
                      foregroundColor: _textSecondary,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Сброс',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  _PlayButton(isRunning: _isRunning, onTap: _toggleTimer),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _TimerPageState._textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    );
  }
}

class _WheelTimer extends StatelessWidget {
  const _WheelTimer({
    super.key,
    required this.hourController,
    required this.minuteController,
    required this.secondController,
    required this.selectedHour,
    required this.selectedMinute,
    required this.selectedSecond,
    required this.onHour,
    required this.onMinute,
    required this.onSecond,
  });

  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final FixedExtentScrollController secondController;
  final int selectedHour;
  final int selectedMinute;
  final int selectedSecond;
  final ValueChanged<int> onHour;
  final ValueChanged<int> onMinute;
  final ValueChanged<int> onSecond;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TimeWheel(
            count: 24,
            selectedIndex: selectedHour,
            controller: hourController,
            onChanged: onHour,
          ),
          const _Colon(),
          _TimeWheel(
            count: 60,
            selectedIndex: selectedMinute,
            controller: minuteController,
            onChanged: onMinute,
          ),
          const _Colon(),
          _TimeWheel(
            count: 60,
            selectedIndex: selectedSecond,
            controller: secondController,
            onChanged: onSecond,
          ),
        ],
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({
    required this.count,
    required this.selectedIndex,
    required this.controller,
    required this.onChanged,
  });

  final int count;
  final int selectedIndex;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      child: CupertinoPicker.builder(
        scrollController: controller,
        itemExtent: 36,
        magnification: 1.04,
        squeeze: 1.08,
        useMagnifier: true,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onSelectedItemChanged: onChanged,
        childCount: count,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: TextStyle(
                color: index == selectedIndex
                    ? _TimerPageState._textPrimary
                    : _TimerPageState._textSecondary.withValues(alpha: 0.42),
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          color: _TimerPageState._textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RunningTimer extends StatelessWidget {
  const _RunningTimer({super.key, required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _TimerPageState._card,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: _TimerPageState._border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x144D3C7A),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Text(
        time,
        style: const TextStyle(
          color: _TimerPageState._textPrimary,
          fontSize: 34,
          fontWeight: FontWeight.w600,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isRunning, required this.onTap});

  final bool isRunning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        height: 46,
        decoration: BoxDecoration(
          color: _TimerPageState._card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _TimerPageState._border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x174D3C7A),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Icon(
          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: isRunning ? _TimerPageState._purple : _TimerPageState._accent,
          size: 28,
        ),
      ),
    );
  }
}
