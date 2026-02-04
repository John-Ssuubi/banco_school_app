import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addNotification(String uid, String schoolId, String title, String message) async {
  await FirebaseFirestore.instance
      .collection('Schools')
      .doc(schoolId)
      .collection('notifications')
      .add({
        'title': title,
        'message': message,
        'senderId': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'status' : 'pending'
      });
}

Stream<QuerySnapshot> getSchoolNotifications(String schoolId) {
  return FirebaseFirestore.instance
    .collection('schools')
    .doc(schoolId)
    .collection('notifications')
    .orderBy('timestamp', descending: true)
    .snapshots();
}

