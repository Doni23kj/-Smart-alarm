import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/services/alarm_audio_service.dart';

class CreateAlarmPage extends StatefulWidget {
  const CreateAlarmPage({super.key, this.initialAlarm});

  final Map<String, dynamic>? initialAlarm;

  @override
  State<CreateAlarmPage> createState() => _CreateAlarmPageState();
}

class _CreateAlarmPageState extends State<CreateAlarmPage> {
  static const _dayMap = {
    'Пн': 0,
    'Вт': 1,
    'Ср': 2,
    'Чт': 3,
    'Пт': 4,
    'Сб': 5,
    'Вс': 6,
  };

  static const _backgroundTop = Color(0xFFF9F7F2);
  static const _backgroundBottom = Color(0xFFF3EFFB);
  static const _card = Color(0xFFFFFFFF);
  static const _cardSoft = Color(0xFFF2EEFE);
  static const _cardBorder = Color(0xFFE7DFF4);
  static const _accent = Color(0xFF6E63F6);
  static const _accentSoft = Color(0xFFB3A8FF);
  static const _success = Color(0xFF4F8CFF);
  static const _muted = Color(0xFF8F879E);
  static const _textPrimary = Color(0xFF2B2540);

  TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 0);
  final TextEditingController titleController = TextEditingController();
  final List<String> weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  final Set<int> selectedDays = <int>{};
  final List<String> difficulties = ['Легко', 'Средне', 'Сложно'];
  bool isEnabled = true;
  String selectedTask = 'Математика';
  String selectedDifficulty = 'Средне';
  double volume = 92;
  int attempts = 3;
  bool _isPreviewPlaying = false;
  Timer? _previewStopTimer;

  @override
  void initState() {
    super.initState();
    final alarm = widget.initialAlarm;
    if (alarm == null) return;

    final time = (alarm['time'] ?? '07:00').toString().split(':');
    selectedTime = TimeOfDay(
      hour: int.tryParse(time.first) ?? 7,
      minute: int.tryParse(time.length > 1 ? time[1] : '0') ?? 0,
    );
    titleController.text = (alarm['title'] ?? '').toString();
    selectedTask = (alarm['task'] ?? 'Математика').toString();
    selectedDifficulty = (alarm['difficulty'] ?? 'Средне').toString();
    volume = ((alarm['volume'] ?? 92) as num).toDouble();
    attempts = (alarm['attempts'] as num? ?? 3).toInt();
    isEnabled = alarm['active'] != false;

    final days = List<dynamic>.from(alarm['days'] ?? []);
    selectedDays
      ..clear()
      ..addAll(
        days.map((day) {
          if (day is int) return day;
          return _dayMap[day.toString()] ?? 0;
        }),
      );
  }

  @override
  void dispose() {
    _previewStopTimer?.cancel();
    unawaited(AlarmAudioService.instance.stop());
    titleController.dispose();
    super.dispose();
  }

  Future<void> _playSoundPreview() async {
    _previewStopTimer?.cancel();
    final previewVolume = (volume / 100).clamp(0.72, 1.0);
    await AlarmAudioService.instance.start(volume: previewVolume);
    if (!mounted) return;
    setState(() => _isPreviewPlaying = true);
    _previewStopTimer = Timer(const Duration(seconds: 4), () async {
      await AlarmAudioService.instance.stop();
      if (!mounted) return;
      setState(() => _isPreviewPlaying = false);
    });
  }

  Future<void> _stopSoundPreview() async {
    _previewStopTimer?.cancel();
    await AlarmAudioService.instance.stop();
    if (!mounted) return;
    setState(() => _isPreviewPlaying = false);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _accent,
              surface: _card,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: _card),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() => selectedTime = picked);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _daysLabel() {
    if (selectedDays.isEmpty) return 'Не выбрано';
    final days = selectedDays.toList()..sort();
    return days.map((index) => weekDays[index]).join(', ');
  }

  void _saveAlarm() {
    Navigator.pop(context, {
      'id': widget.initialAlarm?['id'],
      'active': isEnabled,
      'time': _formatTime(selectedTime),
      'title': titleController.text.trim(),
      'task': selectedTask,
      'days': selectedDays.toList()..sort(),
      'difficulty': selectedDifficulty,
      'attempts': attempts,
      'volume': volume.toInt(),
    });
  }

  void _deleteAlarm() {
    Navigator.pop(context, {
      'action': 'delete',
      'id': widget.initialAlarm?['id'],
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _backgroundBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundTop, _backgroundBottom],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -110,
              right: -40,
              child: _AmbientGlow(size: 220, color: Color(0x227B61FF)),
            ),
            const Positioned(
              top: 210,
              left: -60,
              child: _AmbientGlow(size: 180, color: Color(0x224F8CFF)),
            ),
            SafeArea(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 220),
                padding: EdgeInsets.only(bottom: viewInsets),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                  children: [
                    Row(
                      children: [
                        _TopCircleButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          widget.initialAlarm == null
                              ? 'Будильник'
                              : 'Редактирование',
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        _TopCircleButton(
                          icon: isEnabled
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined,
                          onTap: () => setState(() => isEnabled = !isEnabled),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.94, end: 1),
                      duration: const Duration(milliseconds: 550),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickTime,
                            child: Text(
                              _formatTime(selectedTime),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 66,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(7, (index) {
                                final selected = selectedDays.contains(index);
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index == 6 ? 0 : 10,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selected) {
                                          selectedDays.remove(index);
                                        } else {
                                          selectedDays.add(index);
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selected ? _accent : _cardSoft,
                                        boxShadow: selected
                                            ? const [
                                                BoxShadow(
                                                  color: Color(0x558D5CFF),
                                                  blurRadius: 22,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        weekDays[index].toLowerCase(),
                                        style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : _textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _SectionCard(
                      child: Column(
                        children: [
                          _textFieldLabel('Этикетка'),
                          const SizedBox(height: 10),
                          TextField(
                            controller: titleController,
                            style: const TextStyle(color: _textPrimary),
                            decoration: _darkInputDecoration(
                              'Например: Утренний подъём',
                            ),
                          ),
                          const SizedBox(height: 18),
                          _settingLine(
                            title: 'Повтор',
                            trailing: Text(
                              _daysLabel(),
                              style: const TextStyle(color: _muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textFieldLabel('Метод отключения сигнала'),
                          const SizedBox(height: 14),
                          ...[
                            ('Математическая задача', Icons.calculate_outlined),
                            ('Память', Icons.psychology_alt_outlined),
                            ('Фото', Icons.camera_alt_outlined),
                            ('Головоломка', Icons.extension_rounded),
                          ].map((option) {
                            final selected =
                                _mapTask(option.$1) == selectedTask;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TaskOptionTile(
                                label: option.$1,
                                icon: option.$2,
                                selected: selected,
                                onTap: () {
                                  setState(() {
                                    selectedTask = _mapTask(option.$1);
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _settingLine(
                            title: 'Показать уведомление',
                            trailing: Switch(
                              value: isEnabled,
                              onChanged: (value) {
                                setState(() => isEnabled = value);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _settingLine(
                            title: 'Звук',
                            trailing: GestureDetector(
                              onTap: _isPreviewPlaying
                                  ? _stopSoundPreview
                                  : _playSoundPreview,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isPreviewPlaying
                                        ? 'Остановить'
                                        : 'Встроенный сигнал',
                                    style: const TextStyle(color: _muted),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    _isPreviewPlaying
                                        ? Icons.stop_circle_outlined
                                        : Icons.play_circle_outline_rounded,
                                    color: _accent,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _settingLine(
                            title: 'Громкость',
                            trailing: Text(
                              '${volume.toInt()}%',
                              style: const TextStyle(color: _textPrimary),
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _accent,
                              inactiveTrackColor: _cardBorder,
                              thumbColor: Colors.white,
                              overlayColor: _accent.withValues(alpha: 0.12),
                            ),
                            child: Slider(
                              value: volume,
                              min: 40,
                              max: 100,
                              onChanged: (value) {
                                setState(() => volume = value);
                                unawaited(_playSoundPreview());
                              },
                              onChangeEnd: (_) => unawaited(_playSoundPreview()),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _settingLine(
                            title: 'Сложность',
                            trailing: Text(
                              selectedDifficulty,
                              style: const TextStyle(color: _textPrimary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: difficulties.map((item) {
                              final active = item == selectedDifficulty;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => selectedDifficulty = item);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: active ? _accent : _cardSoft,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: active ? _accentSoft : _cardBorder,
                                    ),
                                  ),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: active
                                          ? Colors.white
                                          : _textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 18),
                          _settingLine(
                            title: 'Количество попыток',
                            trailing: Text(
                              '$attempts',
                              style: const TextStyle(color: _textPrimary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [1, 2, 3, 5].map((value) {
                              final active = attempts == value;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => attempts = value);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 48,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: active ? _accent : _cardSoft,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: active
                                            ? _accentSoft
                                            : _cardBorder,
                                      ),
                                    ),
                                    child: Text(
                                      '$value',
                                      style: TextStyle(
                                        color: active
                                            ? Colors.white
                                            : _textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _SecondaryActionButton(
                            label: 'Отмена',
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        if (widget.initialAlarm != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SecondaryActionButton(
                              label: 'Удалить',
                              danger: true,
                              onTap: _deleteAlarm,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    _PrimaryActionButton(
                      label: 'Сохранить будильник',
                      color: _success,
                      onTap: _saveAlarm,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mapTask(String label) {
    switch (label) {
      case 'Математическая задача':
        return 'Математика';
      case 'Память':
        return 'Память';
      case 'Фото':
        return 'Фото';
      case 'Головоломка':
        return 'Логика';
      default:
        return 'Математика';
    }
  }

  Widget _textFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _settingLine({required String title, required Widget trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing,
      ],
    );
  }

  InputDecoration _darkInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _muted),
      filled: true,
      fillColor: _cardSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _accent),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _CreateAlarmPageState._card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _CreateAlarmPageState._cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x184D3C7A),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  const _TopCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _CreateAlarmPageState._card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _CreateAlarmPageState._cardBorder),
          ),
          child: Icon(icon, color: _CreateAlarmPageState._textPrimary),
        ),
      ),
    );
  }
}

class _TaskOptionTile extends StatelessWidget {
  const _TaskOptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? _CreateAlarmPageState._accent.withValues(alpha: 0.18)
              : _CreateAlarmPageState._cardSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? _CreateAlarmPageState._accent
                : _CreateAlarmPageState._cardBorder,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x338D5CFF),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? _CreateAlarmPageState._accent
                  : _CreateAlarmPageState._accentSoft,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _CreateAlarmPageState._textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? _CreateAlarmPageState._accent
                  : _CreateAlarmPageState._muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: danger
            ? const Color(0xFFE66A86)
            : _CreateAlarmPageState._textPrimary,
        side: BorderSide(
          color: danger
              ? const Color(0x66E66A86)
              : _CreateAlarmPageState._cardBorder,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: Text(label),
    );
  }
}

class _PrimaryActionButton extends StatefulWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<_PrimaryActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.98 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
