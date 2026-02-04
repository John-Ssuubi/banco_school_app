// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/functions.dart';
import 'package:banco_mobile/main.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HeadTeacherForm extends StatefulWidget {
  const HeadTeacherForm({super.key});

  @override
  State<HeadTeacherForm> createState() => HeadTeacherFormState();
}

class HeadTeacherFormState extends State<HeadTeacherForm> {
  List<ClassesModel> classesList = [];
  List<ClassesModel> selectedClasses = [];
  String? selectedSchoolId;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Save teacher with linked classes
  Future<void> linkTeacherToClasses() async {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  // Automatically assign ALL classes
  final linkedClasses = [
    {"schoolId": selectedSchoolId, "classModel": "studentModelP1", "className": "P1"},
    {"schoolId": selectedSchoolId, "classModel": "studentModelP2", "className": "P2"},
    {"schoolId": selectedSchoolId, "classModel": "studentModelP3", "className": "P3"},
    {"schoolId": selectedSchoolId, "classModel": "studentModelP4", "className": "P4"},
    {"schoolId": selectedSchoolId, "classModel": "studentModelP5", "className": "P5"},
    {"schoolId": selectedSchoolId, "classModel": "studentModelP6", "className": "P6"},
    {"schoolId": selectedSchoolId, "classModel": "studentModelP7", "className": "P7"},
  ];

  await firestore.collection('Users').doc(user!.uid).set({
    'role': 'headteacher',
    'firstName': _firstNameController.text.trim(),
    'secondName': _secondNameController.text.trim(),
    'phone': _phoneController.text.trim(),
    'linkedClasses': linkedClasses,
    'approved': 'false',
  }, SetOptions(merge: true));

  addNotification(
    user.uid,
    selectedSchoolId!,
    '${_firstNameController.text} ${_secondNameController.text} registered as a Head Teacher.',
    'Please approve their account. They are assigned ALL classes automatically.'
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('✅ Assigned all classes automatically!')),
  );

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const MyApp()),
    (route) => false,
  );
}


  // Load all possible classes (static list)
  // Future<void> loadClassesFromSchool(String schoolId) async {
  //   final possibleCollections = [
  //     ClassesModel(model: 'studentModelP1', className: 'P1'),
  //     ClassesModel(model: 'studentModelP2', className: 'P2'),
  //     ClassesModel(model: 'studentModelP3', className: 'P3'),
  //     ClassesModel(model: 'studentModelP4', className: 'P4'),
  //     ClassesModel(model: 'studentModelP5', className: 'P5'),
  //     ClassesModel(model: 'studentModelP6', className: 'P6'),
  //     ClassesModel(model: 'studentModelP7', className: 'P7'),
  //   ];

  //   setState(() {
  //     classesList = possibleCollections;
  //     selectedClasses.clear();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Banco Mobile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Name & Phone Fields ---
            TextFormField(
              controller: _firstNameController,
              decoration: customDecorationParentForm(labelText: 'First Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please type your first name' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _secondNameController,
              decoration: customDecorationParentForm(labelText: 'Second Name'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please type your second name' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              decoration: customDecorationParentForm(labelText: 'Phone Number'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please type your phone number' : null,
            ),

            const SizedBox(height: 20),
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
              stream: FirebaseFirestore.instance.collection('Schools').snapshots(),
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

                return DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Select School"),
                  value: selectedSchoolId,
                  items: schools.map((school) {
                    return DropdownMenuItem<String>(
                      value: school.id,
                      child: Text(school['school_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedSchoolId = value);
                      // loadClassesFromSchool(value);
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // --- Class List ---
            

            const SizedBox(height: 20),

            // --- Done Button ---
            ElevatedButton(
              onPressed: (selectedSchoolId != null)
                  ? linkTeacherToClasses
                  : null,
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

class ClassesModel {
  final String model;
  final String className;

  ClassesModel({required this.model, required this.className});

  // ✅ Override equality to allow proper list comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassesModel && model == other.model && className == other.className;

  @override
  int get hashCode => model.hashCode ^ className.hashCode;
}
