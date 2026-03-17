// ignore_for_file: unused_local_variable

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

Future<void> sendNotification({
  required BuildContext context,
  required String title,
  required String body,
  required String token,
}) async {
  try {
    final callable = FirebaseFunctions.instanceFor(
      region: "us-central1",
    ).httpsCallable(
      "sendNotification",
      options: HttpsCallableOptions(
        timeout: Duration(seconds: 30),
      ),
    );

    // final result = await callable.call({
    //   "title": title,
    //   "body": body,
    //   "token": token,
    // });

    // ✅ SUCCESS SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Notification sent successfully"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  } on FirebaseFunctionsException catch (e) {
    // ❌ FUNCTION ERROR SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message ?? "Failed to send notification"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  } catch (e) {
    // ❌ UNKNOWN ERROR SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Something went wrong"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
