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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      drawer: StreamBuilder(
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
                    child: Icon(Icons.person, size: 45, color: mainColor),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () => Navigator.pop(
                    context,
                    // MaterialPageRoute(builder: (context) => const HomePage())
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ParentEditProfilePage()),
                  ),
                ),
                // Text(
                //   'Account',
                //   style: TextStyle(
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //     color: mainColor,
                //   ),
                // ),
                InkWell(
                  onTap: () {
                    logout(context);
                  },
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: const Text('Logout'),
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Schools')
                      .doc(schoolId)
                      .snapshots(),
                  builder: (context, schoolSnapshot) {
                    if (!schoolSnapshot.hasData) return const SizedBox();

                    final data =
                        schoolSnapshot.data!.data() as Map<String, dynamic>? ??
                        {};

                    final schoolName = data['school_name'] ?? '';
                    final contact = data['contact'] ?? '';
                    final address = data['address'] ?? '';
                    final moto = data['moto'] ?? '';
                    final pobox = data['pobox'] ?? '';
                    final email = data['email'] ?? '';
                    final subscription = data['subscription'] ?? '';

                    final d1Start = data['D1Start'] ?? 0;
                    final d1End = data['D1End'] ?? 0;
                    final d2Start = data['D2Start'] ?? 0;
                    final d2End = data['D2End'] ?? 0;
                    final c3Start = data['c3Start'] ?? 0;
                    final c3End = data['c3End'] ?? 0;
                    final c4Start = data['c4Start'] ?? 0;
                    final c4End = data['c4End'] ?? 0;
                    final c5Start = data['c5Start'] ?? 0;
                    final c5End = data['c5End'] ?? 0;
                    final c6Start = data['c6Start'] ?? 0;
                    final c6End = data['c6End'] ?? 0;
                    final p7Start = data['p7Start'] ?? 0;
                    final p7End = data['p7End'] ?? 0;
                    final p8Start = data['p8Start'] ?? 0;
                    final p8End = data['p8End'] ?? 0;
                    final f9Start = data['f9Start'] ?? 0;
                    final f9End = data['f9End'] ?? 0;

                    // 🔥 Nested staff stream
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Schools')
                          .doc(schoolId)
                          .collection('staffMembers')
                          .snapshots(),
                      builder: (context, staffSnapshot) {
                        if (!staffSnapshot.hasData) return const SizedBox();

                        final staffMembersList = staffSnapshot.data!.docs.map((
                          doc,
                        ) {
                          final memberData = doc.data() as Map<String, dynamic>;

                          return StaffMember(
                            firstName: memberData['firstName'] ?? '',
                            secondName: memberData['secondName'] ?? '',
                            role: memberData['role'] ?? '',
                            phone: memberData['phone'] ?? '',
                            uid: memberData['teacherUid'] ?? '',
                          );
                        }).toList();

                        return ListTile(
                          leading: const Icon(Icons.info, color: Colors.black),
                          title: const Text(
                            'About School',
                            style: TextStyle(color: Colors.black),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AboutSchoolParent(
                                firstName: firstName,
                                secondName: secondName,
                                schoolId: schoolId,
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
                                linkedParents: const [],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),

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
