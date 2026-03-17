import 'package:banco_mobile/Parents/ChildrenResults/child_results.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChildrenResults extends StatefulWidget {
  final String approve;

  const ChildrenResults({super.key, required this.approve});

  @override
  State<ChildrenResults> createState() => _ChildrenResultsState();
}

class _ChildrenResultsState extends State<ChildrenResults> {
  final String year = DateTime.now().year.toString();

  Future<void> _refresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

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

      if (docSnap.exists) {
        if (kDebugMode) {
          print("Found student in $col");
        }
        return col;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

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

        final rawChildren = parentData['linkedChildren'];

        final List<Map<String, dynamic>> children = [];

        if (rawChildren is List) {
          for (var item in rawChildren) {
            if (item is Map) {
              children.add(Map<String, dynamic>.from(item));
            }
          }
        }

        if (children.isEmpty) {
          return const Center(child: Text('You have no linked children.'));
        }

        if (widget.approve != 'true') {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Waiting for Admin to approve you.\nPlease contact the school.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final schoolId = child['schoolId'];
              final studentId = child['studentId'];

              if (schoolId == null || studentId == null) {
                return const ListTile(
                  title: Text("Invalid child data"),
                );
              }

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChildResults(
                                studentId: studentId,
                                schoolId: schoolId,
                                collectionName: collectionName,
                                snp: FirebaseFirestore.instance
                                    .collection('Schools')
                                    .doc(schoolId)
                                    .collection('Years')
                                    .doc(year)
                                    .collection(collectionName)
                                    .where(
                                      FieldPath.documentId,
                                      isEqualTo: studentId,
                                    )
                                    .snapshots(),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: mainColor,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
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
                                    fontSize: 12, color: Colors.grey),
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
          ),
        );
      },
    );
  }
}
