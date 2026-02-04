import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/HeadTeacher/head_teacher_dashboard.dart';
import 'package:banco_mobile/Parents/parents_children_list.dart';
import 'package:banco_mobile/Teachers/teacher_classes.dart';
import 'package:banco_mobile/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

var d1Start = 100;
var d1End = 90;

var d2Start = 89;
var d2End = 80;

var c3Start = 79;
var c3End = 70;

var c4Start = 69;
var c4End = 60;

var c5Start = 59;
var c5End = 55;

var c6Start = 54;
var c6End = 50;

var p7Start = 49;
var p7End = 45;

var p8Start = 44;
var p8End = 40;

var f9Start = 39;
var f9End = 0;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling background message: ${message.notification?.title}");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // setupFcm();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 👇 If user is not logged in, go to AuthScreen
          if (!snapshot.hasData) {
            return const AuthStudent();
          }

          // 👇 User is logged in, check their Firestore role
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
                return Scaffold(
                  body: Center(
                    child: Text('Error loading user: ${userSnapshot.error}'),
                  ),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Scaffold(
                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      // Future<void> logout(BuildContext context) async {
                      await FirebaseAuth.instance.signOut();

                      // Navigate to AuthScreen (or your login screen)
                      Navigator.pushAndRemoveUntil(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthStudent(),
                        ),
                        (route) => false, // remove all previous routes
                      );
                      // }
                    },
                  ),
                  
                  body: Center(child: Text('User data not found.')),
                );
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              final role = userData['role']?.toString().toLowerCase() ?? '';
              List<dynamic>? classes = userData['linkedClasses'] ?? [];
              final approve = userData['approved'].toString().toLowerCase();

              // ✅ Navigate based on role
              if (role == 'parent') {
                return ParentsChildrenList(approve: approve,);
              } else if (role == 'headteacher') {
                return HeadTeacherDashboard(classes: classes, approve: approve);
              } else {
                return TeacherClasses(classes: classes, approve: approve);
              }
            },
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
