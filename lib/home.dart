// ignore_for_file: deprecated_member_use

import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/Excel/excel_p44Subs.dart';
import 'package:banco_mobile/P4/student_p4.dart';
import 'package:banco_mobile/Reports/bulk_term_one.dart';
import 'package:banco_mobile/Reports/bulk_term_three.dart';
import 'package:banco_mobile/Reports/bulk_term_two.dart';
import 'package:banco_mobile/addstudents/addstudent.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final String model;
  final String schoolId;

  const HomePage({super.key, required this.model, required this.schoolId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String currentYear = DateTime.now().year.toString();
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeaderCard(),
          _buildSearchBar(),
          Expanded(child: _buildStudentList()),
        ],
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schoolTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.model,
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

  Widget _buildHeaderCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [mainColor, mainColor.withOpacity(0.8)],
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
          child: isWide
              ? Row(
                  children: [
                    _buildHeaderIcon(),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStudentCount()),
                    _buildReportsDropdown(),
                    const SizedBox(width: 10),
                    _buildAddDropdown(),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildHeaderIcon(),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStudentCount()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildReportsDropdown(),
                        const SizedBox(width: 10),
                        _buildAddDropdown(),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.people_rounded, color: Colors.white, size: 32),
    );
  }

  Widget _buildStudentCount() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(currentYear)
          .collection(widget.model)
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.data?.docs.length ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Students",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              "$count Student${count != 1 ? 's' : ''}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportsDropdown() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      color: Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'report':
            // your report logic
            break;
          case 'end_of_term':
            // your end of term logic
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          height: 36,
          child: Text(
            "REPORTS",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E88E5),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          onTap: () {
            showDialog(
              context: context,
              builder: ((context) {
                return StatefulBuilder(
                  builder: ((context, setState) {
                    return AlertDialog(
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      content: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 200,
                        // width: 400,
                        child:  StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('Schools')
                                  .doc(widget.schoolId)
                                  .snapshots(),
                              builder: (context, schoolSnapshot) {
                                if (!schoolSnapshot.hasData) {
                                  return const SizedBox();
                                }
                                final data = schoolSnapshot.data!.data() ?? {};
                                
                                return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                BulkPrintP4(
                                      schoolId: widget.schoolId,
                                      model: widget.model,
                                      d1Start: data['D1Start'] ?? 100,
                                      d2Start: data['D2Start'] ?? 89,
                                      c3Start: data['c3Start'] ?? 79,
                                      c4Start: data['c4Start'] ?? 69,
                                      c5Start: data['c5Start'] ?? 59,
                                      c6Start: data['c6Start'] ?? 54,
                                      p7Start: data['p7Start'] ?? 49,
                                      p8Start: data['p8Start'] ?? 44,
                                      f9Start: data['f9Start'] ?? 39,
                                      f9End: data['f9End'] ?? 0,
                                      d1End: data['D1End'] ?? 90,
                                      d2End: data['D2End'] ?? 80,
                                      c3End: data['c3End'] ?? 70,
                                      c4End: data['c4End'] ?? 60,
                                      c5End: data['c5End'] ?? 55,
                                      c6End: data['c6End'] ?? 50,
                                      p7End: data['p7End'] ?? 45,
                                      p8End: data['p8End'] ?? 40,
                                    ),
                                     BulkPrintP4Term2(
                                      schoolId: widget.schoolId,
                                      model: widget.model,
                                      d1Start: data['D1Start'] ?? 100,
                                      d2Start: data['D2Start'] ?? 89,
                                      c3Start: data['c3Start'] ?? 79,
                                      c4Start: data['c4Start'] ?? 69,
                                      c5Start: data['c5Start'] ?? 59,
                                      c6Start: data['c6Start'] ?? 54,
                                      p7Start: data['p7Start'] ?? 49,
                                      p8Start: data['p8Start'] ?? 44,
                                      f9Start: data['f9Start'] ?? 39,
                                      f9End: data['f9End'] ?? 0,
                                      d1End: data['D1End'] ?? 90,
                                      d2End: data['D2End'] ?? 80,
                                      c3End: data['c3End'] ?? 70,
                                      c4End: data['c4End'] ?? 60,
                                      c5End: data['c5End'] ?? 55,
                                      c6End: data['c6End'] ?? 50,
                                      p7End: data['p7End'] ?? 45,
                                      p8End: data['p8End'] ?? 40,
                                    ),
                            
                             BulkPrintP4Term3(
                                      schoolId: widget.schoolId,
                                      model: widget.model,
                                      d1Start: data['D1Start'] ?? 100,
                                      d2Start: data['D2Start'] ?? 89,
                                      c3Start: data['c3Start'] ?? 79,
                                      c4Start: data['c4Start'] ?? 69,
                                      c5Start: data['c5Start'] ?? 59,
                                      c6Start: data['c6Start'] ?? 54,
                                      p7Start: data['p7Start'] ?? 49,
                                      p8Start: data['p8Start'] ?? 44,
                                      f9Start: data['f9Start'] ?? 39,
                                      f9End: data['f9End'] ?? 0,
                                      d1End: data['D1End'] ?? 90,
                                      d2End: data['D2End'] ?? 80,
                                      c3End: data['c3End'] ?? 70,
                                      c4End: data['c4End'] ?? 60,
                                      c5End: data['c5End'] ?? 55,
                                      c6End: data['c6End'] ?? 50,
                                      p7End: data['p7End'] ?? 45,
                                      p8End: data['p8End'] ?? 40,
                                    ),
                                   
                                
                              ],
                            );
                          }
                        ),
                      ),
                    );
                  }),
                );
              }),
            );
          },
          value: 'report',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Color(0xFF1E88E5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Report",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    "View student reports",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'end_of_term',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.summarize_rounded,
                  color: Color(0xFF1E88E5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "End of Term Report",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    "Full term summary",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              size: 17,
              color: Color(0xFF1E88E5),
            ),
            const SizedBox(width: 6),
            const Text(
              "Reports",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDropdown() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      color: Colors.white,
      onSelected: (value) {
        switch (value) {
          case 'import_excel':
            // your import excel logic
            break;
          case 'add_student':
            // your add student logic
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          height: 36,
          child: Text(
            "ADD",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF00897B),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          onTap: () {
            showDialog(
              context: context,
              builder: ((context) {
                return StatefulBuilder(
                  builder: ((context, setState) {
                    return AlertDialog(
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      content: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 200,
                        // width: 400,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ExcelButtonP44Subs(
                              schoolId: widget.schoolId,
                              model: widget.model,
                            ),
                            // ExcelButtonP45Subs(),
                            // ExcelButtonP46Subs(),
                            // ExcelButtonP47Subs(),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }),
            );
          },
          value: 'import_excel',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.table_chart_rounded,
                  color: Color(0xFF00897B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Import Excel",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    "Bulk upload via .xlsx",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'add_student',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddStudent(schoolId: widget.schoolId, model: widget.model),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: Color(0xFF00897B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Student",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    "Register a new student",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              size: 17,
              color: Color(0xFF00897B),
            ),
            const SizedBox(width: 6),
            const Text(
              "Add",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search by name or ID...",
          prefixIcon: Icon(Icons.search_rounded, color: mainColor),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = "");
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
      ),
    );
  }

  Widget _buildStudentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(currentYear)
          .collection(widget.model)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final students =
            snapshot.data!.docs
                .map(
                  (doc) => StudentModelP4.fromJson(
                    doc.data() as Map<String, dynamic>,
                  ),
                )
                .toList()
              ..sort(
                (a, b) => (a.studentName ?? '').compareTo(b.studentName ?? ''),
              );

        final filteredStudents = students.where((student) {
          final name = (student.studentName ?? "").toLowerCase();
          final nin = (student.idNin ?? "").toLowerCase();
          return name.contains(searchQuery) || nin.contains(searchQuery);
        }).toList();

        if (filteredStudents.isEmpty) return _buildNoResultsState();

        return FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: constraints.maxWidth > 900 ? 3 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3.2,
                  ),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) =>
                      _buildStudentCard(filteredStudents[index], index),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredStudents.length,
                itemBuilder: (context, index) =>
                    _buildStudentCard(filteredStudents[index], index),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStudentCard(StudentModelP4 student, int index) {
    final Color cardColor = _getStudentColor(student.studentName ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentP4(
                  index: index,
                  model: widget.model,
                  schoolId: widget.schoolId,
                  studentId: student.idNin ?? '',
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cardColor, cardColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(student.studentName ?? '?'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.studentName ?? 'No Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(student.classIn ?? 'Unknown'),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: cardColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(mainColor),
      ),
    );
  }

  Widget _buildErrorState(String error) => Center(child: Text(error));

  Widget _buildEmptyState() => const Center(child: Text("No Students Found"));

  Widget _buildNoResultsState() =>
      const Center(child: Text("No matching students"));

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color _getStudentColor(String name) {
    final List<Color> colors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}
