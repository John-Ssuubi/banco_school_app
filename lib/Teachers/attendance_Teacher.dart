// ignore_for_file: file_names

import 'package:banco_mobile/BarCodeScanner/barcode_scanner.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceTeacher extends StatefulWidget {
  final String schoolId;
  final String date; // e.g. "2025-11-13"

  const AttendanceTeacher({
    super.key,
    required this.schoolId,
    required this.date,
  });

  @override
  State<AttendanceTeacher> createState() => _AttendanceTeacherState();
}

class _AttendanceTeacherState extends State<AttendanceTeacher> {
  late Future<Map<String, int>> _attendanceData;

  // Predefined classes from P1–P7 with initial count 0

  //  Future<void> _handleScannedId(String scannedId) async {
  //   // if (_isProcessing) return;
  //   // setState(() => _isProcessing = true);

  //   try {
  //     final cleanId = scannedId.trim().replaceAll('\n', '');

  //     if (kDebugMode) {
  //       print(widget.schoolId);
  //     }

  //     final schoolRef = FirebaseFirestore.instance
  //         .collection('Schools')
  //         .doc(widget.schoolId);

  //     /// 1️⃣ FAST LOOKUP (studentIndex)
  //     final indexSnap = await schoolRef
  //         .collection('studentIndex')
  //         .doc(cleanId)
  //         .get();

  //     if (!indexSnap.exists) {
  //       print("No student found for this ID.");
  //       return;
  //     }

  //     final indexData = indexSnap.data()!;
  //     final String classCollection = indexData['classCollection'];
  //     final String studentDocId = indexData['studentDocId'];

  //     if (kDebugMode) {
  //       print('Class Collection: $classCollection, Student Doc ID: $studentDocId');
  //     }

  //     /// 2️⃣ FETCH STUDENT (single read)
  //     final studentSnap = await schoolRef
  //         .collection(classCollection)
  //         .doc(studentDocId)
  //         .get();

  //     if (!studentSnap.exists) {
  //       print("Student record missing.");
  //       return;
  //     }

  //     final data = studentSnap.data()!;
  //     final studentName = data['studentName'] ?? 'Unknown';
  //     final classIn = data['classIn'] ?? '';
  //     final String parentFcmToken = (data['parentFcmToken'] ?? '').toString();
  //     final String parentUid = data['parentUid'] ?? '';

  //     final today = DateTime.now().toIso8601String().split('T').first;

  //     // final notificationRef = schoolRef
  //     //     .collection('notifications')
  //     //     .doc();

  //     // final notificationRef = FirebaseFirestore.instance
  //     //     .collection('Users')
  //     //     .doc(parentUid)
  //     //     .collection('inbox')
  //     //     .doc();

  //     final attendanceRef = schoolRef
  //         .collection('attendance')
  //         .doc(today)
  //         .collection('students')
  //         .doc(cleanId);

  //     /// 3️⃣ IDEMPOTENT ATTENDANCE WRITE (NO READ)
  //     await attendanceRef.set({
  //       'studentName': studentName,
  //       'idNin': cleanId,
  //       'classCollection': classCollection,
  //       'classIn': classIn,
  //       'timeIn': FieldValue.serverTimestamp(),
  //       'status': 'present',
  //       'schoolFrom': widget.schoolId,
  //       'parentFcmToken': parentFcmToken,
  //     }, SetOptions(merge: true));

  //     print("$studentName marked present.");

  //     /// 4️⃣ LOG NOTIFICATION (Cloud Function can listen here)
  //     if (parentUid.isNotEmpty) {
  //       final notificationRef = FirebaseFirestore.instance
  //           .collection('Users')
  //           .doc(parentUid)
  //           .collection('inbox')
  //           .doc();

  //       await notificationRef.set({
  //         'title': 'Attendance',
  //         'body': '$studentName has arrived at school',
  //         'timestamp': FieldValue.serverTimestamp(),
  //         'studentId': cleanId,
  //         'studentName': studentName,
  //         'schoolFrom': widget.schoolId,
  //         'status': 'pending',
  //         'fcmToken': parentFcmToken,
  //         'type': 'Attendance',
  //       });
  //     } else {
  //       debugPrint('⚠️ parentUid missing for student $cleanId');
  //     }

  //     // if (parentFcmToken.isNotEmpty) {
  //     //   sendNotification(
  //     //     context: context,
  //     //     title: 'Attendance',
  //     //     body: '$studentName has arrived at school',
  //     //     token: parentFcmToken,
  //     //   );
  //     // }
  //   } catch (e) {
  //     print("Error: $e");
  //   } finally {
  //     if (mounted) {
  //       // setState(() => _isProcessing = false);
  //     }
  //   }
  // }

  final List<String> allClasses = [
    'P1',
    'P2',
    'P3',
    'P4',
    'P5',
    'P6',
    'P7',
  ];

  Future<Map<String, int>> getAttendanceData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('attendance')
        .doc(widget.date)
        .collection('students')
        .get();

    if (kDebugMode) {
      print('Fetched ${snapshot.docs.length} students for ${widget.date}');
    }

    // Start with all classes set to 0
    Map<String, int> classCounts = {
      for (var c in allClasses) c: 0,
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = (data['status'] ?? '').toString().toLowerCase().trim();
      final classIn = (data['classIn'] ?? '').toString().toUpperCase().trim();

      // Count only present students
      if (status == 'present' && classCounts.containsKey(classIn)) {
        classCounts[classIn] = (classCounts[classIn] ?? 0) + 1;
      }
    }

    if (kDebugMode) {
      print('Class-wise present count: $classCounts');
    }

    return classCounts;
  }

  @override
  void initState() {
    super.initState();
    _attendanceData = getAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Attendance by Class',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: mainColor,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _attendanceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data ?? {};
          final chartData = allClasses
              .map((c) => AttendanceData(c, data[c] ?? 0))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SfCartesianChart(
              title: ChartTitle(
                text: 'Present Students per Class (${widget.date})',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              primaryXAxis: CategoryAxis(
                title: AxisTitle(text: 'Class'),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: 'Number of Present Students'),
                interval: 1,
                minimum: 0,
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<AttendanceData, String>(
                  dataSource: chartData,
                  xValueMapper: (AttendanceData data, _) => data.className,
                  yValueMapper: (AttendanceData data, _) => data.presentCount,
                  name: 'Present Students',
                  color: Colors.indigo,
                  dataLabelSettings:
                      const DataLabelSettings(isVisible: true),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  BarcodeScannerPage(schoolId: widget.schoolId),
                      ),
                    );

                    // _handleScannedId('538105-P4-001429');
                  },
                  child: const Icon(Icons.barcode_reader),
                ),
    );
  }
}

class AttendanceData {
  final String className;
  final int presentCount;

  AttendanceData(this.className, this.presentCount);
}
