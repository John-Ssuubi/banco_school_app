import 'package:banco_mobile/Events/add_alert.dart';
import 'package:banco_mobile/Events/add_events_page.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpcomingEventsPageHeadTeacher extends StatefulWidget {
  final String schoolId;
  const UpcomingEventsPageHeadTeacher({super.key, required this.schoolId});

  @override
  State<UpcomingEventsPageHeadTeacher> createState() =>
      _UpcomingEventsPageState();
}

class _UpcomingEventsPageState
    extends State<UpcomingEventsPageHeadTeacher> {

  Future<void> _deleteEvent(String docId) async {
    await FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('events')
        .doc(docId)
        .delete();
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('This event will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEvent(docId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _editEvent(String docId, Map<String, dynamic> event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventsPage(
          schoolId: widget.schoolId,
          eventId: docId,       // <-- for editing
          existingEvent: event, // <-- pass data
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // SizedBox(height: 16),
           FloatingActionButton(
            heroTag: "Add Alert",
            child: const Icon(Icons.notification_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddAlertPage(schoolId: widget.schoolId, eventId: '', existingEvent: {},),
                ),
              );
            },
          ),
            const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "Add Event",
            child: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEventsPage(schoolId: widget.schoolId, eventId: '', existingEvent: {},),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Schools')
            .doc(widget.schoolId)
            .collection('events')
            .orderBy('date')
            .snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!asyncSnapshot.hasData ||
              asyncSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: asyncSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final eventDoc = asyncSnapshot.data!.docs[index];
              final event = eventDoc.data() as Map<String, dynamic>;
              final docId = eventDoc.id;

              final Timestamp timestamp = event['date'];
              final DateTime dateTime = timestamp.toDate();

              final String day =
                  dateTime.day.toString().padLeft(2, '0');
              final String month =
                  dateTime.month.toString().padLeft(2, '0');

              final String title = event['title'];
              final String description = event['description'];
              final String location = event['location'];

              final String time =
                  '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

              return Dismissible(
                key: Key(docId),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  _confirmDelete(docId);
                  return false; // dialog handles deletion
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // Date box
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                day,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              Text(
                                month,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Event info
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _editEvent(docId, event),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                description,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                      Icons.location_on,
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text(location),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                      Icons.access_time,
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text(time),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
