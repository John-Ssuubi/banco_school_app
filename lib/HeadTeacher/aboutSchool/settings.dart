// settings.dart
// ignore_for_file: deprecated_member_use

import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SchoolSettings extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const SchoolSettings({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<SchoolSettings> createState() => _SchoolSettingsState();
}

class _SchoolSettingsState extends State<SchoolSettings>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ClassSubject> classSubjects = [];
  bool isLoading = true;

  // Available classes
  final List<String> availableClasses = [
    'Primary 1',
    'Primary 2',
    'Primary 3',
    'Primary 4',
    'Primary 5',
    'Primary 6',
    'Primary 7',
    
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClassSubjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD CLASS SUBJECTS
  // ============================================================

  Future<void> _loadClassSubjects() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('classSubjects')
          .get();

      final List<ClassSubject> loadedSubjects = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        loadedSubjects.add(ClassSubject(
          id: doc.id,
          className: data['className'] ?? '',
          subjectName: data['subjectName'] ?? '',
          teacherInitials: data['teacherInitials'] ?? '',
        ));
      }

      if (mounted) {
        setState(() {
          classSubjects = loadedSubjects;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading class subjects: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load subjects: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ============================================================
  // ADD SUBJECT
  // ============================================================

  Future<void> _addSubject(ClassSubject subject) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('classSubjects')
          .add({
        'className': subject.className,
        'subjectName': subject.subjectName,
        'teacherInitials': subject.teacherInitials,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          classSubjects.add(ClassSubject(
            id: docRef.id,
            className: subject.className,
            subjectName: subject.subjectName,
            teacherInitials: subject.teacherInitials,
          ));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Subject added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add subject: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ============================================================
  // DELETE SUBJECT
  // ============================================================

  Future<void> _deleteSubject(ClassSubject subject) async {
    final confirm = await _showDeleteConfirmation(
      'Delete Subject',
      'Are you sure you want to delete "${subject.subjectName}" for ${subject.className}?',
    );

    if (!confirm) return;

    try {
      await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('classSubjects')
          .doc(subject.id)
          .delete();

      if (mounted) {
        setState(() {
          classSubjects.removeWhere((s) => s.id == subject.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Subject deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to delete subject: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ============================================================
  // EDIT SUBJECT
  // ============================================================

  Future<void> _editSubject(ClassSubject subject) async {
    final result = await _showAddEditDialog(
      title: 'Edit Subject',
      initialClass: subject.className,
      initialSubject: subject.subjectName,
      initialInitials: subject.teacherInitials,
    );

    if (result == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('classSubjects')
          .doc(subject.id)
          .update({
        'className': result.className,
        'subjectName': result.subjectName,
        'teacherInitials': result.teacherInitials,
      });

      if (mounted) {
        setState(() {
          final index = classSubjects.indexWhere((s) => s.id == subject.id);
          if (index != -1) {
            classSubjects[index] = ClassSubject(
              id: subject.id,
              className: result.className,
              subjectName: result.subjectName,
              teacherInitials: result.teacherInitials,
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Subject updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to update subject: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ============================================================
  // SHOW ADD/EDIT DIALOG
  // ============================================================

  Future<ClassSubject?> _showAddEditDialog({
    required String title,
    String? initialClass,
    String? initialSubject,
    String? initialInitials,
  }) async {
    final classNameController = TextEditingController(text: initialClass ?? '');
    final subjectController = TextEditingController(text: initialSubject ?? '');
    final initialsController =
        TextEditingController(text: initialInitials ?? '');

    String selectedClass = initialClass ?? availableClasses.first;

    return showDialog<ClassSubject>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    title == 'Add Subject'
                        ? Icons.add_circle_outline
                        : Icons.edit_outlined,
                    color: mainColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Class Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedClass,
                      decoration: InputDecoration(
                        labelText: 'Class',
                        prefixIcon: const Icon(Icons.class_),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: availableClasses.map((String className) {
                        return DropdownMenuItem<String>(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            selectedClass = value;
                            classNameController.text = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Subject Name
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject Name',
                        prefixIcon: const Icon(Icons.book),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., Mathematics',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Teacher Initials
                    TextField(
                      controller: initialsController,
                      decoration: InputDecoration(
                        labelText: 'Teacher Initials',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'e.g., J.K.',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final className = classNameController.text.trim();
                    final subject = subjectController.text.trim();
                    final initials = initialsController.text.trim();

                    if (className.isEmpty || subject.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      context,
                      ClassSubject(
                        id: '', // Will be set by Firestore
                        className: className,
                        subjectName: subject,
                        teacherInitials: initials,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    title == 'Add Subject' ? 'Add' : 'Update',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SHOW DELETE CONFIRMATION
  // ============================================================

  Future<bool> _showDeleteConfirmation(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSubjectsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddSubjectDialog,
              backgroundColor: mainColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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
      title: Text(
        'School Settings - ${widget.schoolName}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
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

  // ============================================================
  // TAB BAR
  // ============================================================

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: const [
          Tab(icon: Icon(Icons.book), text: 'Subjects'),
          Tab(icon: Icon(Icons.settings), text: 'Settings'),
        ],
      ),
    );
  }

  // ============================================================
  // SHOW ADD SUBJECT DIALOG
  // ============================================================

  Future<void> _showAddSubjectDialog() async {
    final result = await _showAddEditDialog(title: 'Add Subject');
    if (result != null) {
      await _addSubject(result);
    }
  }

  // ============================================================
  // SUBJECTS TAB
  // ============================================================

  Widget _buildSubjectsTab() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (classSubjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Subjects Added',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add subjects for each class',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Group subjects by class
    final Map<String, List<ClassSubject>> groupedSubjects = {};
    for (final subject in classSubjects) {
      groupedSubjects.putIfAbsent(subject.className, () => []).add(subject);
    }

    final sortedKeys = groupedSubjects.keys.toList()
      ..sort((a, b) {
        // Sort classes in order: Primary 1, Primary 2, etc.
        final aNum = int.tryParse(a.replaceAll('Primary ', ''));
        final bNum = int.tryParse(b.replaceAll('Primary ', ''));
        if (aNum != null && bNum != null) {
          return aNum.compareTo(bNum);
        }
        return a.compareTo(b);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final className = sortedKeys[index];
        final subjects = groupedSubjects[className]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [mainColor, mainColor.withOpacity(0.7)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.class_,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      className,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${subjects.length} subject${subjects.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Subject List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: subjects.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.book,
                        color: mainColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      subject.subjectName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Teacher: ${subject.teacherInitials.isEmpty ? 'Not assigned' : subject.teacherInitials}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editSubject(subject);
                        } else if (value == 'delete') {
                          _deleteSubject(subject);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SETTINGS TAB
  // ============================================================

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSettingsCard(
          title: 'Subject Management',
          icon: Icons.book,
          color: Colors.blue,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.green),
              title: const Text('Add New Subject'),
              subtitle: const Text('Add a subject for a specific class'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showAddSubjectDialog,
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.orange),
              title: const Text('Refresh Subjects'),
              subtitle: const Text('Reload all subjects from database'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _loadClassSubjects,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsCard(
          title: 'Statistics',
          icon: Icons.analytics,
          color: Colors.purple,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Classes',
                    _getUniqueClasses().length.toString(),
                    Icons.class_,
                  ),
                  _buildStatItem(
                    'Subjects',
                    classSubjects.length.toString(),
                    Icons.book,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSettingsCard(
          title: 'Clear All',
          icon: Icons.warning,
          color: Colors.red,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Clear All Subjects',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('This will delete all subjects for this school'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _clearAllSubjects,
            ),
          ],
        ),
      
      ],
    );
  }

  // ============================================================
  // SETTINGS CARD HELPER
  // ============================================================

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
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
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // STAT ITEM HELPER
  // ============================================================

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: mainColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GET UNIQUE CLASSES
  // ============================================================

  List<String> _getUniqueClasses() {
    final Set<String> classes = {};
    for (final subject in classSubjects) {
      classes.add(subject.className);
    }
    return classes.toList();
  }

  // ============================================================
  // CLEAR ALL SUBJECTS
  // ============================================================

  Future<void> _clearAllSubjects() async {
    final confirm = await _showDeleteConfirmation(
      'Clear All Subjects',
      'Are you sure you want to delete ALL subjects for this school? This action cannot be undone.',
    );

    if (!confirm) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('classSubjects')
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (mounted) {
        setState(() {
          classSubjects.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ All subjects deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to clear subjects: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ============================================================
// CLASS SUBJECT MODEL
// ============================================================

class ClassSubject {
  final String id;
  final String className;
  final String subjectName;
  final String teacherInitials;

  ClassSubject({
    required this.id,
    required this.className,
    required this.subjectName,
    required this.teacherInitials,
  });

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'subjectName': subjectName,
      'teacherInitials': teacherInitials,
    };
  }

  factory ClassSubject.fromMap(String id, Map<String, dynamic> map) {
    return ClassSubject(
      id: id,
      className: map['className'] ?? '',
      subjectName: map['subjectName'] ?? '',
      teacherInitials: map['teacherInitials'] ?? '',
    );
  }
}