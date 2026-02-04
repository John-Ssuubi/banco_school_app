// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/Parents/ChildAttendance/pick_child.dart';
import 'package:banco_mobile/Parents/calender.dart';
import 'package:banco_mobile/Parents/children_results.dart';
import 'package:banco_mobile/Parents/nottifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParentsChildrenList extends StatefulWidget {
  final String approve;
  // final String schoolId;
  const ParentsChildrenList({
    super.key,
    required this.approve,
    // required this.schoolId,
  });

  @override
  State<ParentsChildrenList> createState() => _ParentsChildrenListState();
}

class _ParentsChildrenListState extends State<ParentsChildrenList> {
  int currentIndex = 0;

  // Define a primary color for consistent branding
  final Color primaryColor = const Color(0xFF2E3E5C); // Dark Blue/Slate
  final Color accentColor = const Color(0xFF1E88E5); // Bright Blue

  int notificationCount = 0;

  void notificationCountUpdate() async {
    var user = FirebaseAuth.instance.currentUser!.uid;
    var snap = await FirebaseFirestore.instance
        .collection('Users').doc(user)
        .collection('notifications')
        .where('status', isEqualTo: 'pending').get();

        setState(() {
      notificationCount = snap.docs.length;
        });
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthStudent()),
      (route) => false,
    );
  }

@override
  void initState() {
    super.initState();
    notificationCountUpdate();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Light grey background to make content cards pop
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0, // Removes the shadow for a cleaner look
        centerTitle: true,
        title: Text(
          "Smart Schools App",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: primaryColor),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => logout(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.logout, color: Colors.red[400]),
              ),
            ),
          ),
        ],
      ),

      body: _getSelectedView(),

      // 2. Custom Container to style the Bottom Nav Bar
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
              offset: const Offset(0, -3), // Shadow pointing up
            ),
          ],
        ),
        child: ClipRRect(
          // Clips the internal navbar to the rounded corners
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // Keeps icons visible
            backgroundColor: Colors.white,
            currentIndex: currentIndex,
            onTap: (value) {
              setState(() {
                currentIndex = value;
              });
            },

            // Selected Item Style
            selectedItemColor: accentColor,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),

            // Unselected Item Style
            unselectedItemColor: Colors.grey,
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),

            showUnselectedLabels: true,
            elevation: 0, // We handle the shadow in the Container above

            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(
                    Icons.analytics_outlined,
                  ), // Changed to "analytics" to look like results
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.analytics),
                ),
                label: 'Results',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.calendar_today_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.calendar_month),
                ),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.check_circle_outline),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.check_circle),
                ),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Icon(Icons.notifications_outlined),
                    ),
                    if (notificationCount != 0)
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
                              notificationCount > 99
                                  ? '99+'
                                  : '$notificationCount',
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
                ),
                activeIcon: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Icon(Icons.notifications),
                    ),
                    if (notificationCount != 0)
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
                              notificationCount > 99
                                  ? '99+'
                                  : '$notificationCount',
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
    // I recommend wrapping these views in a SafeArea or Padding if they feel too close to the edge
    if (currentIndex == 0) {
      return ChildrenResults(approve: widget.approve);
    }
    if (currentIndex == 1) {
      return const Calender(); // Ensure Calender is const if possible
    }
    if (currentIndex == 2) {
      return PickChild(approve: widget.approve);
    }
    return const Nottifications();
  }
}


// Stack(
//                         clipBehavior: Clip.none, // allows badge to overflow
//                         children: [
//                           Icon(Icons.message, size: 30, color: Colors.black),
//                           if (notificationCount != 0)
//                             Positioned(
//                               right: -2,
//                               top: -2,
//                               child: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 constraints: const BoxConstraints(
//                                   minWidth: 18,
//                                   minHeight: 18,
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     notificationCount > 99
//                                         ? '99+'
//                                         : '$notificationCount',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),