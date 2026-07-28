import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/HeadTeacher/AssessmentTerm3/TermSectionsTerm3.dart';
// import 'package:banco_mobile/P4/student_p4.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';



class ClassAssessmentTerm3 extends StatefulWidget {
  final String model;
  final String schoolId;

  const ClassAssessmentTerm3({
    super.key,
    required this.model,
    required this.schoolId,
  });

  @override
  State<ClassAssessmentTerm3> createState() => _ClassAssessmentState();
}

class _ClassAssessmentState extends State<ClassAssessmentTerm3> {
  String currentYear = DateTime.now().year.toString();



  TextEditingController searchController = TextEditingController();


  // Future<void> loadCurrentYear() async {
  //   final schoolDoc = await FirebaseFirestore.instance
  //       .collection('Schools')
  //       .doc(widget.schoolId)
  //       .get();

  //   setState(() {
  //     currentYear =
  //         schoolDoc.data()?['currentYear'] ??
  //             DateTime.now().year.toString();
  //   });
  // }

  // Convert score → aggregate (Uganda system)
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

  // Total BOT score
  double totalBOT(List subjects) {
    // ignore: avoid_types_as_parameter_names
    return subjects.fold(0, (sum, s) => sum + (s.scoreBOT ?? 0));
  }

  // Total aggregate
  int totalAggregate(List subjects) {
    // ignore: avoid_types_as_parameter_names
    return subjects.fold(0, (sum, s) => sum + getAggregate(s.scoreBOT ?? 0));
  }

  //  Average
  double averageScore(List subjects) {
    if (subjects.isEmpty) return 0;
    return totalBOT(subjects) / subjects.length;
  }

  int divStudents = 0;
  int div2Students = 0;
  int div3Students = 0;
  int div4Students = 0;
  int uStudents = 0;

  // Division
  String getDivision(int agg) {
    if (agg <= 12) {
      divStudents++;
      return "Division 1";
    }
    if (agg <= 24) {
      div2Students++;
      return "Division 2";
    }
    if (agg <= 32) {
      div3Students++;
      return "Division 3";
    }
    if (agg <= 35) {
      div4Students++;
      return "Division 4";
    }
    {
      uStudents++;
      return "Ungraded";
    }
  }

  bool isSearching = false;

   int _currentIndex = 0;
  late List<Widget> _termPages;
  
 @override
  void initState() {
    super.initState();

    // Initialize pages here because widget.* is available in initState
    _termPages = [
      Term3Bot(
        model: widget.model,
        schoolId: widget.schoolId,
      ),
      Term3Mid(
        model: widget.model,
        schoolId: widget.schoolId,
      ),
      Term3End(
        model: widget.model,
        schoolId: widget.schoolId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        
        body: TabBarView(
          children: [
            _termPages[_currentIndex]
          ],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        
         bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mainColor,
        unselectedItemColor: const Color.fromARGB(255, 124, 124, 124),
        selectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Bot'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Mid'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'End'),
        ],
      ),
      ),
    );
  }
void showStudentSummaryDialog(
  BuildContext context,
  StudentModelP4 student,
  int position,
) {
  int total = totalBOT(student.subjectsScoreTerm3).toInt();
  int average = averageScore(student.subjectsScoreTerm3).toInt();
  int aggregate = totalAggregate(student.subjectsScoreTerm3);
  String division = getDivision(aggregate);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        title: Column(
          children: [
             Icon(
              Icons.school,
              size: 40,
              color: mainColor,
            ),
            const SizedBox(height: 10),

            Text(
              student.studentName ?? "Student",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),

        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // POSITION
              Text(
                "Position: $position",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text("Total Marks: $total"),
              Text("Average Score: $average"),
              Text("Aggregate: $aggregate"),
              Text("Division: $division"),

              const Divider(height: 25),

              const Text(
                "Subjects Performance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              ...student.subjectsScoreTerm3.map((sub) {
                double score = sub.scoreBOT;
                int agg = getAggregate(score);

                String displayScore =
                    score == -1 ? "x" : score.toInt().toString();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(sub.subjectName),
                      Text("$displayScore  (Agg: $agg)"),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
}
