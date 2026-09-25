import 'package:banco_mobile/biometric/ui.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AdminAttendance extends StatefulWidget {
  final String schoolId;
  final String today;

  const AdminAttendance({
    super.key,
    required this.schoolId,
    required this.today,
  });

  @override
  State<AdminAttendance> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AdminAttendance> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> attendanceDates = [];
  bool loadingDates = true;
  int length = 0;

  // Tab filter
  String _selectedTab = 'All'; // 'All', 'Students', 'Staff'

  // 🔧 NEW: Status filter
  String _statusFilter = 'all'; // all | late | ontime | signedout | noout

  /// Late threshold (from Firestore or default)
  TimeOfDay _lateThreshold = const TimeOfDay(hour: 8, minute: 30);

  @override
  void initState() {
    super.initState();
    loadAttendanceDates();
    _loadLateThreshold();
  }

  /// Load the school's configured late threshold (optional — adjust to your schema)
  Future<void> _loadLateThreshold() async {
    try {
      final schoolDoc = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .get();
      final data = schoolDoc.data() ?? {};
      final h = (data['lateThresholdHour'] as num?)?.toInt();
      final m = (data['lateThresholdMinute'] as num?)?.toInt();
      if (h != null && m != null) {
        setState(() {
          _lateThreshold = TimeOfDay(hour: h, minute: m);
        });
      }
    } catch (_) {
      // Silently keep default
    }
  }

  /// Load all dates that have attendance (both students and staff)
  Future<void> loadAttendanceDates() async {
    final attendanceCollection = FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('attendance');

    final allDates = await attendanceCollection.get();
    List<DateTime> temp = [];

    for (var dateDoc in allDates.docs) {
      final dateId = dateDoc.id;
      bool hasAttendance = false;

      final studentsSnap = await attendanceCollection
          .doc(dateId)
          .collection('students')
          .limit(1)
          .get();
      if (studentsSnap.docs.isNotEmpty) hasAttendance = true;

      if (!hasAttendance) {
        final staffSnap = await attendanceCollection
            .doc(dateId)
            .collection('staff')
            .limit(1)
            .get();
        if (staffSnap.docs.isNotEmpty) hasAttendance = true;
      }

      if (hasAttendance) {
        try {
          temp.add(DateTime.parse(dateId));
        } catch (_) {}
      }
    }

    setState(() {
      attendanceDates = temp;
      loadingDates = false;
    });
  }

  /// 🔧 Determine status string for an attendee
  String _statusOf(Map<String, dynamic> a) {
    final fsStatus = (a['status'] ?? '').toString().toLowerCase();
    if (fsStatus.isNotEmpty &&
        fsStatus != 'present' &&
        fsStatus != 'ontime' &&
        fsStatus != 'on time') {
      return fsStatus;
    }

    final timeIn = a['timeIn'];
    if (timeIn is Timestamp) {
      final t = timeIn.toDate();
      final threshold = DateTime(
        t.year, t.month, t.day,
        _lateThreshold.hour, _lateThreshold.minute,
      );
      if (t.isAfter(threshold)) return 'late';
    }
    return 'ontime';
  }

  /// 🔧 Load attendance for selected date (with filters)
  Future<List<Map<String, dynamic>>> loadAttendance() async {
    String dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    List<Map<String, dynamic>> allAttendance = [];

    try {
      final attendanceDoc = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('attendance')
          .doc(dateString);

      // Load students
      if (_selectedTab == 'All' || _selectedTab == 'Students') {
        final studentsSnap = await attendanceDoc.collection('students').get();
        for (var doc in studentsSnap.docs) {
          final data = doc.data();
          data['attendanceType'] = 'student';
          data['_docId'] = doc.id;
          allAttendance.add(data);
        }
      }

      // Load staff
      if (_selectedTab == 'All' || _selectedTab == 'Staff') {
        final staffSnap = await attendanceDoc.collection('staff').get();
        for (var doc in staffSnap.docs) {
          final data = doc.data();
          data['attendanceType'] = 'staff';
          data['_docId'] = doc.id;
          allAttendance.add(data);
        }
      }

      // ---- Apply status filter ----
      if (_statusFilter != 'all') {
        allAttendance = allAttendance.where((a) {
          final st = _statusOf(a);
          switch (_statusFilter) {
            case 'late':
              return st == 'late';
            case 'ontime':
              return st == 'ontime';
            case 'signedout':
              return a['timeOut'] != null;
            case 'noout':
              return a['timeOut'] == null;
            default:
              return true;
          }
        }).toList();
      }

      // Sort by timeIn desc
      allAttendance.sort((a, b) {
        final timeA = a['timeIn'] is Timestamp
            ? (a['timeIn'] as Timestamp).toDate()
            : DateTime(2000);
        final timeB = b['timeIn'] is Timestamp
            ? (b['timeIn'] as Timestamp).toDate()
            : DateTime(2000);
        return timeB.compareTo(timeA);
      });
    } catch (e) {
      print('Error loading attendance: $e');
    }

    return allAttendance;
  }

  Future<int> getPresentCount() async {
    final attendance = await loadAttendance();
    return attendance.where((s) => s['status'] == 'present').length;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);

    if (_selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day) {
      formattedDate = "Today";
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        title: Text(
          "$formattedDate - $length present",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AttendanceApp()));
            },
            icon: const Icon(Icons.fingerprint),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => loadingDates = true);
              loadAttendanceDates();
            },
          ),
        ],
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
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _updatePresentCount();
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
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 10),

                /// 📊 Type filter tabs (All / Students / Staff)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildFilterTab('All', Icons.people),
                      const SizedBox(width: 8),
                      _buildFilterTab('Students', Icons.school),
                      const SizedBox(width: 8),
                      _buildFilterTab('Staff', Icons.work),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                /// 🔧 NEW: Status filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusChip('All', 'all', Icons.list),
                        const SizedBox(width: 8),
                        _buildStatusChip('Late', 'late', Icons.warning_amber),
                        const SizedBox(width: 8),
                        _buildStatusChip('On Time', 'ontime', Icons.check_circle),
                        const SizedBox(width: 8),
                        _buildStatusChip('Signed Out', 'signedout', Icons.logout),
                        const SizedBox(width: 8),
                        _buildStatusChip('No Sign Out', 'noout', Icons.lock_clock),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 👨‍🎓 Attendance list
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: loadAttendance(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted && length != 0) {
                            setState(() => length = 0);
                          }
                        });

                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                "No attendance found",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "No one matches the current filters",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      final attendees = snapshot.data!;
                      final presentCount = attendees
                          .where((s) => s['status'] == 'present')
                          .length;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && length != presentCount) {
                          setState(() => length = presentCount);
                        }
                      });

                      return ListView.builder(
                        itemCount: attendees.length,
                        itemBuilder: (context, index) {
                          final attendee = attendees[index];
                          return _buildAttendeeTile(attendee, formattedDate);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  /// 🔧 NEW: single attendee row widget
  Widget _buildAttendeeTile(Map<String, dynamic> attendee, String formattedDate) {
    final timeIn = attendee['timeIn'] is Timestamp
        ? (attendee['timeIn'] as Timestamp).toDate()
        : null;
    final timeOut = attendee['timeOut'] is Timestamp
        ? (attendee['timeOut'] as Timestamp).toDate()
        : null;

    final isStaff = attendee['attendanceType'] == 'staff';
    final name = isStaff
        ? attendee['staffName'] ?? 'Unknown Staff'
        : attendee['studentName'] ?? 'Unknown Student';
    final classInfo = isStaff
        ? 'Role: ${(attendee['role'] ?? 'Staff').toString().toUpperCase()}'
        : 'Class: ${attendee['classIn'] ?? 'N/A'}';

    final status = _statusOf(attendee);
    final isLate = status == 'late';

    return InkWell(
      onTap: () {
        if (isStaff) {
          // 🔧 Staff → open full history screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StaffAttendanceHistory(
                schoolId: widget.schoolId,
                staffId: attendee['staffId'] ?? attendee['_docId'] ?? '',
                staffName: name,
              ),
            ),
          );
        } else {
          // Students → simple dialog (as before)
          _showStudentDialog(attendee, name, classInfo, formattedDate,
              timeIn, timeOut);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          decoration: BoxDecoration(
            color: isStaff ? Colors.purple.shade700 : mainColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Icon(
                isStaff ? Icons.work : Icons.school,
                color: Colors.white,
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              classInfo,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isStaff)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'STAFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                // In / Out times
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (timeIn != null)
                      Text(
                        "In: ${DateFormat('hh:mm a').format(timeIn)}",
                        style: TextStyle(
                          color: isLate
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    if (timeOut != null)
                      Text(
                        "Out: ${DateFormat('hh:mm a').format(timeOut)}",
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )
                    else
                      const Text(
                        "No out",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Student detail dialog
  void _showStudentDialog(
    Map<String, dynamic> attendee,
    String name,
    String classInfo,
    String formattedDate,
    DateTime? timeIn,
    DateTime? timeOut,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: Student"),
            Text("Status: ${attendee['status']}"),
            Text(classInfo),
            Text("Date: $formattedDate"),
            if (timeIn != null)
              Text("Time In: ${DateFormat('hh:mm a').format(timeIn)}"),
            if (timeOut != null)
              Text("Time Out: ${DateFormat('hh:mm a').format(timeOut)}"),
            if (attendee['remarks'] != null)
              Text("Remarks: ${attendee['remarks']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, IconData icon) {
    final isSelected = _selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = label;
            _updatePresentCount();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? mainColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔧 NEW: status filter chip
  Widget _buildStatusChip(String label, String value, IconData icon) {
    final isSelected = _statusFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _statusFilter = value;
          _updatePresentCount();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepOrange : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updatePresentCount() async {
    final count = await getPresentCount();
    if (mounted) {
      setState(() => length = count);
    }
  }
}

// =====================================================================
// 🔧 NEW: Staff Attendance History screen
// =====================================================================

class StaffAttendanceHistory extends StatefulWidget {
  final String schoolId;
  final String staffId;
  final String staffName;

  const StaffAttendanceHistory({
    super.key,
    required this.schoolId,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<StaffAttendanceHistory> createState() =>
      _StaffAttendanceHistoryState();
}

class _StaffAttendanceHistoryState extends State<StaffAttendanceHistory> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  bool _loading = false;
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _records = [];
    });

    final attendanceCol = FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('attendance');

    final days = <DateTime>[];
    var cur = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
    final end = DateTime(_toDate.year, _toDate.month, _toDate.day);
    while (!cur.isAfter(end)) {
      days.add(cur);
      cur = cur.add(const Duration(days: 1));
      if (days.length > 366) break;
    }

    final results = <Map<String, dynamic>>[];

    for (final d in days) {
      final dateId = DateFormat('yyyy-MM-dd').format(d);
      try {
        final snap = await attendanceCol
            .doc(dateId)
            .collection('staff')
            .doc('${widget.staffId}_$dateId')
            .get();
        if (snap.exists) {
          final data = snap.data()!;
          data['_date'] = dateId;
          results.add(data);
        }
      } catch (_) {
        // ignore
      }
    }

    results.sort((a, b) {
      final da = a['_date'] as String? ?? '';
      final db = b['_date'] as String? ?? '';
      return db.compareTo(da);
    });

    if (mounted) {
      setState(() {
        _records = results;
        _loading = false;
      });
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int ontime = 0;
    int late = 0;
    int withOut = 0;

    for (final r in _records) {
      final t = r['timeIn'] is Timestamp
          ? (r['timeIn'] as Timestamp).toDate()
          : null;
      if (t != null && t.hour > 8 || (t != null && t.hour == 8 && t.minute > 30)) {
        late++;
      } else {
        ontime++;
      }
      if (r['timeOut'] != null) withOut++;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.staffName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat('yyyy-MM-dd').format(_fromDate)),
                    onPressed: () => _pickDate(true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("→"),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat('yyyy-MM-dd').format(_toDate)),
                    onPressed: () => _pickDate(false),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loadHistory,
                  style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                  child: const Text("Load",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // Summary chips
          if (!_loading && _records.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  _statChip('Total', '${_records.length}', Colors.blue),
                  const SizedBox(width: 8),
                  _statChip('On Time', '$ontime', Colors.green),
                  const SizedBox(width: 8),
                  _statChip('Late', '$late', Colors.orange),
                  const SizedBox(width: 8),
                  _statChip('Signed Out', '$withOut', Colors.purple),
                ],
              ),
            ),

          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? const Center(
                        child: Text("No records in this range",
                            style: TextStyle(color: Colors.grey)),
                      )
                    : ListView.separated(
                        itemCount: _records.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final r = _records[i];
                          final date = r['_date'] ?? '—';
                          final inT = r['timeIn'] is Timestamp
                              ? (r['timeIn'] as Timestamp).toDate()
                              : null;
                          final outT = r['timeOut'] is Timestamp
                              ? (r['timeOut'] as Timestamp).toDate()
                              : null;

                          final isLate = inT != null &&
                              (inT.hour > 8 ||
                                  (inT.hour == 8 && inT.minute > 30));

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isLate ? Colors.orange : Colors.green,
                              child: Icon(
                                isLate
                                    ? Icons.warning_amber
                                    : Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(date),
                            subtitle: Row(
                              children: [
                                if (inT != null)
                                  Text(
                                    "In: ${DateFormat('hh:mm a').format(inT)}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                const SizedBox(width: 10),
                                if (outT != null)
                                  Text(
                                    "Out: ${DateFormat('hh:mm a').format(outT)}",
                                    style: const TextStyle(fontSize: 12),
                                  )
                                else
                                  const Text(
                                    "No sign out",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                isLate ? "Late" : "On Time",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                              backgroundColor:
                                  isLate ? Colors.orange : Colors.green,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$label: $value",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
} 