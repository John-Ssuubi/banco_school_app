// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/HeadTeacher/Assessment/headteacher_assessment.dart';
import 'package:banco_mobile/HeadTeacher/Results/headteacher_classes.dart';
import 'package:banco_mobile/HeadTeacher/about_school.dart';
import 'package:banco_mobile/HeadTeacher/attendance.dart';
import 'package:banco_mobile/HeadTeacher/headteacher_stat.dart';
import 'package:banco_mobile/HeadTeacher/headteachernotificatios.dart';
import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/Notifications/local_notifications.dart';
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

class _HeadTeacherDashboardState extends State<HeadTeacherDashboard> {
  String? schoolId;
  List<Map<String, dynamic>>? schoolClasses = [];

  Future<void> loadData() async {
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
          // pick the first school's ID
          if (classes.isNotEmpty) {
            schoolId = classes.first['schoolId'];
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data');
      }
    }
  }

  // Future<void> logout(BuildContext context) async {
  //   await FirebaseAuth.instance.signOut();

  //   // Navigate to AuthScreen (or your login screen)
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => const AuthStudent()),
  //     (route) => false, // remove all previous routes
  //   );
  // }

  Future<void> logout(BuildContext context) async {
    final shouldLogout = await confirmLogout(context);
    if (!shouldLogout) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      // ignore: unused_local_variable
      final uid = user?.uid;

      // 1️⃣ Remove FCM token from Firestore
      // if (uid != null) {
      //   await FirebaseFirestore.instance.collection("users").doc(uid).update({
      //     "fcmToken": FieldValue.delete(),
      //     "lastLogout": FieldValue.serverTimestamp(),
      //   });
      // }

      // // 2️⃣ Unsubscribe from topics (important for school-wide notifications)
      // await FirebaseMessaging.instance.unsubscribeFromTopic("all");
      // await FirebaseMessaging.instance.unsubscribeFromTopic("teachers");
      // await FirebaseMessaging.instance.unsubscribeFromTopic("parents");

      // 3️⃣ Clear local storage (offline data)
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();

      // 4️⃣ Firebase sign out
      await FirebaseAuth.instance.signOut();

      // 5️⃣ Navigate to login & remove back stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthStudent()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logout failed")));
    }
  }

  Future<bool> confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void initState()  {
    super.initState();
    AwesomeNotificationsEngine.scheduledNotificationAwesome();
    // AwesomeNotificationsEngine.showAwesomeNotification();
    // LocalNotifications.showNotification();
    // ZonedNotifications.showZonedNotification();
    loadData();
  }

  // int count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        actions: [],
        title: const Text(
          "Head Teacher ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 1,
      ),

      backgroundColor: Colors.grey[100],
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
                    MaterialPageRoute(builder: (context) => SettingsTeacher()),
                  ),
                ),

                InkWell(
                  onTap: () {
                    logout(context);
                  },
                  child: ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.logout),
                    ),
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
                            uid: memberData['teacherUid'],
                            firstName: memberData['firstName'] ?? '',
                            secondName: memberData['secondName'] ?? '',
                            role: memberData['role'] ?? '',
                            phone: memberData['phone'] ?? '',
                          );
                        }).toList();

                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Schools')
                              .doc(schoolId)
                              .collection('linkedParents')
                              .snapshots(),

                          builder: (context, parentsSnp) {
                            final linkedParentsList = parentsSnp.hasData
                                ? parentsSnp.data!.docs.map((doc) {
                                    final parentData = doc.data();

                                    return LinkedParent(
                                      phone: parentData['phone'] ?? '',
                                      email: parentData['email'] ?? '',
                                      firstName: parentData['firstName'] ?? '',
                                      secondName:
                                          parentData['secondName'] ?? '',
                                      fcmToken: parentData['fcmToken'] ?? '',
                                      parentUid: parentData['parentUid'] ?? '',
                                    );
                                  }).toList()
                                : <LinkedParent>[];
                            return ListTile(
                              leading: const Icon(
                                Icons.info,
                                color: Colors.black,
                              ),
                              title: const Text(
                                'About School',
                                style: TextStyle(color: Colors.black),
                              ),
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
                                    schoolId: schoolId,
                                  ),
                                ),
                              ),
                            );
                          },
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
      body: Container(
        color: Colors.white60,
        child: Center(
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),

                child: GridTile(
                  // header: Text('Classes Assigned', style: TextStyle(fontWeight: FontWeight.bold),),
                  child: InkWell(
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: mainColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.class_, size: 40, color: Colors.white),
                          SizedBox(height: 5),
                          Text(
                            'Results',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HeadteacherClasses(
                            classes: widget.classes,
                            approve: widget.approve,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),

                child: GridTile(
                  // header: Text('Classes Assigned', style: TextStyle(fontWeight: FontWeight.bold),),
                  child: InkWell(
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: mainColor,

                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.check_circle,
                            size: 40,
                            color: Colors.white,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Attendance',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      final today = DateFormat(
                        'yyyy-MM-dd',
                      ).format(DateTime.now());

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceScreen(
                            schoolId: widget.schoolId, // from your loaded data
                            today: today, // or pass today's date dynamically
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),

                child: GridTile(
                  // header: Text('Classes Assigned', style: TextStyle(fontWeight: FontWeight.bold),),
                  child: InkWell(
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: mainColor,

                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Schools')
                                .doc(
                                  schoolId ?? 'defaultSchoolId',
                                ) // replace with dynamic schoolId if needed
                                .collection('notifications')
                                // .where('status', isEqualTo: 'pending')
                                .snapshots(),
                            builder: (context, asyncSnapshot) {
                              int count = asyncSnapshot.hasData
                                  ? asyncSnapshot.data!.docs.length
                                  : 0;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Icon(
                                      Icons.notifications,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (count != 0)
                                    Positioned(
                                      right: 0,
                                      top: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                        child: Center(
                                          child: Text(
                                            count > 99 ? '99+' : '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
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

                          SizedBox(height: 5),
                          Text(
                            'Notifications',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      //                 final notificationRef = FirebaseFirestore.instance
                      //     .collection('Users')
                      //     .doc('63sCeiPa0nXvqSHeQnyb1f7PN272')
                      //     .collection('inbox')
                      //     .doc();

                      //               await notificationRef.set({
                      //   'title': 'Attendance',
                      //   'body': 'Gitta Isaac has arrived at school',
                      //   'timestamp': FieldValue.serverTimestamp(),
                      //   'studentId': 'P4-958979',
                      //   'studentName': 'Gitta Isaac',
                      //   'schoolFrom': 'Banco Primary Schools',
                      //   'status': 'pending',
                      //   'fcmToken': 'dwB_KPpJSle7ZSYrP5ALEF:APA91bEIfnt4Y8bDQqheLLaCymy3ZAbJZ1ZTR2qxztOV67Eict-PrUdyfJBhF8MS6Ko2Z7anXagw5pfVzVMLwPWXObWnh7PZtswKU2UCw5NKb5ngfHFXSWw',
                      //   'type': 'Attendance',
                      // });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HeadTeacherTabs(schoolId: schoolId!),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),

                child: GridTile(
                  // header: Text('Classes Assigned', style: TextStyle(fontWeight: FontWeight.bold),),
                  child: InkWell(
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: mainColor,

                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.bar_chart, size: 40, color: Colors.white),
                          SizedBox(height: 5),
                          Text(
                            'Statistics',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),

                child: GridTile(
                  // header: Text('Classes Assigned', style: TextStyle(fontWeight: FontWeight.bold),),
                  child: InkWell(
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: mainColor,

                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.assignment, size: 40, color: Colors.white),
                          SizedBox(height: 5),
                          Text(
                            'Assessment',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HeadteacherAssessment(
                            classes: widget.classes,
                            approve: widget.approve,
                            // schoolId: widget.schoolId,
                          ),
                        ),
                      );
                    },
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
