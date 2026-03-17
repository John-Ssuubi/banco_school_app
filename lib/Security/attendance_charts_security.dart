// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:banco_mobile/BarCodeScanner/barcode_scanner.dart';
import 'package:banco_mobile/HeadTeacher/about_school.dart';
import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/Teachers/SettingsTeacher/settings_teacher.dart';
import 'package:banco_mobile/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyAttendanceChartSecurity extends StatefulWidget {
  final String schoolId;
  final String date; // e.g. "2025-11-13"

  const DailyAttendanceChartSecurity({
    super.key,
    required this.schoolId,
    required this.date,
  });

  @override
  State<DailyAttendanceChartSecurity> createState() => _DailyAttendanceChartSecurityState();
}

class _DailyAttendanceChartSecurityState extends State<DailyAttendanceChartSecurity> {
  late Future<Map<String, int>> _attendanceData;

  // Predefined classes from P1–P7 with initial count 0
  final List<String> allClasses = [
    'P1',
    'P2',
    'P3',
    'P4',
    'P5',
    'P6',
    'P7',
  ];

  Future<Map<String, int>> getAttendanceData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('attendance')
        .doc(widget.date)
        .collection('students')
        .get();

    if (kDebugMode) {
      print('Fetched ${snapshot.docs.length} students for ${widget.date}');
    }

    // Start with all classes set to 0
    Map<String, int> classCounts = {
      for (var c in allClasses) c: 0,
    };

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = (data['status'] ?? '').toString().toLowerCase().trim();
      final classIn = (data['classIn'] ?? '').toString().toUpperCase().trim();

      // Count only present students
      if (status == 'present' && classCounts.containsKey(classIn)) {
        classCounts[classIn] = (classCounts[classIn] ?? 0) + 1;
      }
    }

    if (kDebugMode) {
      print('Class-wise present count: $classCounts');
    }

    return classCounts;
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthStudent()),
      (_) => false,
    );
  }


  Container _buildDrawer() {
    return   Container(
      color: Colors.white,

      
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const SizedBox();
            }
      
            final data = snapshot.data!.data() as Map<String, dynamic>;
      
            final firstName = data['firstName'] ?? '';
            final secondName = data['secondName'] ?? '';
            final role = data['role'] ?? '';
            final schoolId = data['schoolId'] ?? '';
      
            return Drawer(
              
              // backgroundColor: mainColor,
              // width: double.infinity - 20,
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: mainColor),
                    accountName: Text(
                      "$firstName $secondName",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: Text(
                      role.toUpperCase(), // e.g HEADTEACHER / TEACHER
                      style: const TextStyle(fontSize: 13),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.school, size: 45, color: mainColor),
                    ),
                  ),
      
                  ListTile(
                    leading: const Icon(Icons.home,
                    color: Colors.black,),
                    title: const Text('Home', style: TextStyle(color: Colors.black),),
                    onTap: () => Navigator.pop(
                      context,
                      // MaterialPageRoute(builder: (context) => const HomePage())
                    ),
                  ),
      
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black),
                    title: const Text('Settings', style: TextStyle(color: Colors.black),),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsTeacher()),
                    ),
                  ),
                  Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      logout(context);
                    },
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.logout, color: Colors.black),
                      ),
                      title: const Text('Logout', style: TextStyle(color: Colors.black),),
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Schools')
                      .doc(schoolId)
                      .snapshots(),
                  builder: (context, schoolSnapshot) {
                    if (!schoolSnapshot.hasData) return const SizedBox();

                    final data =
                        schoolSnapshot.data!.data() as Map<String, dynamic>? ??
                        {};

                    final schoolName = data['school_name'] ?? '';
                    final contact = data['contact'] ?? '';
                    final address = data['address'] ?? '';
                    final moto = data['moto'] ?? '';
                    final pobox = data['pobox'] ?? '';
                    final email = data['email'] ?? '';
                    final subscription = data['subscription'] ?? '';

                    final d1Start = data['D1Start'] ?? 0;
                    final d1End = data['D1End'] ?? 0;
                    final d2Start = data['D2Start'] ?? 0;
                    final d2End = data['D2End'] ?? 0;
                    final c3Start = data['c3Start'] ?? 0;
                    final c3End = data['c3End'] ?? 0;
                    final c4Start = data['c4Start'] ?? 0;
                    final c4End = data['c4End'] ?? 0;
                    final c5Start = data['c5Start'] ?? 0;
                    final c5End = data['c5End'] ?? 0;
                    final c6Start = data['c6Start'] ?? 0;
                    final c6End = data['c6End'] ?? 0;
                    final p7Start = data['p7Start'] ?? 0;
                    final p7End = data['p7End'] ?? 0;
                    final p8Start = data['p8Start'] ?? 0;
                    final p8End = data['p8End'] ?? 0;
                    final f9Start = data['f9Start'] ?? 0;
                    final f9End = data['f9End'] ?? 0;

                    // 🔥 Nested staff stream
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Schools')
                          .doc(schoolId)
                          .collection('staffMembers')
                          .snapshots(),
                      builder: (context, staffSnapshot) {
                        if (!staffSnapshot.hasData) return const SizedBox();

                        final staffMembersList = staffSnapshot.data!.docs.map((
                          doc,
                        ) {
                          final memberData = doc.data() as Map<String, dynamic>;

                          return StaffMember(
                            uid: memberData['teacherUid'],

                            firstName: memberData['firstName'] ?? '',
                            secondName: memberData['secondName'] ?? '',
                            role: memberData['role'] ?? '',
                            phone: memberData['phone'] ?? '',
                          );
                        }).toList();

                        return ListTile(
                          leading: const Icon(Icons.info, color: Colors.black),
                          title: const Text(
                            'About School',
                            style: TextStyle(color: Colors.black),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AboutSchool(
                                schoolName: schoolName,
                                pobox: pobox,
                                address: address,
                                moto: moto,
                                contact: contact,
                                email: email,
                                subscription: subscription,
                                d1Start: d1Start,
                                d1End: d1End,
                                d2Start: d2Start,
                                d2End: d2End,
                                c3Start: c3Start,
                                c3End: c3End,
                                c4Start: c4Start,
                                c4End: c4End,
                                c5Start: c5Start,
                                c5End: c5End,
                                c6Start: c6Start,
                                c6End: c6End,
                                p7Start: p7Start,
                                p7End: p7End,
                                p8Start: p8Start,
                                p8End: p8End,
                                f9Start: f9Start,
                                f9End: f9End,
                                staffMembers: staffMembersList,
                                linkedParents: const [], schoolId: schoolId,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                ],
              ),
            );
          },
        ),
    );
  }

  @override
  void initState() {
    super.initState();
    _attendanceData = getAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Daily Attendance by Class',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: mainColor,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _attendanceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data ?? {};
          final chartData = allClasses
              .map((c) => AttendanceData(c, data[c] ?? 0))
              .toList();

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SfCartesianChart(
              title: ChartTitle(
                text: 'Present Students per Class (${widget.date})',
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              primaryXAxis: CategoryAxis(
                title: AxisTitle(text: 'Class'),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: 'Number of Present Students'),
                interval: 1,
                minimum: 0,
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<AttendanceData, String>(
                  dataSource: chartData,
                  xValueMapper: (AttendanceData data, _) => data.className,
                  yValueMapper: (AttendanceData data, _) => data.presentCount,
                  name: 'Present Students',
                  color: Colors.indigo,
                  dataLabelSettings:
                      const DataLabelSettings(isVisible: true),
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  BarcodeScannerPage(schoolId: widget.schoolId),
                      ),
                    );
                  },
                  child: const Icon(Icons.barcode_reader),
                ),
    );
  }
}

class AttendanceData {
  final String className;
  final int presentCount;

  AttendanceData(this.className, this.presentCount);
}
