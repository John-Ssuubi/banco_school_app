// ignore_for_file: unused_element

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/HeadTeacher/head_teacher_dashboard.dart';
import 'package:banco_mobile/Notifications/local_notifications.dart';
import 'package:banco_mobile/Parents/parents_children_list.dart';
import 'package:banco_mobile/Security/attendance_charts_security.dart';
import 'package:banco_mobile/Teachers/teacher_home.dart';
import 'package:banco_mobile/admin/admin_dashboard.dart';
import 'package:banco_mobile/admin/inactive_sub.dart';
import 'package:banco_mobile/firebase_options.dart';
import 'package:banco_mobile/landingpage/landing_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    print("Handling background message: ${message.notification?.title}");
  }
}

Future<void> main() async {
  /// 1. Flutter binding FIRST
  WidgetsFlutterBinding.ensureInitialized();

  /// 2. Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Nairobi'));

  /// 3. Firebase initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// 4. Notifications (NOT supported on Web)
  if (!kIsWeb) {
    await AwesomeNotificationsEngine.initializeAwesomeNotifications();

    await initNotifications();
  }

  /// 5. Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banco Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),

        builder: (context, snapshot) {
          /// Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          /// Not logged in
          if (!snapshot.hasData) {
            String? schoolId;
            try {
              final uri = Uri.parse(html.window.location.href);
              final rawSchoolId = uri.queryParameters['schoolId'];

              if (rawSchoolId != null && rawSchoolId.isNotEmpty) {
                // Decode the URL-encoded school ID
                schoolId = Uri.decodeComponent(rawSchoolId);
                if (kDebugMode) {
                  print('Received school ID: $schoolId');
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing school ID: $e');
              }
            }

            return LandingPage(
              schoolId: schoolId,
              fromApplyButton: schoolId != null,
            );
          }

          /// Logged in — check role
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('Users')
                .doc(snapshot.data!.uid)
                .get(),

            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasError) {
                return const Scaffold(
                  body: Center(child: Text('Error loading user')),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();

                      Navigator.pushAndRemoveUntil(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthStudent(),
                        ),
                        (route) => false,
                      );
                    },
                  ),

                  body: const Center(child: Text('User data not found.')),
                );
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;

              final role = userData['role']?.toString().toLowerCase() ?? '';

              List<dynamic>? classes = userData['linkedClasses'] ?? [];

              final approve = userData['approved'].toString().toLowerCase();

              final schoolname = userData['linkedChildren']?.toString() ?? '';

              final schoolId = userData['schoolId']?.toString() ?? '';

              if (schoolId.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text('School ID not found.')),
                );
              }

              /// Parent
              if (role == 'parent') {
                return ParentsChildrenList(
                  approve: approve,
                  schoolname: schoolname,
                );
              }

              /// Admin
              if (role == 'admin') {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Schools')
                      .doc(schoolId)
                      .snapshots(),

                  builder: (context, asyncSnapshot) {
                    final data = asyncSnapshot.data?.data();

                    final subscription = data?['subscription']
                        .toString()
                        .toLowerCase();

                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (subscription != 'paid') {
                      return InactiveSub();
                    }

                    return AdminDashboard(
                      approve: approve,
                      schoolname: schoolname,
                    );
                  },
                );
              }

              /// Security
              if (role == 'security') {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Schools')
                      .doc(schoolId)
                      .snapshots(),

                  builder: (context, asyncSnapshot) {
                    final data = asyncSnapshot.data?.data();

                    final subscription = data?['subscription']
                        .toString()
                        .toLowerCase();

                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (subscription != 'paid') {
                      return InactiveSub();
                    }

                    return DailyAttendanceChartSecurity(
                      schoolId: schoolId,
                      date: DateTime.now().toIso8601String().split('T').first,
                    );
                  },
                );
              }

              /// Headteacher
              if (role == 'headteacher') {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Schools')
                      .doc(schoolId)
                      .snapshots(),

                  builder: (context, asyncSnapshot) {
                    final data = asyncSnapshot.data?.data();

                    final subscription = data?['subscription']
                        .toString()
                        .toLowerCase();

                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (subscription != 'paid') {
                      return InactiveSub();
                    }

                    return HeadTeacherDashboard(
                      classes: classes,
                      approve: approve,
                      schoolId: schoolId,
                    );
                  },
                );
              }

              /// Teacher (default)
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Schools')
                    .doc(schoolId)
                    .snapshots(),

                builder: (context, asyncSnapshot) {
                  final data = asyncSnapshot.data?.data();

                  final subscription = data?['subscription']
                      .toString()
                      .toLowerCase();

                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (subscription != 'paid') {
                    return InactiveSub();
                  }

                  return TeacherHome(schoolname: schoolname, approve: approve);
                },
              );
            },
          );
        },
      ),
    );
  }
}
