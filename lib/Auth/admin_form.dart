// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/functions.dart';
import 'package:banco_mobile/main.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminForm extends StatefulWidget {
  const AdminForm({super.key});

  @override
  State<AdminForm> createState() => _AdminFormState();
}

class _AdminFormState extends State<AdminForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? selectedSchoolId;
  bool isSaving = false;

  /// Static list of ALL classes for Head Teacher
  List<Map<String, dynamic>> _buildLinkedClasses(String schoolId) {
    return [
      {'schoolId': schoolId, 'classModel': 'studentModelP1', 'className': 'P1'},
      {'schoolId': schoolId, 'classModel': 'studentModelP2', 'className': 'P2'},
      {'schoolId': schoolId, 'classModel': 'studentModelP3', 'className': 'P3'},
      {'schoolId': schoolId, 'classModel': 'studentModelP4', 'className': 'P4'},
      {'schoolId': schoolId, 'classModel': 'studentModelP5', 'className': 'P5'},
      {'schoolId': schoolId, 'classModel': 'studentModelP6', 'className': 'P6'},
      {'schoolId': schoolId, 'classModel': 'studentModelP7', 'className': 'P7'},
    ];
  }

Future<String?> showInfoDialog(BuildContext context, String title) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // return message
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedSchoolId == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('Users').doc(user.uid).set({
        'role': 'admin',
        'firstName': _firstNameController.text.trim(),
        'secondName': _secondNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'schoolId': selectedSchoolId,
        'linkedClasses': _buildLinkedClasses(selectedSchoolId!),
        'approved': 'false',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await addNotification(
        user.uid,
        selectedSchoolId!,
        '${_firstNameController.text} ${_secondNameController.text} registered as Admin',
        'Please approve their account. All classes were assigned automatically.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Admin registered successfully')),
      );

      final schoolref = firestore.collection('Schools').doc(selectedSchoolId).collection('staffMembers').doc(user.uid);

      await schoolref.set({
        // 'staffMembers': {
         
            'role': 'admin',
            'firstName': _firstNameController.text.trim(),
            'secondName': _secondNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': user.email,
            'teacherUid': user.uid, 
          
        // },
      }, SetOptions(merge: true));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()),
        (_) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error')));
    } finally {
      setState(() => isSaving = false);
    }
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
    return Scaffold(
      appBar: AppBar(title: const Text("Banco Mobile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// First Name
              TextFormField(
                controller: _firstNameController,
                decoration: customDecorationParentForm(labelText: 'First Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'First name required' : null,
              ),
              const SizedBox(height: 10),

              /// Second Name
              TextFormField(
                controller: _secondNameController,
                decoration: customDecorationParentForm(
                  labelText: 'Second Name',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Second name required' : null,
              ),
              const SizedBox(height: 10),

              /// Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: customDecorationParentForm(
                  labelText: 'Phone Number',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Phone number required' : null,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    "Choose the School",
                    style: TextStyle(
                      fontSize: normalFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      showInfoDialog(
                        context,
                        'Can\'t find your school? Contact support to register. 0707477946 / 0757999413',
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

              /// School Dropdown
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Schools')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return DropdownButtonFormField<String>(
                    initialValue: selectedSchoolId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select School',
                    ),
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc['schoolId']),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedSchoolId = value),
                    validator: (v) =>
                        v == null ? 'Please select a school' : null,
                  );
                },
              ),

              const SizedBox(height: 25),

              /// Submit Button
              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Done',
                          style: TextStyle(fontSize: normalFontSize),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
