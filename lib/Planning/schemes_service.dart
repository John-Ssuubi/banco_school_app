import 'package:banco_mobile/Planning/scheme_of_work.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchemesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String schoolId) =>
      _db.collection('Schools').doc(schoolId).collection('SchemesOfWork');

  // ─── Stream list (scoped to class) ───────────────────────
  Stream<List<SchemeOfWork>> streamSchemes({
    required String schoolId,
    required String classId,
    String? term,
    int? year,
    String? status,
  }) {
    Query<Map<String, dynamic>> q =
        _col(schoolId).where('classId', isEqualTo: classId);

    if (term != null && term.isNotEmpty) {
      q = q.where('term', isEqualTo: term);
    }
    if (year != null) {
      q = q.where('year', isEqualTo: year);
    }
    if (status != null && status.isNotEmpty) {
      q = q.where('status', isEqualTo: status);
    }

    return q.orderBy('updatedAt', descending: true).snapshots().map(
          (s) => s.docs.map((d) => SchemeOfWork.fromFirestore(d)).toList(),
        );
  }

  // ─── Create ───────────────────────────────────────────────
  Future<String> create(SchemeOfWork s) async {
    final ref = _col(s.schoolId).doc();
    await ref.set({
      ...s.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // ─── Update (drafts only) ─────────────────────────────────
  Future<void> update(SchemeOfWork s) async {
    await _col(s.schoolId).doc(s.id).update({
      ...s.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Submit for approval ──────────────────────────────────
  Future<void> submit(String schoolId, String schemeId) async {
    await _col(schoolId).doc(schemeId).update({
      'status': SchemeStatus.pending,
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Approve ──────────────────────────────────────────────
  Future<void> approve(
      String schoolId, String schemeId, String approverName) async {
    await _col(schoolId).doc(schemeId).update({
      'status': SchemeStatus.approved,
      'approvedByName': approverName,
      'approvedAt': FieldValue.serverTimestamp(),
      'rejectionReason': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Reject ───────────────────────────────────────────────
  Future<void> reject(
      String schoolId, String schemeId, String reason) async {
    await _col(schoolId).doc(schemeId).update({
      'status': SchemeStatus.rejected,
      'rejectionReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Delete ───────────────────────────────────────────────
  Future<void> delete(String schoolId, String schemeId) async {
    await _col(schoolId).doc(schemeId).delete();
  }
}