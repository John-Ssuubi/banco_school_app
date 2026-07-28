// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/Notifications/local_notifications.dart';
import 'package:banco_mobile/Teachers/SettingsTeacher/settings_teacher.dart';
import 'package:banco_mobile/admin/admin_attendance.dart';
import 'package:banco_mobile/admin/admin_parent.dart';
import 'package:banco_mobile/admin/admin_stafflist.dart';
import 'package:banco_mobile/admin/classes.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminDashboardRevised extends StatefulWidget {
  final String schoolId;
  final String approve;
  final List<dynamic>? classes;

  const AdminDashboardRevised({
    super.key,
    required this.schoolId,
    required this.approve,
    this.classes,
  });

  @override
  State<AdminDashboardRevised> createState() => _AdminDashboardRevisedState();
}

class _AdminDashboardRevisedState extends State<AdminDashboardRevised>
    with SingleTickerProviderStateMixin {
  int totalStudents = 0;
  int presentToday = 0;
  bool loading = true;

  List<LinkedParent> parentsList = [];
  List<StaffMember> staffList = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isLargeScreen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Metric card definitions
  late final List<_MetricCard> _cards;

  @override
  void initState() {
    super.initState();
    AwesomeNotificationsEngine.scheduledNotificationAwesome();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _cards = [
      _MetricCard(
        title: 'Students',
        icon: Icons.school_rounded,
        gradient: const [Color(0xFF1E88E5), Color(0xFF1565C0)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminClasses(
                classes: widget.classes, approve: widget.approve),
          ),
        ),
      ),
      _MetricCard(
        title: 'Parents',
        icon: Icons.family_restroom_rounded,
        gradient: const [Color(0xFFF57C00), Color(0xFFE65100)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminParent(
                linkedParents: parentsList, schoolId: widget.schoolId),
          ),
        ),
      ),
      _MetricCard(
        title: 'Teachers',
        icon: Icons.person_rounded,
        gradient: const [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminStafflist(
                schoolId: widget.schoolId, staffMembers: staffList),
          ),
        ),
      ),
      _MetricCard(
        title: 'Present Today',
        icon: Icons.check_circle_rounded,
        gradient: const [Color(0xFF00897B), Color(0xFF00695C)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminAttendance(
              schoolId: widget.schoolId,
              today: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            ),
          ),
        ),
      ),
    ];

    loadDashboardData();
    listenParents();
    listenStaff();
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
    final isLarge = MediaQuery.of(context).size.width >= 900;
    if (_isLargeScreen != isLarge) setState(() => _isLargeScreen = isLarge);
  }

  // ─── Data ──────────────────────────────────────────────────────────────────

  void listenParents() {
    FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('linkedParents')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        parentsList = snapshot.docs.map((doc) {
          final d = doc.data();
          return LinkedParent(
            phone: d['phone'] ?? '',
            email: d['email'] ?? '',
            firstName: d['firstName'] ?? '',
            secondName: d['secondName'] ?? '',
            fcmToken: d['fcmToken'] ?? '',
            parentUid: d['parentUid'] ?? '',
          );
        }).toList();
      });
    });
  }

  void listenStaff() {
    FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('staffMembers')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        staffList = snapshot.docs.map((doc) {
          final d = doc.data();
          return StaffMember(
            uid: d['teacherUid'],
            firstName: d['firstName'] ?? '',
            secondName: d['secondName'] ?? '',
            role: d['role'] ?? '',
            phone: d['phone'] ?? '',
          );
        }).toList();
      });
    });
  }

  Future<void> loadDashboardData() async {
    if (mounted) setState(() => loading = true);
    try {
      final schoolRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final studentsSnap = await schoolRef.collection('studentIndex').get();
      final attendanceSnap = await schoolRef
          .collection('attendance')
          .doc(today)
          .collection('students')
          .where('status', isEqualTo: 'present')
          .get();

      if (mounted) {
        setState(() {
          totalStudents = studentsSnap.docs.length;
          presentToday = attendanceSnap.docs.length;
          loading = false;
        });
        _fadeController.forward(from: 0);
      }
    } catch (e) {
      debugPrint('Dashboard Error: $e');
      if (mounted) setState(() => loading = false);
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black54,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.logout_rounded,
                        color: Colors.red.shade600, size: 32),
                  ),
                  const SizedBox(height: 20),
                  const Text('Sign Out',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  Text('Are you sure you want to sign out?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600)),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.grey.shade700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Sign Out',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600)),
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

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthStudent()),
        (route) => false,
      );
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _checkScreenSize();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _isLargeScreen ? null : _buildDrawer(),
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final content = loading
              ? _buildLoading()
              : RefreshIndicator(
                  onRefresh: loadDashboardData,
                  color: mainColor,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildHeroHeader()),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'Overview',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A202C),
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _buildMetricCard(i),
                              childCount: _cards.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.15,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverToBoxAdapter(child: _buildChartCard()),
                        SliverToBoxAdapter(child: _buildSummaryCard()),
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
                    ),
                  ),
                );

          if (_isLargeScreen) {
            return Row(
              children: [
                SizedBox(width: 300, child: _buildDrawer()),
                Expanded(child: content),
              ],
            );
          }
          return content;
        },
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: _isLargeScreen
          ? null
          : Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.2)!],
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin Dashboard',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3)),
          Text('School Management',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.6), width: 2),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Drawer ────────────────────────────────────────────────────────────────

  Widget _buildDrawer() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final firstName = data['firstName'] ?? '';
        final secondName = data['secondName'] ?? '';
        final role = data['role'] ?? '';

        return Drawer(
          backgroundColor: Colors.white,
          elevation: _isLargeScreen ? 0 : 16,
          width: _isLargeScreen ? 300 : null,
          child: Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      mainColor,
                      Color.lerp(mainColor, Colors.black, 0.25)!
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
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
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person_rounded,
                            color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$firstName $secondName',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
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
                                  letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _drawerSection('NAVIGATION'),
                    _drawerItem(
                      icon: Icons.dashboard_rounded,
                      title: 'Dashboard',
                      isActive: true,
                      onTap: () {
                        if (!_isLargeScreen) Navigator.pop(context);
                      },
                    ),
                    _drawerItem(
                      icon: Icons.tune_rounded,
                      title: 'Settings',
                      onTap: () {
                        if (!_isLargeScreen) Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SettingsTeacher()),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Divider(color: Colors.grey.shade100, height: 1),
                    const SizedBox(height: 8),
                    _drawerSection('ACCOUNT'),
                    _drawerItem(
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
                    Icon(Icons.shield_rounded,
                        size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text('Banco Mobile v1.0.0',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _drawerSection(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
                letterSpacing: 1.2)),
      );

  Widget _drawerItem({
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
          child: Icon(icon,
              color:
                  isActive ? mainColor : (color ?? Colors.grey.shade600),
              size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                color: isActive
                    ? mainColor
                    : (color ?? const Color(0xFF2D3748)),
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14)),
        trailing: isActive
            ? Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(2)),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        dense: true,
      ),
    );
  }

  // ─── Hero Header ───────────────────────────────────────────────────────────

  Widget _buildHeroHeader() {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final dateStr = DateFormat('EEEE, MMMM d').format(now);
    final absent = totalStudents - presentToday;
    final rate = totalStudents > 0
        ? (presentToday / totalStudents * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mainColor, Color.lerp(mainColor, const Color(0xFF000033), 0.3)!],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: mainColor.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 7)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25, top: -25,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05)),
            ),
          ),
          Positioned(
            right: 20, bottom: -35,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded,
                            color: Colors.amber, size: 13),
                        const SizedBox(width: 5),
                        Text(dateStr,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(greeting,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 2),
              const Text('Admin Dashboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              Row(
                children: [
                  _heroPill(
                      icon: Icons.check_circle_rounded,
                      label: 'Present',
                      value: '$presentToday'),
                  const SizedBox(width: 10),
                  _heroPill(
                      icon: Icons.cancel_rounded,
                      label: 'Absent',
                      value: '$absent'),
                  const SizedBox(width: 10),
                  _heroPill(
                      icon: Icons.percent_rounded,
                      label: 'Rate',
                      value: '$rate%'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroPill(
      {required IconData icon,
      required String label,
      required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1)),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Metric Cards ──────────────────────────────────────────────────────────

  int _valueForCard(int index) {
    switch (index) {
      case 0: return totalStudents;
      case 1: return parentsList.length;
      case 2: return staffList.length;
      case 3: return presentToday;
      default: return 0;
    }
  }

  Widget _buildMetricCard(int index) {
    final card = _cards[index];
    final value = _valueForCard(index);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + (index * 70)),
      curve: Curves.easeOut,
      builder: (ctx, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
            offset: Offset(0, 16 * (1 - v)), child: child),
      ),
      child: GestureDetector(
        onTap: card.onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: card.gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: card.gradient[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -14, bottom: -14,
                child: Icon(card.icon,
                    size: 80,
                    color: Colors.white.withOpacity(0.08)),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(card.icon,
                          size: 22, color: Colors.white),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$value',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1),
                        ),
                        const SizedBox(height: 2),
                        Text(card.title,
                            style: TextStyle(
                                fontSize: 12,
                                color:
                                    Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Chart ─────────────────────────────────────────────────────────────────

  Widget _buildChartCard() {
    final absent = totalStudents - presentToday;
    final hasData = totalStudents > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pie_chart_rounded,
                    color: mainColor, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Attendance Today',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: hasData
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          value: presentToday.toDouble(),
                          color: const Color(0xFF00897B),
                          radius: 60,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: absent.toDouble(),
                          color: Colors.red.shade400,
                          radius: 60,
                          title: '',
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Text('No data yet',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14)),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(color: const Color(0xFF00897B), label: 'Present'),
              const SizedBox(width: 24),
              _legend(color: Colors.red.shade400, label: 'Absent'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600)),
      ],
    );
  }

  // ─── Summary Card ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard() {
    final absent = totalStudents - presentToday;
    final rate = totalStudents > 0
        ? (presentToday / totalStudents * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.analytics_rounded,
                    color: mainColor, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Summary',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A202C))),
            ],
          ),
          const SizedBox(height: 16),
          _summaryRow('Total Students', '$totalStudents',
              Icons.school_rounded, const Color(0xFF1E88E5)),
          _summaryDivider(),
          _summaryRow('Present', '$presentToday',
              Icons.check_circle_rounded, const Color(0xFF00897B)),
          _summaryDivider(),
          _summaryRow('Absent', '$absent',
              Icons.cancel_rounded, Colors.red.shade400),
          _summaryDivider(),
          _summaryRow('Attendance Rate', '$rate%',
              Icons.percent_rounded, const Color(0xFF8E24AA)),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }

  Widget _summaryDivider() =>
      Divider(color: Colors.grey.shade100, height: 1);

  // ─── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
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
                    offset: const Offset(0, 8))
              ],
            ),
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text('Loading dashboard...',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Data Model ──────────────────────────────────────────────────────────────

class _MetricCard {
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  _MetricCard({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
}