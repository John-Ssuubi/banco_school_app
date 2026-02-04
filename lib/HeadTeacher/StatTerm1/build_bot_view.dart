import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
  
List<Map<String, dynamic>> getSubjectRankingBOT(
    List<StudentModelP4> students, String subjectName) {
  List<Map<String, dynamic>> rankings = [];

  for (var student in students) {
    for (var subject in student.subjectsScore) {
      if (subject.subjectName == subjectName) {
        rankings.add({
          'studentName': student.studentName,
          'botScore': subject.scoreBOT.toInt(),
        });
      }
    }
  }

  // Sort descending by BOT score
  rankings.sort((a, b) => b['botScore'].compareTo(a['botScore']));

  return rankings;
}
List<Map<String, dynamic>> getSubjectRankingBOTTerm2(
    List<StudentModelP4> students, String subjectName) {
  List<Map<String, dynamic>> rankings = [];

  for (var student in students) {
    for (var subject in student.subjectsScoreTerm2) {
      if (subject.subjectName == subjectName) {
        rankings.add({
          'studentName': student.studentName,
          'botScore': subject.scoreBOT.toInt(),
        });
      }
    }
  }

  // Sort descending by BOT score
  rankings.sort((a, b) => b['botScore'].compareTo(a['botScore']));

  return rankings;
}

List<Map<String, dynamic>> getSubjectRankingBOTTerm3(
    List<StudentModelP4> students, String subjectName) {
  List<Map<String, dynamic>> rankings = [];

  for (var student in students) {
    for (var subject in student.subjectsScoreTerm3) {
      if (subject.subjectName == subjectName) {
        rankings.add({
          'studentName': student.studentName,
          'botScore': subject.scoreBOT.toInt(),
        });
      }
    }
  }

  // Sort descending by BOT score
  rankings.sort((a, b) => b['botScore'].compareTo(a['botScore']));

  return rankings;
}

List<Map<String, dynamic>> getSubjectRankingMID(
    List<StudentModelP4> students, String subjectName) {
  List<Map<String, dynamic>> rankings = [];

  for (var student in students) {
    for (var subject in student.subjectsScore) {
      if (subject.subjectName == subjectName) {
        rankings.add({
          'studentName': student.studentName,
          'mtScore': subject.scoreMT.toInt(),
        });
      }
    }
  }

  // Sort descending by BOT score
  rankings.sort((a, b) => b['mtScore'].compareTo(a['mtScore']));

  return rankings;
}

List<Map<String, dynamic>> getSubjectRankingMIDTerm2(
    List<StudentModelP4> students, String subjectName) {
  List<Map<String, dynamic>> rankings = [];

  for (var student in students) {
    for (var subject in student.subjectsScoreTerm2) {
      if (subject.subjectName == subjectName) {
        rankings.add({
          'studentName': student.studentName,
          'mtScore': subject.scoreMT.toInt(),
        });
      }
    }
  }

  // Sort descending by BOT score
  rankings.sort((a, b) => b['mtScore'].compareTo(a['mtScore']));

  return rankings;
}

List<Map<String, dynamic>> getSubjectRankingMIDTerm3(
    List<StudentModelP4> students, String subjectName) {
  List<Map<String, dynamic>> rankings = [];

  for (var student in students) {
    for (var subject in student.subjectsScoreTerm3) {
      if (subject.subjectName == subjectName) {
        rankings.add({
          'studentName': student.studentName,
          'mtScore': subject.scoreMT.toInt(),
        });
      }
    }
  }

  // Sort descending by BOT score
  rankings.sort((a, b) => b['mtScore'].compareTo(a['mtScore']));

  return rankings;
}

List<Map<String, dynamic>> getSubjectRankingEND(
    List<StudentModelP4> students, String subjectName) {
  List<Map<String, dynamic>> rankings = [];

  for (var student in students) {
    for (var subject in student.subjectsScore) {
      if (subject.subjectName == subjectName) {
        rankings.add({
          'studentName': student.studentName,
          'endScore': subject.scoreEOT.toInt(),
        });
      }
    }
  }

  // Sort descending by BOT score
  rankings.sort((a, b) => b['endScore'].compareTo(a['endScore']));

  return rankings;
}


List<Map<String, dynamic>> getSubjectRankingENDTerm2(
    List<StudentModelP4> students, String subjectName) {
  List<Map<String, dynamic>> rankings = [];

  for (var student in students) {
    for (var subject in student.subjectsScoreTerm2) {
      if (subject.subjectName == subjectName) {
        rankings.add({
          'studentName': student.studentName,
          'endScore': subject.scoreEOT.toInt(),
        });
      }
    }
  }

  // Sort descending by BOT score
  rankings.sort((a, b) => b['endScore'].compareTo(a['endScore']));

  return rankings;
}


List<Map<String, dynamic>> getSubjectRankingENDTerm3(
    List<StudentModelP4> students, String subjectName) {
  List<Map<String, dynamic>> rankings = [];

  for (var student in students) {
    for (var subject in student.subjectsScoreTerm3) {
      if (subject.subjectName == subjectName) {
        rankings.add({
          'studentName': student.studentName,
          'endScore': subject.scoreEOT.toInt(),
        });
      }
    }
  }

  // Sort descending by BOT score
  rankings.sort((a, b) => b['endScore'].compareTo(a['endScore']));

  return rankings;
}