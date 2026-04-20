import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/storage/alarm_storage.dart';
import 'package:frontend/features/alarms/data/models/alarm_model.dart';

void main() {
  group('Alarm day normalization', () {
    test('normalizes mixed day formats into sorted unique weekday indexes', () {
      expect(AlarmStorage.normalizeDays(['Пн', 2, '6', 'Пн', 99, -1, null]), [
        0,
        2,
        6,
      ]);
    });

    test('presentation mapping accepts legacy string day labels', () {
      final model = AlarmModel.fromPresentationMap({
        'time': '07:30',
        'title': 'Morning',
        'active': true,
        'task': 'Математика',
        'difficulty': 'Средне',
        'volume': 80,
        'attempts': 3,
        'days': ['Пн', 'Ср', 5],
      });

      expect(model.repeatDays, [0, 2, 5]);
    });
  });
}
