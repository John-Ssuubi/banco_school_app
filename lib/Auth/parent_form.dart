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
  final _formKey = GlobalKey<FormState>();

  // State
  List<Map<String, dynamic>> _studentList = [];
  final List<String> _selectedChildrenIds = [];
  String? _selectedSchoolId;

  bool _isSubmitting = false;
  bool _isLoadingStudents = false;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /* ---------------- ERROR UI ---------------- */

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /* ---------------- CHECK STUDENT ---------------- */

  Future<bool> _isStudentAlreadyLinked(String studentId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('linkedStudentIds', arrayContains: studentId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /* ---------------- SUBMIT ---------------- */

  Future<void> _handleSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedChildrenIds.isEmpty || _selectedSchoolId == null) {
      _showError("Please select at least one student");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showError("Session expired. Please login again.");
        setState(() => _isSubmitting = false);
        return;
      }

      final firestore = FirebaseFirestore.instance;

      /* ---------- CHECK STUDENT LINKS ---------- */

      for (final id in _selectedChildrenIds) {
        final linked = await _isStudentAlreadyLinked(id);

        if (linked) {
          _showError(
            "One of the selected students is already registered with another parent.",
          );

          setState(() => _isSubmitting = false);
          return;
        }
      }

      /* ---------- GET SCHOOL NAME ---------- */

      final schoolDoc = await firestore
          .collection('Schools')
          .doc(_selectedSchoolId)
          .get();

      final schoolName = schoolDoc.data()?['school_name'] ?? 'Unknown School';

      /* ---------- PREPARE CHILDREN ---------- */

      final linkedChildren = _selectedChildrenIds.map((id) {
        final student = _studentList.firstWhere(
          (s) => s['id'] == id,
          orElse: () => {'id': id, 'name': 'Unknown'},
        );

        return {
          'schoolId': _selectedSchoolId,
          'studentId': student['id'],
          'studentName': student['name'],
          'schoolName': schoolName,
        };
      }).toList();

      /* ---------- SAVE PROFILE ---------- */

      await firestore.collection('Users').doc(user.uid).set({
        'role': 'parent',
        'firstName': _firstNameController.text.trim(),
        'secondName': _lastNameController.text.trim(),
        'relation': _relationController.text.trim(),
        'address': _addressController.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'schoolId': _selectedSchoolId,
        'phone': _phoneController.text.trim(),

        // IMPORTANT
        'linkedChildren': linkedChildren,
        'linkedStudentIds': _selectedChildrenIds,

        'approved': false,
        'accessResults': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      /* ---------- FCM ---------- */

      await setupFcmForm(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        
      );

      /* ---------- NOTIFY ADMIN ---------- */

      await addNotification(
        user.uid,
        _selectedSchoolId!,
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()} has registered as a parent.',
        'Requested access for: '
            '${linkedChildren.map((e) => e['studentName']).join(', ')}',
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MyApp()),
        (_) => false,
      );
    } catch (e) {
      _showError("Error:");
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /* ---------------- LOAD STUDENTS ---------------- */

  Future<void> _loadStudents(String schoolId) async {
    setState(() => _isLoadingStudents = true);

    final firestore = FirebaseFirestore.instance;
    final collections = List.generate(7, (i) => 'studentModelP${i + 1}');

    try {
      final futures = collections.map((col) {
        return firestore
            .collection('Schools')
            .doc(schoolId)
            .collection('Years')
            .doc(DateTime.now().year.toString())
            .collection(col)
            .get();
      });

      final snapshots = await Future.wait(futures);

      List<Map<String, dynamic>> allStudents = [];

      for (var snapshot in snapshots) {
        for (var doc in snapshot.docs) {
          allStudents.add({
            'id': doc.id,
            'name': doc['studentName'] ?? 'Unknown',
            'classIn': doc['classIn'] ?? '',
          });
        }
      }

      setState(() {
        _studentList = allStudents;
        _selectedChildrenIds.clear();
      });
    } finally {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parent Registration"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _buildSectionHeader("Personal Information"),

              _buildTextField(_firstNameController, "First Name"),
              _buildTextField(_lastNameController, "Second Name"),
              _buildTextField(_phoneController, "Phone Number", isPhone: true),
              _buildTextField(_relationController, "Relationship to Student"),
              _buildTextField(_addressController, "Residential Address"),
              _buildTextField(_nationalityController, "Nationality"),

              const SizedBox(height: 30),

              _buildSectionHeaderSchoolName("School & Student Link"),

              _buildSchoolDropdown(),

              if (_selectedSchoolId != null) ...[
                const SizedBox(height: 20),
                _buildStudentList(),
              ],

              const SizedBox(height: 40),

              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /* ---------------- WIDGETS ---------------- */

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildSectionHeaderSchoolName(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),

      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) {
                  return const AlertDialog(
                    content: Text(
                      "Can't find your school?\n"
                      "Contact support:\n"
                      "0707477946 / 0757999413",
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.info_outline, size: 20, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: TextFormField(
        controller: controller,

        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,

        decoration: customDecorationParentForm(labelText: label),

        validator: (value) =>
            (value == null || value.isEmpty) ? 'Required field' : null,
      ),
    );
  }

  Widget _buildSchoolDropdown() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Schools')
        .snapshots(),

    builder: (context, snapshot) {
      if (snapshot.connectionState ==
          ConnectionState.waiting) {
        return const LinearProgressIndicator();
      }

      if (!snapshot.hasData ||
          snapshot.data!.docs.isEmpty) {
        return const Text("No schools found");
      }

      final docs = snapshot.data!.docs;

      // Validate selected value
      final validValue = docs.any(
        (d) => d.id == _selectedSchoolId,
      )
          ? _selectedSchoolId
          : null;

      return DropdownButtonFormField<String>(
        decoration: customDecorationParentForm(
          labelText: "Select School",
        ),

        initialValue: validValue,

        validator: (value) =>
            value == null ? "Select a school" : null,

        items: docs.map((doc) {
          final name = doc.data() as Map<String, dynamic>;

          return DropdownMenuItem<String>(
            value: doc.id,
            child: Text(
              name['school_name'] ??
                  doc.id, // fallback
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),

        onChanged: (val) {
          if (val == null) return;

          setState(() {
            _selectedSchoolId = val;
            _studentList.clear();
            _selectedChildrenIds.clear();
          });

          _loadStudents(val);
        },
      );
    },
  );
}


  Widget _buildStudentList() {
    if (_isLoadingStudents) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),

      child: Column(
        children: [
          const ListTile(
            title: Text(
              "Select Your Child(ren)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.group_add),
          ),

          const Divider(height: 1),

          if (_studentList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("No students found"),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),

              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _studentList.length,

                itemBuilder: (context, index) {
                  final student = _studentList[index];

                  final isSelected = _selectedChildrenIds.contains(
                    student['id'],
                  );

                  return CheckboxListTile(
                    title: Text(student['name']),
                    subtitle: Text("Class: ${student['classIn']}"),

                    value: isSelected,

                    onChanged: (bool? selected) {
                      setState(() {
                        selected == true
                            ? _selectedChildrenIds.add(student['id'])
                            : _selectedChildrenIds.remove(student['id']);
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmission,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Register & Link Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
