// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/HeadTeacher/attendance.dart';
import 'package:banco_mobile/HeadTeacher/teacher_classes_stat.dart';
import 'package:banco_mobile/Teachers/SettingsTeacher/settings_teacher.dart';
import 'package:banco_mobile/Teachers/teacher_classes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeadTeacherDashboard extends StatefulWidget {
  final String approve;
  final List<dynamic>? classes;

  const HeadTeacherDashboard({super.key, required this.approve, this.classes});

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
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navigate to AuthScreen (or your login screen)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthStudent()),
      (route) => false, // remove all previous routes
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              logout(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.logout),
            ),
          ),
        ],
        title: const Text(
          "Head Teacher ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),

      backgroundColor: Colors.grey[100],
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              accountName: Text('Banco Admin'),
              accountEmail: Text('admin@banco.edu'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.school, size: 45, color: Colors.indigo),
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
          ],
        ),
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
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.class_, size: 40, color: Colors.white),
                          SizedBox(height: 5),
                          Text(
                            'Classes',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherClasses(
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
                        color: Colors.grey,
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
                            schoolId: schoolId!, // from your loaded data
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
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.notifications,
                            size: 40,
                            color: Colors.white,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Notifications',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onTap: ()  {
                      //  sendNotification(
                      //   context: context,
                      //   title: 'Attendance',
                      //   body: 'Gitta Isaac marked present',
                      //   token:
                      //       'dwB_KPpJSle7ZSYrP5ALEF:APA91bEIfnt4Y8bDQqheLLaCymy3ZAbJZ1ZTR2qxztOV67Eict-PrUdyfJBhF8MS6Ko2Z7anXagw5pfVzVMLwPWXObWnh7PZtswKU2UCw5NKb5ngfHFXSWw',
                      // );
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
                        color: Colors.grey,
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
                          builder: (context) => TeacherClassesStat(
                            classes: widget.classes,
                            approve: widget.approve,
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
