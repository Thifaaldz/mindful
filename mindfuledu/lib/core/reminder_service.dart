import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService._();

  static const int _dailyReminderId = 1107;
  static const int _activityReminderBase = 200000;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: ios,
        macOS: ios,
      ),
    );
  }

  static Future<void> requestPermission() async {
    if (kIsWeb) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await _notifications
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> scheduleDaily(TimeOfDay time) async {
    await requestPermission();
    await cancelDaily();

    await _notifications.zonedSchedule(
      id: _dailyReminderId,
      title: 'Waktunya jeda mindful',
      body: 'Luangkan 5-10 menit untuk latihan hari ini.',
      scheduledDate: _nextInstance(time),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'mindfulness_daily_reminder',
          'Pengingat latihan',
          channelDescription: 'Pengingat harian untuk latihan mindfulness',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDaily() {
    return _notifications.cancel(id: _dailyReminderId);
  }

  static Future<void> scheduleActivityReminders({
    required int activityId,
    required String title,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    await requestPermission();
    await cancelActivity(activityId);

    final now = DateTime.now();
    final checkInAt = startAt.subtract(const Duration(minutes: 10));
    if (checkInAt.isAfter(now)) {
      await _notifications.zonedSchedule(
        id: _activityNotificationId(activityId, 0),
        title: 'Kegiatan akan dimulai',
        body: '$title segera dimulai. Yuk check-in.',
        scheduledDate: tz.TZDateTime.from(checkInAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'activity_checkin_reminder',
            'Pengingat check-in',
            channelDescription: 'Pengingat check-in sebelum aktivitas',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    if (endAt.isAfter(now)) {
      await _notifications.zonedSchedule(
        id: _activityNotificationId(activityId, 1),
        title: 'Waktunya check-out',
        body: 'Catat kondisi setelah $title agar ledger lengkap.',
        scheduledDate: tz.TZDateTime.from(endAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'activity_checkout_reminder',
            'Pengingat check-out',
            channelDescription: 'Pengingat check-out setelah aktivitas',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelActivity(int activityId) async {
    await _notifications.cancel(id: _activityNotificationId(activityId, 0));
    await _notifications.cancel(id: _activityNotificationId(activityId, 1));
  }

  static tz.TZDateTime _nextInstance(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static int _activityNotificationId(int activityId, int offset) {
    return _activityReminderBase + (activityId % 100000) * 2 + offset;
  }
}
