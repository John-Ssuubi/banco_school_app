import 'package:banco_mobile/biometric/app_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference _school() =>
      _db.collection('Schools').doc(AppConfig.instance.schoolId);

  Future<String?> identifyUserType(String userId) async {
    final school = _school();
    final staff = await school.collection('LinkedStaff').doc(userId).get();
    if (staff.exists) return 'staff';

    final student = await school.collection('studentIndex').doc(userId).get();
    if (student.exists) return 'student';

    return null;
  }

  Future<Map<String, dynamic>?> getStaff(String userId) async {
    final snap = await _school().collection('LinkedStaff').doc(userId).get();
    if (!snap.exists) return null;
    final d = snap.data()!;
    return {
      'name': '${d['firstName'] ?? ''} ${d['secondName'] ?? ''}'.trim(),
      'role': d['role'] ?? 'staff',
      'phone': d['phone'] ?? '',
      'email': d['email'] ?? '',
    };
  }

  Future<Map<String, dynamic>?> getStudent(
      String userId, String scanDate) async {
    final year = DateTime.parse(scanDate).year;
    final school = _school();

    final idx = await school.collection('studentIndex').doc(userId).get();
    if (!idx.exists) return null;
    final idxData = idx.data()!;
    final classCollection = idxData['classCollection'] as String?;
    final studentDocId    = idxData['studentDocId'] as String?;
    if (classCollection == null || studentDocId == null) return null;

    final s = await school
        .collection('Years')
        .doc('$year')
        .collection(classCollection)
        .doc(studentDocId)
        .get();
    if (!s.exists) return null;
    final d = s.data()!;
    return {
      'name': d['studentName'] ?? 'Unknown',
      'class_collection': classCollection,
      'class_in': d['classIn'] ?? '',
    };
  }

  /// Idempotent write: uses deterministic doc IDs `${userId}_${scanDate}`.
  /// If a doc already exists, we skip the write (mirrors your Python
  /// "already present" check but enforced by Firestore itself).
  Future<String?> saveStaff(
      String userId, String scanDate, String scanTime) async {
    final staff = await getStaff(userId);
    if (staff == null) return 'staff not found';

    final ref = _school()
        .collection('attendance').doc(scanDate)
        .collection('staff').doc('${userId}_$scanDate');

    final existing = await ref.get();
    if (existing.exists) return 'already present';

    await ref.set({
      'staffName': staff['name'],
      'staffId': userId,
      'role': staff['role'],
      'phone': staff['phone'],
      'email': staff['email'],
      'timeIn': FieldValue.serverTimestamp(),
      'scanTime': scanTime,
      'status': 'present',
      'schoolFrom': AppConfig.instance.schoolId,
    }, SetOptions(merge: true));
    return null; // null = success
  }

  Future<String?> saveStudent(
      String userId, String scanDate, String scanTime) async {
    final s = await getStudent(userId, scanDate);
    if (s == null) return 'student not found';

    final ref = _school()
        .collection('attendance').doc(scanDate)
        .collection('students').doc('${userId}_$scanDate');

    final existing = await ref.get();
    if (existing.exists) return 'already present';

    await ref.set({
      'studentName': s['name'],
      'idNin': userId,
      'classCollection': s['class_collection'],
      'classIn': s['class_in'],
      'timeIn': FieldValue.serverTimestamp(),
      'scanTime': scanTime,
      'status': 'present',
      'schoolFrom': AppConfig.instance.schoolId,
    }, SetOptions(merge: true));
    return null;
  }
}