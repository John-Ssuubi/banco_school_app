import 'package:banco_mobile/HeadTeacher/AssessmentTerm1/TermSections.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';

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
  final String currentYear = DateTime.now().year.toString();
  final TextEditingController searchController = TextEditingController();

  int _currentIndex = 0;

  // FIX: pages built once in initState so widget.* is safely available.
  late final List<Widget> _termPages;

  @override
  void initState() {
    super.initState();
    _termPages = [
      TermBot(model: widget.model, schoolId: widget.schoolId),
      TermMid(model: widget.model, schoolId: widget.schoolId),
      TermEnd(model: widget.model, schoolId: widget.schoolId),
    ];
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Removed DefaultTabController — it was unused and conflicted with
    // the manual BottomNavigationBar index.
    // FIX: IndexedStack keeps pages alive when switching tabs so they don't
    // reload Firestore data on every tap.
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _termPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: mainColor,
        unselectedItemColor: const Color.fromARGB(255, 124, 124, 124),
        selectedItemColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'BOT'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'MID'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'END'),
        ],
      ),
    );
  }

  
}