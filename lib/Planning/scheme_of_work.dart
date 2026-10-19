import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchemeStatus {
  static const draft = 'draft';
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';

  static Color colorOf(String s) {
    switch (s) {
      case draft:
        return const Color(0xFFF57C00);
      case pending:
        return const Color(0xFFF9A825);
      case approved:
        return const Color(0xFF2E7D32);
      case rejected:
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }

  static String labelOf(String s) {
    switch (s) {
      case draft:
        return 'Draft';
      case pending:
        return 'Pending';
      case approved:
        return 'Approved';
      case rejected:
        return 'Rejected';
      default:
        return s;
    }
  }
}

class SchemeWeek {
  String id;
  int weekNumber;
  String startDate;
  String endDate;
  String topic;
  String subTopics;
  String objectives;
  int periods;
  String remarks;

  SchemeWeek({
    String? id,
    required this.weekNumber,
    this.startDate = '',
    this.endDate = '',
    this.topic = '',
    this.subTopics = '',
    this.objectives = '',
    this.periods = 0,
    this.remarks = '',
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  bool get isComplete => topic.trim().isNotEmpty && periods > 0;

  Map<String, dynamic> toMap() => {
        'weekNumber': weekNumber,
        'startDate': startDate,
        'endDate': endDate,
        'topic': topic,
        'subTopics': subTopics,
        'objectives': objectives,
        'periods': periods,
        'remarks': remarks,
      };

  factory SchemeWeek.fromMap(Map<String, dynamic> m) => SchemeWeek(
        weekNumber: (m['weekNumber'] ?? 0) as int,
        startDate: m['startDate'] ?? '',
        endDate: m['endDate'] ?? '',
        topic: m['topic'] ?? '',
        subTopics: m['subTopics'] ?? '',
        objectives: m['objectives'] ?? '',
        periods: (m['periods'] ?? 0) as int,
        remarks: m['remarks'] ?? '',
      );
}

class SchemeOfWork {
  String id;
  String schoolId;
  String classId;
  String className;
  String subject;
  String term;
  int year;
  String teacherUid;
  String teacherName;
  String status;
  List<SchemeWeek> weeks;
  String generalRemarks;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? submittedAt;
  String? approvedByName;
  DateTime? approvedAt;
  String? rejectionReason;

  SchemeOfWork({
    this.id = '',
    required this.schoolId,
    required this.classId,
    required this.className,
    required this.subject,
    required this.term,
    required this.year,
    required this.teacherUid,
    required this.teacherName,
    this.status = SchemeStatus.draft,
    List<SchemeWeek>? weeks,
    this.generalRemarks = '',
    this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.approvedByName,
    this.approvedAt,
    this.rejectionReason,
  }) : weeks = weeks ?? [];

  int get totalPeriods => weeks.fold(0, (s, w) => s + w.periods);
  int get totalWeeks => weeks.length;

  Map<String, dynamic> toMap() => {
        'schoolId': schoolId,
        'classId': classId,
        'className': className,
        'subject': subject,
        'term': term,
        'year': year,
        'teacherUid': teacherUid,
        'teacherName': teacherName,
        'status': status,
        'weeks': weeks.map((w) => w.toMap()).toList(),
        'generalRemarks': generalRemarks,
        'submittedAt': submittedAt,
        'approvedByName': approvedByName,
        'approvedAt': approvedAt,
        'rejectionReason': rejectionReason,
      };

  factory SchemeOfWork.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SchemeOfWork(
      id: doc.id,
      schoolId: d['schoolId'] ?? '',
      classId: d['classId'] ?? '',
      className: d['className'] ?? '',
      subject: d['subject'] ?? '',
      term: d['term'] ?? '',
      year: (d['year'] ?? 0) as int,
      teacherUid: d['teacherUid'] ?? '',
      teacherName: d['teacherName'] ?? '',
      status: d['status'] ?? SchemeStatus.draft,
      weeks: (d['weeks'] as List?)
              ?.map((w) => SchemeWeek.fromMap(w as Map<String, dynamic>))
              .toList() ??
          [],
      generalRemarks: d['generalRemarks'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      submittedAt: (d['submittedAt'] as Timestamp?)?.toDate(),
      approvedByName: d['approvedByName'],
      approvedAt: (d['approvedAt'] as Timestamp?)?.toDate(),
      rejectionReason: d['rejectionReason'],
    );
  }
}