import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/PDF/pdf_term_two.dart';
import 'package:banco_mobile/division_cal.dart';
import 'package:banco_mobile/editable_score_field.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TermTwo extends StatefulWidget {
  final String model;
  final String schoolId;
  final String studentId;

  const TermTwo({
    super.key,
    required this.model,
    required this.schoolId,
    required this.studentId,
  });

  @override
  State<TermTwo> createState() => _TermTwoState();
}

class _TermTwoState extends State<TermTwo> {
  late PageController _pageController;

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
    _pageController = PageController(initialPage: 0); // will update after snapshot
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Schools')
            .doc(widget.schoolId)
            .collection('Years')
            .doc(DateTime.now().year.toString())
            .collection(widget.model)
            .snapshots(), // fetch all students
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
              .map((doc) =>
                  StudentModelP4.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          // find index of student to start at
          final initialIndex =
              students.indexWhere((s) => s.idNin == widget.studentId);

          if (initialIndex != -1 && _pageController.hasClients == false) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _pageController.jumpToPage(initialIndex);
            });
          }

          return PageView.builder(
            controller: _pageController,
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
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Class: ${student.classIn}  |  Year: ${DateTime.now().year}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'SID: ${student.idNin}',
                                  style: const TextStyle(
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
                      itemCount: student.subjectsScoreTerm2.length,
                      itemBuilder: (context, index) {
                        final subject = student.subjectsScoreTerm2[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.subjectName,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // BOT
                                    Column(
                                      children: [
                                        const Text(
                                          'BOT',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 40,
                                          child: EditableScoreFieldTerm2(
                                            model: widget.model,
                                            schoolId: widget.schoolId,
                                            studentId: student.idNin!,
                                            subjectName: subject.subjectName,
                                            initialScore: subject.scoreBOT,
                                            scoreKey: 'scoreBOT',
                                            time: 'BOT',
                                          ),
                                        ),
                                        Text(divCalBOT(subject.scoreBOT, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End),
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    // MID
                                    Column(
                                      children: [
                                        const Text(
                                          'MID',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 40,
                                          child: EditableScoreFieldTerm2(
                                            model: widget.model,
                                            schoolId: widget.schoolId,
                                            studentId: student.idNin!,
                                            subjectName: subject.subjectName,
                                            initialScore: subject.scoreMT,
                                            scoreKey: 'scoreMT',
                                            time: 'MID',
                                          ),
                                        ),
                                        Text(divCalMid(subject.scoreMT, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End),
                                            style: const TextStyle(
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    // END
                                    Column(
                                      children: [
                                        const Text(
                                          'END',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          height: 40,
                                          child: EditableScoreFieldTerm2(
                                            model: widget.model,
                                            schoolId: widget.schoolId,
                                            studentId: student.idNin!,
                                            subjectName: subject.subjectName,
                                            initialScore: subject.scoreEOT,
                                            scoreKey: 'scoreEOT',
                                            time: 'END',
                                          ),
                                        ),
                                        Text(divEND(subject.scoreEOT, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End),
                                            style: const TextStyle(
                                                color: Colors.grey)),
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
                        borderRadius: BorderRadius.circular(35),
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
                                gradeEotTerm2(student.subjectsScoreTerm2, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End),
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('Schools')
                                .doc(widget.schoolId)
                                .snapshots(),
                            builder: (context, asyncSnapshot) {
                              final data = asyncSnapshot.data;
                              final schoolName = data != null
                                  ? data['school_name'] ?? 'School'
                                  : 'School';
                              final contacts = data != null
                                  ? data['contact'] ?? 'N/A'
                                  : 'N/A';
                              final address = data?['address'] ?? '';
                              final moto = data?['moto'] ?? '';
                              final pobox = data?['pobox'] ?? '';
                              final email = data?['email'] ?? '';

                              if (asyncSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (asyncSnapshot.hasError) {
                                return const Icon(Icons.error,
                                    color: Colors.red);
                              }

                              return IconButton(
                                icon: Icon(
                                  Icons.download_rounded,
                                  size: 30,
                                  color: mainColor,
                                ),
                                onPressed: () async {
                                  await ReportCardPdfTermII.generate(
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
                                    term: "Term II",
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
