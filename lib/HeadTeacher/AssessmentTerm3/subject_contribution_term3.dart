import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectContributionBotTerm3 extends StatefulWidget {
  final String schoolId;
  final String model;

  const SubjectContributionBotTerm3({
    super.key,
    required this.schoolId,
    required this.model,
  });

  @override
  State<SubjectContributionBotTerm3> createState() =>
      SubjectContributionBotTerm3State();
}

class SubjectContributionBotTerm3State
    extends State<SubjectContributionBotTerm3> {
  String currentYear = DateTime.now().year.toString();

  bool loading = true;

  // SUBJECT DATA
  Map<String, Map<String, int>> subjectGradeCounts = {};
  Map<String, int> subjectTotals = {};

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

    for (var doc in snapshot.docs) {
      final data = doc.data();

      List subjects = data["subjectsScoreTerm3"] ?? [];

      for (var subject in subjects) {
        String subjectName =
            subject["subjectName"] ?? "Unknown";

        double score =
            (subject["scoreBOT"] ?? 0).toDouble();

        String grade = getGrade(score);

        // CREATE SUBJECT
        if (!subjectGradeCounts
            .containsKey(subjectName)) {
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
        subjectTotals[subjectName] =
            subjectTotals[subjectName]! + 1;
      }
    }

    setState(() {
      loading = false;
    });
  }

  double calculateFirstGradeContribution(
      Map<String, int> grades,
      int total,
      ) {
    if (total == 0) return 0;

    int firstGrades =
        grades["D1"]! +
            grades["D2"]! +
            grades["C3"]!;

    return (firstGrades / total) * 100;
  }

  double calculateFailureRate(
      Map<String, int> grades,
      int total,
      ) {
    if (total == 0) return 0;

    int failures = grades["F9"]!;

    return (failures / total) * 100;
  }

  Widget buildSubjectCard(
      String subject,
      Map<String, int> grades,
      ) {
    int total = subjectTotals[subject] ?? 0;

    double contribution =
    calculateFirstGradeContribution(
      grades,
      total,
    );

    double failureRate =
    calculateFailureRate(
      grades,
      total,
    );

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Icon(
                  Icons.analytics,
                  size: 26,
                ),
                const SizedBox(width: 8),

                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Students",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  total.toString(),
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding:
              const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green
                    .withValues(alpha: 0.1),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  const Text(
                    "First Grade Contribution",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${contribution.toStringAsFixed(1)} %",
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
              const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red
                    .withValues(alpha: 0.1),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  const Text(
                    "Failure Rate",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${failureRate.toStringAsFixed(1)} %",
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Performance Contribution BOT",
        ),
      ),

      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: loadAnalysis,
        child: ListView(
          children:
          subjectGradeCounts.entries
              .map(
                (entry) =>
                buildSubjectCard(
                  entry.key,
                  entry.value,
                ),
          )
              .toList(),
        ),
      ),
    );
  }
}


class SubjectContributionMidTerm3 extends StatefulWidget {
  final String schoolId;
  final String model;

  const SubjectContributionMidTerm3({
    super.key,
    required this.schoolId,
    required this.model,
  });

  @override
  State<SubjectContributionMidTerm3> createState() =>
      SubjectContributionMidTerm3State();
}

class SubjectContributionMidTerm3State
    extends State<SubjectContributionMidTerm3> {
  String currentYear = DateTime.now().year.toString();

  bool loading = true;

  // SUBJECT DATA
  Map<String, Map<String, int>> subjectGradeCounts = {};
  Map<String, int> subjectTotals = {};

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

    for (var doc in snapshot.docs) {
      final data = doc.data();

      List subjects = data["subjectsScoreTerm3"] ?? [];

      for (var subject in subjects) {
        String subjectName =
            subject["subjectName"] ?? "Unknown";

        double score =
            (subject["scoreMT"] ?? 0).toDouble();

        String grade = getGrade(score);

        // CREATE SUBJECT
        if (!subjectGradeCounts
            .containsKey(subjectName)) {
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
        subjectTotals[subjectName] =
            subjectTotals[subjectName]! + 1;
      }
    }

    setState(() {
      loading = false;
    });
  }

  double calculateFirstGradeContribution(
      Map<String, int> grades,
      int total,
      ) {
    if (total == 0) return 0;

    int firstGrades =
        grades["D1"]! +
            grades["D2"]! +
            grades["C3"]!;

    return (firstGrades / total) * 100;
  }

  double calculateFailureRate(
      Map<String, int> grades,
      int total,
      ) {
    if (total == 0) return 0;

    int failures = grades["F9"]!;

    return (failures / total) * 100;
  }

  Widget buildSubjectCard(
      String subject,
      Map<String, int> grades,
      ) {
    int total = subjectTotals[subject] ?? 0;

    double contribution =
    calculateFirstGradeContribution(
      grades,
      total,
    );

    double failureRate =
    calculateFailureRate(
      grades,
      total,
    );

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Icon(
                  Icons.analytics,
                  size: 26,
                ),
                const SizedBox(width: 8),

                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Students",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  total.toString(),
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding:
              const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green
                    .withValues(alpha: 0.1),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  const Text(
                    "First Grade Contribution",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${contribution.toStringAsFixed(1)} %",
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
              const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red
                    .withValues(alpha: 0.1),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  const Text(
                    "Failure Rate",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${failureRate.toStringAsFixed(1)} %",
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Performance Contribution MID",
        ),
      ),

      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: loadAnalysis,
        child: ListView(
          children:
          subjectGradeCounts.entries
              .map(
                (entry) =>
                buildSubjectCard(
                  entry.key,
                  entry.value,
                ),
          )
              .toList(),
        ),
      ),
    );
  }
}


class SubjectContributionEndTerm3 extends StatefulWidget {
  final String schoolId;
  final String model;

  const SubjectContributionEndTerm3({
    super.key,
    required this.schoolId,
    required this.model,
  });

  @override
  State<SubjectContributionEndTerm3> createState() =>
      SubjectContributionEndTerm3EndState();
}

class SubjectContributionEndTerm3EndState
    extends State<SubjectContributionEndTerm3> {
  String currentYear = DateTime.now().year.toString();

  bool loading = true;

  // SUBJECT DATA
  Map<String, Map<String, int>> subjectGradeCounts = {};
  Map<String, int> subjectTotals = {};

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

    for (var doc in snapshot.docs) {
      final data = doc.data();

      List subjects = data["subjectsScoreTerm3"] ?? [];

      for (var subject in subjects) {
        String subjectName =
            subject["subjectName"] ?? "Unknown";

        double score =
            (subject["scoreEOT"] ?? 0).toDouble();

        String grade = getGrade(score);

        // CREATE SUBJECT
        if (!subjectGradeCounts
            .containsKey(subjectName)) {
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
        subjectTotals[subjectName] =
            subjectTotals[subjectName]! + 1;
      }
    }

    setState(() {
      loading = false;
    });
  }

  double calculateFirstGradeContribution(
      Map<String, int> grades,
      int total,
      ) {
    if (total == 0) return 0;

    int firstGrades =
        grades["D1"]! +
            grades["D2"]! +
            grades["C3"]!;

    return (firstGrades / total) * 100;
  }

  double calculateFailureRate(
      Map<String, int> grades,
      int total,
      ) {
    if (total == 0) return 0;

    int failures = grades["F9"]!;

    return (failures / total) * 100;
  }

  Widget buildSubjectCard(
      String subject,
      Map<String, int> grades,
      ) {
    int total = subjectTotals[subject] ?? 0;

    double contribution =
    calculateFirstGradeContribution(
      grades,
      total,
    );

    double failureRate =
    calculateFailureRate(
      grades,
      total,
    );

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                const Icon(
                  Icons.analytics,
                  size: 26,
                ),
                const SizedBox(width: 8),

                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Students",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  total.toString(),
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding:
              const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green
                    .withValues(alpha: 0.1),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  const Text(
                    "First Grade Contribution",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${contribution.toStringAsFixed(1)} %",
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding:
              const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red
                    .withValues(alpha: 0.1),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  const Text(
                    "Failure Rate",
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),
                  Text(
                    "${failureRate.toStringAsFixed(1)} %",
                    style: const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Performance Contribution End",
        ),
      ),

      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: loadAnalysis,
        child: ListView(
          children:
          subjectGradeCounts.entries
              .map(
                (entry) =>
                buildSubjectCard(
                  entry.key,
                  entry.value,
                ),
          )
              .toList(),
        ),
      ),
    );
  }
}