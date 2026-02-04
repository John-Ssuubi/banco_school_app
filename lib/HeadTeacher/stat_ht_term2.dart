// ignore_for_file: avoid_print, deprecated_member_use

import 'package:banco_mobile/Charts/stat_model.dart';
import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/HeadTeacher/StatTerm1/build_bot_view.dart';
import 'package:banco_mobile/division_cal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatHtTermII extends StatefulWidget {
  final String model;
  final String schoolId;
  const StatHtTermII({super.key, required this.model, required this.schoolId});

  @override
  State<StatHtTermII> createState() => _StatHtTermIIState();
}

class _StatHtTermIIState extends State<StatHtTermII> {
  String? selectedSubject;
  List<String> subjects = [];
  bool isLoadingSubjects = true; // New state for subject loading
  int currentIndex = 0;
  // -----------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _extractSubjects();
  }

  // ------------------------- Subject Extraction -------------------------
  void _extractSubjects() async {
    // Set loading state
    setState(() {
      isLoadingSubjects = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection(widget.model)
          .limit(1) // Only need one document to get the subject list
          .get();

      if (snapshot.docs.isNotEmpty) {
        final firstDoc = snapshot.docs.first;
        final student = StudentModelP4.fromJson(firstDoc.data());

        // Update state with extracted subjects and set the first one as selected
        setState(() {
          subjects = student.subjectsScoreTerm2
              .map((subject) => subject.subjectName)
              .toList();

          if (subjects.isNotEmpty) {
            selectedSubject = subjects[0];
          }
        });
      }
    } catch (e) {
      // Log or handle the error gracefully
      print('Error loading subjects: $e');
    } finally {
      // End loading state
      setState(() {
        isLoadingSubjects = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'BOT'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'MID'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'END'),
        ],
      ),
    );
  }

  Widget _getSelectedView() {
    if (currentIndex == 0) return _buildBOTView();
    if (currentIndex == 1) return _buildMIDView();
    return _buildENDView();
  }

  Widget _buildBOTView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Subject Dropdown moved outside the StreamBuilder for faster interaction

          // StreamBuilder for chart data
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Schools')
                .doc(widget.schoolId)
                .collection(widget.model)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              // Data processing logic
              final students = snapshot.data!.docs
                  .map((doc) => StudentModelP4.fromJson(doc.data()))
                  .toList();

              // Grade Distribution Data Calculation
              final List<GradeData> chartData = _calculateGradeDistribution(
                students,
              );

              // Subject Ranking Data Calculation
              final List<Map<String, dynamic>> rankingsub =
                  getSubjectRankingBOTTerm2(students, selectedSubject ?? '');

              return Column(
                children: [
                  if (isLoadingSubjects)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                    )
                  else if (subjects.isNotEmpty)
                    _buildSubjectDropdown(),

                  // const SizedBox(height: 32),

                  // Subject Ranking Chart Card
                  if (selectedSubject != null)
                    _buildChartCard(
                      title: 'BOT Rankings - $selectedSubject',
                      chart: _buildSubjectRankingChart(rankingsub),
                    ),
                  // Grade Distribution Chart Card
                  _buildChartCard(
                    title: 'Overall BOT Grade Distribution',
                    chart: _buildGradeDistributionChart(chartData),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMIDView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Subject Dropdown moved outside the StreamBuilder for faster interaction

          // StreamBuilder for chart data
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Schools')
                .doc(widget.schoolId)
                .collection(widget.model)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              // Data processing logic
              final students = snapshot.data!.docs
                  .map((doc) => StudentModelP4.fromJson(doc.data()))
                  .toList();

              // Grade Distribution Data Calculation
              final List<GradeData> chartData = _calculateGradeDistributionMID(
                students,
              );

              // Subject Ranking Data Calculation
              final List<Map<String, dynamic>> rankingsub =
                  getSubjectRankingMIDTerm2(students, selectedSubject ?? '');

              return Column(
                children: [
                  if (isLoadingSubjects)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                    )
                  else if (subjects.isNotEmpty)
                    _buildSubjectDropdown(),

                  // const SizedBox(height: 32),

                  // Subject Ranking Chart Card
                  if (selectedSubject != null)
                    _buildChartCard(
                      title: 'MID Rankings - $selectedSubject',
                      chart: _buildSubjectRankingChartMID(rankingsub),
                    ),
                  // Grade Distribution Chart Card
                  _buildChartCard(
                    title: 'Overall MID Grade Distribution',
                    chart: _buildGradeDistributionChart(chartData),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildENDView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Subject Dropdown moved outside the StreamBuilder for faster interaction

          // StreamBuilder for chart data
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Schools')
                .doc(widget.schoolId)
                .collection(widget.model)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              // Data processing logic
              final students = snapshot.data!.docs
                  .map((doc) => StudentModelP4.fromJson(doc.data()))
                  .toList();

              // Grade Distribution Data Calculation
              final List<GradeData> chartData = _calculateGradeDistributionEND(
                students,
              );

              // Subject Ranking Data Calculation
              final List<Map<String, dynamic>> rankingsub =
                  getSubjectRankingENDTerm2(students, selectedSubject ?? '');

              return Column(
                children: [
                  if (isLoadingSubjects)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                    )
                  else if (subjects.isNotEmpty)
                    _buildSubjectDropdown(),

                  // const SizedBox(height: 32),

                  // Subject Ranking Chart Card
                  if (selectedSubject != null)
                    _buildChartCard(
                      title: 'BOT Rankings - $selectedSubject',
                      chart: _buildSubjectRankingChartEND(rankingsub),
                    ),
                  // Grade Distribution Chart Card
                  _buildChartCard(
                    title: 'Overall BOT Grade Distribution',
                    chart: _buildGradeDistributionChart(chartData),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 12),
            Text(
              'Loading student data...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          '🚨 Error loading data: $error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'No Student Found',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      elevation: 6, // Increased elevation for a floating effect
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            const Divider(color: Colors.grey, height: 1),
            SizedBox(
              height: 300, // Fixed height for charts
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSubject,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          onChanged: (value) {
            setState(() {
              selectedSubject = value;
            });
          },
          items: subjects
              .map(
                (subject) =>
                    DropdownMenuItem(value: subject, child: Text(subject)),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildGradeDistributionChart(List<GradeData> chartData) {
    return SfCartesianChart(
      // title: ChartTitle(text: 'BOT Grade Distribution'), // Title moved to the Card
      plotAreaBorderWidth: 0, // Remove chart border
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'Number of Students',
          textStyle: const TextStyle(color: Colors.indigo),
        ),
        interval: 1,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        tooltipPosition: TooltipPosition.pointer,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries<GradeData, String>>[
        ColumnSeries<GradeData, String>(
          dataSource: chartData,
          xValueMapper: (GradeData data, _) => data.grade,
          yValueMapper: (GradeData data, _) => data.count,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // Gradient fill for a modern look
          gradient: LinearGradient(
            colors: [Colors.indigo.shade400, Colors.indigo.shade700],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(4), // Rounded corners for bars
        ),
      ],
    );
  }

  Widget _buildSubjectRankingChart(List<Map<String, dynamic>> rankingsub) {
    return SfCartesianChart(
      // title: ChartTitle(text: 'BOT Rankings - $selectedSubject'), // Title moved to the Card
      plotAreaBorderWidth: 0, // Remove chart border
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: 'Students (Ranked)',
          textStyle: const TextStyle(color: Colors.indigo),
        ),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelRotation: -45, // Rotate labels to fit student names
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'BOT Score',
          textStyle: const TextStyle(color: Colors.indigo),
        ),
        minimum: 0,
        maximum: 100, // Keep 100 as max score for standard view
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries<Map<String, dynamic>, String>>[
        // Use BarSeries (horizontal bars) for potentially long student names
        BarSeries<Map<String, dynamic>, String>(
          dataSource: rankingsub,
          xValueMapper: (data, _) => data['studentName'],
          yValueMapper: (data, _) => data['botScore'],
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          color: Colors.teal.shade500, // Different color for distinction
          // You could use a point color mapper for top/bottom students
        ),
      ],
    );
  }

  Widget _buildSubjectRankingChartMID(List<Map<String, dynamic>> rankingsub) {
    return SfCartesianChart(
      // title: ChartTitle(text: 'BOT Rankings - $selectedSubject'), // Title moved to the Card
      plotAreaBorderWidth: 0, // Remove chart border
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: 'Students (Ranked)',
          textStyle: const TextStyle(color: Colors.indigo),
        ),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelRotation: -45, // Rotate labels to fit student names
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'MID Score',
          textStyle: const TextStyle(color: Colors.indigo),
        ),
        minimum: 0,
        maximum: 100, // Keep 100 as max score for standard view
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries<Map<String, dynamic>, String>>[
        // Use BarSeries (horizontal bars) for potentially long student names
        BarSeries<Map<String, dynamic>, String>(
          dataSource: rankingsub,
          xValueMapper: (data, _) => data['studentName'],
          yValueMapper: (data, _) => data['mtScore'],
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          color: Colors.teal.shade500, // Different color for distinction
          // You could use a point color mapper for top/bottom students
        ),
      ],
    );
  }

  Widget _buildSubjectRankingChartEND(List<Map<String, dynamic>> rankingsub) {
    return SfCartesianChart(
      // title: ChartTitle(text: 'BOT Rankings - $selectedSubject'), // Title moved to the Card
      plotAreaBorderWidth: 0, // Remove chart border
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: 'Students (Ranked)',
          textStyle: const TextStyle(color: Colors.indigo),
        ),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelRotation: -45, // Rotate labels to fit student names
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'END Score',
          textStyle: const TextStyle(color: Colors.indigo),
        ),
        minimum: 0,
        maximum: 100, // Keep 100 as max score for standard view
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        textStyle: const TextStyle(color: Colors.white),
      ),
      series: <CartesianSeries<Map<String, dynamic>, String>>[
        // Use BarSeries (horizontal bars) for potentially long student names
        BarSeries<Map<String, dynamic>, String>(
          dataSource: rankingsub,
          xValueMapper: (data, _) => data['studentName'],
          yValueMapper: (data, _) => data['endScore'],
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          color: Colors.teal.shade500, // Different color for distinction
          // You could use a point color mapper for top/bottom students
        ),
      ],
    );
  }

  List<GradeData> _calculateGradeDistribution(List<StudentModelP4> students) {
    Map<String, int> gradeCount = {
      'D1': 0,
      'D2': 0,
      'C3': 0,
      'C4': 0,
      'C5': 0,
      'C6': 0,
      'P7': 0,
      'P8': 0,
      'F9': 0,
      'X': 0,
    };

    for (var student in students) {
      if (student.subjectsScoreTerm2.isEmpty) continue;

      // 1. Calculate AVERAGE BOT score of the student
      double total = 0;
      int count = 0;

      for (var subject in student.subjectsScoreTerm2) {
        if (subject.scoreBOT != -1) {
          total += subject.scoreBOT.toDouble();
          count++;
        }
      }

      double average = count == 0 ? -1 : total / count;

      // 2. Grade the average
      String division = divCalBOT(average);

      gradeCount[division] = (gradeCount[division] ?? 0) + 1;
    }

    // Convert map → chart list
    final List<GradeData> chartData = gradeCount.entries
        .map((e) => GradeData(e.key, e.value))
        .toList();

    return chartData.where((data) => data.count > 0).toList();
  }

  List<GradeData> _calculateGradeDistributionMID(
    List<StudentModelP4> students,
  ) {
    Map<String, int> gradeCount = {
      'D1': 0,
      'D2': 0,
      'C3': 0,
      'C4': 0,
      'C5': 0,
      'C6': 0,
      'P7': 0,
      'P8': 0,
      'F9': 0,
      'X': 0,
    };

    for (var student in students) {
      if (student.subjectsScoreTerm2.isEmpty) continue;

      // 1. Calculate AVERAGE BOT score of the student
      double total = 0;
      int count = 0;

      for (var subject in student.subjectsScoreTerm2) {
        if (subject.scoreMT != -1) {
          total += subject.scoreMT.toDouble();
          count++;
        }
      }

      double average = count == 0 ? -1 : total / count;

      // 2. Grade the average
      String division = divCalMid(average);

      gradeCount[division] = (gradeCount[division] ?? 0) + 1;
    }

    

    // Convert map to list of GradeData objects
    final List<GradeData> chartData = gradeCount.entries
        .map((e) => GradeData(e.key, e.value))
        .toList();

    // Optional: Filter out grades with zero count if you want a cleaner look
    return chartData.where((data) => data.count > 0).toList();
  }

  List<GradeData> _calculateGradeDistributionEND(
    List<StudentModelP4> students,
  ) {
    Map<String, int> gradeCount = {
      'D1': 0,
      'D2': 0,
      'C3': 0,
      'C4': 0,
      'C5': 0,
      'C6': 0,
      'P7': 0,
      'P8': 0,
      'F9': 0,
      'X': 0,
    };

    for (var student in students) {
      if (student.subjectsScoreTerm2.isEmpty) continue;

      // 1. Calculate AVERAGE BOT score of the student
      double total = 0;
      int count = 0;

      for (var subject in student.subjectsScoreTerm2) {
        if (subject.scoreEOT != -1) {
          total += subject.scoreEOT.toDouble();
          count++;
        }
      }

      double average = count == 0 ? -1 : total / count;

      // 2. Grade the average
      String division = divCalBOT(average);

      gradeCount[division] = (gradeCount[division] ?? 0) + 1;
    }

    // Convert map to list of GradeData objects
    final List<GradeData> chartData = gradeCount.entries
        .map((e) => GradeData(e.key, e.value))
        .toList();

    // Optional: Filter out grades with zero count if you want a cleaner look
    return chartData.where((data) => data.count > 0).toList();
  }
}
