import 'dart:async';
import 'dart:convert';

import '../storage/alarm_storage.dart';
import 'notification_service.dart';

class AlarmRuntimeService {
  AlarmRuntimeService._();

  static final AlarmRuntimeService instance = AlarmRuntimeService._();

  Timer? _timer;
  final Set<String> _triggeredKeys = <String>{};
  bool _isChecking = false;

  void start() {
    _timer?.cancel();
    _checkNow();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkNow() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final alarms = await AlarmStorage.loadAlarms();
      final now = DateTime.now();
      final currentMinuteKey =
          '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';

      _triggeredKeys.removeWhere(
        (key) => !key.startsWith(
          '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}',
        ),
      );

      for (final alarm in alarms) {
        if (alarm['active'] != true) continue;

        final time = (alarm['time'] ?? '07:00').toString().split(':');
        final hour = int.tryParse(time.first) ?? 0;
        final minute = int.tryParse(time.length > 1 ? time[1] : '0') ?? 0;

        if (hour != now.hour || minute != now.minute) continue;
        if (!_matchesRepeatDay(alarm, now)) continue;

        final alarmKey =
            '$currentMinuteKey-${AlarmStorage.normalizeAlarmId(alarm['id'])}';
        if (_triggeredKeys.contains(alarmKey)) continue;
        _triggeredKeys.add(alarmKey);

        final task = (alarm['task'] ?? 'Математика').toString();
        final volume = ((alarm['volume'] as num?)?.toDouble() ?? 80)
            .clamp(0, 100)
            .round();

        NotificationService.instance.openChallengeByTaskPayload(
          jsonEncode({'task': task, 'volume': volume}),
        );
      }
    } finally {
      _isChecking = false;
    }
  }

  bool _matchesRepeatDay(Map<String, dynamic> alarm, DateTime now) {
    final normalizedDays = AlarmStorage.normalizeDays(alarm['days']);
    if (normalizedDays.isEmpty) return true;
    final today = now.weekday - 1;
    return normalizedDays.contains(today);
  }
}
