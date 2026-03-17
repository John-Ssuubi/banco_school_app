import 'package:banco_mobile/Parents/ChildAttendance/child_attendance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PickChild extends StatefulWidget {
  final String approve;

  const PickChild({super.key, required this.approve});

  @override
  State<PickChild> createState() => _PickChildState();
}

class _PickChildState extends State<PickChild> {
  final String year = DateTime.now().year.toString();

  Future<String?> getStudentCollection(
    String schoolId,
    String studentId,
  ) async {
    final possibleCollections = [
      'studentModelP1',
      'studentModelP2',
      'studentModelP3',
      'studentModelP4',
      'studentModelP5',
      'studentModelP6',
      'studentModelP7',
    ];

    for (final col in possibleCollections) {
      final docSnap = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('Years')
          .doc(year)
          .collection(col)
          .doc(studentId)
          .get();

      if (docSnap.exists) return col;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, parentSnapshot) {
        if (parentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!parentSnapshot.hasData || !parentSnapshot.data!.exists) {
          return const Center(child: Text('No linked children found.'));
        }

        final parentData =
            parentSnapshot.data!.data() as Map<String, dynamic>? ?? {};

        final children = List<Map<String, dynamic>>.from(
          parentData['linkedChildren'] ?? [],
        );

        if (children.isEmpty) {
          return const Center(child: Text('You have no linked children.'));
        }

        /// approval check
        if (widget.approve != 'true') {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Waiting for Admin approval.\nPlease contact the school.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        /// ✅ SAFE ListView
        return ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: children.length,
          itemBuilder: (context, index) {
            final child = children[index];
            final schoolId = child['schoolId'];
            final studentId = child['studentId'];

            return FutureBuilder<String?>(
              future: getStudentCollection(schoolId, studentId),
              builder: (context, classSnapshot) {
                if (classSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const ListTile(
                    title: Text("Checking student class..."),
                  );
                }

                final collectionName = classSnapshot.data;

                if (collectionName == null) {
                  return const ListTile(
                    title: Text("Student record not found."),
                  );
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Schools')
                      .doc(schoolId)
                      .collection('Years')
                      .doc(year)
                      .collection(collectionName)
                      .doc(studentId)
                      .snapshots(),
                  builder: (context, studentSnap) {
                    if (studentSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                        title: Text("Loading student info..."),
                      );
                    }

                    if (!studentSnap.hasData ||
                        !studentSnap.data!.exists) {
                      return const ListTile(
                        title: Text("Student data not found."),
                      );
                    }

                    final student = studentSnap.data!;
                    final studentName =
                        student['studentName'] ?? 'Unknown';
                    final classIn = student['classIn'] ?? '';
                    final stream = student['stream'] ?? '';

                    return InkWell(
                      onTap: () {
                        if (kDebugMode) print(schoolId);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildAttendance(
                              schoolId: schoolId,
                              studentId: studentName,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.person,
                                color: Colors.white),
                          ),
                          title: Text(studentName),
                          subtitle:
                              Text("Class: $classIn ($stream)"),
                          trailing: SizedBox(
                            width: 100,
                            child: Text(
                              schoolId,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
