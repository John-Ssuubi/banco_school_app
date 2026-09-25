// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:banco_mobile/DataBase/P4/Term%20I/p4_database.dart';
import 'package:banco_mobile/DataBase/P4/Term%20II/p4_database_term2.dart';
import 'package:banco_mobile/DataBase/P4/Term%20III/p4_database_term3.dart';
import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Core grade resolver — single source of truth.
//
// FIX 1: Original used plain `if` chains — every matching condition
//         overwrote the previous one, so the last match always won.
//         Now uses `if / else if` so only the FIRST match is returned.
//
// FIX 2: Original stored result in global vars (divisionBot, divisionMid,
//         divisionEnd) which could be corrupted by concurrent calls.
//         Result is now a local return value only.
//
// Boundary comparison direction (<=) is kept exactly as the original
// so Firestore values continue to work unchanged.
// ---------------------------------------------------------------------------
String _resolveGrade(
  double score,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) {
  if (score == -1) return 'X';
   if (score <= f9Start) {
    return 'F9';
  }
  if (score <= p8Start) {
    return 'P8';
  }
  if (score <= p7Start) {
    return 'P7';
  }
  if (score <= c6Start) {
    return 'C6';
  }
  if (score <= c5Start) {
    return 'C5';
  }
  if (score <= c4Start) {
    return 'C4';
  }
  if (score <= c3Start) {
    return 'C3';
  }
  if (score <= d2Start) {
    return 'D2';
  }
  if (score <= d1Start) {
    return 'D1';
  }
  return 'F9';
}

// Display variant: returns '' for unset scores (-1).
String _resolveGradeDisplay(
  double score,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) {
  if (score == -1) return '';
  return _resolveGrade(
    score,
    d1Start,
    d2Start,
    c3Start,
    c4Start,
    c5Start,
    c6Start,
    p7Start,
    p8Start,
    f9Start,
    f9End,
  );
}

// Numeric weight used for aggregate sums.
int _resolveWeight(
  double score,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) {
  if (score == -1) return 0;
  const weights = {
    'D1': 1,
    'D2': 2,
    'C3': 3,
    'C4': 4,
    'C5': 5,
    'C6': 6,
    'P7': 7,
    'P8': 8,
    'F9': 9,
  };
  final grade = _resolveGrade(
    score,
    d1Start,
    d2Start,
    c3Start,
    c4Start,
    c5Start,
    c6Start,
    p7Start,
    p8Start,
    f9Start,
    f9End,
  );
  return weights[grade] ?? 9;
}

// ---------------------------------------------------------------------------
// Public grade functions — signatures unchanged from original.
// ---------------------------------------------------------------------------

String divCalBOT(
  double grades,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) => _resolveGrade(
  grades,
  d1Start,
  d2Start,
  c3Start,
  c4Start,
  c5Start,
  c6Start,
  p7Start,
  p8Start,
  f9Start,
  f9End,
);

String gradeBot(
  double grade,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) => _resolveGradeDisplay(
  grade,
  d1Start,
  d2Start,
  c3Start,
  c4Start,
  c5Start,
  c6Start,
  p7Start,
  p8Start,
  f9Start,
  f9End,
);

String divCalMid(
  double grades,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) => _resolveGrade(
  grades,
  d1Start,
  d2Start,
  c3Start,
  c4Start,
  c5Start,
  c6Start,
  p7Start,
  p8Start,
  f9Start,
  f9End,
);

String gradeMid(
  double grade,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) => _resolveGradeDisplay(
  grade,
  d1Start,
  d2Start,
  c3Start,
  c4Start,
  c5Start,
  c6Start,
  p7Start,
  p8Start,
  f9Start,
  f9End,
);

String divEND(
  double grades,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) => _resolveGrade(
  grades,
  d1Start,
  d2Start,
  c3Start,
  c4Start,
  c5Start,
  c6Start,
  p7Start,
  p8Start,
  f9Start,
  f9End,
);

// ---------------------------------------------------------------------------
// Aggregate helpers
//
// FIX 3: `setData.contains(-1.0)` was checked INSIDE the per-subject loop,
//         resetting `agg3` to 0 on every iteration. Now checked ONCE before
//         the loop.
// FIX 4: The three near-identical functions are collapsed into one generic
//         helper so the fix only lives in one place.
// ---------------------------------------------------------------------------

String _aggregateEot<T>(
  List<T>? subjects,
  double Function(T) scoreOf,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) {
  if (subjects == null || subjects.isEmpty) return '0';

  final hasUnmarked = subjects.any((s) => scoreOf(s) == -1.0);
  if (hasUnmarked) return '0';

  final toScore = subjects.length > 4
      ? subjects.getRange(0, 4).toList()
      : subjects;

  int total = 0;
  for (final s in toScore) {
    total += _resolveWeight(
      scoreOf(s),
      d1Start,
      d2Start,
      c3Start,
      c4Start,
      c5Start,
      c6Start,
      p7Start,
      p8Start,
      f9Start,
      f9End,
    );
  }
  return total.toString();
}

String gradeEot(
  List<P4Subjects>? s,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) => _aggregateEot<P4Subjects>(
  s,
  (e) => e.scoreEOT.toDouble(),
  d1Start,
  d2Start,
  c3Start,
  c4Start,
  c5Start,
  c6Start,
  p7Start,
  p8Start,
  f9Start,
  f9End,
);

String gradeEotTerm2(
  List<P4SubjectsTerm2>? s,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) => _aggregateEot<P4SubjectsTerm2>(
  s,
  (e) => e.scoreEOT.toDouble(),
  d1Start,
  d2Start,
  c3Start,
  c4Start,
  c5Start,
  c6Start,
  p7Start,
  p8Start,
  f9Start,
  f9End,
);

String gradeEotTerm3(
  List<P4SubjectsTerm3>? s,
  int d1Start,
  int d2Start,
  int c3Start,
  int c4Start,
  int c5Start,
  int c6Start,
  int p7Start,
  int p8Start,
  int f9Start,
  int f9End,
) => _aggregateEot<P4SubjectsTerm3>(
  s,
  (e) => e.scoreEOT.toDouble(),
  d1Start,
  d2Start,
  c3Start,
  c4Start,
  c5Start,
  c6Start,
  p7Start,
  p8Start,
  f9Start,
  f9End,
);

// ---------------------------------------------------------------------------
// Score-entry dialogs
//
// FIX 5: Three identical dialogs collapsed into one private helper.
// ---------------------------------------------------------------------------

Future<void> _scoreDialog({
  required BuildContext context,
  required TextEditingController resultInput,
  required String studentId,
  required String subjectName,
  required String scoreField,
  required String examLabel,
}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter $examLabel score for $subjectName'),
        content: TextFormField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          controller: resultInput,
          decoration: InputDecoration(hintText: 'Enter score (e.g. 85.0)'),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            onPressed: () async {
              final scoreText = resultInput.text.trim();
              if (scoreText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a score')),
                );
                return;
              }
              final newScore = double.tryParse(scoreText);
              if (newScore == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid number format')),
                );
                return;
              }
              try {
                final docRef = FirebaseFirestore.instance
                    .collection('studentModelP4')
                    .doc(studentId);
                final docSnap = await docRef.get();
                if (!docSnap.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Student $studentId not found!')),
                  );
                  return;
                }
                final subjects = List<Map<String, dynamic>>.from(
                  docSnap.data()!['subjectsScore'],
                );
                for (final sub in subjects) {
                  if (sub['subjectName'] == subjectName) {
                    sub[scoreField] = newScore;
                  }
                }
                await docRef.update({
                  'subjectsScore': subjects,
                  'lastUpdated': DateTime.now().toIso8601String(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Score updated successfully')),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error updating score')),
                );
              }
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              resultInput.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

Future<void> dialogBOT({
  required BuildContext context,
  required TextEditingController resultInput,
  required String studentId,
  required String subjectName,
}) => _scoreDialog(
  context: context,
  resultInput: resultInput,
  studentId: studentId,
  subjectName: subjectName,
  scoreField: 'scoreBOT',
  examLabel: 'BOT',
);

Future<void> dialogMID({
  required BuildContext context,
  required TextEditingController resultInput,
  required String studentId,
  required String subjectName,
}) => _scoreDialog(
  context: context,
  resultInput: resultInput,
  studentId: studentId,
  subjectName: subjectName,
  scoreField: 'scoreMT',
  examLabel: 'MID',
);

Future<void> dialogEOT({
  required BuildContext context,
  required TextEditingController resultInput,
  required String studentId,
  required String subjectName,
}) => _scoreDialog(
  context: context,
  resultInput: resultInput,
  studentId: studentId,
  subjectName: subjectName,
  scoreField: 'scoreEOT',
  examLabel: 'EOT',
);

// ---------------------------------------------------------------------------
// Subject rankings
// ---------------------------------------------------------------------------

Map<String, List<Map<String, dynamic>>> rankAllSubjectsBOT(
  List<StudentModelP4> students,
) {
  final Map<String, List<Map<String, dynamic>>> rankings = {};
  for (final student in students) {
    for (final subject in student.subjectsScore) {
      rankings.putIfAbsent(subject.subjectName, () => []);
      rankings[subject.subjectName]!.add({
        'studentName': student.studentName,
        'botScore': subject.scoreBOT.toInt(),
      });
    }
  }
  for (final list in rankings.values) {
    list.sort((a, b) => (b['botScore'] as int).compareTo(a['botScore'] as int));
  }
  return rankings;
}
