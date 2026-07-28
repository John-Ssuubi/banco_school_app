// ignore_for_file: avoid_types_as_parameter_names, deprecated_member_use, file_names

import 'package:banco_mobile/BarCodeScanner/barcode_scanner.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceTeacher extends StatefulWidget {
  final String schoolId;
  final String date;

  const AttendanceTeacher({
    super.key,
    required this.schoolId,
    required this.date,
  });

  @override
  State<AttendanceTeacher> createState() => _AttendanceTeacherState();
}

class _AttendanceTeacherState extends State<AttendanceTeacher>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, int>> _attendanceData;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> allClasses = [
    'P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7',
  ];

  // Gradient pairs per class for the summary cards
  static const List<List<Color>> _classGradients = [
    [Color(0xFF1E88E5), Color(0xFF1565C0)],
    [Color(0xFF00897B), Color(0xFF00695C)],
    [Color(0xFF8E24AA), Color(0xFF6A1B9A)],
    [Color(0xFFF57C00), Color(0xFFE65100)],
    [Color(0xFFE53935), Color(0xFFC62828)],
    [Color(0xFF3949AB), Color(0xFF283593)],
    [Color(0xFF00ACC1), Color(0xFF00838F)],
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

    Map<String, int> classCounts = {for (var c in allClasses) c: 0};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = (data['status'] ?? '').toString().toLowerCase().trim();
      final classIn = (data['classIn'] ?? '').toString().toUpperCase().trim();
      if (status == 'present' && classCounts.containsKey(classIn)) {
        classCounts[classIn] = (classCounts[classIn] ?? 0) + 1;
      }
    }

    if (kDebugMode) print('Class-wise present count: $classCounts');
    return classCounts;
  }

  @override
  void initState() {
    super.initState();
    _attendanceData = getAttendanceData();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _attendanceData.then((_) => _fadeController.forward());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String get _formattedDate {
    try {
      final dt = DateTime.parse(widget.date);
      return DateFormat('EEEE, MMMM d, yyyy').format(dt);
    } catch (_) {
      return widget.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FutureBuilder<Map<String, int>>(
        future: _attendanceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final data = snapshot.data ?? {};
          final chartData =
              allClasses.map((c) => AttendanceData(c, data[c] ?? 0)).toList();
          final totalPresent =
              data.values.fold<int>(0, (sum, v) => sum + v);

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeroHeader(totalPresent)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'By Class',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A202C),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cls = allClasses[index];
                        final count = data[cls] ?? 0;
                        final gradient = _classGradients[
                            index % _classGradients.length];
                        return _buildClassCard(
                          cls: cls,
                          count: count,
                          gradient: gradient,
                          index: index,
                        );
                      },
                      childCount: allClasses.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildChartSection(chartData)),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ─── Hero Header ───────────────────────────────────────────────────────────

  Widget _buildHeroHeader(int totalPresent) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.25)!],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.how_to_reg_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Attendance',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _formattedDate,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStatPill(
                    label: 'Total Present',
                    value: '$totalPresent',
                    icon: Icons.check_circle_rounded,
                  ),
                  const SizedBox(width: 12),
                  _buildStatPill(
                    label: 'Classes',
                    value: '${allClasses.length}',
                    icon: Icons.class_rounded,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Class Cards ───────────────────────────────────────────────────────────

  Widget _buildClassCard({
    required String cls,
    required int count,
    required List<Color> gradient,
    required int index,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60)),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child:
            Transform.translate(offset: Offset(0, 14 * (1 - value)), child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: count == 0
                ? [Colors.grey.shade200, Colors.grey.shade300]
                : gradient,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (count == 0 ? Colors.grey : gradient[0])
                  .withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: count == 0 ? Colors.grey.shade500 : Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              cls,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: count == 0
                    ? Colors.grey.shade500
                    : Colors.white.withOpacity(0.85),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Chart ─────────────────────────────────────────────────────────────────

  Widget _buildChartSection(List<AttendanceData> chartData) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart_rounded,
                    color: mainColor, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Attendance Chart',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                axisLine: const AxisLine(width: 0),
                majorGridLines: const MajorGridLines(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: TextStyle(
                    color: Colors.grey.shade600, fontSize: 11),
              ),
              primaryYAxis: NumericAxis(
                interval: 1,
                minimum: 0,
                axisLine: const AxisLine(width: 0),
                majorGridLines: MajorGridLines(
                    color: Colors.grey.shade100, width: 1),
                majorTickLines: const MajorTickLines(size: 0),
                labelStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 10),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                color: mainColor,
                textStyle: const TextStyle(color: Colors.white),
              ),
              series: <CartesianSeries>[
                ColumnSeries<AttendanceData, String>(
                  dataSource: chartData,
                  xValueMapper: (d, _) => d.className,
                  yValueMapper: (d, _) => d.presentCount,
                  name: 'Present',
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.2)!],
                  ),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  spacing: 0.2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── FAB ───────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.2)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BarcodeScannerPage(schoolId: widget.schoolId),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner_rounded,
                    color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Scan Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── States ────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: mainColor.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading attendance...',
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.red.shade300),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load attendance',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748)),
          ),
          const SizedBox(height: 6),
          Text(error,
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}

class AttendanceData {
  final String className;
  final int presentCount;
  AttendanceData(this.className, this.presentCount);
}