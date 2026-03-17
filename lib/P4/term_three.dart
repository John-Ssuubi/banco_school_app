import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/division_cal.dart';
import 'package:banco_mobile/editable_score_field.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TermThree extends StatefulWidget {
  final String model;
  final String schoolId;
  const TermThree({super.key, required this.model, required this.schoolId});

  @override
  State<TermThree> createState() => _TermTwoState();
}

class _TermTwoState extends State<TermThree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Schools')
            .doc(widget.schoolId)
            .collection(widget.model)
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

          return PageView.builder(
            itemCount: students.length,
            itemBuilder: (context, i) {
              final student = students[i];
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // --- Header ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.studentName ?? 'No Name',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                   color: Colors.white 
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Class: ${student.classIn}  |  Year: ${DateTime.now().year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SID: ${student.idNin}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // --- Subject Cards ---
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: student.subjectsScoreTerm3.length,
                      itemBuilder: (context, index) {
                        final subject = student.subjectsScoreTerm3[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.subjectName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // --- BOT ---
                                    Column(
                                      children: [
                                        const Text(
                                          'BOT',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 40,
                                          child: EditableScoreFieldTerm3(
                                            model: widget.model,
                                            schoolId: widget.schoolId,
                                            studentId: student.idNin!,
                                            subjectName: subject.subjectName,
                                            initialScore: subject.scoreBOT,
                                            scoreKey: 'scoreBOT',
                                            time: 'BOT',
                                          ),
                                        ),
                                        Text(
                                          divCalBOT(subject.scoreBOT),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // --- MID ---
                                    Column(
                                      children: [
                                        const Text(
                                          'MID',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 40,
                                          child: EditableScoreFieldTerm3(
                                            model: widget.model   ,
                                            studentId: student.idNin!,
                                            subjectName: subject.subjectName,
                                            initialScore: subject.scoreMT,
                                            scoreKey: 'scoreMT',
                                            time: 'MID', schoolId: widget.schoolId,
                                          ),
                                        ),
                                        Text(
                                          divCalMid(subject.scoreMT),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // --- END ---
                                    Column(
                                      children: [
                                        const Text(
                                          'END',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 40,
                                          child: EditableScoreFieldTerm3(
                                            studentId: student.idNin!,
                                            subjectName: subject.subjectName,
                                            initialScore: subject.scoreEOT,
                                            scoreKey: 'scoreEOT',
                                            time: 'END', model: widget.model, schoolId: widget.schoolId,
                                          ),
                                        ),
                                        Text(
                                          divEND(subject.scoreEOT),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // --- Footer Row ---
                    Container(
                      height: 75,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      margin: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Aggregate: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                gradeEotTerm3(student.subjectsScoreTerm3),
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon:  Icon(
                              Icons.download_rounded,
                              size: 30,
                              color: mainColor
                            ),
                            onPressed: () {
                              // TODO: Implement download
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}