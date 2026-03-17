import 'package:banco_mobile/Chat/HeadTeacher/chat_list_headteacher.dart';
import 'package:banco_mobile/Events/events_headteacher.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
class AdminNotifications extends StatelessWidget {
  final String schoolId;
  const AdminNotifications({super.key, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: mainColor,
        //    leading: InkWell(
        //   child: Icon(Icons.arrow_back_outlined, color: Colors.white,),
        //   onTap: () {
        //     Navigator.pop(context);
        //   },
        // ),
          title: const Text("Head Teacher", style: TextStyle(color: Colors.white),),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Color.fromARGB(255, 151, 151, 151),
            indicatorWeight: 3,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(
                icon: Icon(Icons.notifications),
                text: "Notifications",
              ),
              Tab(
                icon: Icon(Icons.event),
                text: "Events",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            HeadTeacherNotificationsTab(schoolId: schoolId),
            UpcomingEventsPageHeadTeacher(schoolId: schoolId),
          ],
        ),
      ),
    );
  }
}



class HeadTeacherNotificationsTab extends StatefulWidget {
  final String schoolId;
  const HeadTeacherNotificationsTab({super.key, required this.schoolId});

  @override
  State<HeadTeacherNotificationsTab> createState() =>
      _HeadTeacherNotificationsTabState();
}

class _HeadTeacherNotificationsTabState
    extends State<HeadTeacherNotificationsTab> {
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
      List<QueryDocumentSnapshot> docs) {
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
        return Icons.notifications;
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
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No notifications"));
        }

        final docs = snapshot.data!.docs;
        final grouped = _groupByType(docs);
        final categories = grouped.keys.toList();

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
                      builder: (_) => ChatListHeadteacher(schoolId: widget.schoolId),
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
                padding: const EdgeInsets.all(12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final notifications = grouped[category]!;
              
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...notifications.map((notification) {
                        final String title = notification['title'] ?? '';
                        final String body = notification['message'] ?? '';
                        final Timestamp? ts = notification['timestamp'];
                        final String timeAgo =
                            ts != null ? timeago.format(ts.toDate()) : '';
              
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getColorForType(category),
                              child: Icon(
                                _getIconForType(category),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('$body • $timeAgo'),
                          ),
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
