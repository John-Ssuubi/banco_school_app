// ignore_for_file: avoid_print, deprecated_member_use, unused_import

import 'package:banco_mobile/Charts/stat_model.dart';
import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/division_cal.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatHtTermI extends StatefulWidget {
  final String model;
  final String schoolId;

  const StatHtTermI({
    super.key,
    required this.model,
    required this.schoolId,
  });

  @override
  State<StatHtTermI> createState() => _StatHtTermIState();
}

class _StatHtTermIState extends State<StatHtTermI> {

 

  int d1Start = 0, d1End = 0;
  int d2Start = 0, d2End = 0;
  int c3Start = 0, c3End = 0;
  int c4Start = 0, c4End = 0;
  int c5Start = 0, c5End = 0;
  int c6Start = 0, c6End = 0;
  int p7Start = 0, p7End = 0;
  int p8Start = 0, p8End = 0;
  int f9Start = 0, f9End = 0;

  bool gradingLoaded = false;

  

  Future<void> _loadGrading() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;

      d1Start = data['D1Start'];
      d1End   = data['D1End'];

      d2Start = data['D2Start'];
      d2End   = data['D2End'];

      c3Start = data['c3Start'];
      c3End   = data['c3End'];

      c4Start = data['c4Start'];
      c4End   = data['c4End'];

      c5Start = data['c5Start'];
      c5End   = data['c5End'];

      c6Start = data['c6Start'];
      c6End   = data['c6End'];

      p7Start = data['p7Start'];
      p7End   = data['p7End'];

      p8Start = data['p8Start'];
      p8End   = data['p8End'];

      f9Start = data['f9Start'];
      f9End   = data['f9End'];

      setState(() {
        gradingLoaded = true;
      });
    } catch (e) {
      print("Error loading grading: $e");
    }
  }



  String? selectedSubject;
  List<String> subjects = [];
  bool isLoadingSubjects = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGrading();      
    _extractSubjects();
  }



  void _extractSubjects() async {
    setState(() => isLoadingSubjects = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(DateTime.now().year.toString())
          .collection(widget.model)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final student =
            StudentModelP4.fromJson(snapshot.docs.first.data());

        setState(() {
          subjects = student.subjectsScore
              .map((e) => e.subjectName)
              .toList();

          if (subjects.isNotEmpty) {
            selectedSubject = subjects.first;
          }
        });
      }
    } catch (e) {
      print("Error loading subjects: $e");
    }

    setState(() => isLoadingSubjects = false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() => currentIndex = value);
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

    if (!gradingLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (currentIndex == 0) return _buildBOTView();
    if (currentIndex == 1) return _buildMIDView();
    return _buildENDView();
  }



  Widget _buildBOTView() {
    return _buildView(
      scoreSelector: (s) => s.scoreBOT.toDouble(),
      gradeCalculator: (avg) => divCalBOT(
        avg,
        d1Start, d2Start, c3Start, c4Start,
        c5Start, c6Start, p7Start, p8Start,
        f9Start, f9End,
      ),
      title: "BOT",
    );
  }

  Widget _buildMIDView() {
    return _buildView(
      scoreSelector: (s) => s.scoreMT.toDouble(),
      gradeCalculator: (avg) => divCalMid(
        avg,
        d1Start, d2Start, c3Start, c4Start,
        c5Start, c6Start, p7Start, p8Start,
        f9Start, f9End,
      ),
      title: "MID",
    );
  }

  Widget _buildENDView() {
    return _buildView(
      scoreSelector: (s) => s.scoreEOT.toDouble(),
      gradeCalculator: (avg) => divEND(
        avg,
        d1Start, d2Start, c3Start, c4Start,
        c5Start, c6Start, p7Start, p8Start,
        f9Start, f9End,
      ),
      title: "END",
    );
  }



  Widget _buildView({
    required double Function(dynamic subject) scoreSelector,
    required String Function(double avg) gradeCalculator,
    required String title,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(DateTime.now().year.toString())
          .collection(widget.model)
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No students found"));
        }

        final students = snapshot.data!.docs
            .map((doc) => StudentModelP4.fromJson(doc.data()))
            .toList();

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
          if (student.subjectsScore.isEmpty) continue;

          double total = 0;
          int count = 0;

          for (var subject in student.subjectsScore) {
            double score = scoreSelector(subject);
            if (score != -1) {
              total += score;
              count++;
            }
          }

          double avg = count == 0 ? -1 : total / count;

          String grade = gradeCalculator(avg);

          gradeCount[grade] = (gradeCount[grade] ?? 0) + 1;
        }

        final chartData = gradeCount.entries
            .where((e) => e.value > 0)
            .map((e) => GradeData(e.key, e.value))
            .toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(interval: 1),
            series: <CartesianSeries>[
              ColumnSeries<GradeData, String>(
                dataSource: chartData,
                xValueMapper: (data, _) => data.grade,
                yValueMapper: (data, _) => data.count,
                dataLabelSettings:
                    const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        );
      },
    );
  }
}
