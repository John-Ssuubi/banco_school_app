// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_field

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/HeadTeacher/about_school.dart';
import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/Notifications/local_notifications.dart';
import 'package:banco_mobile/Teachers/teacher_classes_stat.dart';
import 'package:banco_mobile/Teachers/SettingsTeacher/settings_teacher.dart';
import 'package:banco_mobile/Teachers/attendance_Teacher.dart';
import 'package:banco_mobile/Teachers/events_teacher.dart';
import 'package:banco_mobile/Teachers/teacher_classes.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherHome extends StatefulWidget {
  final String approve;
  final String schoolname;

  const TeacherHome({
    super.key,
    required this.approve,
    required this.schoolname,
  });

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  int currentIndex = 0;

  static const Color accentColor = Color(0xFF1E88E5);

  @override
  void initState() {
    super.initState();
    AwesomeNotificationsEngine.scheduledNotificationAwesome();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }

        if (!authSnapshot.hasData) {
          return const AuthStudent();
        }

        final uid = authSnapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _Loading();
            }

            if (userSnapshot.hasError || !userSnapshot.data!.exists) {
              return Scaffold(
                backgroundColor: mainColor,
                body: Center(
                  child: Text(
                    'Unable to load user data',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            final userData =
                userSnapshot.data!.data() as Map<String, dynamic>;

            return _buildScaffold(userData);
          },
        );
      },
    );
  }

  Scaffold _buildScaffold(Map<String, dynamic> userData) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: _getSelectedView(userData),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  

  // ─── AppBar ────────────────────────────────────────────────────────────────

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
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.schoolname,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const Text(
            'Teacher Portal',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.6), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
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
        final schoolId = data['schoolId'] ?? '';

        return Drawer(
          backgroundColor: Colors.white,
          elevation: 0,
          child: Column(
            children: [
              _buildDrawerHeader(firstName, secondName, role),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildDrawerSection('NAVIGATION'),
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      title: 'Home',
                      isActive: true,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      icon: Icons.tune_rounded,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsTeacher()),
                        );
                      },
                    ),
                    _buildAboutSchoolItem(schoolId, context),
                    const SizedBox(height: 8),
                    Divider(color: Colors.grey.shade100, height: 1),
                    const SizedBox(height: 8),
                    _buildDrawerSection('ACCOUNT'),
                    _buildDrawerItem(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      color: Colors.red.shade400,
                      onTap: () => _confirmLogout(context),
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
                    Text(
                      'Banco Mobile v1.0.0',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 11),
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

  Widget _buildDrawerHeader(
      String firstName, String secondName, String role) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.25)!],
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
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white24,
              child:
                  Icon(Icons.person_rounded, color: Colors.white, size: 30),
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
                    color: Colors.white,
                  ),
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
        color:
            isActive ? mainColor.withOpacity(0.08) : Colors.transparent,
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
            color: isActive
                ? mainColor
                : (color ?? const Color(0xFF2D3748)),
            fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w500,
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        dense: true,
      ),
    );
  }

  Widget _buildAboutSchoolItem(String schoolId, BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .snapshots(),
      builder: (context, schoolSnapshot) {
        if (!schoolSnapshot.hasData) return const SizedBox();
        final data =
            schoolSnapshot.data!.data() as Map<String, dynamic>? ?? {};

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Schools')
              .doc(schoolId)
              .collection('staffMembers')
              .snapshots(),
          builder: (context, staffSnapshot) {
            if (!staffSnapshot.hasData) return const SizedBox();

            final staffMembersList =
                staffSnapshot.data!.docs.map((doc) {
              final m = doc.data() as Map<String, dynamic>;
              return StaffMember(
                uid: m['teacherUid'],
                firstName: m['firstName'] ?? '',
                secondName: m['secondName'] ?? '',
                role: m['role'] ?? '',
                phone: m['phone'] ?? '',
              );
            }).toList();

            return _buildDrawerItem(
              icon: Icons.account_balance_rounded,
              title: 'About School',
              onTap: () {
                Navigator.pop(context);
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
                      linkedParents: const [],
                      schoolId: schoolId,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          barrierColor: Colors.black54,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
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
                    child: Icon(Icons.logout_rounded,
                        color: Colors.red.shade600, size: 32),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to sign out of your account?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            side: BorderSide(
                                color: Colors.grey.shade300),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.grey.shade700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
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

    if (shouldLogout) {
      await logout(context);
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthStudent()),
      (_) => false,
    );
  }

  // ─── Bottom Nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: mainColor,
        unselectedItemColor: Colors.grey.shade400,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Results',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }

  // ─── Views ─────────────────────────────────────────────────────────────────

  Widget _getSelectedView(Map<String, dynamic> userData) {
    switch (currentIndex) {
      case 0:
        return TeacherClasses(
          approve: widget.approve,
          classes: userData['linkedClasses'] ?? [],
        );
      case 1:
        return EventsTeacher(schoolId: userData['schoolId'] ?? '');
      case 2:
        return AttendanceTeacher(
          schoolId: userData['schoolId'] ?? '',
          date: DateTime.now().toIso8601String().split('T').first,
        );
      default:
        return TeacherClassesStat(
          approve: widget.approve,
          classes: userData['linkedClasses'] ?? [],
          schoolId: userData['schoolId'] ?? '',
        );
    }
  }
}

// ─── Loading Widget ──────────────────────────────────────────────────────────

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
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
                  )
                ],
              ),
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(mainColor),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading...',
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
}