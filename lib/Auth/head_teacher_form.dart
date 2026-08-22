// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/functions.dart';
import 'package:banco_mobile/main.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HeadTeacherForm extends StatefulWidget {
  final String? selectedSchoolId;
  const HeadTeacherForm({super.key, this.selectedSchoolId});

  @override
  State<HeadTeacherForm> createState() => _HeadTeacherFormState();
}

class _HeadTeacherFormState extends State<HeadTeacherForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.selectedSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No school selected. Please go back and try again.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('Users').doc(user.uid).set({
        'role': 'headteacher',
        'firstName': _firstNameController.text.trim(),
        'secondName': _secondNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'schoolId': widget.selectedSchoolId,
        'linkedClasses': _buildLinkedClasses(widget.selectedSchoolId!),
        'approved': 'false',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await addNotification(
        user.uid,
        widget.selectedSchoolId!,
        '${_firstNameController.text} ${_secondNameController.text} registered as Head Teacher',
        'Please approve their account. All classes were assigned automatically.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Head Teacher registered successfully')),
      );

      final schoolref = firestore
          .collection('Schools')
          .doc(widget.selectedSchoolId)
          .collection('staffMembers')
          .doc(user.uid);

      await schoolref.set({
        'role': 'headteacher',
        'firstName': _firstNameController.text.trim(),
        'secondName': _secondNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': user.email,
        'teacherUid': user.uid,
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
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
                    "School Information",
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

              const SizedBox(height: 10),

              /// School Info Display (Read-only)
              _buildSchoolInfo(),

              const SizedBox(height: 25),

              /// Submit Button
              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Done',
                          style: TextStyle(
                            fontSize: normalFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
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