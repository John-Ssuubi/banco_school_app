import 'package:banco_mobile/DataBase/P4/Term%20I/p4_database.dart';
import 'package:banco_mobile/DataBase/P4/Term%20II/p4_database_term2.dart';
import 'package:banco_mobile/DataBase/P4/Term%20III/p4_database_term3.dart';
import 'package:banco_mobile/DataBase/P4/extra_sub_p4.dart';
import 'package:hive/hive.dart';

part 'p4_student_model.g.dart';

@HiveType(typeId: 13)
class StudentModelP4 extends HiveObject {
  @HiveField(0)
  late String? studentName;

  @HiveField(1)
  late String? classIn;

  @HiveField(2)
  late String? stream;

  @HiveField(3)
  late String? contactNumber;

  @HiveField(4)
  late List<P4Subjects> subjectsScore;

  @HiveField(5)
  late List<P4SubjectsTerm2> subjectsScoreTerm2;

  @HiveField(6)
  late List<P4SubjectsTerm3> subjectsScoreTerm3; 

  @HiveField(7)
  late int? id;

  @HiveField(8)
  late String? idNin;

  
  @HiveField(9)
  late List<ExtraSubP4>? extraSub;

  StudentModelP4({
    this.studentName,
    this.classIn,
    this.contactNumber,
    this.stream,
    required this.subjectsScore,
    required this.subjectsScoreTerm2,
    required this.subjectsScoreTerm3,
    
    required this.idNin,
    this.id,
   
    required this.extraSub,
  });

  Map<String, dynamic> toJson() => {
    "studentName": studentName,
    "classIn": classIn,
    "subjectsScore": subjectsScore.map((s) => s.toJson()).toList(),
    "subjectsScoreTerm2": subjectsScoreTerm2.map((s) => s.toJson()).toList(),
    "subjectsScoreTerm3": subjectsScoreTerm3.map((s) => s.toJson()).toList(),
    "lastUpdated": DateTime.now().toIso8601String(),
  };

  factory StudentModelP4.fromJson(Map<String, dynamic> json) => StudentModelP4(
    studentName: json['studentName'],
    classIn: json['classIn'],
    contactNumber: json['contactNumber'],
    stream: json['stream'],
    subjectsScore: (json['subjectsScore'] as List).map((e) => P4Subjects.fromJson(e)).toList(),
    subjectsScoreTerm2: (json['subjectsScoreTerm2'] as List).map((e) => P4SubjectsTerm2.fromJson(e)).toList(),
    subjectsScoreTerm3: (json['subjectsScoreTerm3'] as List).map((e) => P4SubjectsTerm3.fromJson(e)).toList(),
   
    // amountTerm1: (json['amountTerm1'] != null) ? json['amountTerm1'].toDouble() : null,
    // amountTerm2: (json['amountTerm2'] != null) ? json['amountTerm2'].toDouble() : null,
    // amountTerm3: (json['amountTerm3'] != null) ? json['amountTerm3'].toDouble() : null,
    // amountOwedTerm1: (json['amountOwedTerm1'] != null) ? json['amountOwedTerm1'].toDouble() : null,
    // amountOwedTerm2: (json['amountOwedTerm2'] != null) ? json['amountOwedTerm2'].toDouble() : null,
    // amountOwedTerm3: (json['amountOwedTerm3'] != null) ? json['amountOwedTerm3'].toDouble() : null,
    // paymentList: json['paymentList'] != null
    //     ? (json['paymentList'] as List).map((e) => PaymentsP4.fromJson(e)).toList()
    //     : null,

    extraSub: json['extraSub'] != null
        ? (json['extraSub'] as List).map((e) => ExtraSubP4.fromJson(e)).toList()
        : null, idNin: json['idNin'],
  );
}
