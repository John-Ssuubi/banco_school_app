import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendPushNotification(String token, String studentName) async {
  const serverKey = 'YOUR_FIREBASE_SERVER_KEY'; // From Firebase console > Project settings > Cloud Messaging

  final data = {
    'notification': {
      'title': 'Attendance Update',
      'body': '$studentName has been marked present today.',
    },
    'priority': 'high',
    'to': token,
  };

  final response = await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode(data),
  );

  if (kDebugMode) {
    print("Push response: ${response.body}");
  }
}
