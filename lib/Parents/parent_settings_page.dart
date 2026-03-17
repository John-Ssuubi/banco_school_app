// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/parentFcmToken.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentEditProfilePage extends StatefulWidget {
  const ParentEditProfilePage({super.key});

  @override
  State<ParentEditProfilePage> createState() =>
      _ParentEditProfilePageState();
}

class _ParentEditProfilePageState
    extends State<ParentEditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // State
  List<Map<String, dynamic>> _studentList = [];
  final List<String> _selectedChildrenIds = [];

  String? _selectedSchoolId;

  bool _isSaving = false;
  bool _isLoadingStudents = false;
  bool _isLoadingProfile = true;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

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

  /* ---------------- LOAD PROFILE ---------------- */

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    _firstNameController.text = data['firstName'] ?? '';
    _lastNameController.text = data['secondName'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _relationController.text = data['relation'] ?? '';
    _addressController.text = data['address'] ?? '';
    _nationalityController.text = data['nationality'] ?? '';

    _selectedSchoolId = data['schoolId'];

    final children = data['linkedChildren'] ?? [];

    for (var c in children) {
      _selectedChildrenIds.add(c['studentId']);
    }

    if (_selectedSchoolId != null) {
      await _loadStudents(_selectedSchoolId!);
    }

    if (mounted) {
      setState(() => _isLoadingProfile = false);
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

      for (var snap in snapshots) {
        for (var doc in snap.docs) {
          allStudents.add({
            'id': doc.id,
            'name': doc['studentName'] ?? '',
            'classIn': doc['classIn'] ?? '',
          });
        }
      }

      setState(() => _studentList = allStudents);
    } finally {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  /* ---------------- SAVE ---------------- */

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedChildrenIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one student')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final firestore = FirebaseFirestore.instance;

      final schoolDoc = await firestore
          .collection('Schools')
          .doc(_selectedSchoolId)
          .get();

      final schoolName =
          schoolDoc.data()?['school_name'] ?? 'Unknown School';

      final linkedChildren = _selectedChildrenIds.map((id) {
        final student = _studentList.firstWhere(
          (s) => s['id'] == id,
        );

        return {
          'schoolId': _selectedSchoolId,
          'studentId': student['id'],
          'studentName': student['name'],
          'schoolName': schoolName,
        };
      }).toList();

      await firestore.collection('Users').doc(user.uid).update({
        'firstName': _firstNameController.text.trim(),
        'secondName': _lastNameController.text.trim(),
        'relation': _relationController.text.trim(),
        'address': _addressController.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'phone': _phoneController.text.trim(),
        // 'accessResults': true,
        'approved': false,
        'linkedChildren': linkedChildren,
      });

      await setupFcmForm(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        // linkedChildren,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    _section("Personal Information"),

                    _field(_firstNameController, "First Name"),
                    _field(_lastNameController, "Second Name"),
                    _field(_phoneController, "Phone", isPhone: true),
                    _field(_relationController, "Relation"),
                    _field(_addressController, "Address"),
                    _field(_nationalityController, "Nationality"),

                    const SizedBox(height: 30),

                    _section("Linked Students"),

                    _studentListWidget(),

                    const SizedBox(height: 40),

                    _saveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: c,
        keyboardType:
            isPhone ? TextInputType.phone : TextInputType.text,
        decoration: customDecorationParentForm(labelText: label),
        validator: (v) =>
            v == null || v.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _studentListWidget() {
    if (_isLoadingStudents) {
      return const CircularProgressIndicator();
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
            title: Text("Select Your Children",
                style: TextStyle(fontWeight: FontWeight.bold)),
            leading: Icon(Icons.group),
          ),

          const Divider(),

          SizedBox(
            height: 280,
            child: ListView.builder(
              itemCount: _studentList.length,
              itemBuilder: (c, i) {
                final s = _studentList[i];

                final selected =
                    _selectedChildrenIds.contains(s['id']);

                return CheckboxListTile(
                  title: Text(s['name']),
                  subtitle: Text("Class: ${s['classIn']}"),
                  value: selected,
                  onChanged: (v) {
                    setState(() {
                      v == true
                          ? _selectedChildrenIds.add(s['id'])
                          : _selectedChildrenIds.remove(s['id']);
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

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Save Changes",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
