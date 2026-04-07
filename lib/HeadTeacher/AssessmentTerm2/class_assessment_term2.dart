import 'dart:ui';

import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/HeadTeacher/AssessmentTerm1/class_assessment.dart';
import 'package:banco_mobile/HeadTeacher/AssessmentTerm2/subject_analysis_term2.dart';
import 'package:banco_mobile/HeadTeacher/AssessmentTerm2/subject_contribution_term2.dart';
import 'package:banco_mobile/HeadTeacher/AssessmentTerm3/class_assessment_term3.dart';
// import 'package:banco_mobile/P4/student_p4.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassAssessmentTerm2 extends StatefulWidget {
  final String model;
  final String schoolId;

  const ClassAssessmentTerm2({
    super.key,
    required this.model,
    required this.schoolId,
  });

  @override
  State<ClassAssessmentTerm2> createState() => _ClassAssessmentState();
}

class _ClassAssessmentState extends State<ClassAssessmentTerm2> {
  String currentYear = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    // loadCurrentYear();
  }

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onTap: () => Navigator.pop(context),
        ),
        backgroundColor: mainColor,
        title: isSearching
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  cursorColor: Colors.white,
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search student...",
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),

                    // CLEAR BUTTON
                    // suffixIcon: searchQuery.isNotEmpty
                    //     ? IconButton(
                    //         icon: const Icon(Icons.clear, color: Colors.white),
                    //         onPressed: () {
                    //           searchController.clear();
                    //           setState(() {
                    //             searchQuery = "";
                    //           });
                    //         },
                    //       )
                    //     : null,
                    border: InputBorder.none,
                  ),

                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
              )
            : Text('Class Assessment Term II', style: whiteText),

        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                searchController.clear();
                searchQuery = "";
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5), // transparency
              borderRadius: BorderRadius.circular(20),

              // Glass border
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),

              // Optional shadow
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  child: Text('Term I'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ClassAssessment(
                            model: widget.model,
                            schoolId: widget.schoolId,
                          );
                        },
                      ),
                    );
                  },
                ),
                FloatingActionButton(
                  child: Text('Term III'),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ClassAssessmentTerm3(
                            model: widget.model,
                            schoolId: widget.schoolId,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 🔥 STUDENT LIST
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Schools')
                  .doc(widget.schoolId)
                  .collection('Years')
                  .doc(currentYear)
                  .collection(widget.model)
                  .orderBy('studentName')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No students found.'));
                }

                final students = snapshot.data!.docs
                    .map((doc) => StudentModelP4.fromJson(doc.data()))
                    .toList();

                // ✅ FILTER LOGIC
                final filteredStudents = students.where((student) {
                  final name = (student.studentName ?? "").toLowerCase();
                  final nin = (student.idNin ?? "").toLowerCase();

                  return name.contains(searchQuery) ||
                      nin.contains(searchQuery);
                }).toList();

                // 🔥 Sort students by total aggregate (lowest is best)
                filteredStudents.sort(
                  (a, b) => totalAggregate(
                    a.subjectsScoreTerm2,
                  ).compareTo(totalAggregate(b.subjectsScoreTerm2)),
                );

                if (filteredStudents.isEmpty) {
                  return const Center(child: Text("No matching students."));
                }

                return ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];

                    int totalBOTInt = totalBOT(
                      student.subjectsScoreTerm2,
                    ).toInt();
                    String totalBOTString = totalBOTInt.toString();

                    if (totalBOTInt < 0) {
                      totalBOTString = "U";
                    }

                    int totalAvgInt = averageScore(
                      student.subjectsScoreTerm2,
                    ).toInt();
                    String totalAvgString = totalAvgInt.toString();

                    if (totalAvgInt < 0) {
                      totalAvgString = "U";
                    }

                    return Card(
                      elevation: 3,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text("${index + 1}"), // 🏆 Position
                        ),

                        title: Text(
                          student.studentName ?? 'No Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),

                            // 📚 SUBJECTS
                            ...student.subjectsScoreTerm2.map((sub) {
                              double score = sub.scoreBOT;
                              int agg = getAggregate(score);
                              var scorename = score.toInt().toString();
                              if (score == -1) {
                                scorename = 'x';
                              }
                              return Text(
                                "${sub.subjectName}: $scorename (Agg: $agg)",
                                style: const TextStyle(fontSize: 14),
                              );
                            }),

                            const Divider(),

                            // 📊 SUMMARY
                            Text(
                              "Total: $totalBOTString   |   "
                              "Avg: $totalAvgString",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Text(
                              "Agg: ${totalAggregate(student.subjectsScoreTerm2)}   |   "
                              "Div: ${getDivision(totalAggregate(student.subjectsScoreTerm2))}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => StudentP4(
                      //       index: index,
                      //       model: widget.model,
                      //       schoolId: widget.schoolId,
                      //       studentId: student.idNin ?? '',
                      //     ),
                      //   ),
                      // );
                      // },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: 350,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5), // transparency
                borderRadius: BorderRadius.circular(20),

                // Glass border
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),

                // Optional shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FloatingActionButton(
                    child: Icon(Icons.analytics),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SubjectAnalysisTerm2(
                              schoolId: widget.schoolId,
                              model: widget.model,
                            );
                          },
                        ),
                      );
                    },
                  ),

                  FloatingActionButton(
                    child: Icon(Icons.insights),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SubjectContributionTerm2(
                              schoolId: widget.schoolId,
                              model: widget.model,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
