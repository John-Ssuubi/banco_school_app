import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void setupForegroundNotifications() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await flutterLocalNotificationsPlugin.show(
        // notification.hashCode,
      title: notification.title,
       body: notification.body,
      notificationDetails:   const NotificationDetails(
          android: AndroidNotificationDetails(
            'attendance_channel', // channel id
            'Attendance Notifications', // channel name
            importance: Importance.max,
            priority: Priority.high,
          ),
        ), id: notification.hashCode,
      );
    }
  });
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // your app icon

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(settings:  initializationSettings);
}
