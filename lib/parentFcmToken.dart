// ignore_for_file: unused_element, empty_catches, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

String? _fcmToken;
bool _isSaving = false;

Future<void> setupFcm() async {

  try {

    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permissionnnnnnnnnnnnnnn');
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        _fcmToken = token;
        await _saveParentFcmToken(token,  user.email ?? '');
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _saveParentFcmToken(newToken, user.email ?? '');
      });
    } else {
    }
  } catch (e) {
  }
}

/// Save the token in parent record and link to children
Future<void> _saveParentFcmToken(String token, String parentEmail) async {
  _isSaving = true;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }

  final parentRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);

  // Save the token in parent record

  // Get the parent's linked children
  final parentDoc = await parentRef.get();
  final parentData = parentDoc.data();
  if (parentData == null) return;

  // Verify parent role
  if (parentData['role'] != 'parent') {
    return;
  } else {
  await parentRef.set({'fcmToken': token, "email": parentEmail,}, SetOptions(merge: true));

  final linkedChildren = parentData['linkedChildren'] as List<dynamic>?;

  if (linkedChildren == null || linkedChildren.isEmpty) {
    return;
  }

  // Loop through each linked child and update their record
  for (var child in linkedChildren) {
    final schoolId = child['schoolId'];
    final idNin = child['idNin'];

    // Loop through all student class collections
    final classCollections = [
      'studentModelP1',
      'studentModelP2',
      'studentModelP3',
      'studentModelP4',
      'studentModelP5',
      'studentModelP6',
      'studentModelP7',
    ];
 
    for (final collection in classCollections) {
      final query = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection(collection)
          .where('idNin', isEqualTo: idNin)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'parentFcmToken': token,
          'nextofKinidEmail': parentEmail,
        });
        break; // stop searching once found
      }
    }
  }

  _isSaving = false;
}}
