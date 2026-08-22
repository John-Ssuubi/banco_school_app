// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/functions.dart';
import 'package:banco_mobile/main.dart';
import 'package:banco_mobile/parentFcmToken.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentForm extends StatefulWidget {
  final String? selectedSchoolId;

  const ParentForm({super.key,required this.selectedSchoolId});

  @override
  State<ParentForm> createState() => _ParentFormState();
}

class _ParentFormState extends State<ParentForm> {
  final _formKey = GlobalKey<FormState>();

  // State
  List<Map<String, dynamic>> _studentList = [];
  List<Map<String, dynamic>> _filteredStudentList = [];
  final List<String> _selectedChildrenIds = [];
  
  bool _isSubmitting = false;
  bool _isLoadingStudents = false;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _addressController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load students when the widget is initialized
    if (widget.selectedSchoolId != null) {
      _loadStudents(widget.selectedSchoolId!);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    _searchController.dispose();
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

    if (_selectedChildrenIds.isEmpty || widget.selectedSchoolId == null) {
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
          .doc(widget.selectedSchoolId)
          .get();

      final schoolName = schoolDoc.data()?['school_name'] ?? 'Unknown School';

      /* ---------- PREPARE CHILDREN ---------- */

      final linkedChildren = _selectedChildrenIds.map((id) {
        final student = _studentList.firstWhere(
          (s) => s['id'] == id,
          orElse: () => {'id': id, 'name': 'Unknown'},
        );

        return {
          'schoolId': widget.selectedSchoolId,
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
        'schoolId': widget.selectedSchoolId,
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
        widget.selectedSchoolId!,
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
        _filteredStudentList = allStudents;
        _selectedChildrenIds.clear();
      });
    } finally {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  /* ---------------- SEARCH FUNCTION ---------------- */

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudentList = _studentList;
      } else {
        _filteredStudentList = _studentList.where((student) {
          final name = student['name'].toString().toLowerCase();
          final classIn = student['classIn'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || classIn.contains(searchLower);
        }).toList();
      }
    });
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    // Check if school ID is provided
    if (widget.selectedSchoolId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Parent Registration"),
          centerTitle: true,
        ),
        body: const Center(
          child: Text("No school selected. Please go back and try again."),
        ),
      );
    }

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

              _buildSchoolInfo(),

              const SizedBox(height: 20),

              _buildStudentList(),

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
                return Text(
                  data['school_name'] ?? 'Unknown School',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                );
              },
            ),
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.group_add),
                SizedBox(width: 12),
                Text(
                  "Select Your Child(ren)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),

          // Search Bar
          if (_studentList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _filterStudents,
                decoration: InputDecoration(
                  hintText: 'Search by name or class...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterStudents('');
                          },
                        )
                      : null,
                ),
              ),
            ),

          const Divider(height: 1),

          if (_filteredStudentList.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    _studentList.isEmpty ? "No students found" : "No matching students",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),

              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredStudentList.length,

                itemBuilder: (context, index) {
                  final student = _filteredStudentList[index];

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

          // Show count of selected students
          if (_selectedChildrenIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Selected: ${_selectedChildrenIds.length} student(s)',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                ),
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