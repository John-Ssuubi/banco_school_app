// ignore_for_file: deprecated_member_use, use_build_context_synchronously, sized_box_for_whitespace

import 'package:banco_mobile/HeadTeacher/Assessment/class_assessment.dart';
import 'package:banco_mobile/home.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HeadteacherAssessment extends StatefulWidget {
  final List<dynamic>? classes;
  final String approve;

  const HeadteacherAssessment({
    super.key,
    required this.classes,
    required this.approve,
  });

  @override
  State<HeadteacherAssessment> createState() => _HeadteacherClassesState();
}

class _HeadteacherClassesState extends State<HeadteacherAssessment> {
  String? schoolId;
  List<Map<String, dynamic>>? schoolClasses = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          child: const Icon(Icons.arrow_back_outlined, color: Colors.white),
          onTap: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Classes",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
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

                  final className = classData is Map
                      ? classData['className'] ?? 'Unknown Class'
                      : classData.toString();

                  if (widget.approve != 'true') {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text('Waiting for Admin to approve you.',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )),
                            Text('Please contact the school.',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                )),
                          ],
                        ),
                      ),
                    );
                  }

                  if (widget.approve == 'false') {
                    return Container(
                      width: 500,
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Column(
                          children: [
                            Text('Access Denied.', style: whiteText),
                            const SizedBox(height: 8),
                            Text(
                              'Contact the school or register again in settings.',
                              style: whiteText,
                            ),
                          ],
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
                          className.isNotEmpty
                              ? className[0].toUpperCase()
                              : '?',
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
                      trailing:
                          const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClassAssessment(
                              model: classData['classModel'],
                              schoolId: classData['schoolId'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
