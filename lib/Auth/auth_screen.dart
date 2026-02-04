// import 'package:banco_mobile/Auth/auth_student.dart';
// import 'package:banco_mobile/home.dart';
// import 'package:banco_mobile/styles.dart';
// import 'package:flutter/material.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2, // Number of tabs
//       child: Scaffold(
//         // backgroundColor: backgroundColor,
        
//         body: const TabBarView(
//           children: [
//             AuthStudent(),
//             // OnBoarding(),

//             HomePage(),
//             // Center(child: Text("Settings Page")),
//           ],
//         ),
//         bottomNavigationBar:  TabBar(
//           tabs: [
//             Tab(icon: Icon(Icons.person, color: mainColor,), text: "Parent"),
//             Tab(icon: Icon(Icons.school, color: mainColor,), text: "Teacher"),
//             // Tab(icon: Icon(Icons.settings, color: moneyColor), text: "Explore"),
//           ],
//         ),
//       ),
//     );
//   }
// }