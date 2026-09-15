import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Schedules a once-daily local notification at 8:30 PM (inexact / no alarms).
class ExpenseReminderService {
  ExpenseReminderService._();
  static final instance = ExpenseReminderService._();

  static const notificationId = 830;
  static const channelId = 'daily_expense_reminder';
  static const payloadAdd = '/add';
  static const reminderHour = 20;
  static const reminderMinute = 30;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  void Function(String? payload)? onNotificationTap;

  Future<void> init({void Function(String? payload)? onTap}) async {
    onNotificationTap = onTap;
    if (_initialized) return;

    await _configureLocalTimeZone();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
    );

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              'Daily expense reminder',
              description: 'Reminds you each evening to log spending',
              importance: Importance.high,
            ),
          );
    }

    _initialized = true;
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb) return;
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Keep package default; wall-clock scheduling still uses device local time.
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  /// Enable → permission + schedule. Disable → cancel.
  /// Returns false if the user denied notification permission.
  Future<bool> sync({required bool enabled}) async {
    if (!_initialized) await init();
    if (!enabled) {
      await cancel();
      return true;
    }
    final allowed = await requestPermission();
    if (!allowed) {
      await cancel();
      return false;
    }
    await scheduleDaily();
    return true;
  }

  Future<void> cancel() => _plugin.cancel(id: notificationId);

  Future<void> scheduleDaily() async {
    await cancel();
    final when = _nextInstanceOfReminder();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'Daily expense reminder',
        channelDescription: 'Reminds you each evening to log spending',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      title: 'Log today’s spending',
      body: 'Add any expenses before the day ends.',
      payload: payloadAdd,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<NotificationAppLaunchDetails?> notificationAppLaunchDetails() {
    return _plugin.getNotificationAppLaunchDetails();
  }

  tz.TZDateTime _nextInstanceOfReminder() {
    final now = DateTime.now();
    var next = DateTime(
      now.year,
      now.month,
      now.day,
      reminderHour,
      reminderMinute,
    );
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.local,
      next.millisecondsSinceEpoch,
    );
  }
}
