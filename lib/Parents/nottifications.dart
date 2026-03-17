import 'dart:async';

import 'package:banco_mobile/Chat/Parent/chat_list.dart';
import 'package:banco_mobile/Parents/ChildAttendance/child_attendance.dart';
import 'package:banco_mobile/Events/calender.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Nottifications extends StatefulWidget {
  final String approve;
  const Nottifications({super.key, required this.approve});

  @override
  State<Nottifications> createState() => _NottificationsState();
}

class _NottificationsState extends State<Nottifications> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Map<String, List<QueryDocumentSnapshot>> _groupByType(
    List<QueryDocumentSnapshot> docs,
  ) {
    final Map<String, List<QueryDocumentSnapshot>> grouped = {};
    for (var doc in docs) {
      final type = doc['type'] ?? 'Others';
      grouped.putIfAbsent(type, () => []);
      grouped[type]!.add(doc);
    }
    return grouped;
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Attendance':
        return Colors.green;
      case 'Alerts':
        return Colors.red;
      case 'Messages':
        return Colors.blue;
      case 'Events':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Attendance':
        return Icons.how_to_reg;
      case 'Alerts':
        return Icons.warning;
      case 'Messages':
        return Icons.message;
      case 'Events':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('inbox')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final groupedNotifications = _groupByType(docs);
        final categories = groupedNotifications.keys.toList();

        return Column(
          children: [
           
            Padding(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatListScreen(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.message, color: Colors.white),
                    ),
                    title: Text(
                      'Messages',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Tap to view conversations'),
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final notifications = groupedNotifications[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...notifications.map((notification) {
                        final String title =
                            notification['title'] ?? '';
                        final String body =
                            notification['body'] ?? '';
                            final type = notification['type'] ?? '';

                        final Timestamp? timestamp =
                            notification['timestamp'];
                        final DateTime? dateTime =
                            timestamp?.toDate();

                        final String timeAgo = dateTime != null
                            ? timeago.format(dateTime)
                            : '';

                        return InkWell(
                          child: Container(
                            margin:
                                const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).cardColor,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getColorForType(category),
                                child: Icon(
                                  _getIconForType(category),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold),
                              ),
                              subtitle:
                                  Text('$body • $timeAgo'),
                            ),
                          ),
                          onTap: () {
                            if (type == "Attendance") {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                builder: (_) {
                                  return ChildAttendance(
                                    schoolId: notification['schoolFrom'],
                                    studentName: notification['studentName'],
                                  );
                                },
                              ));
                            }
                            if (type == "Events") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UpcomingEventsPage(
                                    schoolId: notification['schoolFrom'],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
