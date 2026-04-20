import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/alarm_storage.dart';
import '../../data/datasources/alarm_remote_datasource.dart';
import '../../data/models/alarm_model.dart';
import 'create_alarm_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _bg = Color(0xFFF8F6F1);
  static const _card = Color(0xFFFFFFFF);
  static const _cardBorder = Color(0xFFE8E2F0);
  static const _textPrimary = Color(0xFF2B2540);
  static const _textSecondary = Color(0xFF8F879E);
  static const _accent = Color(0xFF6E63F6);
  static const _danger = Color(0xFFE66A86);

  final AlarmRemoteDataSource _alarmRemoteDataSource = AlarmRemoteDataSource();
  List<Map<String, dynamic>> alarms = [];
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error
            ? const Color(0xFFE66A86)
            : const Color(0xFF6E63F6),
      ),
    );
  }

  Future<void> _loadAlarms() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final remoteAlarms = await _alarmRemoteDataSource.getAlarms();
      final loaded = remoteAlarms
          .map((alarm) => alarm.toPresentationMap())
          .toList();

      setState(() {
        alarms = loaded;
      });

      await AlarmStorage.saveAlarms(alarms);
      for (final alarm in alarms.where((item) => item['active'] == true)) {
        await _scheduleAlarmFromMap(alarm);
      }
    } catch (error) {
      final loaded = await AlarmStorage.loadAlarms();
      setState(() {
        alarms = loaded;
        final message = error.toString();
        if (message.contains('Сессия истекла')) {
          _errorText = 'Сессия истекла. Войдите снова.';
        } else {
          _errorText = 'Не удалось загрузить будильники с сервера.';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _scheduleAlarmFromMap(Map<String, dynamic> alarm) async {
    final time = (alarm['time'] ?? '07:00').toString();
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 7;
    final minute = int.tryParse(parts[1]) ?? 0;
    final id = AlarmStorage.normalizeAlarmId(alarm['id']);

    final volume = ((alarm['volume'] as num?)?.toDouble() ?? 80)
        .clamp(0, 100)
        .round();
    final task = (alarm['task'] ?? 'Математика').toString();

    await NotificationService.instance.scheduleAlarm(
      id: id,
      title: (alarm['title'] ?? '').toString().trim().isEmpty
          ? 'Будильник'
          : alarm['title'].toString(),
      body: 'Пора вставать! Задача: $task',
      hour: hour,
      minute: minute,
      payload: jsonEncode({'task': task, 'volume': volume}),
      repeatDays: AlarmStorage.normalizeDays(alarm['days']),
    );
  }

  Future<void> _openCreateAlarmPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateAlarmPage()),
    );

    if (result == null || result is! Map<String, dynamic>) return;

    Map<String, dynamic> alarm;
    try {
      final created = await _alarmRemoteDataSource.createAlarm(
        AlarmModel.fromPresentationMap(result),
      );
      alarm = created.toPresentationMap();
      _showMessage('Будильник добавлен');
    } catch (_) {
      alarm = {...result, 'id': AlarmStorage.createAlarmId()};
      _showMessage(
        'Сервер недоступен. Будильник сохранён только на устройстве.',
        error: true,
      );
    }

    setState(() {
      alarms.insert(0, alarm);
    });

    await AlarmStorage.saveAlarms(alarms);
    if (alarm['active'] == true) {
      try {
        await _scheduleAlarmFromMap(alarm);
      } catch (_) {
        _showMessage('Не удалось запланировать уведомление.', error: true);
      }
    }
  }

  Future<void> _openExistingAlarm(int index) async {
    final currentAlarm = Map<String, dynamic>.from(alarms[index]);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAlarmPage(initialAlarm: currentAlarm),
      ),
    );

    if (result == null || result is! Map<String, dynamic>) return;

    if (result['action'] == 'delete') {
      await _deleteAlarm(index);
      return;
    }

    Map<String, dynamic> updatedAlarm;
    try {
      final updated = await _alarmRemoteDataSource.updateAlarm(
        AlarmModel.fromPresentationMap({...result, 'id': currentAlarm['id']}),
      );
      updatedAlarm = updated.toPresentationMap();
      _showMessage('Будильник обновлён');
    } catch (_) {
      updatedAlarm = {...result, 'id': currentAlarm['id']};
      _showMessage(
        'Сервер недоступен. Изменения сохранены только на устройстве.',
        error: true,
      );
    }

    setState(() {
      alarms[index] = updatedAlarm;
    });

    await AlarmStorage.saveAlarms(alarms);

    final id = AlarmStorage.normalizeAlarmId(currentAlarm['id']);
    await NotificationService.instance.cancelAlarm(id);
    if (updatedAlarm['active'] == true) {
      try {
        await _scheduleAlarmFromMap(updatedAlarm);
      } catch (_) {
        _showMessage('Не удалось обновить уведомление.', error: true);
      }
    }
  }

  Future<void> _toggleAlarm(int index, bool value) async {
    setState(() {
      alarms[index]['active'] = value;
    });

    try {
      final updated = await _alarmRemoteDataSource.updateAlarm(
        AlarmModel.fromPresentationMap(alarms[index]),
      );
      alarms[index] = updated.toPresentationMap();
    } catch (_) {
      _showMessage(
        'Сервер недоступен. Переключение сохранено только на устройстве.',
        error: true,
      );
    }
    await AlarmStorage.saveAlarms(alarms);

    final id = AlarmStorage.normalizeAlarmId(alarms[index]['id']);
    if (value) {
      try {
        await _scheduleAlarmFromMap(alarms[index]);
      } catch (_) {
        _showMessage('Не удалось включить уведомление.', error: true);
      }
    } else {
      await NotificationService.instance.cancelAlarm(id);
    }
  }

  Future<void> _deleteAlarm(int index) async {
    final id = AlarmStorage.normalizeAlarmId(alarms[index]['id']);
    final remoteId = alarms[index]['id'];

    if (remoteId is int) {
      try {
        await _alarmRemoteDataSource.deleteAlarm(remoteId);
      } catch (_) {
        _showMessage(
          'Сервер недоступен. Будильник удалён только на устройстве.',
          error: true,
        );
      }
    }

    setState(() {
      alarms.removeAt(index);
    });
    await AlarmStorage.saveAlarms(alarms);
    await NotificationService.instance.cancelAlarm(id);
    _showMessage('Будильник удалён');
  }

  String _daysLabel(List<dynamic> days) {
    const dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final normalizedDays = AlarmStorage.normalizeDays(days);
    if (normalizedDays.isEmpty) return 'Без повторов';
    return normalizedDays
        .where((day) => day >= 0 && day < dayLabels.length)
        .map((day) => dayLabels[day])
        .join(', ');
  }

  String _formatDisplayTime(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    final hour = parts[0].padLeft(2, '0');
    final minute = parts[1].padLeft(2, '0');
    return '$hour:$minute';
  }

  String _relativeDayLabel(Map<String, dynamic> alarm) {
    final normalized = AlarmStorage.normalizeDays(alarm['days']).toSet();
    if (normalized.isEmpty) return 'Сегодня';

    final today = DateTime.now().weekday - 1;
    for (var offset = 0; offset < 7; offset++) {
      final check = (today + offset) % 7;
      if (normalized.contains(check)) {
        if (offset == 0) return 'Сегодня';
        if (offset == 1) return 'Завтра';
        return 'Через $offset дн.';
      }
    }
    return 'Скоро';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBody: true,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -80,
              right: -70,
              child: _SoftGlow(size: 210, color: Color(0x227B61FF)),
            ),
            const Positioned(
              bottom: 120,
              left: -80,
              child: _SoftGlow(size: 190, color: Color(0x224F8CFF)),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Умный будильник',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _HeaderButton(
                      icon: Icons.refresh_rounded,
                      onTap: _loadAlarms,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_errorText != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Text(
                      _errorText!,
                      style: const TextStyle(color: _textSecondary),
                    ),
                  ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: _accent),
                    ),
                  ),
                if (!_isLoading && alarms.isEmpty) const _EmptyAlarmCard(),
                if (!_isLoading)
                  ...alarms.asMap().entries.map((entry) {
                    final index = entry.key;
                    final alarm = entry.value;
                    final isActive = alarm['active'] == true;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 260 + (index * 55)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 18 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _openExistingAlarm(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isActive
                                    ? const [
                                        Color(0xFFFFFFFF),
                                        Color(0xFFF2EFFF),
                                      ]
                                    : const [
                                        Color(0xFFFFFFFF),
                                        Color(0xFFFAF8F4),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive
                                    ? _accent.withValues(alpha: 0.28)
                                    : _cardBorder,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isActive
                                      ? _accent.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _relativeDayLabel(alarm),
                                      style: const TextStyle(
                                        color: _textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Transform.scale(
                                      scale: 0.86,
                                      child: Switch(
                                        value: isActive,
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: _accent,
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: const Color(
                                          0xFFD8D2E8,
                                        ),
                                        onChanged: (value) =>
                                            _toggleAlarm(index, value),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDisplayTime(alarm['time'].toString()),
                                  style: TextStyle(
                                    color: isActive
                                        ? _textPrimary
                                        : _textSecondary,
                                    fontSize: 46,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.4,
                                    height: 0.95,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (alarm['title'] ?? '')
                                                    .toString()
                                                    .trim()
                                                    .isEmpty
                                                ? 'Будильник'
                                                : alarm['title'].toString(),
                                            style: const TextStyle(
                                              color: _textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            _daysLabel(
                                              List<dynamic>.from(
                                                alarm['days'] ?? [],
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: _textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _deleteAlarm(index),
                                      icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: _danger,
                                        size: 19,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Center(
                child: GestureDetector(
                  onTap: _openCreateAlarmPage,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.92, end: 1),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accent,
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.42),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAlarmCard extends StatelessWidget {
  const _EmptyAlarmCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _HomePageState._card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _HomePageState._cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Нет будильников',
            style: TextStyle(
              color: _HomePageState._textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Нажмите кнопку снизу, чтобы создать первый будильник.',
            style: TextStyle(
              color: _HomePageState._textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _HomePageState._card,
          border: Border.all(color: _HomePageState._cardBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: _HomePageState._textPrimary, size: 18),
      ),
    );
  }
}
