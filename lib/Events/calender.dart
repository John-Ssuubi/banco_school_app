import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpcomingEventsPage extends StatefulWidget {
  final String schoolId;
  const UpcomingEventsPage({super.key, required this.schoolId});

  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(child: Icon(Icons.arrow_back_rounded, color: Colors.white,),),
        backgroundColor: mainColor,
        title: const Text("Upcoming Events", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Schools')
            .doc(widget.schoolId)
            .collection('events')
            .snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          } else if (!asyncSnapshot.hasData || asyncSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: asyncSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final event = asyncSnapshot.data!.docs[index];
              final Timestamp timestamp = event['date'];
              final DateTime dateTime = timestamp.toDate();
              final String day = dateTime.day.toString().padLeft(2, '0');
              final String month = dateTime.month.toString().padLeft(2, '0');
              final String title = event['title'];
              final String description = event['description'];
              final String time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
              final String location = event['location'];
              return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Box
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        month,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
          
                const SizedBox(width: 16),
          
                // Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Text(location),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
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
              );
            },
          );
        }
      ),
    );
  }
}


// class SchoolEvent {
//   final String title;
//   final String description;
//   final String day;
//   final String month;
//   final String location;
//   final String time;

//   SchoolEvent({
//     required this.title,
//     required this.description,
//     required this.day,
//     required this.month,
//     required this.location,
//     required this.time,
//   });
// }

// /* ---------------- DEMO DATA ---------------- */

// final List<SchoolEvent> demoEvents = [
//   SchoolEvent(
//     title: "Parents Meeting",
//     description: "Discussion about students' academic performance.",
//     day: "18",
//     month: "MAR",
//     location: "School Hall",
//     time: "9:00 AM",
//   ),
//   SchoolEvent(
//     title: "Sports Day",
//     description: "Inter-house sports competitions.",
//     day: "25",
//     month: "MAR",
//     location: "Play Ground",
//     time: "10:00 AM",
//   ),
//   SchoolEvent(
//     title: "Examination Week",
//     description: "End of term examinations begin.",
//     day: "02",
//     month: "APR",
//     location: "All Classes",
//     time: "All Day",
//   ),
// ];
