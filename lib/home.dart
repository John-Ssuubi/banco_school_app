// ignore_for_file: avoid_unnecessary_containers

import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/P4/student_p4.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final String model;
  final String schoolId;
  const HomePage({super.key, required this.model, required this.schoolId});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Stream<List<StudentModelP4>> getP4StudentsStream() {
//   return FirebaseFirestore.instance
//       .collection(widget.model) // Firestore collection
//       .snapshots()
//       .map(
//         (snapshot) => snapshot.docs
//             .map((doc) => StudentModelP4.fromJson(doc.data()))
//             .toList(),
//       );
// }

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Banco Mobile'),
      ),
       
      body: Column(
        children: [
         
          Expanded(
            child: Container(
              // color: Colors.blue[50],
              child: StreamBuilder(
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
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No students found.'));
                  }

                  final students = snapshot.data!.docs
                      .map((doc) => StudentModelP4.fromJson(doc.data()))
                      .toList();
                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Card(
                        child: InkWell(
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(student.studentName ?? 'No Name'),
                            subtitle: Text(
                              'Class: ${student.classIn ?? 'Unknown'}',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentP4(
                                    model: widget.model, 
                                    schoolId: widget.schoolId,
                                    // studentName: student.studentName,
                                    // classIn: student.classIn,
                                    // sid: student.id.toString(),
                                    // student: student,
                                    // students: students,
                                    // scoreTerm1: student.subjectsScore,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
