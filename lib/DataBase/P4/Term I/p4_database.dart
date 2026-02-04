import 'package:hive_flutter/hive_flutter.dart';

part 'p4_database.g.dart';

@HiveType(typeId: 7)
class P4Subjects extends HiveObject {
  @HiveField(0)
  String subjectName;
  @HiveField(1)
  double scoreBOT;
  @HiveField(2)
  double scoreEOT;
  @HiveField(3)
  double scoreMT;

  @HiveField(4)
  String teacher;

  P4Subjects({
    required this.subjectName,
    required this.scoreBOT,
    required this.scoreEOT,
    required this.scoreMT,
    required this.teacher,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
      'scoreBOT': scoreBOT,
      'scoreEOT': scoreEOT,
      'scoreMT': scoreMT,
      'teacher': teacher
    };
  }

  @override
  String toString() {
    return 'SubjectScore(subjectName: $subjectName, scoreBOT: $scoreBOT, scoreEOT: $scoreEOT, scoreMT: $scoreMT, teacher: $teacher  )';
  }
  Map<String, dynamic> toJson() => {
    "subjectName": subjectName,
   "scoreBOT": scoreBOT.toDouble(),
    "scoreEOT": scoreEOT.toDouble(),
    "scoreMT": scoreMT.toDouble(),
    "teacher": teacher,
    "lastUpdated": DateTime.now().toIso8601String(),
  };

   factory P4Subjects.fromJson(Map<String, dynamic> json) => P4Subjects(
    subjectName: json['subjectName'],
    scoreBOT: json['scoreBOT'].toDouble(),
    scoreEOT: json['scoreEOT'].toDouble(),
    scoreMT: json['scoreMT'].toDouble(),
    teacher: json['teacher'],
  );
}
