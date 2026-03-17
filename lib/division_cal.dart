// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/DataBase/P4/Term%20I/p4_database.dart';
import 'package:banco_mobile/DataBase/P4/Term%20II/p4_database_term2.dart';
import 'package:banco_mobile/DataBase/P4/Term%20III/p4_database_term3.dart';
import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

var divisionBot = '';
var divisionMid = '';
var divisionEnd = '';

String divCalBOT(double grades, int d1Start, int d2Start, int c3Start, int c4Start, int c5Start, int c6Start, int p7Start, int p8Start, int f9Start, int f9End) {
  if (grades <= d1Start) {
    divisionBot = 'D1';
  }
  if (grades <= d2Start) {
    divisionBot = 'D2';
  }
  if (grades <= c3Start) {
    divisionBot = 'C3';
  }
  if (grades <= c4Start) {
    divisionBot = 'C4';
  }
  if (grades <= c5Start) {
    divisionBot = 'C5';
  }
  if (grades <= c6Start) {
    divisionBot = 'C6';
  }
  if (grades <= p7Start) {
    divisionBot = 'P7';
  }
  if (grades <= p8Start) {
    divisionBot = 'P8';
  }
  if (grades <= f9Start) {
    divisionBot = 'F9';
  }
  if (grades <= f9Start) {
    divisionBot = 'F9';
  }
  if (grades == -1) {
    divisionBot = 'X';
  }

  return divisionBot;
}

String gradeBot(double grade, int d1Start, int d2Start, int c3Start, int c4Start, int c5Start, int c6Start, int p7Start, int p8Start, int f9Start, int f9End) {
  var totalScores2 = grade;

  var aggregates2 = 'F9';

  if (totalScores2 <= d1Start) {
    aggregates2 = 'D1';
  }
  if (totalScores2 <= d2Start) {
    aggregates2 = 'D2';
  }
  if (totalScores2 <= c3Start) {
    aggregates2 = 'C3';
  }
  if (totalScores2 <= c4Start) {
    aggregates2 = 'C4';
  }
  if (totalScores2 <= c5Start) {
    aggregates2 = 'C5';
  }
  if (totalScores2 <= c6Start) {
    aggregates2 = 'C6';
  }
  if (totalScores2 <= p7Start) {
    aggregates2 = 'P7';
  }
  if (totalScores2 <= p8Start) {
    aggregates2 = 'P8';
  }
  if (totalScores2 <= f9Start) {
    aggregates2 = 'F9';
  }
  if (totalScores2 == f9End) {
    aggregates2 = 'F9';
  }

  if (totalScores2 == -1) {
    aggregates2 = '';
  }

  return aggregates2;
}

String divCalMid(double grades, int d1Start, int d2Start, int c3Start, int c4Start, int c5Start, int c6Start, int p7Start, int p8Start, int f9Start, int f9End) {
  if (grades <= d1Start) {
    divisionMid = 'D1';
  }
  if (grades <= d2Start) {
    divisionMid = 'D2';
  }
  if (grades <= c3Start) {
    divisionMid = 'C3';
  }
  if (grades <= c4Start) {
    divisionMid = 'C4';
  }
  if (grades <= c5Start) {
    divisionMid = 'C5';
  }
  if (grades <= c6Start) {
    divisionMid = 'C6';
  }
  if (grades <= p7Start) {
    divisionMid = 'P7';
  }
  if (grades <= p8Start) {
    divisionMid = 'P8';
  }
  if (grades <= f9Start) {
    divisionMid = 'F9';
  }
  if (grades <= f9Start) {
    divisionMid = 'F9';
  }
  if (grades == -1) {
    divisionMid = 'X';
  }

  return divisionMid;
}

String gradeMid(double grade, int d1Start, int d2Start, int c3Start, int c4Start, int c5Start, int c6Start, int p7Start, int p8Start, int f9Start, int f9End) {
  var totalScores2 = grade;

  var aggregates2 = 'F9';

  if (totalScores2 <= d1Start) {
    aggregates2 = 'D1';
  }
  if (totalScores2 <= d2Start) {
    aggregates2 = 'D2';
  }
  if (totalScores2 <= c3Start) {
    aggregates2 = 'C3';
  }
  if (totalScores2 <= c4Start) {
    aggregates2 = 'C4';
  }
  if (totalScores2 <= c5Start) {
    aggregates2 = 'C5';
  }
  if (totalScores2 <= c6Start) {
    aggregates2 = 'C6';
  }
  if (totalScores2 <= p7Start) {
    aggregates2 = 'P7';
  }
  if (totalScores2 <= p8Start) {
    aggregates2 = 'P8';
  }
  if (totalScores2 <= f9Start) {
    aggregates2 = 'F9';
  }
  if (totalScores2 == f9End) {
    aggregates2 = 'F9';
  }

  if (totalScores2 == -1) {
    aggregates2 = '';
  }

  return aggregates2;
}

// 0700984034

String divEND(double grades, int d1Start, int d2Start, int c3Start, int c4Start, int c5Start, int c6Start, int p7Start, int p8Start, int f9Start, int f9End) {
  if (grades <= d1Start) {
    divisionEnd = 'D1';
  }
  if (grades <= d2Start) {
    divisionEnd = 'D2';
  }
  if (grades <= c3Start) {
    divisionEnd = 'C3';
  }
  if (grades <= c4Start) {
    divisionEnd = 'C4';
  }
  if (grades <= c5Start) {
    divisionEnd = 'C5';
  }
  if (grades <= c6Start) {
    divisionEnd = 'C6';
  }
  if (grades <= p7Start) {
    divisionEnd = 'P7';
  }
  if (grades <= p8Start) {
    divisionEnd = 'P8';
  }
  if (grades <= f9Start) {
    divisionEnd = 'F9';
  }
  if (grades <= f9Start) {
    divisionEnd = 'F9';
  }
  if (grades == -1) {
    divisionEnd = 'X';
  }

  return divisionEnd;
}

String gradeEot(List<P4Subjects>? scoreswidget, int d1Start, int d2Start, int c3Start, int c4Start, int c5Start, int c6Start, int p7Start, int p8Start, int f9Start, int f9End) {
  // var totalScores2 = grade;
  int agg3div2 = 0;
  var agg3div = 0;
  var agg3 = 0;

  var setData = List.generate(scoreswidget!.length, ((index) {
    var data = scoreswidget[index].scoreEOT;
    return data;
  }));

  if (scoreswidget.length > 4) {
    List<P4Subjects> scores = scoreswidget.getRange(0, 4).toList();
    for (var element in scores) {
      // print(sum3);
      var totalScores = element.scoreEOT;

      if (totalScores <= d1Start) {
        agg3div = 1;
      }
      if (totalScores <= d2Start) {
        agg3div = 2;
      }
      if (totalScores <= c3Start) {
        agg3div = 3;
      }
      if (totalScores <= c4Start) {
        agg3div = 4;
      }
      if (totalScores <= c5Start) {
        agg3div = 5;
      }
      if (totalScores <= c6Start) {
        agg3div = 6;
      }
      if (totalScores <= p7Start) {
        agg3div = 7;
      }
      if (totalScores <= p8Start) {
        agg3div = 8;
      }
      if (totalScores <= f9Start) {
        agg3div = 9;
      }
      if (totalScores == f9End) {
        agg3div = 9;
      }

      if (setData.contains(-1.0)) {
        // print('object object object object object');
        agg3 = 0;
      } else {
        agg3 = agg3div2 += agg3div;
      }
      // agg3 = agg3div2 += agg3div;
    }
  } else {
    for (var element in scoreswidget) {
      // print(sum3);
      var totalScores = element.scoreEOT;

      if (totalScores <= d1Start) {
        agg3div = 1;
      }
      if (totalScores <= d2Start) {
        agg3div = 2;
      }
      if (totalScores <= c3Start) {
        agg3div = 3;
      }
      if (totalScores <= c4Start) {
        agg3div = 4;
      }
      if (totalScores <= c5Start) {
        agg3div = 5;
      }
      if (totalScores <= c6Start) {
        agg3div = 6;
      }
      if (totalScores <= p7Start) {
        agg3div = 7;
      }
      if (totalScores <= p8Start) {
        agg3div = 8;
      }
      if (totalScores <= f9Start) {
        agg3div = 9;
      }
      if (totalScores == f9End) {
        agg3div = 9;
      }

      if (setData.contains(-1.0)) {
        // print('object object object object object');
        agg3 = 0;
      } else {
        agg3 = agg3div2 += agg3div;
      }
      // agg3 = agg3div2 += agg3div;
    }
  }

  return agg3.toString();
}


String gradeEotTerm2  (List<P4SubjectsTerm2>? scoreswidget, int d1Start, int d2Start, int c3Start, int c4Start, int c5Start, int c6Start, int p7Start, int p8Start, int f9Start, int f9End) {
  // var totalScores2 = grade;
  int agg3div2 = 0;
  var agg3div = 0;
  var agg3 = 0;

  var setData = List.generate(scoreswidget!.length, ((index) {
    var data = scoreswidget[index].scoreEOT;
    return data;
  }));

  if (scoreswidget.length > 4) {
    List<P4SubjectsTerm2> scores = scoreswidget.getRange(0, 4).toList();
    for (var element in scores) {
      // print(sum3);
      var totalScores = element.scoreEOT;

      if (totalScores <= d1Start) {
        agg3div = 1;
      }
      if (totalScores <= d2Start) {
        agg3div = 2;
      }
      if (totalScores <= c3Start) {
        agg3div = 3;
      }
      if (totalScores <= c4Start) {
        agg3div = 4;
      }
      if (totalScores <= c5Start) {
        agg3div = 5;
      }
      if (totalScores <= c6Start) {
        agg3div = 6;
      }
      if (totalScores <= p7Start) {
        agg3div = 7;
      }
      if (totalScores <= p8Start) {
        agg3div = 8;
      }
      if (totalScores <= f9Start) {
        agg3div = 9;
      }
      if (totalScores == f9End) {
        agg3div = 9;
      }

      if (setData.contains(-1.0)) {
        // print('object object object object object');
        agg3 = 0;
      } else {
        agg3 = agg3div2 += agg3div;
      }
      // agg3 = agg3div2 += agg3div;
    }
  } else {
    for (var element in scoreswidget) {
      // print(sum3);
      var totalScores = element.scoreEOT;

      if (totalScores <= d1Start) {
        agg3div = 1;
      }
      if (totalScores <= d2Start) {
        agg3div = 2;
      }
      if (totalScores <= c3Start) {
        agg3div = 3;
      }
      if (totalScores <= c4Start) {
        agg3div = 4;
      }
      if (totalScores <= c5Start) {
        agg3div = 5;
      }
      if (totalScores <= c6Start) {
        agg3div = 6;
      }
      if (totalScores <= p7Start) {
        agg3div = 7;
      }
      if (totalScores <= p8Start) {
        agg3div = 8;
      }
      if (totalScores <= f9Start) {
        agg3div = 9;
      }
      if (totalScores == f9End) {
        agg3div = 9;
      }

      if (setData.contains(-1.0)) {
        // print('object object object object object');
        agg3 = 0;
      } else {
        agg3 = agg3div2 += agg3div;
      }
      // agg3 = agg3div2 += agg3div;
    }
  }

  return agg3.toString();
}


String gradeEotTerm3  (List<P4SubjectsTerm3>? scoreswidget, int d1Start, int d2Start, int c3Start, int c4Start, int c5Start, int c6Start, int p7Start, int p8Start, int f9Start, int f9End) {
  // var totalScores2 = grade;
  int agg3div2 = 0;
  var agg3div = 0;
  var agg3 = 0;

  var setData = List.generate(scoreswidget!.length, ((index) {
    var data = scoreswidget[index].scoreEOT;
    return data;
  }));

  if (scoreswidget.length > 4) {
    List<P4SubjectsTerm3> scores = scoreswidget.getRange(0, 4).toList();
    for (var element in scores) {
      // print(sum3);
      var totalScores = element.scoreEOT;

      if (totalScores <= d1Start) {
        agg3div = 1;
      }
      if (totalScores <= d2Start) {
        agg3div = 2;
      }
      if (totalScores <= c3Start) {
        agg3div = 3;
      }
      if (totalScores <= c4Start) {
        agg3div = 4;
      }
      if (totalScores <= c5Start) {
        agg3div = 5;
      }
      if (totalScores <= c6Start) {
        agg3div = 6;
      }
      if (totalScores <= p7Start) {
        agg3div = 7;
      }
      if (totalScores <= p8Start) {
        agg3div = 8;
      }
      if (totalScores <= f9Start) {
        agg3div = 9;
      }
      if (totalScores == f9End) {
        agg3div = 9;
      }

      if (setData.contains(-1.0)) {
        // print('object object object object object');
        agg3 = 0;
      } else {
        agg3 = agg3div2 += agg3div;
      }
      // agg3 = agg3div2 += agg3div;
    }
  } else {
    for (var element in scoreswidget) {
      // print(sum3);
      var totalScores = element.scoreEOT;

      if (totalScores <= d1Start) {
        agg3div = 1;
      }
      if (totalScores <= d2Start) {
        agg3div = 2;
      }
      if (totalScores <= c3Start) {
        agg3div = 3;
      }
      if (totalScores <= c4Start) {
        agg3div = 4;
      }
      if (totalScores <= c5Start) {
        agg3div = 5;
      }
      if (totalScores <= c6Start) {
        agg3div = 6;
      }
      if (totalScores <= p7Start) {
        agg3div = 7;
      }
      if (totalScores <= p8Start) {
        agg3div = 8;
      }
      if (totalScores <= f9Start) {
        agg3div = 9;
      }
      if (totalScores == f9End) {
        agg3div = 9;
      }

      if (setData.contains(-1.0)) {
        // print('object object object object object');
        agg3 = 0;
      } else {
        agg3 = agg3div2 += agg3div;
      }
      // agg3 = agg3div2 += agg3div;
    }
  }

  return agg3.toString();
}

Future<void> dialogBOT( {
  required BuildContext context,
  required TextEditingController resultInput,
  required String studentId, // Firestore doc ID (e.g. student name)
  required String subjectName, // Which subject to update
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter new score for $subjectName'),
        content: TextFormField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          controller: resultInput,
          decoration: const InputDecoration(
            hintText: "Enter score (e.g. 85.0)",
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Read score from controller
              final scoreText = resultInput.text.trim();
              if (scoreText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a score")),
                );
                return;
              }

              final newScore = double.tryParse(scoreText);
              if (newScore == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid number format")),
                );
                return;
              }

              try {
                // Fetch the student document
                final docRef = FirebaseFirestore.instance
                    .collection('studentModelP4')
                    .doc(studentId);

                final docSnap = await docRef.get();
                if (!docSnap.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Student $studentId not found!")),
                  );
                  return;
                }

                final data = docSnap.data()!;
                final subjects = List<Map<String, dynamic>>.from(data['subjectsScore']);

                // Find and update the subject
                for (var sub in subjects) {
                  if (sub['subjectName'] == subjectName) {
                    sub['scoreBOT'] = newScore;
                  }
                }

                // Upload updated list back to Firestore
                await docRef.update({
                  'subjectsScore': subjects,
                  'lastUpdated': DateTime.now().toIso8601String(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Score updated successfully")),
                );

                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error updating score")),
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

Future<void> dialogMID( {
  required BuildContext context,
  required TextEditingController resultInput,
  required String studentId, // Firestore doc ID (e.g. student name)
  required String subjectName, // Which subject to update
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter new score for $subjectName'),
        content: TextFormField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          controller: resultInput,
          decoration: const InputDecoration(
            hintText: "Enter score (e.g. 85.0)",
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Read score from controller
              final scoreText = resultInput.text.trim();
              if (scoreText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a score")),
                );
                return;
              }

              final newScore = double.tryParse(scoreText);
              if (newScore == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid number format")),
                );
                return;
              }

              try {
                // Fetch the student document
                final docRef = FirebaseFirestore.instance
                    .collection('studentModelP4')
                    .doc(studentId);

                final docSnap = await docRef.get();
                if (!docSnap.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Student $studentId not found!")),
                  );
                  return;
                }

                final data = docSnap.data()!;
                final subjects = List<Map<String, dynamic>>.from(data['subjectsScore']);

                // Find and update the subject
                for (var sub in subjects) {
                  if (sub['subjectName'] == subjectName) {
                    sub['scoreMT'] = newScore;
                  }
                }

                // Upload updated list back to Firestore
                await docRef.update({
                  'subjectsScore': subjects,
                  'lastUpdated': DateTime.now().toIso8601String(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Score updated successfully")),
                );

                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error updating score")),
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

Future<void> dialogEOT( {
  required BuildContext context,
  required TextEditingController resultInput,
  required String studentId, // Firestore doc ID (e.g. student name)
  required String subjectName, // Which subject to update
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter new score for $subjectName'),
        content: TextFormField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          controller: resultInput,
          decoration: const InputDecoration(
            hintText: "Enter score (e.g. 85.0)",
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Read score from controller
              final scoreText = resultInput.text.trim();
              if (scoreText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a score")),
                );
                return;
              }

              final newScore = double.tryParse(scoreText);
              if (newScore == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid number format")),
                );
                return;
              }

              try {
                // Fetch the student document
                final docRef = FirebaseFirestore.instance
                    .collection('studentModelP4')
                    .doc(studentId);

                final docSnap = await docRef.get();
                if (!docSnap.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Student $studentId not found!")),
                  );
                  return;
                }

                final data = docSnap.data()!;
                final subjects = List<Map<String, dynamic>>.from(data['subjectsScore']);

                // Find and update the subject
                for (var sub in subjects) {
                  if (sub['subjectName'] == subjectName) {
                    sub['scoreEOT'] = newScore;
                  }
                }

                // Upload updated list back to Firestore
                await docRef.update({
                  'subjectsScore': subjects,
                  'lastUpdated': DateTime.now().toIso8601String(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("✅ Score updated successfully")),
                );

                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error updating score")),
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

Map<String, List<Map<String, dynamic>>> rankAllSubjectsBOT(
    List<StudentModelP4> students) {

  Map<String, List<Map<String, dynamic>>> subjectRankings = {};

  for (var student in students) {
    for (var subject in student.subjectsScore) {
      String subName = subject.subjectName;
      int botScore = subject.scoreBOT.toInt();

      // Initialize list for this subject if not exists
      if (!subjectRankings.containsKey(subName)) {
        subjectRankings[subName] = [];
      }

      subjectRankings[subName]!.add({
        'studentName': student.studentName,
        'botScore': botScore,
      });
    }
  }

  // Sort each subject's list descending by BOT score
  subjectRankings.forEach((subjectName, rankingList) {
    rankingList.sort((a, b) => b['botScore'].compareTo(a['botScore']));
  });

  return subjectRankings;
}

