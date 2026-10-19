// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/HeadTeacher/Fees/schoolfees.dart';
import 'package:banco_mobile/HeadTeacher/aboutSchool/about_school.dart';
import 'package:banco_mobile/HeadTeacher/headteacher_assessment.dart';
import 'package:banco_mobile/HeadTeacher/Results/headteacher_classes.dart';
import 'package:banco_mobile/HeadTeacher/attendance.dart';
import 'package:banco_mobile/HeadTeacher/headteacher_stat.dart';
import 'package:banco_mobile/HeadTeacher/headteachernotificatios.dart';
import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/Notifications/local_notifications.dart';
import 'package:banco_mobile/Planning/schemes_of_work.dart';
import 'package:banco_mobile/Teachers/SettingsTeacher/settings_teacher.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeadTeacherDashboard extends StatefulWidget {
  final String approve;
  final List<dynamic>? classes;
  final String schoolId;

  const HeadTeacherDashboard({
    super.key,
    required this.approve,
    this.classes,
    required this.schoolId,
  });

  @override
  State<HeadTeacherDashboard> createState() => _HeadTeacherDashboardState();
}

class _HeadTeacherDashboardState extends State<HeadTeacherDashboard>
    with TickerProviderStateMixin {
  String? schoolId;
  List<Map<String, dynamic>>? schoolClasses = [];
  bool isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLargeScreen = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ─────────────────────────────────────────────────────────────
  // QUICK ACTIONS
  // (Results, Fees, Attendance, Notifications, Inventory, Library, Transport)
  // ─────────────────────────────────────────────────────────────
  final List<DashboardItem> menuItems = [
    DashboardItem(
      title: 'Results',
      subtitle: 'View student grades',
      icon: Icons.workspace_premium_rounded,
      color: const Color.fromARGB(255, 0, 105, 137),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00897B), Color.fromARGB(255, 0, 11, 105)],
      ),
    ),
    DashboardItem(
      title: 'School Fees',
      subtitle: 'View fees balance',
      icon: Icons.account_balance_outlined,
      color: const Color(0xFF00897B),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00897B), Color(0xFF00695C)],
      ),
    ),
    DashboardItem(
      title: 'Attendance',
      subtitle: 'Track daily presence',
      icon: Icons.how_to_reg_rounded,
      color: const Color(0xFF1E88E5),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
      ),
    ),
    DashboardItem(
      title: 'Notifications',
      subtitle: 'Alerts & messages',
      icon: Icons.notifications_active_rounded,
      color: const Color(0xFFE53935),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE53935), Color(0xFFC62828)],
      ),
    ),
    // ── NEW ──
    DashboardItem(
      title: 'Inventory',
      subtitle: 'Manage school stock',
      icon: Icons.inventory_2_rounded,
      color: const Color(0xFF6D4C41),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8D6E63), Color(0xFF4E342E)],
      ),
    ),
    DashboardItem(
      title: 'Library',
      subtitle: 'Books & resources',
      icon: Icons.local_library_rounded,
      color: const Color(0xFF3949AB),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5C6BC0), Color(0xFF283593)],
      ),
    ),
   
  ];

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final classes = List<Map<String, dynamic>>.from(
          data['linkedClasses'] ?? [],
        );
        setState(() {
          schoolClasses = classes;
          if (classes.isNotEmpty) schoolId = classes.first['schoolId'];
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error loading user data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout(BuildContext context) async {
    final shouldLogout = await confirmLogout(context);
    if (!shouldLogout) return;
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthStudent()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Logout failed. Please try again."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black54,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.red.shade600,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Sign Out",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Are you sure you want to sign out of your account?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Sign Out",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    AwesomeNotificationsEngine.scheduledNotificationAwesome();
    loadData().then((_) => _fadeController.forward());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkScreenSize();
  }

  void _checkScreenSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge = screenWidth >= 900;
    if (_isLargeScreen != isLarge) setState(() => _isLargeScreen = isLarge);
  }

  @override
  Widget build(BuildContext context) {
    _checkScreenSize();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      drawer: _isLargeScreen ? null : _buildDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_isLargeScreen) {
            return Row(
              children: [
                SizedBox(width: 300, child: _buildDrawer()),
                Expanded(
                  child: isLoading
                      ? _buildLoadingState()
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildDashboardContent(),
                        ),
                ),
              ],
            );
          }
          return isLoading
              ? _buildLoadingState()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildDashboardContent(),
                );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.2)!],
          ),
        ),
      ),
      leading: _isLargeScreen
          ? null
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
      title: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final name = snapshot.hasData && snapshot.data!.exists
              ? '${snapshot.data!['firstName'] ?? ''}'
              : 'Head Teacher';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                "Welcome back, $name",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          );
        },
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.15),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
void _openSchemesOfWork(BuildContext context) {
  // If only one class, go straight in. Else show a picker.
  final classes = schoolClasses ?? [];
  if (classes.isEmpty) {
    _snack(context, 'No classes linked to your account');
    return;
  }
  if (classes.length == 1) {
    _navToSchemes(context, classes.first);
    return;
  }

  // Bottom sheet class picker
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a class',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...classes.map(
              (c) => ListTile(
                leading: Icon(Icons.school_rounded, color: mainColor),
                title: Text(c['className'] ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  _navToSchemes(context, c);
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _navToSchemes(BuildContext context, Map<String, dynamic> cls) {
  if (!_isLargeScreen) Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SchemesOfWorkScreen(
        schoolId: widget.schoolId,
        classId: cls['classId'] ?? '',
        className: cls['className'] ?? '',
        teacherUid: FirebaseAuth.instance.currentUser?.uid ?? '',
        teacherName: 'Head Teacher',
        role: 'headteacher',
      ),
    ),
  );
}
  // ─────────────────────────────────────────────────────────────
  // DRAWER
  // ─────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final firstName = data['firstName'] ?? '';
        final secondName = data['secondName'] ?? '';
        final role = data['role'] ?? '';
        final userSchoolId = data['schoolId'] ?? '';

        return Drawer(
          backgroundColor: Colors.white,
          elevation: 0,
          width: _isLargeScreen ? 300 : null,
          child: Column(
            children: [
              _buildDrawerHeader(firstName, secondName, role),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    // ================= NAVIGATION =================
                    _buildDrawerSection("NAVIGATION"),
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      title: 'Dashboard',
                      isActive: true,
                      onTap: () {
                        if (!_isLargeScreen) Navigator.pop(context);
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.tune_rounded,
                      title: 'Settings',
                      onTap: () {
                        if (!_isLargeScreen) Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsTeacher(),
                          ),
                        );
                      },
                    ),
                    _buildAboutSchoolItem(userSchoolId, context),

                    const SizedBox(height: 8),
                    Divider(color: Colors.grey.shade100, height: 1),
                    const SizedBox(height: 8),

                    // ================= ACADEMICS =================
                    _buildDrawerSection("ACADEMICS"),

                    // ---- PLANNING ----
                    _buildDrawerGroup(
                      icon: Icons.event_note_rounded,
                      title: 'Planning',
                      color: const Color(0xFF00695C),
                      children: [
                        _buildSubItem(
                          icon: Icons.description_outlined,
                          title: 'Schemes of Work',
                            onTap: () => _openSchemesOfWork(context),
                        ),
                       
                        _buildSubItem(
                          icon: Icons.menu_book_rounded,
                          title: 'Lesson Plans',
                          onTap: () => _snack(context, 'Lesson Plans'),
                        ),
                        _buildSubItem(
                          icon: Icons.schedule_rounded,
                          title: 'Timetables',
                          onTap: () => _snack(context, 'Timetables'),
                        ),
                      ],
                    ),

                    // ---- SCHEDULING ----
                    _buildDrawerGroup(
                      icon: Icons.calendar_month_rounded,
                      title: 'Scheduling',
                      color: const Color(0xFF1E88E5),
                      children: [
                        _buildSubItem(
                          icon: Icons.supervisor_account_rounded,
                          title: 'Supervision Record',
                          onTap: () => _snack(context, 'Supervision Record'),
                        ),
                      ],
                    ),

                    // ---- ASSESSMENT ----
                    _buildDrawerGroup(
                      icon: Icons.assignment_turned_in_rounded,
                      title: 'Assessment',
                      color: const Color(0xFFF57C00),
                      children: [
                        // ✅ NOW NAVIGATES TO HeadteacherAssessment
                        _buildSubItem(
                          icon: Icons.grading_rounded,
                          title: 'Marksheets (Exams)',
                          onTap: () {
                            if (!_isLargeScreen) Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HeadteacherAssessment(
                                  classes: widget.classes,
                                  approve: widget.approve,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildSubItem(
                          icon: Icons.fact_check_outlined,
                          title: 'Marksheets (CA)',
                          onTap: () => _snack(context, 'Marksheets (CA)'),
                        ),
                        _buildSubItem(
                          icon: Icons.psychology_outlined,
                          title: 'Conduct of Learner',
                          onTap: () => _snack(context, 'Conduct of Learner'),
                        ),
                      ],
                    ),

                    // ---- REPORTS ----
                    _buildDrawerGroup(
                      icon: Icons.assessment_rounded,
                      title: 'Reports',
                      color: const Color(0xFF8E24AA),
                      children: [
                        _buildSubItem(
                          icon: Icons.card_membership_rounded,
                          title: 'Report Card (Academics)',
                          onTap: () =>
                              _snack(context, 'Report Card (Academics)'),
                        ),
                        _buildSubItem(
                          icon: Icons.stars_rounded,
                          title: 'Report Card (Skills)',
                          onTap: () => _snack(context, 'Report Card (Skills)'),
                        ),
                        // ✅ NOW NAVIGATES TO HeadteacherStat
                        _buildSubItem(
                          icon: Icons.insights_rounded,
                          title: 'Academic Statistics',
                          onTap: () {
                            if (!_isLargeScreen) Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HeadteacherStat(
                                  classes: widget.classes,
                                  approve: widget.approve,
                                  schoolId: widget.schoolId,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // ---- PROJECTS ----
                    _buildDrawerGroup(
                      icon: Icons.school_rounded,
                      title: 'Projects',
                      color: const Color(0xFFE53935),
                      children: [
                        _buildSubItem(
                          icon: Icons.folder_special_rounded,
                          title: 'Project Work Records',
                          onTap: () =>
                              _snack(context, 'Project Work Records'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Divider(color: Colors.grey.shade100, height: 1),
                    const SizedBox(height: 8),

                    // ================= OPERATIONS =================
                    _buildDrawerSection("OPERATIONS"),

                    _buildDrawerItem(
                      icon: Icons.inventory_2_rounded,
                      title: 'Inventory Management',
                      onTap: () {
                        if (!_isLargeScreen) Navigator.pop(context);
                        _snack(context, 'Inventory Management');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.local_library_rounded,
                      title: 'Library',
                      onTap: () {
                        if (!_isLargeScreen) Navigator.pop(context);
                        _snack(context, 'Library');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.directions_bus_rounded,
                      title: 'Transport',
                      onTap: () {
                        if (!_isLargeScreen) Navigator.pop(context);
                        _snack(context, 'Transport');
                      },
                    ),

                    // ---- ELECTIONS (drawer only) ----
                    _buildDrawerItem(
                      icon: Icons.how_to_vote_rounded,
                      title: 'Elections',
                      onTap: () {
                        if (!_isLargeScreen) Navigator.pop(context);
                        _snack(context, 'Elections');
                      },
                    ),

                    const SizedBox(height: 8),
                    Divider(color: Colors.grey.shade100, height: 1),
                    const SizedBox(height: 8),

                    // ================= ACCOUNT =================
                    _buildDrawerSection("ACCOUNT"),
                    _buildDrawerItem(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      color: Colors.red.shade400,
                      onTap: () => logout(context),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Banco Mobile v1.0.0',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // DRAWER HELPERS
  // ─────────────────────────────────────────────────────────────

  Widget _buildDrawerGroup({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.only(left: 8, bottom: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        iconColor: color,
        collapsedIconColor: Colors.grey.shade500,
        children: children,
      ),
    );
  }

  Widget _buildSubItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDrawerHeader(String firstName, String secondName, String role) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.25)!],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$firstName $secondName",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade400,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAboutSchoolItem(String userSchoolId, BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Schools')
          .doc(userSchoolId)
          .snapshots(),
      builder: (context, schoolSnapshot) {
        if (!schoolSnapshot.hasData) return const SizedBox();
        final data = schoolSnapshot.data!.data() as Map<String, dynamic>? ?? {};

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Schools')
              .doc(userSchoolId)
              .collection('staffMembers')
              .snapshots(),
          builder: (context, staffSnapshot) {
            if (!staffSnapshot.hasData) return const SizedBox();
            final staffMembersList = staffSnapshot.data!.docs.map((doc) {
              final m = doc.data() as Map<String, dynamic>;
              return StaffMember(
                uid: m['teacherUid'],
                firstName: m['firstName'] ?? '',
                secondName: m['secondName'] ?? '',
                role: m['role'] ?? '',
                phone: m['phone'] ?? '',
              );
            }).toList();

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Schools')
                  .doc(userSchoolId)
                  .collection('linkedParents')
                  .snapshots(),
              builder: (context, parentsSnp) {
                final linkedParentsList = parentsSnp.hasData
                    ? parentsSnp.data!.docs.map((doc) {
                        final p = doc.data() as Map<String, dynamic>;
                        return LinkedParent(
                          phone: p['phone'] ?? '',
                          email: p['email'] ?? '',
                          firstName: p['firstName'] ?? '',
                          secondName: p['secondName'] ?? '',
                          fcmToken: p['fcmToken'] ?? '',
                          parentUid: p['parentUid'] ?? '',
                        );
                      }).toList()
                    : <LinkedParent>[];

                return _buildDrawerItem(
                  icon: Icons.account_balance_rounded,
                  title: 'About School',
                  onTap: () {
                    if (!_isLargeScreen) Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutSchool(
                          schoolName: data['school_name'] ?? '',
                          pobox: data['pobox'] ?? '',
                          address: data['address'] ?? '',
                          moto: data['moto'] ?? '',
                          contact: data['contact'] ?? '',
                          email: data['email'] ?? '',
                          subscription: data['subscription'] ?? '',
                          d1Start: data['D1Start'] ?? 0,
                          d1End: data['D1End'] ?? 0,
                          d2Start: data['D2Start'] ?? 0,
                          d2End: data['D2End'] ?? 0,
                          c3Start: data['c3Start'] ?? 0,
                          c3End: data['c3End'] ?? 0,
                          c4Start: data['c4Start'] ?? 0,
                          c4End: data['c4End'] ?? 0,
                          c5Start: data['c5Start'] ?? 0,
                          c5End: data['c5End'] ?? 0,
                          c6Start: data['c6Start'] ?? 0,
                          c6End: data['c6End'] ?? 0,
                          p7Start: data['p7Start'] ?? 0,
                          p7End: data['p7End'] ?? 0,
                          p8Start: data['p8Start'] ?? 0,
                          p8End: data['p8End'] ?? 0,
                          f9Start: data['f9Start'] ?? 0,
                          f9End: data['f9End'] ?? 0,
                          staffMembers: staffMembersList,
                          linkedParents: linkedParentsList,
                          schoolId: userSchoolId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? mainColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? mainColor.withOpacity(0.12)
                : (color ?? Colors.grey.shade700).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isActive ? mainColor : (color ?? Colors.grey.shade600),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? mainColor : (color ?? const Color(0xFF2D3748)),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: isActive
            ? Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        dense: true,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // DASHBOARD CONTENT
  // ─────────────────────────────────────────────────────────────
  Widget _buildDashboardContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Schools')
                .doc(schoolId)
                .snapshots(),
            builder: (context, schoolSnapshot) {
              if (!schoolSnapshot.hasData) return const SizedBox(height: 16);
              final data =
                  schoolSnapshot.data!.data() as Map<String, dynamic>? ?? {};
              return _buildHeroHeader(
                schoolName: data['school_name'] ?? '',
              );
            },
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A202C),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildDashboardCard(menuItems[index], index),
              childCount: menuItems.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _isLargeScreen ? 3 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.88,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // HERO HEADER (with NOW TEACHING card)
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeroHeader({
    required String schoolName,
  }) {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? "Good Morning"
        : now.hour < 17
        ? "Good Afternoon"
        : "Good Evening";
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    // Design-only placeholders — swap with Firestore later
    const currentSubject = 'Biology';
    const currentTeacher = 'Mr. Okello';
    const currentClass = 'Form 2A';
    const currentRoom = 'Lab 1';
    const periodLabel = 'Period 3 · 10:20 – 11:00';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            mainColor,
            Color.lerp(mainColor, const Color(0xFF000033), 0.3)!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wb_sunny_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schoolName.isNotEmpty ? schoolName : 'Your School',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // ── NOW TEACHING CARD ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.20),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF69F0AE),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "NOW TEACHING",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            periodLabel,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.science_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentSubject,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "$currentTeacher  ·  $currentClass",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoChip(
                            icon: Icons.meeting_room_rounded,
                            label: currentRoom,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: Icons.people_alt_rounded,
                            label: '32 learners',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(DashboardItem item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => _navigateToMenuItem(item),
        child: Container(
          decoration: BoxDecoration(
            gradient: item.gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: item.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  item.icon,
                  size: 90,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Positioned(
                left: -10,
                top: -10,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(item.icon, size: 26, color: Colors.white),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.title == 'Notifications') _buildNotificationBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBadge() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId ?? 'defaultSchoolId')
          .collection('notifications')
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        if (count == 0) return const SizedBox.shrink();
        return Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading dashboard...',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // QUICK ACTION NAVIGATION
  // ─────────────────────────────────────────────────────────────
  void _navigateToMenuItem(DashboardItem item) {
    switch (item.title) {
      case 'Results':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeadteacherClasses(
              classes: widget.classes,
              approve: widget.approve,
            ),
          ),
        );
        break;
      case 'School Fees':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchoolFees(),
          ),
        );
        break;
      case 'Attendance':
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AttendanceScreen(schoolId: widget.schoolId, today: today),
          ),
        );
        break;
      case 'Notifications':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeadTeacherTabs(schoolId: schoolId!),
          ),
        );
        break;
      // ── NEW Quick Actions ──
      case 'Inventory':
        _snack(context, 'Inventory Management');
        break;
      case 'Library':
        _snack(context, 'Library');
        break;
      case 'Transport':
        _snack(context, 'Transport');
        break;
    }
  }
}

class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;

  DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}