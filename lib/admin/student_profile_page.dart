// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io' show File;
import 'dart:typed_data';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  bool isUploadingImage = false;
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

  // Image
  String? _profileImageUrl;
  dynamic _selectedImage; // File on mobile, XFile on web
  Uint8List? _selectedImageBytes; // preview bytes for web (never use File() on web)

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
        _profileImageUrl = data['image'] != null && data['image'] != "null" && data['image'] != "Not given"
            ? data['image']
            : null;
        loading = false;
      });
    } catch (e) {
      debugPrint("Profile Error: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      if (kIsWeb) {
        // On web, dart:io's File() is unsupported (throws _Namespace error).
        // Read bytes directly for both preview and upload.
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = pickedFile;
          _selectedImageBytes = bytes;
        });
      } else {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _selectedImageBytes = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImageToFirebase(dynamic imageFile) async {
    try {
      setState(() => isUploadingImage = true);

      // Create a unique filename
      final fileName = '${widget.studentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('Schools')
          .child(widget.schoolId)
          .child('Years')
          .child(widget.year)
          .child(widget.classModel)
          .child(widget.studentId)
          .child('profile')
          .child(fileName);

      if (kIsWeb) {
        // Use the bytes we already read in _pickImage — avoids touching dart:io.
        Uint8List? bytes = _selectedImageBytes;
        bytes ??= await (imageFile as XFile).readAsBytes();
        final uploadTask = await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      } else if (imageFile is File) {
        // Mobile / desktop
        final uploadTask = await storageRef.putFile(imageFile);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      } else if (imageFile is XFile) {
        // Fallback: shouldn't normally hit this on mobile, but handle gracefully
        final bytes = await imageFile.readAsBytes();
        final uploadTask = await storageRef.putData(bytes);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        return downloadUrl;
      }

      return null;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      setState(() => isUploadingImage = false);
    }
  }

  Future<void> _removeImage() async {
    try {
      if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
        // Delete from Firebase Storage
        try {
          final storageRef = FirebaseStorage.instance.refFromURL(_profileImageUrl!);
          await storageRef.delete();
        } catch (e) {
          debugPrint("Error deleting image from storage: $e");
          // Continue even if delete fails (image might already be deleted)
        }
      }

      // Update Firestore
      final schoolRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId);

      await schoolRef
          .collection('Years')
          .doc(widget.year)
          .collection(widget.classModel)
          .doc(widget.studentId)
          .update({
        'image': 'Not given',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _profileImageUrl = null;
        _selectedImage = null;
        _selectedImageBytes = null;
        if (studentData != null) {
          studentData!['image'] = 'Not given';
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error removing image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove profile picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> saveStudentData() async {
    setState(() => isSaving = true);

    try {
      String? imageUrl = _profileImageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        final uploadedUrl = await _uploadImageToFirebase(_selectedImage);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          // If upload failed, show error and return
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => isSaving = false);
          return;
        }
      }

      final schoolRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId);

      final updateData = {
        'birthDate': _birthDateController.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'address': _addressController.text.trim(),
        'contactNumber': _contactController.text.trim(),
        'emis': _emisController.text.trim(),
        'nextofKinName': _nextOfKinNameController.text.trim(),
        'nextofKincontactNumberWhatsApp': _nextOfKinPhoneController.text.trim(),
        'nextofKinidEmail': _nextOfKinEmailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only update image if we have a new URL
      if (imageUrl != null && imageUrl != _profileImageUrl) {
        updateData['image'] = imageUrl;
      }

      await schoolRef
          .collection('Years')
          .doc(widget.year)
          .collection(widget.classModel)
          .doc(widget.studentId)
          .update(updateData);

      // Update local data
      setState(() {
        studentData!['birthDate'] = _birthDateController.text.trim();
        studentData!['nationality'] = _nationalityController.text.trim();
        studentData!['address'] = _addressController.text.trim();
        studentData!['contactNumber'] = _contactController.text.trim();
        studentData!['emis'] = _emisController.text.trim();
        studentData!['nextofKinName'] = _nextOfKinNameController.text.trim();
        studentData!['nextofKincontactNumberWhatsApp'] = _nextOfKinPhoneController.text.trim();
        studentData!['nextofKinidEmail'] = _nextOfKinEmailController.text.trim();
        if (imageUrl != null && imageUrl != _profileImageUrl) {
          studentData!['image'] = imageUrl;
          _profileImageUrl = imageUrl;
        }
        _selectedImage = null;
        _selectedImageBytes = null;
        isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
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
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text('Failed to update profile: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
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
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: readOnly ? Colors.grey[100] : (isEditing ? Colors.white : Colors.grey[50]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: readOnly ? Colors.grey[300]! : (isEditing ? mainColor : Colors.grey[200]!),
            width: readOnly ? 1 : (isEditing ? 1.5 : 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: readOnly ? Colors.grey : mainColor),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: readOnly ? Colors.grey[600] : Colors.black,
                ),
              ),
            ),
            Expanded(
              child: isEditing && !readOnly
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
                      controller.text.isEmpty || controller.text == "Not given" ? "Not provided" : controller.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: readOnly ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
            ),
            if (readOnly)
              Icon(
                Icons.lock_outline,
                size: 16,
                color: Colors.grey[400],
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

  /// Resolves the correct ImageProvider for the current state, without ever
  /// constructing a dart:io File() on web (which throws _Namespace errors).
  ImageProvider? _resolveProfileImageProvider(bool hasImage) {
    if (_selectedImage != null) {
      if (kIsWeb) {
        return _selectedImageBytes != null ? MemoryImage(_selectedImageBytes!) : null;
      }
      if (_selectedImage is File) {
        return FileImage(_selectedImage as File);
      }
      return null;
    }
    if (hasImage) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  Widget _buildProfileHeader() {
    final hasImage = _selectedImage != null ||
        (_profileImageUrl != null && _profileImageUrl!.isNotEmpty && _profileImageUrl != "null" && _profileImageUrl != "Not given");

    final imageProvider = _resolveProfileImageProvider(hasImage);

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
              // Profile Image
              GestureDetector(
                onTap: isEditing ? _pickImage : null,
                child: Container(
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
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: mainColor.withOpacity(0.2),
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? Icon(Icons.person, size: 65, color: mainColor)
                            : null,
                      ),
                      if (isEditing && !isUploadingImage)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: mainColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      if (isUploadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Remove image button (only in edit mode and when image exists)
              if (isEditing && hasImage && !isUploadingImage)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _removeImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              // Status indicator
              if (!isEditing && hasImage)
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
          if (isEditing) ...[
            const SizedBox(height: 8),
            Text(
              "Tap on the profile picture to change it",
              style: TextStyle(
                fontSize: 12,
                color: mainColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
          enabled: false,
          readOnly: true,
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