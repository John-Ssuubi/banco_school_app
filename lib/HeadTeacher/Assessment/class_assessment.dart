import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
// import 'package:banco_mobile/P4/student_p4.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassAssessment extends StatefulWidget {
  final String model;
  final String schoolId;

  const ClassAssessment({
    super.key,
    required this.model,
    required this.schoolId,
  });

  @override
  State<ClassAssessment> createState() => _ClassAssessmentState();
}

class _ClassAssessmentState extends State<ClassAssessment> {
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

  // Division
  String getDivision(int agg) {
    if (agg <= 12) return "Division 1";
    if (agg <= 24) return "Division 2";
    if (agg <= 32) return "Division 3";
    return "Division 4";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onTap: () => Navigator.pop(context),
        ),
        backgroundColor: mainColor,
        title: Text(schoolname, style: whiteText),
      ),
      body: Column(
        children: [
          // 🔎 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search student...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = "";
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
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
                    a.subjectsScore,
                  ).compareTo(totalAggregate(b.subjectsScore)),
                );

                if (filteredStudents.isEmpty) {
                  return const Center(child: Text("No matching students."));
                }

                return ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];

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
                            ...student.subjectsScore.map((sub) {
                              double score = sub.scoreBOT ?? 0;
                              int agg = getAggregate(score);

                              return Text(
                                "${sub.subjectName}: ${score.toInt()} (Agg: $agg)",
                                style: const TextStyle(fontSize: 14),
                              );
                            }).toList(),

                            const Divider(),

                            // 📊 SUMMARY
                            Text(
                              "Total: ${totalBOT(student.subjectsScore).toInt()}   |   "
                              "Avg: ${averageScore(student.subjectsScore).toStringAsFixed(1)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            Text(
                              "Agg: ${totalAggregate(student.subjectsScore)}   |   "
                              "Div: ${getDivision(totalAggregate(student.subjectsScore))}",
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
    );
  }
}
