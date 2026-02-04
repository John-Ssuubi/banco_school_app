import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final String schoolId;
  final String today;

  const AttendanceScreen({
    super.key,
    required this.schoolId,
    required this.today,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> attendanceDates = [];
  bool loadingDates = true;
  int length = 0;

  @override
  void initState() {
    super.initState();
    loadStudentAttendanceDates();
  }

  /// Load all dates that have attendance
  Future<void> loadStudentAttendanceDates() async {
    final attendanceCollection = FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('attendance');

    final allDates = await attendanceCollection.get();
    List<DateTime> temp = [];

    for (var dateDoc in allDates.docs) {
      final studentsSnap = await attendanceCollection
          .doc(dateDoc.id)
          .collection('students')
          .get();

      if (studentsSnap.docs.isNotEmpty) {
        temp.add(DateTime.parse(dateDoc.id));
      }
    }

    setState(() {
      attendanceDates = temp;
      loadingDates = false;
    });
  }

  /// Load attendance for selected date
  Future<List<Map<String, dynamic>>> loadAttendance() async {
    String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final snap = await FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('attendance')
        .doc(dateString)
        .collection('students')
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd/MM/yyyy').format(_selectedDate);

        if (_selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day) {
          formattedDate = "Today";
        }

    return Scaffold(
      appBar: AppBar(
        title: Text("$formattedDate - $length present"),
      ),
      body: loadingDates
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// 📅 Calendar
                TableCalendar(
                  focusedDay: _selectedDate,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  selectedDayPredicate: (day) =>
                      isSameDay(day, _selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),

                  /// 🔴 Highlight days with attendance
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final hasAttendance = attendanceDates.any(
                        (d) =>
                            d.year == day.year &&
                            d.month == day.month &&
                            d.day == day.day,
                      );

                      if (hasAttendance) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${day.day}",
                            style:
                                const TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// 👨‍🎓 Attendance list
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: loadAttendance(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) {
                          if (mounted && length != 0) {
                            setState(() => length = 0);
                          }
                        });

                        return const Center(
                            child: Text("No attendance found."));
                      }

                      final students = snapshot.data!;
                      final presentCount = students
                          .where(
                              (s) => s['status'] == 'present')
                          .length;

                      /// ✅ Safely update AppBar count
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) {
                        if (mounted &&
                            length != presentCount) {
                          setState(
                              () => length = presentCount);
                        }
                      });

                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final s = students[index];
                          final timeIn = s['timeIn'] != null
                              ? (s['timeIn'] as Timestamp)
                                  .toDate()
                              : null;

                          return InkWell(
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title:
                                      Text(s["studentName"]),
                                  content: Column(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                          "Status: ${s['status']}"),
                                      Text(
                                          "Class: ${s['classIn']}"),
                                      Text(
                                          "Date: $formattedDate"),
                                      if (timeIn != null)
                                        Text(
                                            "Time In: ${DateFormat('hh:mm a').format(timeIn)}"),
                                      if (s['timeOut'] !=
                                          null)
                                        Text(
                                            "Time Out: ${DateFormat('hh:mm a').format((s['timeOut'] as Timestamp).toDate())}"),
                                      if (s['remarks'] !=
                                          null)
                                        Text(
                                            "Remarks: ${s['remarks']}"),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(
                                              context),
                                      child:
                                          const Text("Close"),
                                    )
                                  ],
                                ),
                              );
                            },
                            child: ListTile(
                              leading: Icon(
                                s['status'] == "present"
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color:
                                    s['status'] == "present"
                                        ? Colors.green
                                        : Colors.red,
                              ),
                              title:
                                  Text(s["studentName"]),
                              subtitle: Text(
                                  "Class: ${s['classIn']}"),
                              trailing: timeIn != null
                                  ? Text(
                                      "In: ${DateFormat('hh:mm a').format(timeIn)}",
                                      style: TextStyle(
                                        color: s['status'] ==
                                                "present"
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
