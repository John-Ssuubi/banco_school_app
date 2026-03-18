import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/P4/student_p4.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassAssessment extends StatefulWidget {
  final String model;
  final String schoolId;

  const ClassAssessment({super.key, required this.model, required this.schoolId});

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
                  .collection(widget.model).orderBy('studentName')
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

                if (filteredStudents.isEmpty) {
                  return const Center(child: Text("No matching students."));
                }

                return ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];

                    return Card(
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
                                index: index,
                                model: widget.model,
                                schoolId: widget.schoolId,
                                studentId: student.idNin ?? '',
                              ),
                            ),
                          );
                        },
                      ),
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
