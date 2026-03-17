import 'package:banco_mobile/BarCodeScanner/barcode_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyAttendanceChart extends StatefulWidget {
  final String schoolId;
  final String date; // e.g. "2025-11-13"

  const DailyAttendanceChart({
    super.key,
    required this.schoolId,
    required this.date,
  });

  @override
  State<DailyAttendanceChart> createState() => _DailyAttendanceChartState();
}

class _DailyAttendanceChartState extends State<DailyAttendanceChart> {
  late Future<Map<String, int>> _attendanceData;

  // Predefined classes from P1–P7 with initial count 0
  final List<String> allClasses = ['P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7'];

  Future<Map<String, int>> getAttendanceData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('attendance')
        .doc(widget.date)
        .collection('students')
        .get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('attendance')
          .doc(widget.date)
          .set({});
    }

    if (kDebugMode) {
      print('Fetched ${snapshot.docs.length} students for ${widget.date}');
    }

    // Start with all classes set to 0
    Map<String, int> classCounts = {for (var c in allClasses) c: 0};

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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
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
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
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
              builder: (context) =>
                  BarcodeScannerPage(schoolId: widget.schoolId),
            ),
          );
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
