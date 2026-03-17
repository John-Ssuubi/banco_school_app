// ignore_for_file: deprecated_member_use, use_build_context_synchronously, sized_box_for_whitespace

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/Charts/attendance_charts.dart';
import 'package:banco_mobile/HeadTeacher/stat_ht.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TeacherClassesStat extends StatefulWidget {
  final List<dynamic>? classes;
  final String approve;
  final String schoolId;

  const TeacherClassesStat({
    super.key,
    required this.classes,
    required this.approve, required this.schoolId,
  });

  @override
  State<TeacherClassesStat> createState() => _TeacherClassesState();
}

class _TeacherClassesState extends State<TeacherClassesStat> {
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
    final theme = Theme.of(context);

    return Scaffold(
      
      // appBar: AppBar(
      //   backgroundColor: mainColor,
      //   // actions: [
      //   //   InkWell(
      //   //     onTap: () {
      //   //       logout(context);
      //   //     },
      //   //     child: Padding(
      //   //       padding: const EdgeInsets.all(8.0),
      //   //       child: Icon(Icons.logout),
      //   //     ),
      //   //   ),
      //   // ],
      //    leading: InkWell(
      //     child: Icon(Icons.arrow_back_outlined, color: Colors.white,),
      //     onTap: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   title: const Text(
      //     "My Classes",
      //     style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      //   ),
      //   centerTitle: true,
      //   elevation: 1,
      // ),
      // floatingActionButton: Container(
      //   // color: Colors.amber,
      //   width: 70,
      //   height: 70,
      //   child: Column(
      //     children: [
      //       Padding(
      //         padding: const EdgeInsets.only(bottom: 8.0),
      //         child: FloatingActionButton(
      //           onPressed: () {
      //             if (kDebugMode) {
      //               print('School ID: $schoolId');

      //               print('School APPROVEEEEEEE: ${widget.approve}');
      //             }

      //             if (widget.approve != 'true') {
      //               ScaffoldMessenger.of(context).showSnackBar(
      //                 const SnackBar(
      //                   content: Text('Waiting for admin to approve you.'),
      //                 ),
      //               );
      //               return;
      //             }
      //             if (schoolId == null) {
      //               ScaffoldMessenger.of(context).showSnackBar(
      //                 const SnackBar(
      //                   content: Text('Please wait — loading school info...'),
      //                 ),
      //               );
      //               return;
      //             }
      //             Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => DailyAttendanceChart(
      //                   schoolId: widget.schoolId,
      //                   date: DateTime.now().toIso8601String().split('T').first,
      //                 ),
      //               ),
      //             );
      //           },
      //           child: Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Icon(Icons.bar_chart),
      //           ),
      //         ),
      //       ),
      //       // FloatingActionButton(
      //       //   onPressed: () {
      //       //     Navigator.push(
      //       //       context,
      //       //       MaterialPageRoute(builder: (context) => BarcodeHome()),
      //       //     );
      //       //   },
      //       //   child: Padding(
      //       //     padding: const EdgeInsets.all(8.0),
      //       //     child: Icon(Icons.barcode_reader),
      //       //   ),
      //       // ),
      //     ],
      //   ),
      // ),
      // backgroundColor: mainColor,
      // drawer: Drawer(
      //   child: Column(
      //     children: [
      //       const UserAccountsDrawerHeader(
      //         decoration: BoxDecoration(color: Colors.indigo),
      //         accountName: Text('Banco Admin'),
      //         accountEmail: Text('admin@banco.edu'),
      //         currentAccountPicture: CircleAvatar(
      //           backgroundColor: Colors.white,
      //           child: Icon(Icons.school, size: 45, color: Colors.indigo),
      //         ),
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.home),
      //         title: const Text('Home'),
      //         onTap: () => Navigator.pop(
      //           context,
      //           // MaterialPageRoute(builder: (context) => const HomePage())
      //         ),
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.settings),
      //         title: const Text('Settings'),
      //         onTap: () => Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => SettingsTeacher()),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: widget.classes == null || widget.classes!.isEmpty
          ? const Center(
              child: Text(
                "No classes assigned yet.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: widget.classes!.length,
                itemBuilder: (context, index) {
                  final classData = widget.classes![index];

                  // Each class can be stored as a Map (from Firestore)
                  final className = classData is Map
                      ? classData['className'] ?? 'Unknown Class'
                      : classData.toString();

                  if (widget.approve != 'true') {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text('Waiting for Admin to approve you.'),
                            Text('Please contact the school to approve you.'),
                          ],
                        ),
                      ),
                    );
                  } else if (widget.approve == 'false') {
                    return Container(
                      width: 500,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                            children: [
                              Text('Access Denied.'),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Please contact the school to approve you. Or Register again in settings',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.primaryColor.withOpacity(0.2),
                        child: Text(
                          className[1].toUpperCase(),
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        className,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text("Tap to view class statistics"),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatHt(
                              model: classData['classModel'],
                              // schoolId: classData['schoolId'],
                              schoolId: widget.schoolId,
                            ),
                          ),
                        );
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text("Opening $className...")),
                        // );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
