import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/alarm_ring/presentation/pages/math_challenge_page.dart';
import '../../features/alarm_ring/presentation/pages/memory_challenge_page.dart';
import '../../features/alarm_ring/presentation/pages/logic_challenge_page.dart';
import '../../features/alarm_ring/presentation/pages/photo_challenge_page.dart';
import '../../features/alarm_ring/presentation/pages/shake_challenge_page.dart';
import '../navigation/app_navigator.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _settingsChannel = MethodChannel(
    'smart_alarm/settings',
  );

  Future<void> init() async {
    tz.initializeTimeZones();
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        _openChallengeByPayload(response.payload);
      },
    );
  }

  Future<void> requestIOSPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<bool> hasNotificationPermission() async {
    if (kIsWeb) return true;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        final permissions = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.checkPermissions();
        return permissions?.isEnabled == true &&
            permissions?.isAlertEnabled == true &&
            permissions?.isSoundEnabled == true;
      case TargetPlatform.macOS:
        final permissions = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.checkPermissions();
        return permissions?.isEnabled == true &&
            permissions?.isAlertEnabled == true &&
            permissions?.isSoundEnabled == true;
      case TargetPlatform.android:
        return await flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.areNotificationsEnabled() ??
            false;
      default:
        return true;
    }
  }

  Future<bool> requestNotificationPermissions() async {
    if (kIsWeb) return true;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        break;
      case TargetPlatform.macOS:
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        break;
      case TargetPlatform.android:
        final androidPlugin = flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        await androidPlugin?.requestNotificationsPermission();
        await androidPlugin?.requestExactAlarmsPermission();
        break;
      default:
        break;
    }

    return hasNotificationPermission();
  }

  Future<bool> openSystemSettings() async {
    if (kIsWeb) return false;
    try {
      final opened = await _settingsChannel.invokeMethod<bool>(
        'openAppSettings',
      );
      return opened ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> getLaunchPayload() async {
    final details = await flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp == true) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }

  void _openChallengeByPayload(String? payload) {
    final context = AppNavigator.navigatorKey.currentContext;
    if (context == null) return;

    final alarmPayload = _parsePayload(payload);

    Widget page;

    switch (alarmPayload.task) {
      case 'Фото':
        page = PhotoChallengePage(ringVolume: alarmPayload.ringVolume);
        break;
      case 'Память':
        page = MemoryChallengePage(ringVolume: alarmPayload.ringVolume);
        break;
      case 'Логика':
        page = LogicChallengePage(ringVolume: alarmPayload.ringVolume);
        break;
      case 'Встряска':
        page = ShakeChallengePage(ringVolume: alarmPayload.ringVolume);
        break;
      case 'Математика':
      default:
        page = MathChallengePage(ringVolume: alarmPayload.ringVolume);
        break;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void openChallengeByTaskPayload(String? payload) {
    _openChallengeByPayload(payload);
  }

  Future<void> openChallengeFromLaunchPayload() async {
    final payload = await getLaunchPayload();
    if (payload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openChallengeByPayload(payload);
      });
    }
  }

  Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
    List<int> repeatDays = const [],
  }) async {
    await cancelAlarm(id);

    final normalizedDays =
        repeatDays.where((day) => day >= 0 && day <= 6).toSet().toList()
          ..sort();

    if (normalizedDays.isEmpty) {
      await _scheduleSingleAlarm(
        id: id,
        title: title,
        body: body,
        hour: hour,
        minute: minute,
        payload: payload,
      );
      return;
    }

    for (final day in normalizedDays) {
      await _scheduleSingleAlarm(
        id: _notificationIdForDay(id, day),
        title: title,
        body: body,
        hour: hour,
        minute: minute,
        payload: payload,
        repeatDay: day,
      );
    }
  }

  Future<void> _scheduleSingleAlarm({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
    int? repeatDay,
  }) async {
    final scheduledDate = repeatDay == null
        ? _nextDateTime(hour: hour, minute: minute)
        : _nextDateTimeForRepeatDay(
            repeatDay: repeatDay,
            hour: hour,
            minute: minute,
          );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
      sound: 'default',
    );

    const androidDetails = AndroidNotificationDetails(
      'smart_alarm_channel',
      'Smart Alarm',
      channelDescription: 'Будильники Smart Alarm',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    const details = NotificationDetails(
      iOS: darwinDetails,
      macOS: darwinDetails,
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: repeatDay == null
          ? null
          : DateTimeComponents.dayOfWeekAndTime,
    );
  }

  Future<void> cancelAlarm(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
    for (var day = 0; day < 7; day++) {
      await flutterLocalNotificationsPlugin.cancel(
        id: _notificationIdForDay(id, day),
      );
    }
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  int _notificationIdForDay(int id, int day) {
    return ((id % 200000000) * 10) + day;
  }

  tz.TZDateTime _nextDateTime({required int hour, required int minute}) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return tz.TZDateTime.from(scheduledDate, tz.local);
  }

  tz.TZDateTime _nextDateTimeForRepeatDay({
    required int repeatDay,
    required int hour,
    required int minute,
  }) {
    final now = DateTime.now();
    final targetWeekday = repeatDay + 1;
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    var daysToAdd = targetWeekday - scheduledDate.weekday;
    if (daysToAdd < 0 || (daysToAdd == 0 && !scheduledDate.isAfter(now))) {
      daysToAdd += 7;
    }
    return tz.TZDateTime.from(
      scheduledDate.add(Duration(days: daysToAdd)),
      tz.local,
    );
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timezoneName = await _settingsChannel.invokeMethod<String>(
        'getLocalTimezone',
      );
      if (timezoneName != null && timezoneName.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(timezoneName));
        return;
      }
    } catch (_) {
      // Continue with fallback location.
    }

    tz.setLocalLocation(
      _fallbackLocationByOffset(DateTime.now().timeZoneOffset),
    );
  }

  tz.Location _fallbackLocationByOffset(Duration offset) {
    final offsetMinutes = offset.inMinutes;
    const offsetToLocation = <int, String>{
      -720: 'Etc/GMT+12',
      -660: 'Pacific/Midway',
      -600: 'Pacific/Honolulu',
      -540: 'America/Anchorage',
      -480: 'America/Los_Angeles',
      -420: 'America/Denver',
      -360: 'America/Chicago',
      -300: 'America/New_York',
      -240: 'America/Halifax',
      -210: 'America/St_Johns',
      -180: 'America/Sao_Paulo',
      -120: 'Atlantic/South_Georgia',
      -60: 'Atlantic/Azores',
      0: 'Etc/UTC',
      60: 'Europe/Berlin',
      120: 'Europe/Athens',
      180: 'Europe/Moscow',
      210: 'Asia/Tehran',
      240: 'Asia/Dubai',
      270: 'Asia/Kabul',
      300: 'Asia/Karachi',
      330: 'Asia/Kolkata',
      345: 'Asia/Kathmandu',
      360: 'Asia/Bishkek',
      390: 'Asia/Yangon',
      420: 'Asia/Bangkok',
      480: 'Asia/Singapore',
      525: 'Australia/Eucla',
      540: 'Asia/Tokyo',
      570: 'Australia/Darwin',
      600: 'Australia/Sydney',
      630: 'Australia/Adelaide',
      660: 'Pacific/Noumea',
      720: 'Pacific/Auckland',
    };

    return tz.getLocation(offsetToLocation[offsetMinutes] ?? 'Etc/UTC');
  }

  _AlarmPayload _parsePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return const _AlarmPayload(task: 'Математика', ringVolume: 0.8);
    }

    final trimmedPayload = payload.trim();
    try {
      final decoded = jsonDecode(trimmedPayload);
      if (decoded is Map<String, dynamic>) {
        final task = (decoded['task'] ?? 'Математика').toString();
        final volume = ((decoded['volume'] as num?)?.toDouble() ?? 80).clamp(
          0,
          100,
        );
        return _AlarmPayload(task: task, ringVolume: volume / 100);
      }
    } catch (_) {
      // Old payload format: plain text task.
    }

    return _AlarmPayload(task: trimmedPayload, ringVolume: 0.8);
  }
}

class _AlarmPayload {
  const _AlarmPayload({required this.task, required this.ringVolume});

  final String task;
  final double ringVolume;
}
