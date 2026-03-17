// ignore_for_file: unused_element, empty_catches, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

String? _fcmToken;
bool _isSaving = false;


Future<void> setupFcmForm(
  String parentName,
  String parentSecondName,
  String parentPhone,
) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus !=
        AuthorizationStatus.authorized) {
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    _fcmToken = token;

    await _saveParentFcmToken(
      token,
      user.email ?? '',
      parentName,
      parentSecondName,
      parentPhone,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _saveParentFcmToken(
        newToken,
        user.email ?? '',
        parentName,
        parentSecondName,
        parentPhone,
      );
    });
  } catch (e) {
    if (kDebugMode) {
      print("FCM setup error: $e");
    }
  }
}


Future<void> setupFcm() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus !=
        AuthorizationStatus.authorized) {
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    _fcmToken = token;

    await _saveParentFcmTokenAuth(token, user.email ?? '');

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _saveParentFcmTokenAuth(newToken, user.email ?? '');
    });
  } catch (e) {
    if (kDebugMode) {
      print("FCM auth setup error: $e");
    }
  }
}


Future<void> _saveParentFcmToken(
  String token,
  String parentEmail,
  String parentName,
  String parentSecondName,
  String parentPhone,
) async {
  if (_isSaving) return;

  _isSaving = true;

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final parentRef =
        FirebaseFirestore.instance.collection('Users').doc(user.uid);

    final parentDoc = await parentRef.get();
    final parentData = parentDoc.data();

    if (parentData == null) return;

    if (parentData['role'] != 'parent') return;

    /* ---------- Save token on parent ---------- */

    await parentRef.set({
      'fcmToken': token,
      'email': parentEmail,
    }, SetOptions(merge: true));

    final linkedChildren =
        parentData['linkedChildren'] as List<dynamic>?;

    if (linkedChildren == null || linkedChildren.isEmpty) return;

    /* ---------- Loop selected children ---------- */

    for (final child in linkedChildren) {
      final schoolId = child['schoolId'];
      final studentId = child['studentId']; // IMPORTANT FIX

      if (schoolId == null || studentId == null) continue;

      /* ---------- Save in linkedParents ---------- */

      final schoolParentRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('linkedParents')
          .doc(user.uid);

      await schoolParentRef.set({
        'role': 'parent',
        'firstName': parentName,
        'secondName': parentSecondName,
        'phone': parentPhone,
        'fcmToken': token,
        'approved': false,
        'createdAt': FieldValue.serverTimestamp(),
        'email': parentEmail,
        'parentUid': user.uid,
      }, SetOptions(merge: true));

      /* ---------- Update correct student ---------- */

      await _updateStudentToken(
        schoolId,
        studentId,
        token,
        parentEmail,
        user.uid,
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print("Save FCM error: $e");
    }
  } finally {
    _isSaving = false;
  }
}


Future<void> _saveParentFcmTokenAuth(
  String token,
  String parentEmail,
) async {
  if (_isSaving) return;

  _isSaving = true;

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final parentRef =
        FirebaseFirestore.instance.collection('Users').doc(user.uid);

    final parentDoc = await parentRef.get();
    final parentData = parentDoc.data();

    if (parentData == null) return;

    if (parentData['role'] != 'parent') return;

    await parentRef.set({
      'fcmToken': token,
      'email': parentEmail,
    }, SetOptions(merge: true));

    final linkedChildren =
        parentData['linkedChildren'] as List<dynamic>?;

    if (linkedChildren == null || linkedChildren.isEmpty) return;

    for (final child in linkedChildren) {
      final schoolId = child['schoolId'];
      final studentId = child['studentId'];

      if (schoolId == null || studentId == null) continue;

      await _updateStudentToken(
        schoolId,
        studentId,
        token,
        parentEmail,
        user.uid,
      );
    }
  } catch (e) {
    if (kDebugMode) {
      print("Auth FCM save error: $e");
    }
  } finally {
    _isSaving = false;
  }
}


Future<void> _updateStudentToken(
  String schoolId,
  String studentId,
  String token,
  String parentEmail,
  String parentUid,
) async {
  final firestore = FirebaseFirestore.instance;

  final classCollections = [
    'studentModelP1',
    'studentModelP2',
    'studentModelP3',
    'studentModelP4',
    'studentModelP5',
    'studentModelP6',
    'studentModelP7',
  ];

  final year = DateTime.now().year.toString();

  for (final collection in classCollections) {
    final ref = firestore
        .collection('Schools')
        .doc(schoolId)
        .collection('Years')
        .doc(year)
        .collection(collection)
        .doc(studentId);

    final snap = await ref.get();

    if (snap.exists) {
      await ref.update({
        'parentFcmToken': token,
        'nextofKinidEmail': parentEmail,
        'parentUid': parentUid,
      });

      if (kDebugMode) {
        print("Updated student: $studentId");
      }

      break;
    }
  }
}
