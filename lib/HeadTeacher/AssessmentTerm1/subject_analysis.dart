import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectAnalysis extends StatefulWidget {
  final String schoolId;
  final String model; // e.g P4

  const SubjectAnalysis({
    super.key,
    required this.schoolId,
    required this.model,
  });

  @override
  State<SubjectAnalysis> createState() => _SubjectAnalysisScreenState();
}

class _SubjectAnalysisScreenState extends State<SubjectAnalysis> {
  String currentYear = DateTime.now().year.toString();

  bool loading = true;

  // SUBJECT → GRADE → COUNT
  Map<String, Map<String, int>> subjectGradeCounts = {};

  // SUBJECT → TOTAL
  Map<String, int> subjectTotals = {};

  // DIVISION COUNTS (ALL SUBJECTS)
  Map<String, int> divisionCounts = {
    "Division 1": 0,
    "Division 2": 0,
    "Division 3": 0,
    "Division 4": 0,
    "Ungraded": 0,
  };

  @override
  void initState() {
    super.initState();
    loadAnalysis();
  }

  // MARK → GRADE
  String getGrade(double score) {
    if (score >= 80) return "D1";
    if (score >= 75) return "D2";
    if (score >= 70) return "C3";
    if (score >= 65) return "C4";
    if (score >= 60) return "P5";
    if (score >= 55) return "P6";
    return "F9";
  }

  // MARK → AGGREGATE
  int getAggregate(double score) {
    if (score >= 80) return 1;
    if (score >= 75) return 2;
    if (score >= 70) return 3;
    if (score >= 65) return 4;
    if (score >= 60) return 5;
    if (score >= 55) return 6;
    if (score >= 50) return 7;
    if (score >= 45) return 8;
    return 9;
  }

  // AGGREGATE → DIVISION
  String getDivision(int agg) {
    if (agg <= 12) return "Division 1";
    if (agg <= 24) return "Division 2";
    if (agg <= 32) return "Division 3";
    if (agg <= 35) return "Division 4";
    return "Ungraded";
  }

  Future<void> loadAnalysis() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('Years')
        .doc(currentYear)
        .collection(widget.model)
        .get();

    subjectGradeCounts.clear();
    subjectTotals.clear();

    for (var key in divisionCounts.keys) {
      divisionCounts[key] = 0;
    }

    for (var doc in snapshot.docs) {
      final data = doc.data();

      List subjects = data["subjectsScore"] ?? [];

      int totalAgg = 0;

      for (var subject in subjects) {
        String subjectName = subject["subjectName"] ?? "Unknown";

        double score = (subject["scoreBOT"] ?? 0).toDouble();

        String grade = getGrade(score);

        // CREATE SUBJECT
        if (!subjectGradeCounts.containsKey(subjectName)) {
          subjectGradeCounts[subjectName] = {
            "D1": 0,
            "D2": 0,
            "C3": 0,
            "C4": 0,
            "P5": 0,
            "P6": 0,
            "F9": 0,
          };

          subjectTotals[subjectName] = 0;
        }

        // COUNT GRADE
        subjectGradeCounts[subjectName]![grade] =
            subjectGradeCounts[subjectName]![grade]! + 1;

        // COUNT TOTAL
        subjectTotals[subjectName] = subjectTotals[subjectName]! + 1;

        // ADD TO AGGREGATE
        totalAgg += getAggregate(score);
      }

      // DIVISION PER STUDENT
      String division = getDivision(totalAgg);

      divisionCounts[division] = divisionCounts[division]! + 1;
    }

    setState(() {
      loading = false;
    });
  }

  Widget buildRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget buildSubjectCard(String subject, Map<String, int> grades) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics),
                const SizedBox(width: 8),

                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(),

            buildRow("D1", grades["D1"]!),
            buildRow("D2", grades["D2"]!),
            buildRow("C3", grades["C3"]!),
            buildRow("C4", grades["C4"]!),
            buildRow("P5", grades["P5"]!),
            buildRow("P6", grades["P6"]!),
            buildRow("F9", grades["F9"]!),

            const Divider(),

            buildRow("Total", subjectTotals[subject] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget buildDivisionCard() {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.emoji_events),
                SizedBox(width: 8),
                Text(
                  "Division Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const Divider(),

            buildRow("Division 1", divisionCounts["Division 1"]!),
            buildRow("Division 2", divisionCounts["Division 2"]!),
            buildRow("Division 3", divisionCounts["Division 3"]!),
            buildRow("Division 4", divisionCounts["Division 4"]!),
            buildRow("Ungraded", divisionCounts["Ungraded"]!),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subject Analysis")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadAnalysis,
              child: ListView(
                children: [
                  // SUBJECT ANALYSIS
                  ...subjectGradeCounts.entries.map(
                    (entry) => buildSubjectCard(entry.key, entry.value),
                  ),

                  // DIVISION SUMMARY
                  buildDivisionCard(),
                ],
              ),
            ),
    );
  }
}
