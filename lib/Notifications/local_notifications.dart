
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future initNotifications() async {
  tz.initializeTimeZones();
  // final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  // tz.setLocalLocation(tz.getLocation(timeZoneName));
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

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

    final List<ActiveNotification> activeNotifications =
        await flutterLocalNotificationsPlugin.getActiveNotifications();
    for (var notification in activeNotifications) {
      if (kDebugMode) {
        print(
        'Active Notification: ID=${notification.id}, Title=${notification.title}, Body=${notification.body}, Payload=${notification.payload}',
      );
      }
    }
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

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
      // 'resource://android:drawable/ic_dialog_info',
  // 'resource://drawable/ic_notification',
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
        hour: 19, // 7 PM
        minute: 5,
        second: 0,
        repeats: true,
      ),
    );
  }
}

// DateTime _scheduleDaily(DateTime time) {
//   final now = DateTime.now();
//   final shceduleDate = DateTime(
//     // tz.local,
//     now.year,
//     now.month,
//     now.day,
//     time.hour,
//     time.minute,
//     time.second,
//   );
//   return shceduleDate.isBefore(now)
//       ? shceduleDate.add(const Duration(days: 1))
//       : shceduleDate;
// }

class ZonedNotifications {
  static Future<void> showZonedNotification() async {
    // const AndroidNotificationDetails androidDetails =
    //     AndroidNotificationDetails(
    //       'daily_channel_zoned',
    //       'Daily Notifications Zoned',
    //       importance: Importance.max,
    //       priority: Priority.high,
    //     );

    // const NotificationDetails details = NotificationDetails(
    //   android: androidDetails,
    // );

    //   await flutterLocalNotificationsPlugin.zonedSchedule(
    //     title: 'scheduled title',
    //     body: 'scheduled body',
    //     scheduledDate: tz.TZDateTime.now(
    //       tz.local,
    //     ).add(const Duration(seconds: 5)),
    //     notificationDetails: const NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'your channel id',
    //         'your channel name',
    //         channelDescription: 'your channel description',
    //       ),
    //     ),
    //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //     id: 0,
    //   );

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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'zoned_notifications_channel',
          'Zoned Notifications Channel',
          channelDescription: 'Notifications scheduled with timezone support',
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: 'Today\'s Summary',
    );
  }
}
