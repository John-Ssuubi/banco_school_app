import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/HeadTeacher/StatTerm1/stat_ht_term1.dart';
import 'package:banco_mobile/HeadTeacher/stat_ht_term2.dart';
import 'package:banco_mobile/HeadTeacher/stat_ht_term3.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StatHt extends StatefulWidget {
  final String model;
  final String schoolId;

  const StatHt({
    super.key,
    required this.model,
    required this.schoolId,
  });

  @override
  State<StatHt> createState() => _StatHtState();
}

class _StatHtState extends State<StatHt>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  String? selectedSubject;
  List<String> subjects = [];
  bool isLoadingSubjects = true;

  @override
  void initState() {
    super.initState();
    _extractSubjects();
  }

  Future<void> _extractSubjects() async {
    if (!mounted) return;

    setState(() => isLoadingSubjects = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection(widget.model)
          .limit(1)
          .get();

      if (!mounted) return; // Prevent mutation after dispose

      if (snapshot.docs.isNotEmpty) {
        final student =
            StudentModelP4.fromJson(snapshot.docs.first.data());

        if (!mounted) return;

        setState(() {
          subjects =
              student.subjectsScore.map((s) => s.subjectName).toList();
          if (subjects.isNotEmpty) {
            selectedSubject = subjects[0];
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error extracting subjects: $e");
      }
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return;
      setState(() => isLoadingSubjects = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for keep-alive

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.indigo[700],
          elevation: 4,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Banco Primary School",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            unselectedLabelColor: Colors.grey,
            labelColor: Colors.white,
            tabs: [
              Tab(text: "Term I"),
              Tab(text: "Term II"),
              Tab(text: "Term III"),
            ],
          ),
        ),

        // KEEP TABS ALIVE (bug fix)
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatHtTermI(
              model: widget.model,
              schoolId: widget.schoolId,
            ),
            StatHtTermII(
              model: widget.model,
              schoolId: widget.schoolId,
            ),
            StatHtTermIII(
              model: widget.model,
              schoolId: widget.schoolId,
            ),
          ],
        ),
      ),
    );
  }
}
