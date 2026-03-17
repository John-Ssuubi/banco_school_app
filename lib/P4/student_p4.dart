import 'package:banco_mobile/P4/term_one.dart';
import 'package:banco_mobile/P4/term_three.dart';
import 'package:banco_mobile/P4/term_two.dart';
import 'package:banco_mobile/Parents/ChildAttendance/child_attendance.dart';
import 'package:banco_mobile/admin/student_profile_page.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';

class StudentP4 extends StatefulWidget {
  final String model;
  final String schoolId;
  final String studentId;
  final int index;
  const StudentP4({
    super.key,
    required this.model,
    required this.schoolId,
    required this.studentId,
    required this.index,
  });

  @override
  State<StudentP4> createState() => _StudentP4State();
}

class _StudentP4State extends State<StudentP4> {
  int _currentIndex = 0;
  late List<Widget> _termPages;

  @override
  void initState() {
    super.initState();

    // Initialize pages here because widget.* is available in initState
    _termPages = [
      TermOne(
        model: widget.model,
        schoolId: widget.schoolId,
        studentId: widget.studentId,
      ),
      TermTwo(
        model: widget.model,
        schoolId: widget.schoolId,
        studentId: widget.studentId,
      ),
      TermThree(
        model: widget.model,
        schoolId: widget.schoolId,
        studentId: widget.studentId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          schoolname,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
            onSelected: (value) {
              if (value == "profile") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentProfilePage(
                      // index: 0, // adjust if needed
                      schoolId: widget.schoolId,
                      studentId: widget.studentId,
                      year: DateTime.now().year.toString(),
                      classModel: widget.model,
                    ),
                  ),
                );
              }

              if (value == "attendance") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChildAttendance(
                      schoolId: widget.schoolId,
                      // model: widget.model,
                      studentId: widget.studentId,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "profile",
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text("View Student Profile"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "attendance",
                child: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 10),
                    Text("View Student Attendance"),
                  ],
                ),
              ),
            ],
          ),
        ],
        elevation: 0,
        backgroundColor: mainColor,
      ),
      body: _termPages[_currentIndex],
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
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Term I'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Term II'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Term III'),
        ],
      ),
    );
  }
}
