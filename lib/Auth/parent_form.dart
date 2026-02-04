// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/functions.dart';
import 'package:banco_mobile/main.dart';
import 'package:banco_mobile/parentFcmToken.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentForm extends StatefulWidget {
  const ParentForm({super.key});

  @override
  State<ParentForm> createState() => _ParentFormState();
}

class _ParentFormState extends State<ParentForm> {
  List<Map<String, dynamic>> studentList = [];
  List<String> selectedChildren = [];
  String? selectedSchoolId;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();

  Future<void> linkParentToChildren() async {
    // if (!_formKey.currentState!.validate()) {
      // Form is not valid
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    final linkedChildren = selectedChildren.map((id) {
      final student = studentList.firstWhere((s) => s['id'] == id);
      return {
        "schoolId": selectedSchoolId,
        "studentId": id,
        "studentName": student['name'],
      };
    }).toList();

    
    
    await firestore.collection('Users').doc(user!.uid).set({
      'role': 'parent',
      'firstName': _firstNameController.text.trim(),
      'secondName': _secondNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'linkedChildren': FieldValue.arrayUnion(linkedChildren),
      'approved': 'false', // false true pending

    }, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Linked ${linkedChildren.length} child(ren)')),
    );  
  addNotification(user.uid, selectedSchoolId.toString(), 
  '${_firstNameController.text} ${_secondNameController.text} has registed as a parent to you school', 
  'Please aprrove their account. These are the students they want to link to: ${linkedChildren.map((e) => e['studentName']).join(', ')} ');
  setupFcm();
Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const MyApp()),
      (route) => false, // remove all previous routes
    );
    // }
  }

  Future<void> loadStudentsFromSchool(String schoolId) async {
  final firestore = FirebaseFirestore.instance;
  final possibleCollections = [
    'studentModelP1',
    'studentModelP2',
    'studentModelP3',
    'studentModelP4',
    'studentModelP5',
    'studentModelP6',
    'studentModelP7',
  ];

  List<Map<String, dynamic>> allStudents = [];

  for (final col in possibleCollections) {
    final snapshot = await firestore
        .collection('Schools')
        .doc(schoolId)
        .collection(col)
        .get();

    for (var doc in snapshot.docs) {
      allStudents.add({
        'id': doc.id,
        'name': doc['studentName'],
        'classIn': doc['classIn'],
      });
    }
  }

  setState(() {
    studentList = allStudents;
    selectedChildren.clear();
  });
}


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Banco Mobile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
           
            TextFormField(
                  controller: _firstNameController,

                  decoration: customDecorationParentForm(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Type Your First Name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _secondNameController,

                  decoration: customDecorationParentForm(labelText: 'Second Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Type Your Second Name';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,

                  decoration: customDecorationParentForm(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Type Your Second Name';
                    }
                    return null;
                  },
                ),

            const SizedBox(height: 10),
            Text(
              "Choose the School",
              style: TextStyle(
                fontSize: normalFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // --- School Dropdown ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Schools')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text('Error loading schools');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No schools found');
                }

                final schools = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Select School"),
                    value: selectedSchoolId,
                    items: schools.map((school) {
                      return DropdownMenuItem<String>(
                        value: school.id,
                        child: Text(
                          school['school_name'], // ⚠️ check field name
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedSchoolId = value);
                        loadStudentsFromSchool(value);
                      }
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // --- Students List ---
            // if (studentList.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 450),
              color: Colors.amber[50],
              child: ListView.builder(
                itemCount: studentList.length,
                itemBuilder: (context, index) {
                  final student = studentList[index];
                  final isSelected = selectedChildren.contains(student['id']);
                  if (studentList.isEmpty) {
                    return const Center(
                      child: Text('No students found for this school'),
                    );
                  } else {
                    return CheckboxListTile(
                      title: Text("${student['name']} (${student['classIn']})"),
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedChildren.add(student['id']);
                          } else {
                            selectedChildren.remove(student['id']);
                          }
                        });
                      },
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // --- Done Button ---
            ElevatedButton(
              onPressed:
                  (selectedSchoolId != null && selectedChildren.isNotEmpty)
                  ? () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => SelectStudentParent(
                      //       // schoolId: selectedSchoolId!,
                      //       // selectedChildren: selectedChildren,
                      //     ),
                      //   ),
                      // );
                        linkParentToChildren();
                    }
                  : null, // disabled if no school or student selected
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Done', style: TextStyle(fontSize: normalFontSize)),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
