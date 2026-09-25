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

// Conditional import: pulls dart:html ONLY on web
import 'web_url_helper.dart'
    if (dart.library.html) 'web_url_helper_web.dart' as web_helper;

/// Background handler (Android/iOS only — not used on web)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    debugPrint("Handling background message: ${message.notification?.title}");
  }
}

Future<void> main() async {
  /// 1. Flutter binding FIRST
  WidgetsFlutterBinding.ensureInitialized();

  /// 2. Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Nairobi'));

  /// 3. Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 4. Notifications — only on mobile, NOT on web
  if (!kIsWeb) {
    // Register background handler (Android/iOS)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await AwesomeNotificationsEngine.initializeAwesomeNotifications();
    await initNotifications();
  } else {
    // Web: request FCM permission and get token (needs VAPID key)
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      // IMPORTANT: replace with your VAPID public key from Firebase Console
      // Project Settings → Cloud Messaging → Web Push certificates
      const vapidKey = 'YOUR_PUBLIC_VAPID_KEY_HERE';

      final token = await messaging.getToken(
        vapidKey: vapidKey,
      );
      if (kDebugMode) {
        debugPrint('Web FCM token: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Web FCM setup failed: $e');
      }
    }
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
          /// Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          /// Not logged in
          if (!snapshot.hasData) {
            final schoolId = web_helper.getSchoolIdFromUrl();

            if (kDebugMode && schoolId != null) {
              debugPrint('Received school ID: $schoolId');
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
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
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
              final List<dynamic> classes = userData['linkedClasses'] ?? [];
              final approve =
                  userData['approved']?.toString().toLowerCase() ?? 'false';
              final schoolname =
                  userData['linkedChildren']?.toString() ?? '';
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
                return _SubscriptionGate(
                  schoolId: schoolId,
                  builder: (ctx) => AdminDashboard(
                    approve: approve,
                    schoolname: schoolname,
                  ),
                );
              }

              /// Security
              if (role == 'security') {
                return _SubscriptionGate(
                  schoolId: schoolId,
                  builder: (ctx) => DailyAttendanceChartSecurity(
                    schoolId: schoolId,
                    date: DateTime.now().toIso8601String().split('T').first,
                  ),
                );
              }

              /// Headteacher
              if (role == 'headteacher') {
                return _SubscriptionGate(
                  schoolId: schoolId,
                  builder: (ctx) => HeadTeacherDashboard(
                    classes: classes,
                    approve: approve,
                    schoolId: schoolId,
                  ),
                );
              }

              /// Teacher (default)
              return _SubscriptionGate(
                schoolId: schoolId,
                builder: (ctx) => TeacherHome(
                  schoolname: schoolname,
                  approve: approve,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Reusable subscription gate (DRY — replaces 4 copies of the same StreamBuilder)
class _SubscriptionGate extends StatelessWidget {
  const _SubscriptionGate({
    required this.schoolId,
    required this.builder,
  });

  final String schoolId;
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .snapshots(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = asyncSnapshot.data?.data() as Map<String, dynamic>?;
        final subscription =
            data?['subscription']?.toString().toLowerCase() ?? '';

        if (subscription != 'paid') {
          return const InactiveSub();
        }

        return builder(context);
      },
    );
  }
}