// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/admin/admin_attendance.dart';
import 'package:banco_mobile/admin/admin_dashboard_revised.dart';
import 'package:banco_mobile/admin/admin_notifications.dart';
import 'package:banco_mobile/admin/admin_stat.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  final String approve;
  final String schoolname;

  const AdminDashboard({
    super.key,
    required this.approve,
    required this.schoolname,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int currentIndex = 0;

  // static const Color primaryColor = Color(0xFF2E3E5C);
  static const Color accentColor = Color(0xFF1E88E5);

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
                    style: TextStyle(color: mainColor),
                  ),
                ),
              );
            }
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;

            return _buildScaffold(userData);
          },
        );
      },
    );
  }

  Scaffold _buildScaffold(Map<String, dynamic> userData) {
    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: _buildDrawer(),
      // appBar: _buildAppBar(),
      body: _getSelectedView(userData),
      bottomNavigationBar: _buildBottomNav(userData),
    );
  }

  

  

  Widget _buildBottomNav(Map<String, dynamic> userData) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.grey,
      onTap: (index) => setState(() => currentIndex = index),
      items: [
         BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          activeIcon: Icon(Icons.analytics),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Schools')
                .doc(userData['schoolId'] ?? 'defaultSchoolId')
                .collection('notifications')
                // .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
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
                .collection('Schools')
                .doc(
                  userData['schoolId'] ?? '',
                ) // replace with dynamic schoolId if needed
                .collection('notifications')
                // .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
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
       
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.bar_chart_outlined),
        //   activeIcon: Icon(Icons.bar_chart),
        //   label: 'Attendance',
        // ),
      ],
    );
  }

  Widget _getSelectedView(Map<String, dynamic> userData) {
    switch (currentIndex) {
      case 0:
          return AdminDashboardRevised(
          approve: widget.approve,
          classes: userData['linkedClasses'] ?? [],
          schoolId: userData['schoolId'] ?? '',
        );
      case 1:
      return AdminStat(
          approve: widget.approve,
          classes: userData['linkedClasses'] ?? [],
          schoolId: userData['schoolId'] ?? '',
        );
      case 2:
       
        return AdminNotifications(schoolId: userData['schoolId'] ?? '');
        
      default:
     return AdminAttendance(
          schoolId: userData['schoolId'] ?? '',
          today: DateTime.now().toIso8601String().split('T').first,
        );
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthStudent()),
      (_) => false,
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
