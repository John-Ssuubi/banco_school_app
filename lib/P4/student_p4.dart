import 'package:banco_mobile/P4/term_one.dart';
import 'package:banco_mobile/P4/term_three.dart';
import 'package:banco_mobile/P4/term_two.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';

class StudentP4 extends StatefulWidget {
  final String model;
  final String schoolId;
  const StudentP4({super.key, required this.model, required this.schoolId});

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
      TermOne(model: widget.model, schoolId: widget.schoolId),
      TermTwo(model: widget.model, schoolId: widget.schoolId),
      TermThree(model: widget.model, schoolId: widget.schoolId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        leading: InkWell(
          child: Icon(Icons.arrow_back_rounded, color: Colors.white ,),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title:  Text(
          schoolname,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: mainColor,
      ),
      body: _termPages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        
        backgroundColor: mainColor,
        unselectedItemColor: const Color.fromARGB(255, 124, 124, 124),
        selectedItemColor: Colors.white ,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school,), label: 'Term I'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Term II'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Term III'),
        ],
      ),
    );
  }
}
