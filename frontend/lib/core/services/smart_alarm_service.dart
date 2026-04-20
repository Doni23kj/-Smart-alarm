import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'volume_fade_in_controller.dart';

class SmartAlarmService {
  SmartAlarmService({
    required FlutterLocalNotificationsPlugin notificationsPlugin,
    VolumeFadeInController? fadeInController,
  }) : _notificationsPlugin = notificationsPlugin,
       _fadeInController = fadeInController ?? VolumeFadeInController();

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final VolumeFadeInController _fadeInController;

  tz.TZDateTime calculateSmartWindowStart({
    required int targetHour,
    required int targetMinute,
    int windowMinutes = 30,
    tz.Location? location,
  }) {
    final zone = location ?? tz.local;
    final now = tz.TZDateTime.now(zone);
    var target = tz.TZDateTime(
      zone,
      now.year,
      now.month,
      now.day,
      targetHour,
      targetMinute,
    );

    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }

    return target.subtract(Duration(minutes: windowMinutes));
  }

  Future<void> scheduleSmartAlarm({
    required int id,
    required String title,
    required String body,
    required int targetHour,
    required int targetMinute,
    required String payload,
  }) async {
    final scheduledDate = calculateSmartWindowStart(
      targetHour: targetHour,
      targetMinute: targetMinute,
    );

    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: '$body Окно пробуждения: 30 минут.',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> startVolumeFadeIn({
    String assetPath = 'assets/audio/alarm.mp3',
  }) async {
    await _fadeInController.startFadeIn(assetPath: assetPath);
  }

  Future<void> stopAlarmAudio() async {
    await _fadeInController.stop();
  }
}
