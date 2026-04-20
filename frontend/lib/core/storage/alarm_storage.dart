import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AlarmStorage {
  static const _key = 'alarms';
  static const _maxNotificationId = 2147483647;
  static const Map<String, int> _dayMap = {
    'Пн': 0,
    'Вт': 1,
    'Ср': 2,
    'Чт': 3,
    'Пт': 4,
    'Сб': 5,
    'Вс': 6,
  };

  static int createAlarmId() {
    return DateTime.now().millisecondsSinceEpoch % _maxNotificationId;
  }

  static int normalizeAlarmId(dynamic value) {
    if (value is int) {
      return value.abs() % _maxNotificationId;
    }
    return createAlarmId();
  }

  static List<int> normalizeDays(dynamic rawDays) {
    final values = rawDays is List ? rawDays : const [];
    final normalized = <int>{};

    for (final day in values) {
      int? parsedDay;
      if (day is int) {
        parsedDay = day;
      } else if (day is num) {
        parsedDay = day.toInt();
      } else if (day != null) {
        parsedDay = int.tryParse(day.toString()) ?? _dayMap[day.toString()];
      }

      if (parsedDay != null && parsedDay >= 0 && parsedDay <= 6) {
        normalized.add(parsedDay);
      }
    }

    final sorted = normalized.toList()..sort();
    return sorted;
  }

  static Future<List<Map<String, dynamic>>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) return [];

    final decoded = jsonDecode(data);
    return List<Map<String, dynamic>>.from(decoded).map((alarm) {
      return {
        'id': normalizeAlarmId(alarm['id']),
        'time': alarm['time'] ?? '07:00',
        'title': alarm['title'] ?? '',
        'task': alarm['task'] ?? 'Математика',
        'days': normalizeDays(alarm['days']),
        'difficulty': alarm['difficulty'] ?? 'Средне',
        'attempts': alarm['attempts'] ?? 3,
        'volume': alarm['volume'] ?? 80,
        'active': alarm['active'] != false,
      };
    }).toList();
  }

  static Future<void> saveAlarms(List<Map<String, dynamic>> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(alarms));
  }
}
