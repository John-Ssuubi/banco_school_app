// ignore_for_file: deprecated_member_use

import 'package:banco_mobile/HeadTeacher/fullscreenimg.dart';
import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AboutSchool extends StatefulWidget {
  final String schoolId;
  final String schoolName;
  final String pobox;
  final String address;
  final String moto;
  final String contact;
  final String email;
  final String subscription;

  // Grading ranges
  final int d1Start, d1End;
  final int d2Start, d2End;
  final int c3Start, c3End;
  final int c4Start, c4End;
  final int c5Start, c5End;
  final int c6Start, c6End;
  final int p7Start, p7End;
  final int p8Start, p8End;
  final int f9Start, f9End;

  final List<StaffMember> staffMembers;
  final List<LinkedParent> linkedParents;

  const AboutSchool({
    super.key,
    required this.schoolId,
    required this.schoolName,
    required this.pobox,
    required this.address,
    required this.moto,
    required this.contact,
    required this.email,
    required this.subscription,
    required this.d1Start,
    required this.d1End,
    required this.d2Start,
    required this.d2End,
    required this.c3Start,
    required this.c3End,
    required this.c4Start,
    required this.c4End,
    required this.c5Start,
    required this.c5End,
    required this.c6Start,
    required this.c6End,
    required this.p7Start,
    required this.p7End,
    required this.p8Start,
    required this.p8End,
    required this.f9Start,
    required this.f9End,
    required this.staffMembers,
    required this.linkedParents,
  });

  @override
  State<AboutSchool> createState() => _AboutSchoolState();
}

class _AboutSchoolState extends State<AboutSchool>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<String> schoolImages = [];

  /// Maps download URL -> Firestore gallery document ID.
  final Map<String, String> _imageDocumentIds = {};

  bool isLoadingImages = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
    );

    _loadSchoolImages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  

  // LOAD SCHOOL IMAGES
 
void openFullScreenImage(String imageUrl) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: FullScreenImageViewer(imageUrl: imageUrl),
        );
      },
    ),
  );
}
  Future<void> _loadSchoolImages() async {
    if (mounted) {
      setState(() {
        isLoadingImages = true;
      });
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('gallery')
          .get();

      final List<Map<String, dynamic>> images = [];

      _imageDocumentIds.clear();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final url = data['url'];

        if (url is String && url.trim().isNotEmpty) {
          images.add({
            'url': url.trim(),
            'createdAt': data['createdAt'],
            'docId': doc.id,
          });

          _imageDocumentIds[url.trim()] = doc.id;
        }
      }

      // Sort locally instead of using Firestore orderBy().
      //
      // This avoids problems if some old gallery documents
      // don't contain createdAt.
      images.sort((a, b) {
        final aTime = a['createdAt'];
        final bTime = b['createdAt'];

        if (aTime is Timestamp && bTime is Timestamp) {
          return bTime.compareTo(aTime);
        }

        if (aTime is Timestamp) {
          return -1;
        }

        if (bTime is Timestamp) {
          return 1;
        }

        return 0;
      });

      final imageUrls = images
          .map<String>((image) => image['url'] as String)
          .toList();

      if (!mounted) return;

      setState(() {
        schoolImages = imageUrls;
        isLoadingImages = false;
      });
    } catch (e, stackTrace) {
      debugPrint(
        'Error loading school images from Firestore: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      setState(() {
        schoolImages = [];
        isLoadingImages = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load school images: $e',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // IMAGE PICKER SUPPORT
  // ============================================================

  /// image_picker supports the platforms used by this app.
  ///
  /// We intentionally don't import dart:io because Flutter Web
  /// does not support dart:io.
  bool _isImagePickerSupported() {
    return true;
  }

  // ============================================================
  // UPLOAD SCHOOL IMAGE
  // ============================================================

  Future<void> _uploadSchoolImage() async {
    if (!_isImagePickerSupported()) {
      _showUnsupportedDialog();
      return;
    }

    final picker = ImagePicker();

    XFile? image;

    try {
      image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error picking image: $e',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    if (image == null) return;

    if (!mounted) return;

    setState(() {
      isUploading = true;
    });

    try {
      // Generate unique file name.
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Firebase Storage location.
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(
            'schools/${widget.schoolId}/gallery/$fileName',
          );

      // Read image as bytes.
      //
      // This works on Flutter Web and mobile.
      final bytes = await image.readAsBytes();

      // Upload bytes directly.
      await storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
        ),
      );

      // Get Firebase Storage download URL.
      final downloadUrl =
          await storageRef.getDownloadURL();

      // Save URL in Firestore.
      final galleryDoc = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('gallery')
          .add({
        'url': downloadUrl,
        'fileName': fileName,
        'storagePath': storageRef.fullPath,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Keep document ID for deletion.
      _imageDocumentIds[downloadUrl] = galleryDoc.id;

      if (!mounted) return;

      setState(() {
        schoolImages.insert(0, downloadUrl);
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Image uploaded successfully!',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Upload error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Failed to upload image: $e',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // DELETE SCHOOL IMAGE
  // ============================================================

  Future<void> _deleteSchoolImage(
    String imageUrl,
  ) async {
    final shouldDelete = await _confirmDeleteImage();

    if (!shouldDelete) return;

    try {
      // ========================================================
      // 1. DELETE FROM FIREBASE STORAGE
      // ========================================================

      final storageRef =
          FirebaseStorage.instance.refFromURL(imageUrl);

      await storageRef.delete();

      // ========================================================
      // 2. DELETE FIRESTORE GALLERY DOCUMENT
      // ========================================================

      final documentId = _imageDocumentIds[imageUrl];

      if (documentId != null) {
        await FirebaseFirestore.instance
            .collection('Schools')
            .doc(widget.schoolId)
            .collection('gallery')
            .doc(documentId)
            .delete();

        _imageDocumentIds.remove(imageUrl);
      } else {
        // Fallback search by URL.
        final snapshot = await FirebaseFirestore.instance
            .collection('Schools')
            .doc(widget.schoolId)
            .collection('gallery')
            .where(
              'url',
              isEqualTo: imageUrl,
            )
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          await snapshot.docs.first.reference.delete();
        }
      }

      // ========================================================
      // 3. REMOVE FROM UI
      // ========================================================

      if (!mounted) return;

      setState(() {
        schoolImages.remove(imageUrl);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🗑️ Image deleted successfully',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Delete image error: $e',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Failed to delete image: $e',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // UNSUPPORTED PLATFORM
  // ============================================================

  void _showUnsupportedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('Unsupported Platform'),
          ],
        ),
        content: const Text(
          'Image upload is not supported on this platform.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIRM DELETE IMAGE
  // ============================================================

  Future<bool> _confirmDeleteImage() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text('Delete Image'),
                ],
              ),
              content: const Text(
                'Are you sure you want to delete this image? '
                'This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // ============================================================
  // UPDATE ACCESS
  // ============================================================

  Future<void> _updateAccess(
    String uid,
    bool value,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .update({
        'accessResults': value,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? '✅ Results access granted'
                : '🔒 Results access locked',
          ),
          backgroundColor:
              value ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Failed to update access',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // CONFIRM DELETE
  // ============================================================

  Future<bool> _confirmDelete(
    String type,
    String name,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text('Confirm Delete'),
                ],
              ),
              content: Text(
                "Remove $type '$name'? "
                'This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // ============================================================
  // DELETE PARENT
  // ============================================================

  Future<void> _deleteParent(
    LinkedParent parent,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(parent.parentUid)
          .update({
        'approved': false,
      });

      if (!mounted) return;

      setState(() {
        widget.linkedParents.removeWhere(
          (p) => p.parentUid == parent.parentUid,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🗑️ Parent removed successfully',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error removing parent',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // DELETE STAFF
  // ============================================================

  Future<void> _deleteStaff(
    StaffMember staff,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(staff.uid)
          .update({
        'approved': false,
      });

      if (!mounted) return;

      setState(() {
        widget.staffMembers.removeWhere(
          (s) => s.uid == staff.uid,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🗑️ Staff removed successfully',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error removing staff',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // PARENT OPTIONS
  // ============================================================

  void _showParentOptions(
    LinkedParent parent,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHeader(
                'Parent Options',
                '${parent.firstName} ${parent.secondName}',
              ),
              const Divider(),
              ListTile(
                leading: _optionIcon(
                  Icons.lock_open,
                  Colors.green,
                ),
                title: const Text(
                  'Grant Results Access',
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _updateAccess(
                    parent.parentUid,
                    true,
                  );
                },
              ),
              ListTile(
                leading: _optionIcon(
                  Icons.lock,
                  Colors.orange,
                ),
                title: const Text(
                  'Lock Results Access',
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _updateAccess(
                    parent.parentUid,
                    false,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: _optionIcon(
                  Icons.delete,
                  Colors.red,
                ),
                title: const Text(
                  'Remove Parent',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await _confirmDelete(
                    'parent',
                    '${parent.firstName} ${parent.secondName}',
                  );

                  if (ok) {
                    await _deleteParent(parent);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // STAFF OPTIONS
  // ============================================================

  void _showStaffOptions(
    StaffMember staff,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHeader(
                'Staff Options',
                '${staff.firstName} ${staff.secondName}',
              ),
              const Divider(),
              ListTile(
                leading: _optionIcon(
                  Icons.person_remove,
                  Colors.red,
                ),
                title: const Text(
                  'Remove Staff',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await _confirmDelete(
                    'staff',
                    '${staff.firstName} ${staff.secondName}',
                  );

                  if (ok) {
                    await _deleteStaff(staff);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetHeader(
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionIcon(
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeaderCard(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSchoolInfoTab(),
                _buildGalleryTab(),
                _buildStaffTab(),
                _buildParentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        'School Information',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              mainColor,
              mainColor.withOpacity(0.8),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER CARD
  // ============================================================

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor,
            mainColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.schoolName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.moto,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: widget.subscription == 'Paid'
                  ? Colors.green
                  : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.subscription,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB BAR
  // ============================================================

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: mainColor,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.info_outline),
            text: 'Info',
          ),
          Tab(
            icon: Icon(Icons.photo_library),
            text: 'Gallery',
          ),
          Tab(
            icon: Icon(Icons.people_outline),
            text: 'Staff',
          ),
          Tab(
            icon: Icon(Icons.family_restroom),
            text: 'Parents',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCHOOL INFO TAB
  // ============================================================

  Widget _buildSchoolInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoSection(
          title: 'Contact Information',
          icon: Icons.contact_phone,
          children: [
            _infoRow(
              Icons.location_on,
              'Address',
              widget.address,
            ),
            _infoRow(
              Icons.markunread_mailbox,
              'P.O Box',
              widget.pobox,
            ),
            _infoRow(
              Icons.phone,
              'Contact',
              widget.contact,
            ),
            _infoRow(
              Icons.email,
              'Email',
              widget.email,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoSection(
          title: 'Grading System',
          icon: Icons.grade,
          children: [
            _gradeRow(
              'D1',
              widget.d1Start,
              widget.d1End,
            ),
            _gradeRow(
              'D2',
              widget.d2Start,
              widget.d2End,
            ),
            _gradeRow(
              'C3',
              widget.c3Start,
              widget.c3End,
            ),
            _gradeRow(
              'C4',
              widget.c4Start,
              widget.c4End,
            ),
            _gradeRow(
              'C5',
              widget.c5Start,
              widget.c5End,
            ),
            _gradeRow(
              'C6',
              widget.c6Start,
              widget.c6End,
            ),
            _gradeRow(
              'P7',
              widget.p7Start,
              widget.p7End,
            ),
            _gradeRow(
              'P8',
              widget.p8Start,
              widget.p8End,
            ),
            _gradeRow(
              'F9',
              widget.f9Start,
              widget.f9End,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // GALLERY TAB
  // ============================================================

  Widget _buildGalleryTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                isUploading ? null : _uploadSchoolImage,
            icon: isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.add_photo_alternate,
                  ),
            label: Text(
              isUploading
                  ? 'Uploading...'
                  : 'Upload School Image',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: isLoadingImages
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : schoolImages.isEmpty
                  ? _buildEmptyState(
                      'No Images',
                      'Upload school images to showcase your school',
                      Icons.photo_library,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSchoolImages,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: schoolImages.length,
                        itemBuilder: (context, index) {
                          final imageUrl =
                              schoolImages[index];

                          return  Stack(
  fit: StackFit.expand,
  children: [
    GestureDetector(
      onTap: () => openFullScreenImage(imageUrl),
      child: Hero(
        tag: imageUrl,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildPlatformImage(imageUrl),
        ),
      ),
    ),
    Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: () => _deleteSchoolImage(imageUrl),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    ),
  ],
);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE WIDGET
  // ============================================================

  Widget _buildPlatformImage(
    String imageUrl,
  ) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,

      // Important for Flutter Web.
      webHtmlElementStrategy:
          WebHtmlElementStrategy.prefer,

      loadingBuilder:
          (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      },

      errorBuilder:
          (context, error, stackTrace) {
        debugPrint(
          'Image load failed for $imageUrl',
        );

        debugPrint(
          'Image error: $error',
        );

        return Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image,
                size: 32,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 4),
              Text(
                'Failed to load image',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // STAFF TAB
  // ============================================================

  Widget _buildStaffTab() {
    if (widget.staffMembers.isEmpty) {
      return _buildEmptyState(
        'No Staff Members',
        'No staff members have been added yet',
        Icons.people_outline,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.staffMembers.length,
      itemBuilder: (context, index) {
        return _buildStaffCard(
          widget.staffMembers[index],
        );
      },
    );
  }

  // ============================================================
  // PARENTS TAB
  // ============================================================

  Widget _buildParentsTab() {
    if (widget.linkedParents.isEmpty) {
      return _buildEmptyState(
        'No Parents',
        'No parents are linked to this school',
        Icons.family_restroom,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.linkedParents.length,
      itemBuilder: (context, index) {
        return _buildParentCard(
          widget.linkedParents[index],
        );
      },
    );
  }

  // ============================================================
  // INFO SECTION
  // ============================================================

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: mainColor,
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

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: mainColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRADE ROW
  // ============================================================

  Widget _gradeRow(
    String grade,
    int start,
    int end,
  ) {
    Color gradeColor;

    if (grade == 'D1' || grade == 'D2') {
      gradeColor = Colors.green;
    } else if (grade == 'C3' ||
        grade == 'C4' ||
        grade == 'C5' ||
        grade == 'C6') {
      gradeColor = Colors.blue;
    } else if (grade == 'P7' ||
        grade == 'P8') {
      gradeColor = Colors.orange;
    } else {
      gradeColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradeColor,
                  gradeColor.withOpacity(0.7),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                grade,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LinearProgressIndicator(
              value: (end - start) / 100,
              backgroundColor: Colors.grey[200],
              color: gradeColor,
              borderRadius:
                  BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: gradeColor.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              '$start - $end',
              style: TextStyle(
                color: gradeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAFF CARD
  // ============================================================

  Widget _buildStaffCard(
    StaffMember staff,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () =>
            _showStaffOptions(staff),
        borderRadius:
            BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      mainColor,
                      mainColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    staff.firstName.isNotEmpty
                        ? staff.firstName[0]
                            .toUpperCase()
                        : '?',
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${staff.firstName} ${staff.secondName}',
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color: mainColor
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius
                                .circular(8),
                      ),
                      child: Text(
                        staff.role,
                        style: TextStyle(
                          fontSize: 11,
                          color: mainColor,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ),
                    if (staff.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 12,
                            color:
                                Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            staff.phone,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.more_vert,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PARENT CARD
  // ============================================================

  Widget _buildParentCard(
    LinkedParent parent,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () =>
            _showParentOptions(parent),
        borderRadius:
            BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal,
                      Colors.teal.withOpacity(0.7),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    parent.firstName.isNotEmpty
                        ? parent.firstName[0]
                            .toUpperCase()
                        : '?',
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${parent.firstName} ${parent.secondName}',
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (parent.phone.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 12,
                            color:
                                Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            parent.phone,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    if (parent.email.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 12,
                            color:
                                Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            parent.email,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    String title,
    String message,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 50,
              color:
                  mainColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}