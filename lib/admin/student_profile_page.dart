// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentProfilePage extends StatefulWidget {
  final String schoolId;
  final String year;
  final String classModel;
  final String studentId;

  const StudentProfilePage({
    super.key,
    required this.schoolId,
    required this.year,
    required this.classModel,
    required this.studentId,
  });

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? studentData;
  Map<String, dynamic>? parentData;
  bool loading = true;
  bool isEditing = false;
  bool isSaving = false;
  late AnimationController _animationController;

  // Controllers for editable fields
  late TextEditingController _studentIdController;
  late TextEditingController _birthDateController;
  late TextEditingController _nationalityController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _emisController;
  
  // Next of Kin controllers
  late TextEditingController _nextOfKinNameController;
  late TextEditingController _nextOfKinPhoneController;
  late TextEditingController _nextOfKinEmailController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
    
    // Initialize controllers
    _studentIdController = TextEditingController();
    _birthDateController = TextEditingController();
    _nationalityController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
    _emisController = TextEditingController();
    _nextOfKinNameController = TextEditingController();
    _nextOfKinPhoneController = TextEditingController();
    _nextOfKinEmailController = TextEditingController();
    
    loadStudent();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _studentIdController.dispose();
    _birthDateController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emisController.dispose();
    _nextOfKinNameController.dispose();
    _nextOfKinPhoneController.dispose();
    _nextOfKinEmailController.dispose();
    super.dispose();
  }

  Future<void> loadStudent() async {
    try {
      final schoolRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId);

      final studentSnap = await schoolRef
          .collection('Years')
          .doc(widget.year)
          .collection(widget.classModel)
          .doc(widget.studentId)
          .get();

      if (!studentSnap.exists) return;

      final data = studentSnap.data()!;
      final parentUid = data['parentUid'];

      Map<String, dynamic>? parent;

      if (parentUid != null && parentUid.toString().isNotEmpty) {
        final parentSnap = await schoolRef
            .collection('linkedParents')
            .doc(parentUid)
            .get();

        if (parentSnap.exists) {
          parent = parentSnap.data();
        }
      }

      // Populate controllers with data
      _studentIdController.text = data['idNin'] ?? '';
      _birthDateController.text = data['birthDate'] ?? '';
      _nationalityController.text = data['nationality'] ?? '';
      _addressController.text = data['address'] ?? '';
      _contactController.text = data['contactNumber'] ?? '';
      _emisController.text = data['emis'] ?? '';
      _nextOfKinNameController.text = data['nextofKinName'] ?? '';
      _nextOfKinPhoneController.text = data['nextofKincontactNumberWhatsApp'] ?? '';
      _nextOfKinEmailController.text = data['nextofKinidEmail'] ?? '';

      setState(() {
        studentData = data;
        parentData = parent;
        loading = false;
      });
    } catch (e) {
      debugPrint("Profile Error: $e");
      setState(() => loading = false);
    }
  }

  Future<void> saveStudentData() async {
    setState(() => isSaving = true);
    
    try {
      final schoolRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId);

      await schoolRef
          .collection('Years')
          .doc(widget.year)
          .collection(widget.classModel)
          .doc(widget.studentId)
          .update({
        'idNin': _studentIdController.text.trim(),
        'birthDate': _birthDateController.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'address': _addressController.text.trim(),
        'contactNumber': _contactController.text.trim(),
        'emis': _emisController.text.trim(),
        'nextofKinName': _nextOfKinNameController.text.trim(),
        'nextofKincontactNumberWhatsApp': _nextOfKinPhoneController.text.trim(),
        'nextofKinidEmail': _nextOfKinEmailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local data
      setState(() {
        studentData!['idNin'] = _studentIdController.text.trim();
        studentData!['birthDate'] = _birthDateController.text.trim();
        studentData!['nationality'] = _nationalityController.text.trim();
        studentData!['address'] = _addressController.text.trim();
        studentData!['contactNumber'] = _contactController.text.trim();
        studentData!['emis'] = _emisController.text.trim();
        studentData!['nextofKinName'] = _nextOfKinNameController.text.trim();
        studentData!['nextofKincontactNumberWhatsApp'] = _nextOfKinPhoneController.text.trim();
        studentData!['nextofKinidEmail'] = _nextOfKinEmailController.text.trim();
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Profile updated successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Failed to update profile'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Widget _buildEditableField({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEditing ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEditing ? mainColor : Colors.grey[200]!,
            width: isEditing ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: mainColor),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: isEditing
                  ? TextFormField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: "Enter $title",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : Text(
                      controller.text.isEmpty ? "Not provided" : controller.text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: loading
          ? _buildLoadingState()
          : studentData == null
              ? _buildErrorState()
              : FadeTransition(
                  opacity: _animationController,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 20),
                        _buildBioDataCard(),
                        const SizedBox(height: 16),
                        _buildNextOfKinCard(),
                        const SizedBox(height: 16),
                        _buildParentCard(),
                        if (isEditing) ...[
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        "Student Profile",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        if (!isEditing)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => isEditing = true),
            ),
          ),
      ],
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

  Widget _buildProfileHeader() {
    final hasImage = studentData!['image'] != null && studentData!['image'] != "null";
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor.withOpacity(0.1),
            mainColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: mainColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: mainColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: mainColor.withOpacity(0.2),
                  backgroundImage: hasImage
                      ? NetworkImage(studentData!['image'])
                      : null,
                  child: !hasImage
                      ? Icon(Icons.person, size: 65, color: mainColor)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            studentData!['studentName'] ?? "Unknown Student",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Class: ${studentData!['classIn'] ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 14,
                    color: mainColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Stream: ${studentData!['stream'] ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBioDataCard() {
    return _buildCard(
      title: "Bio Data",
      icon: Icons.person_outline,
      children: [
        _buildEditableField(
          title: "Student ID",
          controller: _studentIdController,
          icon: Icons.tag,
          enabled: isEditing,
        ),
        _buildEditableField(
          title: "Birth Date",
          controller: _birthDateController,
          icon: Icons.cake,
          enabled: isEditing,
        ),
        _buildEditableField(
          title: "Nationality",
          controller: _nationalityController,
          icon: Icons.flag,
          enabled: isEditing,
        ),
        _buildEditableField(
          title: "Address",
          controller: _addressController,
          icon: Icons.location_on,
          enabled: isEditing,
        ),
        _buildEditableField(
          title: "Contact",
          controller: _contactController,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          enabled: isEditing,
        ),
        _buildEditableField(
          title: "EMIS",
          controller: _emisController,
          icon: Icons.school,
          enabled: isEditing,
        ),
      ],
    );
  }

  Widget _buildNextOfKinCard() {
    return _buildCard(
      title: "Next Of Kin",
      icon: Icons.family_restroom,
      children: [
        _buildEditableField(
          title: "Name",
          controller: _nextOfKinNameController,
          icon: Icons.person,
          enabled: isEditing,
        ),
        _buildEditableField(
          title: "Phone",
          controller: _nextOfKinPhoneController,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          enabled: isEditing,
        ),
        _buildEditableField(
          title: "Email",
          controller: _nextOfKinEmailController,
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          enabled: isEditing,
        ),
      ],
    );
  }

  Widget _buildParentCard() {
    return _buildCard(
      title: "Linked Parent",
      icon: Icons.people,
      children: parentData == null
          ? [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.person_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      "No Parent Linked",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ]
          : [
              _buildInfoRow("Name", "${parentData!['firstName']} ${parentData!['secondName']}", Icons.person),
              _buildInfoRow("Phone", parentData!['phone'] ?? "", Icons.phone),
              _buildInfoRow("Email", parentData!['email'] ?? "", Icons.email),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (parentData!['approved'] == true ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      parentData!['approved'] == true ? Icons.check_circle : Icons.cancel,
                      color: parentData!['approved'] == true ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      parentData!['approved'] == true ? "Approved" : "Pending Approval",
                      style: TextStyle(
                        color: parentData!['approved'] == true ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: mainColor),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? "Not provided" : value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isSaving ? null : () => setState(() => isEditing = false),
            icon: const Icon(Icons.close),
            label: const Text("Cancel"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : saveStudentData,
            icon: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(isSaving ? "Saving..." : "Save Changes"),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(mainColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading student profile...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red[300],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Student Not Found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Unable to load student profile data",
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                loading = true;
                loadStudent();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}