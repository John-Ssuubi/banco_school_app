// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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

  /// Current selected filter
  String _selectedFilter = "All";

  final List<String> _filters = [
    "All",
    "Attendance",
    "Events",
  //  
    "Alerts",
  ];

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

  /* ---------------- FIRESTORE HELPERS ---------------- */

  Future<void> _markAsRead(String docId) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('inbox')
        .doc(docId)
        .update({'status': 'read'});
  }

  Future<void> _deleteNotification(String docId) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('inbox')
        .doc(docId)
        .delete();
  }

  /* ---------------- FILTER LOGIC ---------------- */

  List<QueryDocumentSnapshot> _applyFilter(
      List<QueryDocumentSnapshot> docs) {
    if (_selectedFilter == "All") return docs;

    return docs
        .where((doc) => doc['type'] == _selectedFilter)
        .toList();
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

  /* ---------------- UI ---------------- */

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
        /* ----------- Approval Check ----------- */

        if (widget.approve != 'true') {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Waiting for Admin Approval'),
                SizedBox(height: 8),
                Text('Please contact your school'),
              ],
            ),
          );
        }

        /* ----------- Loading ----------- */

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        /* ----------- Apply Filter ----------- */

        final allDocs = snapshot.data!.docs;

        final filteredDocs = _applyFilter(allDocs);

        return Column(
          children: [

            /* ---------------- MESSAGES SHORTCUT ---------------- */

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

            /* ---------------- FILTER CHIPS ---------------- */

            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filters.length,
                itemBuilder: (context, i) {
                  final filter = _filters[i];
                  final selected = _selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      selectedColor: Colors.blueAccent,
                      labelStyle: TextStyle(
                        color:
                            selected ? Colors.white : Colors.black,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /* ---------------- NOTIFICATIONS LIST ---------------- */

            Expanded(
              child: filteredDocs.isEmpty
                  ? const Center(
                      child: Text("No notifications found"),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final notification =
                            filteredDocs[index];

                        final title =
                            notification['title'] ?? '';
                        final body =
                            notification['body'] ?? '';
                        final type =
                            notification['type'] ?? '';
                        final status =
                            notification['status'] ?? '';

                        final Timestamp? timestamp =
                            notification['timestamp'];

                        final DateTime? dateTime =
                            timestamp?.toDate();

                        final timeAgo = dateTime != null
                            ? timeago.format(dateTime)
                            : '';

                        return InkWell(
                          /* ----------- TAP ----------- */
                          onTap: () async {
                            if (status == 'pending') {
                              await _markAsRead(
                                  notification.id);
                            }

                            if (type == "Attendance") {
                              Navigator.push(context,
                                  MaterialPageRoute(
                                builder: (_) {
                                  return ChildAttendance(
                                    schoolId: notification[
                                        'schoolFrom'],
                                    studentId: notification[
                                        'studentId'],
                                  );
                                },
                              ));
                            }

                            if (type == "Events") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      UpcomingEventsPage(
                                    schoolId: notification[
                                        'schoolFrom'],
                                  ),
                                ),
                              );
                            }
                          },

                          /* ----------- LONG PRESS ----------- */
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text(
                                    "Delete Notification"),
                                content: const Text(
                                    "Delete this notification?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child:
                                        const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await _deleteNotification(
                                          notification.id);
                                    },
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(
                                          color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },

                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: status == 'pending'
                                  ? Colors.blue.withOpacity(0.08)
                                  : Theme.of(context).cardColor,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getColorForType(type),
                                child: Icon(
                                  _getIconForType(type),
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
