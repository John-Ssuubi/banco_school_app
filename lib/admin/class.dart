import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/admin/student_profile_page.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminClass extends StatefulWidget {
  final String model;
  final String schoolId;

  const AdminClass({
    super.key,
    required this.model,
    required this.schoolId,
  });

  @override
  State<AdminClass> createState() => _AdminClassState();
}

class _AdminClassState extends State<AdminClass> {
  String currentYear = DateTime.now().year.toString();

  final TextEditingController _searchController =
      TextEditingController();

  String searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.arrow_back_outlined,
              color: Colors.white),
          onTap: () => Navigator.pop(context),
        ),
        backgroundColor: mainColor,
        title: Text(schoolname, style: whiteText),
      ),

      body: Column(
        children: [

          /// 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search student...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchText = "";
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
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          /// 📄 Student List
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Schools')
                  .doc(widget.schoolId)
                  .collection('Years')
                  .doc(currentYear)
                  .collection(widget.model)
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No students found.'));
                }

                final students = snapshot.data!.docs
                    .map((doc) =>
                        StudentModelP4.fromJson(doc.data()))
                    .toList();

                /// 🔍 Filter Students
                final filteredStudents = students.where((student) {
                  final name =
                      student.studentName?.toLowerCase() ?? "";
                  return name.contains(searchText);
                }).toList();

                if (filteredStudents.isEmpty) {
                  return const Center(
                      child: Text("No matching students"));
                }

                return ListView.builder(
                  itemCount: filteredStudents.length,

                  itemBuilder: (context, index) {

                    final student = filteredStudents[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),

                        title: Text(
                            student.studentName ?? 'No Name'),

                        subtitle: Text(
                            'Class: ${student.classIn ?? 'Unknown'}'),

                        onTap: () {
                          if (kDebugMode) {
                            print('Tapped on ${student.idNin}');
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentProfilePage(
                                schoolId: widget.schoolId,
                                studentId:
                                    student.idNin ?? '',
                                year: currentYear,
                                classModel: widget.model,
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