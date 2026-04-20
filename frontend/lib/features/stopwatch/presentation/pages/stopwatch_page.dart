import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFFF8F6F1);
  static const _card = Color(0xFFFFFFFF);
  static const _textPrimary = Color(0xFF252033);
  static const _textSecondary = Color(0xFF9A95A8);
  static const _accent = Color(0xFF4F8CFF);
  static const _purple = Color(0xFF7B61FF);
  static const _border = Color(0xFFE8E2F0);

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.96,
      upperBound: 1.04,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      _pulseController.stop();
      setState(() {});
      return;
    }

    _stopwatch.start();
    _pulseController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (mounted) setState(() {});
    });
    setState(() {});
  }

  void _resetStopwatch() {
    _timer?.cancel();
    _pulseController.stop();
    _stopwatch
      ..stop()
      ..reset();
    setState(() => _laps.clear());
  }

  void _addLap() {
    if (!_stopwatch.isRunning) return;
    setState(() => _laps.insert(0, _stopwatch.elapsed));
  }

  String _format(Duration value) {
    final minutes = value.inMinutes.toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    final hundredths = ((value.inMilliseconds % 1000) / 10)
        .floor()
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$hundredths';
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
              const _TopBar(title: 'Секундомер'),
              const Spacer(flex: 2),
              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = _stopwatch.isRunning
                        ? _pulseController.value
                        : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Text(
                    _format(_stopwatch.elapsed),
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 46,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -1.6,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _laps.isEmpty
                    ? const Center(
                        key: ValueKey('empty'),
                        child: Text(
                          'Круги пока не добавлены',
                          style: TextStyle(color: _textSecondary),
                        ),
                      )
                    : _LapList(
                        key: const ValueKey('laps'),
                        laps: _laps,
                        format: _format,
                      ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GhostButton(label: 'Круг', onTap: _addLap),
                  const SizedBox(width: 14),
                  _PlayButton(
                    isRunning: _stopwatch.isRunning,
                    onTap: _toggleStopwatch,
                  ),
                  const SizedBox(width: 14),
                  _GhostButton(label: 'Сброс', onTap: _resetStopwatch),
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
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _StopwatchPageState._textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
      ],
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 86,
        height: 50,
        decoration: BoxDecoration(
          color: _StopwatchPageState._card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _StopwatchPageState._border),
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
          color: isRunning
              ? _StopwatchPageState._purple
              : _StopwatchPageState._accent,
          size: 30,
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _StopwatchPageState._textSecondary,
        shape: const StadiumBorder(),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _LapList extends StatelessWidget {
  const _LapList({super.key, required this.laps, required this.format});

  final List<Duration> laps;
  final String Function(Duration value) format;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 230),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _StopwatchPageState._card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _StopwatchPageState._border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: laps.length,
        separatorBuilder: (_, __) => const Divider(height: 18),
        itemBuilder: (context, index) {
          return Row(
            children: [
              Text(
                'Круг ${laps.length - index}',
                style: const TextStyle(
                  color: _StopwatchPageState._textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                format(laps[index]),
                style: const TextStyle(
                  color: _StopwatchPageState._textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
