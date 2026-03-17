import 'package:banco_mobile/Events/calender.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsFirstScreen extends StatefulWidget {
  final String approve;

  const EventsFirstScreen({super.key, required this.approve});

  @override
  State<EventsFirstScreen> createState() => _EventsFirstScreenState();
}

class _EventsFirstScreenState extends State<EventsFirstScreen> {
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
            // ignore: avoid_unnecessary_containers
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                // ignore: avoid_unnecessary_containers
                child: Container(
                  child: Column(
                    children: [
                      Text('Waiting for Admin to approve you.'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Please contact the school to approve you. Or register again in settings',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final schoolId = child['schoolId'];
              final studentId = child['studentId'];

              // 👇 Use FutureBuilder to first find the correct collection name
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

                  // ✅ Now stream the actual student document
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Schools')
                        .doc(schoolId)
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

                      if (!studentSnap.hasData || !studentSnap.data!.exists) {
                        return const ListTile(
                          title: Text("Student data not found."),
                        );
                      }

                      final student = studentSnap.data!;
                      final studentName = student['studentName'] ?? 'Unknown';
                      final classIn = student['classIn'] ?? '';
                      final stream = student['stream'] ?? '';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpcomingEventsPage(
                                schoolId: schoolId,
                                // studentName: studentName,
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
                            leading:  CircleAvatar(
                              backgroundColor: mainColor ,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(studentName),
                            subtitle: Text("Class: $classIn ($stream)"),
                            trailing: Text(
                              schoolId,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
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