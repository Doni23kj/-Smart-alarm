class AlarmModel {
  const AlarmModel({
    required this.id,
    required this.time,
    required this.label,
    required this.isActive,
    required this.taskType,
    required this.difficulty,
    required this.volume,
    required this.attempts,
    required this.repeatDays,
  });

  final int? id;
  final String time;
  final String label;
  final bool isActive;
  final String taskType;
  final String difficulty;
  final int volume;
  final int attempts;
  final List<int> repeatDays;

  static const Map<String, String> taskToApi = {
    'Математика': 'math',
    'Память': 'memory',
    'Фото': 'photo',
    'Логика': 'logic',
  };

  static const Map<String, String> taskFromApi = {
    'math': 'Математика',
    'memory': 'Память',
    'photo': 'Фото',
    'logic': 'Логика',
  };

  static const Map<String, String> difficultyToApi = {
    'Легко': 'easy',
    'Средне': 'medium',
    'Сложно': 'hard',
  };

  static const Map<String, String> difficultyFromApi = {
    'easy': 'Легко',
    'medium': 'Средне',
    'hard': 'Сложно',
  };

  static List<int> _normalizeDays(dynamic rawDays) {
    final values = rawDays is List ? rawDays : const [];
    const dayMap = {
      'Пн': 0,
      'Вт': 1,
      'Ср': 2,
      'Чт': 3,
      'Пт': 4,
      'Сб': 5,
      'Вс': 6,
    };

    final normalized = <int>{};
    for (final day in values) {
      int? parsedDay;
      if (day is int) {
        parsedDay = day;
      } else if (day is num) {
        parsedDay = day.toInt();
      } else if (day != null) {
        parsedDay = int.tryParse(day.toString()) ?? dayMap[day.toString()];
      }

      if (parsedDay != null && parsedDay >= 0 && parsedDay <= 6) {
        normalized.add(parsedDay);
      }
    }

    final sorted = normalized.toList()..sort();
    return sorted;
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as int?,
      time: (json['time'] ?? '07:00').toString(),
      label: (json['label'] ?? '').toString(),
      isActive: json['is_active'] != false,
      taskType: (json['task_type'] ?? 'math').toString(),
      difficulty: (json['difficulty'] ?? 'medium').toString(),
      volume: (json['volume'] as num? ?? 80).toInt(),
      attempts: (json['attempts'] as num? ?? 3).toInt(),
      repeatDays: _normalizeDays(json['repeat_days']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'label': label,
      'is_active': isActive,
      'task_type': taskType,
      'difficulty': difficulty,
      'volume': volume,
      'attempts': attempts,
      'repeat_days': repeatDays,
    };
  }

  Map<String, dynamic> toPresentationMap() {
    return {
      'id': id,
      'time': time,
      'title': label,
      'active': isActive,
      'task': taskFromApi[taskType] ?? 'Математика',
      'difficulty': difficultyFromApi[difficulty] ?? 'Средне',
      'volume': volume,
      'attempts': attempts,
      'days': List<int>.from(repeatDays)..sort(),
    };
  }

  factory AlarmModel.fromPresentationMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'] as int?,
      time: (map['time'] ?? '07:00').toString(),
      label: (map['title'] ?? '').toString(),
      isActive: map['active'] != false,
      taskType: taskToApi[(map['task'] ?? 'Математика').toString()] ?? 'math',
      difficulty:
          difficultyToApi[(map['difficulty'] ?? 'Средне').toString()] ??
          'medium',
      volume: (map['volume'] as num? ?? 80).toInt(),
      attempts: (map['attempts'] as num? ?? 3).toInt(),
      repeatDays: _normalizeDays(map['days']),
    );
  }
}
