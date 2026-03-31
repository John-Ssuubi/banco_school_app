// ignore_for_file: use_build_context_synchronously

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

class _AdminDashboardRevisedState extends State<AdminDashboardRevised> {
  int totalStudents = 0;
  int presentToday = 0;

  bool loading = true;

  List<LinkedParent> parentsList = [];
  List<StaffMember> staffList = [];

  @override
  void initState() {
    super.initState();

    AwesomeNotificationsEngine.scheduledNotificationAwesome();

    loadDashboardData();
    listenParents();
    listenStaff();
  }

  /* ================= LOGOUT ================= */

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthStudent()),
      (route) => false,
    );
  }

  /* ================= LISTENERS ================= */

  void listenParents() {
    FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('linkedParents')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();

        return LinkedParent(
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          firstName: data['firstName'] ?? '',
          secondName: data['secondName'] ?? '',
          fcmToken: data['fcmToken'] ?? '',
          parentUid: data['parentUid'] ?? '',
        );
      }).toList();

      if (mounted) {
        setState(() => parentsList = list);
      }
    });
  }

  void listenStaff() {
    FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('staffMembers')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();

        return StaffMember(
          uid: data['teacherUid'],
          firstName: data['firstName'] ?? '',
          secondName: data['secondName'] ?? '',
          role: data['role'] ?? '',
          phone: data['phone'] ?? '',
        );
      }).toList();

      if (mounted) {
        setState(() => staffList = list);
      }
    });
  }

  /* ================= DASHBOARD COUNTS ================= */

  Future<void> loadDashboardData() async {
    try {
      final schoolRef =
          FirebaseFirestore.instance.collection('Schools').doc(widget.schoolId);

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
      }
    } catch (e) {
      debugPrint("Dashboard Error: $e");

      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  /* ================= DRAWER ================= */

  Drawer buildDrawer() {
    return Drawer(
      child: StreamBuilder(
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

          return Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: mainColor),
                accountName: Text(
                  "$firstName $secondName",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(role.toUpperCase()),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.school, size: 40),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Home"),
                onTap: () => Navigator.pop(context),
              ),

              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsTeacher()),
                ),
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () => logout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  /* ================= INFO CARD ================= */

  Widget infoCard(String title, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 10),
          Text(title),
          const SizedBox(height: 5),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /* ================= PIE CHART ================= */

  Widget attendanceChart() {
    final absent = totalStudents - presentToday;

    return SizedBox(
      height: 240,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: presentToday.toDouble(),
              title: "Present",
              color: Colors.green,
              radius: 70,
            ),
            PieChartSectionData(
              value: absent.toDouble(),
              title: "Absent",
              color: Colors.red,
              radius: 70,
            ),
          ],
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),

      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /* ===== CARDS ===== */

                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.3,
                      ),

                      children: [

                        // Students
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminClasses(
                                classes: widget.classes,
                                approve: widget.approve,
                              ),
                            ),
                          ),
                          child: infoCard(
                            "Students",
                            totalStudents,
                            Icons.school,
                            Colors.blue,
                          ),
                        ),

                        // Parents
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminParent(
                                linkedParents: parentsList,
                                schoolId: widget.schoolId,
                              ),
                            ),
                          ),
                          child: infoCard(
                            "Parents",
                            parentsList.length,
                            Icons.family_restroom,
                            Colors.orange,
                          ),
                        ),

                        // Staff
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminStafflist(
                                schoolId: widget.schoolId,
                                staffMembers: staffList,
                              ),
                            ),
                          ),
                          child: infoCard(
                            "Teachers",
                            staffList.length,
                            Icons.person,
                            Colors.purple,
                          ),
                        ),

                        // Attendance
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminAttendance(
                                schoolId: widget.schoolId,
                                today: DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now()),
                              ),
                            ),
                          ),
                          child: infoCard(
                            "Present Today",
                            presentToday,
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /* ===== CHART ===== */

                    const Text(
                      "Attendance Today",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    attendanceChart(),

                    const SizedBox(height: 25),

                    /* ===== SUMMARY ===== */

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: ListTile(
                        leading: const Icon(Icons.analytics),

                        title: const Text("Summary"),

                        subtitle: Text(
                          "Total Students: $totalStudents\n"
                          "Present: $presentToday\n"
                          "Absent: ${totalStudents - presentToday}",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
