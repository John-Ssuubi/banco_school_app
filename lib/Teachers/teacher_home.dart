// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/HeadTeacher/about_school.dart';
import 'package:banco_mobile/HeadTeacher/staff_members.dart';
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

  static const Color primaryColor = Color(0xFF2E3E5C);
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
              return  Scaffold(
                backgroundColor: mainColor,
                body: Center(child: Text('Unable to load user data', style: TextStyle(color: mainColor), )),
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
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: _getSelectedView(userData),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: mainColor,
      elevation: 0,
      centerTitle: true,
      title:  Text(
        schoolname,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      // iconTheme: const IconThemeData(color: primaryColor),
     
  }

  Container _buildDrawer() {
    return   Container(
      color: Colors.white,

      
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
            final schoolId = data['schoolId'] ?? '';
      
            return Drawer(
              
              // backgroundColor: mainColor,
              // width: double.infinity - 20,
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: mainColor),
                    accountName: Text(
                      "$firstName $secondName",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: Text(
                      role.toUpperCase(), // e.g HEADTEACHER / TEACHER
                      style: const TextStyle(fontSize: 13),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.school, size: 45, color: mainColor),
                    ),
                  ),
      
                  ListTile(
                    leading: const Icon(Icons.home,
                    color: Colors.black,),
                    title: const Text('Home', style: TextStyle(color: Colors.black),),
                    onTap: () => Navigator.pop(
                      context,
                      // MaterialPageRoute(builder: (context) => const HomePage())
                    ),
                  ),
      
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text('Settings', style: TextStyle(color: Colors.black),),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsTeacher()),
                    ),
                  ),
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      logout(context);
                    },
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.logout, color: Colors.black),
                      ),
                      title: const Text('Logout', style: TextStyle(color: Colors.black),),
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Schools', )
                        .doc(schoolId)
                        // .where(
                        //   'Banco Primary Schools',
                        //   isEqualTo: 'Banco Primary Schools',
                        // )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
      
                      final data = snapshot.data;
      
                      final schoolName = data?['school_name'];
                      final contact = data?['contact'] ?? '';
                      final address = data?['address'] ?? '';
                      final moto = data?['moto'] ?? '';
                      final pobox = data?['pobox'] ?? '';
                      final email = data?['email'] ?? '';
                      final subscription = data?['subscription'] ?? '';
                      final d1Start = data?['D1Start'] ?? 0;
                      final d1End = data?['D1End'] ?? 0;
                      final d2Start = data?['D2Start'] ?? 0;
                      final d2End = data?['D2End'] ?? 0;
                      final c3Start = data?['c3Start'] ?? 0;
                      final c3End = data?['c3End'] ?? 0;
                      final c4Start = data?['c4Start'] ?? 0;
                      final c4End = data?['c4End'] ?? 0;
                      final c5Start = data?['c5Start'] ?? 0;
                      final c5End = data?['c5End'] ?? 0;
                      final c6Start = data?['c6Start'] ?? 0;
                      final c6End = data?['c6End'] ?? 0;
                      final p7Start = data?['p7Start'] ?? 0;
                      final p7End = data?['p7End'] ?? 0;
                      final p8Start = data?['p8Start'] ?? 0;
                      final p8End = data?['p8End'] ?? 0;
                      final f9Start = data?['f9Start'] ?? 0;
                      final f9End = data?['f9End'] ?? 0;
                      final staffMembers = data?['staffMembers'] ?? {};
                      final List<StaffMember> staffMembersList = staffMembers
                          .values
                          .map<StaffMember>(
                            (memberData) => StaffMember(
                              firstName: memberData['firstName'] ?? '',
                              secondName: memberData['secondName'] ?? '',
                              role: memberData['role'] ?? '',
                              phone: memberData['phone'] ?? '',
                            ),
                          )
                          .toList();
      
                      final linkedParentsData = data?['linkedParents'] ?? {};
      
                      final List<LinkedParent> linkedParentsList =
                          linkedParentsData.values.map<LinkedParent>(
                            (parentData) => LinkedParent(
                             
                              parentName: parentData['firstName'] ?? '',
                               fcmToken: parentData['fcmToken'] ?? '',
                            ),
                          ).toList();
      
                      // final role = data['role'] ?? '';
      
                      return ListTile(
                        leading: const Icon(Icons.info, color: Colors.black),
                        title: const Text('About School', style: TextStyle(color: Colors.black),),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutSchool(
                              schoolName: schoolName,
                              pobox: pobox,
                              address: address,
                              moto: moto,
                              contact: contact,
                              email: email,
                              subscription: subscription,
                              d1Start: d1Start,
                              d1End: d1End,
                              d2Start: d2Start,
                              d2End: d2End,
                              c3Start: c3Start,
                              c3End: c3End,
                              c4Start: c4Start,
                              c4End: c4End,
                              c5Start: c5Start,
                              c5End: c5End,
                              c6Start: c6Start,
                              c6End: c6End,
                              p7Start: p7Start,
                              p7End: p7End,
                              p8Start: p8Start,
                              p8End: p8End,
                              f9Start: f9Start,
                              f9End: f9End,
                              staffMembers: staffMembersList,
                              linkedParents: linkedParentsList,
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
        ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.grey,
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
    );
  }

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
        return TeacherClassesStat(approve: widget.approve, classes: userData['linkedClasses'] ?? [], schoolId:  userData['schoolId'] ?? '',);
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
