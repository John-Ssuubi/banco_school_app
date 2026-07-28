// ignore_for_file: deprecated_member_use

import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ChildAttendance extends StatefulWidget {
  final String schoolId;
  final String studentId;

  const ChildAttendance({
    super.key,
    required this.schoolId,
    required this.studentId,
  });

  @override
  State<ChildAttendance> createState() => _ChildAttendanceState();
}

class _ChildAttendanceState extends State<ChildAttendance> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> attendanceDates = [];
  bool loadingDates = true;
  String? studentName;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
    loadStudentAttendanceDates();
    loadStudentInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadStudentInfo() async {
    try {
      final currentYear = DateTime.now().year.toString();
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(currentYear)
          .collection('studentModelP4') // Adjust based on your class model
          .where('idNin', isEqualTo: widget.studentId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          studentName = data['studentName'] ?? 'Student';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading student info: $e");
      }
    }
  }

  Future<void> loadStudentAttendanceDates() async {
    try {
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
            .where('idNin', isEqualTo: widget.studentId)
            .get();

        if (studentsSnap.docs.isNotEmpty) {
          temp.add(DateTime.parse(dateDoc.id));
        }
      }

      setState(() {
        attendanceDates = temp;
        loadingDates = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error loading attendance dates: $e");
      }
      setState(() => loadingDates = false);
    }
  }

  Future<List<Map<String, dynamic>>> loadAttendance() async {
    try {
      String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final snap = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('attendance')
          .doc(dateString)
          .collection('students')
          .where('idNin', isEqualTo: widget.studentId)
          .get();

      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading attendance: $e");
      }
      return [];
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      return "Today";
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (_selectedDate.year == yesterday.year &&
        _selectedDate.month == yesterday.month &&
        _selectedDate.day == yesterday.day) {
      return "Yesterday";
    }
    return DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: loadingDates
          ? _buildLoadingState()
          : FadeTransition(
              opacity: _animationController,
              child: Column(
                children: [
                  // _buildStatsCard(),
                  _buildCalendar(),
                  const SizedBox(height: 16),
                  _buildAttendanceHeader(),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: loadAttendance(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildShimmerEffect();
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyState();
                        }
                        final students = snapshot.data!;
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return _buildAttendanceCard(student);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: mainColor,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Attendance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            studentName ?? "Student",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, mainColor.withOpacity(0.8)],
          ),
        ),
      ),
    );
  }

  // Widget _buildStatsCard() {
  //   final totalDays = attendanceDates.length;
  //   final attendanceRate = totalDays > 0 
  //       ? ((attendanceDates.where((date) => date.isBefore(DateTime.now())).length) / totalDays * 100).toStringAsFixed(1)
  //       : "0.0";

  //   return Container(
  //     margin: const EdgeInsets.all(16),
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [mainColor, mainColor.withOpacity(0.7)],
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: mainColor.withOpacity(0.3),
  //           blurRadius: 10,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         _buildStatItem(
  //           "Days Present",
  //           attendanceDates.length.toString(),
  //           Icons.calendar_today,
  //           Colors.white,
  //         ),
  //         Container(height: 40, width: 1, color: Colors.white24),
  //         _buildStatItem(
  //           "Attendance Rate",
  //           "$attendanceRate%",
  //           Icons.trending_up,
  //           Colors.white,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildStatItem(String label, String value, IconData icon, Color color) {
  //   return Column(
  //     children: [
  //       Icon(icon, color: color, size: 28),
  //       const SizedBox(height: 8),
  //       Text(
  //         value,
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontSize: 24,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: const TextStyle(
  //           color: Colors.white70,
  //           fontSize: 12,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: TableCalendar(
          focusedDay: _selectedDate,
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, size: 24),
            rightChevronIcon: Icon(Icons.chevron_right, size: 24),
          ),
          calendarStyle: CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: mainColor,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: mainColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            weekendTextStyle: const TextStyle(color: Colors.red),
            defaultTextStyle: const TextStyle(color: Colors.grey),
          ),
          selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDate = selectedDay;
            });
          },
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
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "${day.day}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getFormattedDate(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: mainColor),
                const SizedBox(width: 4),
                Text(
                  "Tap card for details",
                  style: TextStyle(
                    fontSize: 11,
                    color: mainColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> student) {
    final isPresent = student['status'] == "present";
    final timeIn = student['timeIn'] != null
        ? (student['timeIn'] as Timestamp).toDate()
        : null;
    final timeOut = student['timeOut'] != null
        ? (student['timeOut'] as Timestamp).toDate()
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showAttendanceDetails(student, timeIn, timeOut),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status Circle
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isPresent
                        ? [Colors.green, Colors.green.shade700]
                        : [Colors.red, Colors.red.shade700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isPresent ? Colors.green : Colors.red).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isPresent ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student["studentName"] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Class: ${student['classIn'] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 11,
                              color: mainColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (timeIn != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time, size: 10, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('hh:mm a').format(timeIn),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPresent ? "Present" : "Absent",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPresent ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceDetails(Map<String, dynamic> student, DateTime? timeIn, DateTime? timeOut) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: student['status'] == "present"
                            ? [Colors.green, Colors.green.shade700]
                            : [Colors.red, Colors.red.shade700],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(
                        student['status'] == "present" ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student["studentName"] ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Status: ${student['status']?.toUpperCase() ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            color: student['status'] == "present" ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow("Class", student['classIn'] ?? "N/A", Icons.class_),
              _buildDetailRow("Date", getFormattedDate(), Icons.calendar_today),
              if (timeIn != null) 
                _buildDetailRow("Time In", DateFormat('hh:mm a').format(timeIn), Icons.login),
              if (timeOut != null) 
                _buildDetailRow("Time Out", DateFormat('hh:mm a').format(timeOut), Icons.logout),
              if (student['remarks'] != null && student['remarks'].toString().isNotEmpty)
                _buildDetailRow("Remarks", student['remarks'], Icons.comment),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: mainColor),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(mainColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading attendance data...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_edu,
                size: 50,
                color: mainColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "No Attendance Records",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "No attendance data found for this date",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}