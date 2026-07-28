// ignore_for_file: deprecated_member_use

import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/DataBase/P4/Term%20I/p4_database.dart';
import 'package:banco_mobile/DataBase/P4/Term%20II/p4_database_term2.dart';
import 'package:banco_mobile/DataBase/P4/Term%20III/p4_database_term3.dart';
import 'package:banco_mobile/generate_unique_id.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AddStudent extends StatefulWidget {
  final String model;
  final String schoolId;
  const AddStudent({super.key, required this.model, required this.schoolId});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  final String currentYear = DateTime.now().year.toString();

  // Controllers
  final _nameController = TextEditingController();
  final _streamController = TextEditingController();
  final _contactController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _emisController = TextEditingController();
  final _nextOfKinNameController = TextEditingController();
  final _nextOfKinContactController = TextEditingController();
  final _nextOfKinEmailController = TextEditingController();
  final _nextOfKinIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _streamController.dispose();
    _contactController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _emisController.dispose();
    _nextOfKinNameController.dispose();
    _nextOfKinContactController.dispose();
    _nextOfKinEmailController.dispose();
    _nextOfKinIdController.dispose();
    super.dispose();
  }



  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final collectionRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(currentYear)
          .collection(widget.model);

      final countSnap = await collectionRef.get();
      final idNin = generateUniqueStudentId(widget.model, countSnap.docs.map((doc) => doc['idNin']).toSet());
      final now = DateTime.now().toIso8601String();

      final Map<String, dynamic> studentData = {
        'studentName': _nameController.text.trim(),
        'classIn': widget.model.substring(widget.model.length - 2),
        'stream': _streamController.text.trim().isEmpty ? 'A' : _streamController.text.trim().toUpperCase(),
        'contactNumber': _contactController.text.trim().isEmpty ? 'Not Given' : _contactController.text.trim(),
        'birthDate': _birthDateController.text.trim().isEmpty ? 'Not given' : _birthDateController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? 'Not given' : _addressController.text.trim(),
        'nationality': _nationalityController.text.trim().isEmpty ? 'Not given' : _nationalityController.text.trim(),
        'emis': _emisController.text.trim().isEmpty ? 'Not given' : _emisController.text.trim(),
        'nextofKinName': _nextOfKinNameController.text.trim().isEmpty ? 'Not given' : _nextOfKinNameController.text.trim(),
        'nextofKincontactNumberWhatsApp': _nextOfKinContactController.text.trim().isEmpty ? 'Not given' : _nextOfKinContactController.text.trim(),
        'nextofKinidEmail': _nextOfKinEmailController.text.trim().isEmpty ? 'Not given' : _nextOfKinEmailController.text.trim(),
        'nextofKinid': _nextOfKinIdController.text.trim().isEmpty ? 'Not given' : _nextOfKinIdController.text.trim(),
        'idNin': idNin,
        'id': null,
        'image': 'Not given',
        'parentFcmToken': '',
        'parentUid': '',
        'termAdmin': 'Not given',
        'yearAdmin': 'Not given',
        'amountTerm1': 0.0,
        'amountTerm2': null,
        'amountTerm3': null,
        'amountOwedTerm1': 0.0,
        'amountOwedTerm2': null,
        'amountOwedTerm3': null,
        'paymentList': [],
        'extraSub': [],
        'lastUpdated': now,
        'subjectsScore': [],
        'subjectsScoreTerm2': [],
        'subjectsScoreTerm3': [],
      };

      // Save to Firestore
      await collectionRef.doc(idNin).set(studentData);

      // Save to Hive if not web
      if (!kIsWeb) {
        final student = StudentModelP4(
          studentName: studentData['studentName'],
          classIn: studentData['classIn'],
          stream: studentData['stream'],
          contactNumber: studentData['contactNumber'],
          subjectsScore: <P4Subjects>[],
          subjectsScoreTerm2: <P4SubjectsTerm2>[],
          subjectsScoreTerm3: <P4SubjectsTerm3>[],
          idNin: idNin,
          id: null,
          extraSub: [],
        );
        final box = Hive.box<StudentModelP4>('p4Students');
        await box.add(student);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text('${_nameController.text.trim()} added successfully!'),
              ],
            ),
            backgroundColor: const Color(0xFF00897B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to save: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
                      vertical: 20,
                    ),
                    child: isWide
                        ? _buildWideLayout()
                        : _buildNarrowLayout(),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildSection(
          title: 'Student Information',
          icon: Icons.person_rounded,
          color: mainColor,
          children: _studentInfoFields(),
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Next of Kin',
          icon: Icons.family_restroom_rounded,
          color: const Color(0xFF1E88E5),
          children: _nextOfKinFields(),
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Additional Info',
          icon: Icons.info_outline_rounded,
          color: const Color(0xFF8E24AA),
          children: _additionalInfoFields(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSection(
                title: 'Student Information',
                icon: Icons.person_rounded,
                color: mainColor,
                children: _studentInfoFields(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildSection(
                    title: 'Next of Kin',
                    icon: Icons.family_restroom_rounded,
                    color: const Color(0xFF1E88E5),
                    children: _nextOfKinFields(),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Additional Info',
                    icon: Icons.info_outline_rounded,
                    color: const Color(0xFF8E24AA),
                    children: _additionalInfoFields(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _studentInfoFields() {
    return [
      _buildField(
        controller: _nameController,
        label: 'Full Name',
        hint: 'e.g. Mugambe Godwin',
        icon: Icons.badge_rounded,
        required: true,
      ),
      _buildField(
        controller: _streamController,
        label: 'Stream',
        hint: 'e.g. A, B, C',
        icon: Icons.account_tree_rounded,
      ),
      _buildField(
        controller: _contactController,
        label: 'Contact Number',
        hint: 'e.g. 0701234567',
        icon: Icons.phone_rounded,
        keyboardType: TextInputType.phone,
      ),
      _buildField(
        controller: _birthDateController,
        label: 'Date of Birth',
        hint: 'e.g. 2015-01-01',
        icon: Icons.cake_rounded,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2015),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: mainColor),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            _birthDateController.text =
                picked.toIso8601String().split('T').first;
          }
        },
        readOnly: true,
      ),
      _buildField(
        controller: _addressController,
        label: 'Address',
        hint: 'e.g. Kampala, Uganda',
        icon: Icons.location_on_rounded,
      ),
    ];
  }

  List<Widget> _nextOfKinFields() {
    return [
      _buildField(
        controller: _nextOfKinNameController,
        label: 'Next of Kin Name',
        hint: 'e.g. John Mugambe',
        icon: Icons.person_outline_rounded,
      ),
      _buildField(
        controller: _nextOfKinContactController,
        label: 'WhatsApp Number',
        hint: 'e.g. 0701234567',
        icon: Icons.phone_rounded,
        keyboardType: TextInputType.phone,
      ),
      _buildField(
        controller: _nextOfKinEmailController,
        label: 'Email',
        hint: 'e.g. parent@email.com',
        icon: Icons.email_rounded,
        keyboardType: TextInputType.emailAddress,
      ),
      _buildField(
        controller: _nextOfKinIdController,
        label: 'Next of Kin ID',
        hint: 'National ID or Passport',
        icon: Icons.credit_card_rounded,
      ),
    ];
  }

  List<Widget> _additionalInfoFields() {
    return [
      _buildField(
        controller: _nationalityController,
        label: 'Nationality',
        hint: 'e.g. Ugandan',
        icon: Icons.flag_rounded,
      ),
      _buildField(
        controller: _emisController,
        label: 'EMIS Number',
        hint: 'e.g. 538105',
        icon: Icons.numbers_rounded,
      ),
    ];
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          prefixIcon: Icon(icon, color: mainColor, size: 20),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: mainColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveStudent,
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_rounded, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Save Student',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final String schoolTitle = schoolname.isNotEmpty ? schoolname : "School";
    return AppBar(
      elevation: 0,
      backgroundColor: mainColor,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schoolTitle,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Add New Student to ${widget.model}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, mainColor.withOpacity(0.8)],
          ),
        ),
      ),
    );
  }
}