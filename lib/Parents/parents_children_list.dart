// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/Parents/ChildAttendance/pick_child.dart';
import 'package:banco_mobile/Events/events_first_screen.dart';
import 'package:banco_mobile/Parents/about_school_parent.dart';
import 'package:banco_mobile/Parents/children_results.dart';
import 'package:banco_mobile/Parents/nottifications.dart';
import 'package:banco_mobile/Parents/parent_settings_page.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentsChildrenList extends StatefulWidget {
  final String approve;
  final String schoolname;

  const ParentsChildrenList({
    super.key,
    required this.approve,
    required this.schoolname,
  });

  @override
  State<ParentsChildrenList> createState() => _ParentsChildrenListState();
}

class _ParentsChildrenListState extends State<ParentsChildrenList> {
  int currentIndex = 0;

  final Color primaryColor = const Color(0xFF2E3E5C); // Dark Blue/Slate
  final Color accentColor = const Color(0xFF1E88E5); // Bright Blue
  Future<void> _refreshPage() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Widget _buildDrawer(String uid) {
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
      final schoolId = data['schoolId'] ?? '';
      final isLargeScreen = MediaQuery.of(context).size.width >= 600;
      
      return Drawer(
        backgroundColor: Colors.white,
        elevation: 0,
        width: isLargeScreen ? 300 : null,
        child: Column(
          children: [
            _buildDrawerHeader(firstName, secondName, role),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerSection("NAVIGATION"),
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    isActive: currentIndex == 0,
                    onTap: () {
                      if (!isLargeScreen) Navigator.pop(context);
                      setState(() {
                        currentIndex = 0;
                      });
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics_rounded,
                    title: 'Results',
                    isActive: currentIndex == 1,
                    onTap: () {
                      if (!isLargeScreen) Navigator.pop(context);
                      setState(() {
                        currentIndex = 0; // Results tab
                      });
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'Events',
                    isActive: currentIndex == 2,
                    onTap: () {
                      if (!isLargeScreen) Navigator.pop(context);
                      setState(() {
                        currentIndex = 1; // Events tab
                      });
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.check_circle_rounded,
                    title: 'Attendance',
                    isActive: currentIndex == 3,
                    onTap: () {
                      if (!isLargeScreen) Navigator.pop(context);
                      setState(() {
                        currentIndex = 2; // Attendance tab
                      });
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_active_rounded,
                    title: 'Alerts',
                    isActive: currentIndex == 4,
                    onTap: () {
                      if (!isLargeScreen) Navigator.pop(context);
                      setState(() {
                        currentIndex = 3; // Alerts tab
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 8),
                  _buildDrawerSection("ACCOUNT"),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    onTap: () {
                      if (!isLargeScreen) Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ParentEditProfilePage()),
                      );
                    },
                  ),
                  _buildAboutSchoolItem(schoolId, context),
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
                    color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          letterSpacing: 1.2),
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
            color: isActive ? mainColor : (color ?? Colors.grey.shade600),
            size: 20),
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

Widget _buildAboutSchoolItem(String schoolId, BuildContext context) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('Schools')
        .doc(schoolId)
        .snapshots(),
    builder: (context, schoolSnapshot) {
      if (!schoolSnapshot.hasData) return const SizedBox();
      final data = schoolSnapshot.data!.data() as Map<String, dynamic>? ?? {};

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Schools')
            .doc(schoolId)
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

          return _buildDrawerItem(
            icon: Icons.account_balance_rounded,
            title: 'About School',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutSchoolParent(
                    firstName: '',
                    secondName: '',
                    schoolId: schoolId,
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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      drawer: _buildDrawer(uid),

      // backgroundColor: mainColor,`
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          schoolname,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: _getSelectedView(),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            currentIndex: currentIndex,
            onTap: (value) {
              setState(() {
                currentIndex = value;
              });
            },
            selectedItemColor: accentColor,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedItemColor: Colors.grey,
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            showUnselectedLabels: true,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.analytics_outlined),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.analytics),
                ),
                label: 'Results',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.calendar_today_outlined),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.calendar_month),
                ),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.check_circle_outline),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.check_circle),
                ),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(uid) // replace with dynamic schoolId if needed
                      .collection('inbox')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int count = snapshot.hasData
                        ? snapshot.data!.docs.length
                        : 0;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Icon(Icons.notifications_outlined),
                        ),
                        if (count != 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 15,
                                minHeight: 15,
                              ),
                              child: Center(
                                child: Text(
                                  count > 99 ? '99+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                activeIcon: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(uid) // replace with dynamic schoolId if needed
                      .collection('inbox')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    int count = snapshot.hasData
                        ? snapshot.data!.docs.length
                        : 0;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Icon(Icons.notifications),
                        ),
                        if (count != 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 15,
                                minHeight: 15,
                              ),
                              child: Center(
                                child: Text(
                                  count > 99 ? '99+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                label: 'Alerts',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getSelectedView() {
    if (currentIndex == 0) return ChildrenResults(approve: widget.approve);
    if (currentIndex == 1) return EventsFirstScreen(approve: widget.approve);
    if (currentIndex == 2) return PickChild(approve: widget.approve);
    return Nottifications(approve: widget.approve);
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthStudent()),
      (route) => false,
    );
  }
}
