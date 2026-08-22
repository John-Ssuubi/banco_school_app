// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/functions.dart';
import 'package:banco_mobile/main.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherForm extends StatefulWidget {
  final String? selectedSchoolId;
  const TeacherForm({super.key, this.selectedSchoolId});

  @override
  State<TeacherForm> createState() => TeacherFormState();
}

class TeacherFormState extends State<TeacherForm> {
  List<ClassesModel> classesList = [];
  List<ClassesModel> selectedClasses = [];

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load classes when the widget is initialized
    if (widget.selectedSchoolId != null) {
      loadClassesFromSchool(widget.selectedSchoolId!);
    }
  }

  // Save teacher with linked classes
  Future<void> linkTeacherToClasses() async {
    if (widget.selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No school selected. Please go back and try again.')),
      );
      return;
    }

    if (selectedClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one class.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login again.')),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;

    final linkedClasses = selectedClasses.map((classObj) {
      return {
        "schoolId": widget.selectedSchoolId,
        "classModel": classObj.model,
        "className": classObj.className,
      };
    }).toList();

    try {
      await firestore.collection('Users').doc(user.uid).set({
        'schoolId': widget.selectedSchoolId,
        'role': 'teacher',
        'firstName': _firstNameController.text.trim(),
        'secondName': _secondNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'linkedClasses': FieldValue.arrayUnion(linkedClasses),
        'approved': 'false',
        'createdAt': FieldValue.serverTimestamp(),
        'email': user.email,
      }, SetOptions(merge: true));

      final schoolref = firestore
          .collection('Schools')
          .doc(widget.selectedSchoolId)
          .collection('staffMembers')
          .doc(user.uid);
          
      await schoolref.set({
        'role': 'teacher',
        'firstName': _firstNameController.text.trim(),
        'secondName': _secondNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': user.email,
        'teacherUid': user.uid,
      }, SetOptions(merge: true));

      await addNotification(
        user.uid,
        widget.selectedSchoolId.toString(),
        '${_firstNameController.text} ${_secondNameController.text} has registered as a Teacher to your school',
        'Please approve their account. These are the classes they want to link to: ${selectedClasses.map((e) => e.className).join(', ')}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Linked ${linkedClasses.length} class(es) successfully!',
          ),
        ),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Load all possible classes (static list)
  void loadClassesFromSchool(String schoolId) {
    final possibleCollections = [
      ClassesModel(model: 'studentModelP1', className: 'P1'),
      ClassesModel(model: 'studentModelP2', className: 'P2'),
      ClassesModel(model: 'studentModelP3', className: 'P3'),
      ClassesModel(model: 'studentModelP4', className: 'P4'),
      ClassesModel(model: 'studentModelP5', className: 'P5'),
      ClassesModel(model: 'studentModelP6', className: 'P6'),
      ClassesModel(model: 'studentModelP7', className: 'P7'),
    ];

    setState(() {
      classesList = possibleCollections;
      selectedClasses.clear();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _secondNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if school ID is provided
    if (widget.selectedSchoolId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Banco Mobile")),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "No school selected. Please go back and try again.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Banco Mobile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Name & Phone Fields ---
            TextFormField(
              controller: _firstNameController,
              decoration: customDecorationParentForm(labelText: 'First Name'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please type your first name'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _secondNameController,
              decoration: customDecorationParentForm(labelText: 'Second Name'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please type your second name'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              decoration: customDecorationParentForm(labelText: 'Phone Number'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Please type your phone number'
                  : null,
            ),

            const SizedBox(height: 20),

            // --- School Information ---
            _buildSchoolInfo(),

            const SizedBox(height: 20),

            // --- Class Selection Header ---
            Row(
              children: [
                Text(
                  "Select Classes",
                  style: TextStyle(
                    fontSize: normalFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text("Class Selection"),
                          content: const Text(
                            "Select the classes you will be teaching. "
                            "You can select multiple classes.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --- Class List ---
            if (classesList.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                constraints: const BoxConstraints(maxHeight: 450),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: classesList.length,
                  itemBuilder: (context, index) {
                    final classObj = classesList[index];
                    final isSelected = selectedClasses.contains(classObj);
                    return CheckboxListTile(
                      title: Text(classObj.className),
                      subtitle: Text(
                        'Model: ${classObj.model}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedClasses.add(classObj);
                          } else {
                            selectedClasses.remove(classObj);
                          }
                        });
                      },
                    );
                  },
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Loading classes...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            // --- Selected Classes Count ---
            if (selectedClasses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Selected: ${selectedClasses.length} class(es)',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // --- Done Button ---
            ElevatedButton(
              onPressed: (selectedClasses.isNotEmpty)
                  ? linkTeacherToClasses
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: normalFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  /// Widget to display the selected school information
  Widget _buildSchoolInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.school, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Schools')
                  .doc(widget.selectedSchoolId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading school...");
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text("School not found");
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['school_name'] ?? 'Unknown School',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (data['schoolId'] != null)
                      Text(
                        'ID: ${data['schoolId']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ClassesModel {
  final String model;
  final String className;

  ClassesModel({required this.model, required this.className});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassesModel &&
          model == other.model &&
          className == other.className;

  @override
  int get hashCode => model.hashCode ^ className.hashCode;
}