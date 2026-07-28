import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:banco_mobile/Notifications/fcm_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


Future<void> initNotifications() async {
  tz.initializeTimeZones();

  InitializationSettings initializationSettings;

  if (kIsWeb) {
    /// Web does not support local notifications
    return;
  }

  if (Platform.isWindows) {
    initializationSettings = const InitializationSettings(
      windows: WindowsInitializationSettings(
        appName: 'Banco Mobile',
        appUserModelId: 'com.banco.mobile',
        guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
      ),
    );
  } else {
    initializationSettings = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
  }

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );
}

class LocalNotifications {
  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'daily_channel',
      'Daily Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    final List<ActiveNotification> activeNotifications =
        await flutterLocalNotificationsPlugin.getActiveNotifications();

    for (var notification in activeNotifications) {
      if (kDebugMode) {
        print(
          'Active Notification: '
          'ID=${notification.id}, '
          'Title=${notification.title}, '
          'Body=${notification.body}',
        );
      }
    }

    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: 'School Summary',
      body: 'Today attendance is ready.',
      notificationDetails: details,
      payload: 'daily_notification',
    );
  }
}

class AwesomeNotificationsEngine {
  static Future<void> initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          vibrationPattern: Int64List.fromList([0, 0, 0, 2000]),
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic tests',
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF9D50DD),
        ),
      ],
    );
  }

  static Future<void> showAwesomeNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'Hello Awesome Notifications',
        body: 'This is a test notification',
      ),
    );
  }

  static Future<void> scheduledNotificationAwesome() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'Daily School Summary',
        body: 'Tap to view today’s report',
      ),
      schedule: NotificationCalendar(
        hour: 19,
        minute: 5,
        second: 0,
        repeats: true,
      ),
    );
  }
}

class ZonedNotifications {
  static Future<void> showZonedNotification() async {
    final now = tz.TZDateTime.now(tz.local);

    if (kDebugMode) {
      print('Current time: ${now.toString()}');
    }

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second + 5,
    );

    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'zoned_notifications_channel',
        'Zoned Notifications Channel',
        channelDescription:
            'Notifications scheduled with timezone support',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1,
      title: "Today's Summary",
      body: 'Tap to view today report',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}