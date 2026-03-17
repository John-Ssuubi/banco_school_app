import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/PDF/pdf_term_one.dart';
import 'package:banco_mobile/division_cal.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ParentsChildProfileTerm1 extends StatefulWidget {
    final String schoolId;
  Stream<QuerySnapshot<Map<String, dynamic>>> snp;
  ParentsChildProfileTerm1({required this.snp, super.key, required this.schoolId});

  @override
  State<ParentsChildProfileTerm1> createState() => _ParentsChildProfileState();
}

class _ParentsChildProfileState extends State<ParentsChildProfileTerm1> {
   int d1Start = 0, d1End = 0;
  int d2Start = 0, d2End = 0;
  int c3Start = 0, c3End = 0;
  int c4Start = 0, c4End = 0;
  int c5Start = 0, c5End = 0;
  int c6Start = 0, c6End = 0;
  int p7Start = 0, p7End = 0;
  int p8Start = 0, p8End = 0;
  int f9Start = 0, f9End = 0;

  bool gradingLoaded = false;

Future<void> _loadGrading() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;

      d1Start = data['D1Start'];
      d1End   = data['D1End'];

      d2Start = data['D2Start'];
      d2End   = data['D2End'];

      c3Start = data['c3Start'];
      c3End   = data['c3End'];

      c4Start = data['c4Start'];
      c4End   = data['c4End'];

      c5Start = data['c5Start'];
      c5End   = data['c5End'];

      c6Start = data['c6Start'];
      c6End   = data['c6End'];

      p7Start = data['p7Start'];
      p7End   = data['p7End'];

      p8Start = data['p8Start'];
      p8End   = data['p8End'];

      f9Start = data['f9Start'];
      f9End   = data['f9End'];

      setState(() {
        gradingLoaded = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading grading: $e");
      }
    }
  }

 @override
  void initState() {
    super.initState();
    _loadGrading(); 
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //    leading: InkWell(child: Icon(Icons.arrow_back_rounded, color: Colors.white,),),
      //   backgroundColor: mainColor,
      //   title: Text(schoolname, style: TextStyle(color: Colors.white),),
      //   centerTitle: true,
      // ),
      

      body: StreamBuilder(
        stream: widget.snp,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          final studentDocs = snapshot.data!.docs;
          final students = studentDocs
              .map((doc) => StudentModelP4.fromJson(doc.data()))
              .toList();

          return PageView.builder(
            itemCount: students.length,
            itemBuilder: (context, i) {
              final student = students[i];
              final schoolId = studentDocs[i]
                  .reference
                  .parent
                  .parent
                  ?.parent
                  .parent
                  ?.id;
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
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                                  'SID: ${student.id}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white
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
                      itemCount: student.subjectsScore.length,
                      itemBuilder: (context, index) {
                        final subject = student.subjectsScore[index];

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
                                          child: Builder(
                                            builder: (context) {
                                              String score = subject.scoreBOT
                                                  .toString();
                                              if (score == '-1.0') {
                                                score = 'X';
                                              }
                                              return Text(
                                                // studentId: student.studentName!,
                                                // subjectName: subject.subjectName,
                                                // initialScore: subject.scoreBOT,
                                                // scoreKey: 'scoreBOT', time: 'BOT',
                                                score.toString(),
                                                textAlign: TextAlign.center,
                                              );
                                            },
                                          ),
                                        ),
                                        Text(
                                          divCalBOT(subject.scoreBOT, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End),
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
                                          child: Builder(
                                            builder: (context) {
                                               String score = subject.scoreMT
                                                  .toString();
                                              if (score == '-1.0') {
                                                score = 'X';
                                              }
                                              return Text(
                                                // studentId: student.studentName!,
                                                // subjectName: subject.subjectName,
                                                // initialScore: subject.scoreMT,
                                                // scoreKey: 'scoreMT', time: 'MID',
                                                score.toString(),
                                                textAlign: TextAlign.center,
                                              );
                                            }
                                          ),
                                        ),
                                        Text(
                                          divCalMid(subject.scoreMT,  d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End),
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
                                          child: Builder(
                                            builder: (context) {
                                               String score = subject.scoreEOT
                                                  .toString();
                                              if (score == '-1.0') {
                                                score = 'X';
                                              }
                                              return Text(
                                                // studentId: student.studentName!,
                                                // subjectName: subject.subjectName,
                                                // initialScore: subject.scoreEOT,
                                                // scoreKey: 'scoreEOT', time: 'END',
                                                score.toString(),
                                                textAlign: TextAlign.center,
                                              );
                                            }
                                          ),
                                        ),
                                        Text(
                                          divEND(subject.scoreEOT,d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End),
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(20),
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
                                gradeEot(student.subjectsScore, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End),
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            future: schoolId == null
                                ? null
                                : FirebaseFirestore.instance
                                    .collection('Schools')
                                    .doc(schoolId)
                                    .get(),
                            builder: (context, schoolSnapshot) {
                              if (schoolId == null) {
                                return const Icon(
                                  Icons.download_rounded,
                                  size: 30,
                                  color: Colors.grey,
                                );
                              }

                              if (schoolSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              }

                              if (!schoolSnapshot.hasData ||
                                  !schoolSnapshot.data!.exists) {
                                return const Icon(
                                  Icons.error,
                                  size: 30,
                                  color: Colors.red,
                                );
                              }

                              final data = schoolSnapshot.data!.data() ?? {};
                              final schoolName =
                                  data['school_name'] ?? 'School';
                              final contacts = data['contact'] ?? 'N/A';
                              final address = data['address'] ?? '';
                              final moto = data['moto'] ?? '';
                              final pobox = data['pobox'] ?? '';
                              final email = data['email'] ?? '';

                              return IconButton(
                                icon: const Icon(
                                  Icons.download_rounded,
                                  size: 30,
                                  color: Colors.indigo,
                                ),
                                onPressed: () async {
                                  await ReportCardPdf.generate(
                                    d1Start: d1Start,
                                    d2Start: d2Start,
                                    c3Start: c3Start,
                                    c4Start: c4Start,
                                    c5Start: c5Start,
                                    c6Start: c6Start,
                                    p7Start: p7Start,
                                    p8Start: p8Start,
                                    f9Start: f9Start,
                                    f9End: f9End,
                                    student: student,
                                    schoolName: schoolName,
                                    term: "Term I",
                                    moto: moto,
                                    address: address,
                                    contacts: contacts,
                                    pobox: pobox,
                                    email: email,
                                    year: DateTime.now().year,
                                  );
                                },
                              );
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
