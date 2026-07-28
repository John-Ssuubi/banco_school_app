// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use

import 'package:banco_mobile/Charts/stat_model.dart';
import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/HeadTeacher/StatTerm1/build_bot_view.dart';
import 'package:banco_mobile/HeadTeacher/stat_ht_term2.dart';
import 'package:banco_mobile/HeadTeacher/stat_ht_term3.dart';
import 'package:banco_mobile/division_cal.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

class StatHt extends StatefulWidget {
  final String model;
  final String schoolId;
  const StatHt({super.key, required this.model, required this.schoolId});

  @override
  State<StatHt> createState() => _StatHtState();
}

class _StatHtState extends State<StatHt> with SingleTickerProviderStateMixin {
  String? selectedSubject;
  List<String> subjects = [];
  bool isLoadingSubjects = true;
  int currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Grading ranges
  int d1Start = 0, d1End = 0;
  int d2Start = 0, d2End = 0;
  int c3Start = 0, c3End = 0;
  int c4Start = 0, c4End = 0;
  int c5Start = 0, c5End = 0;
  int c6Start = 0, c6End = 0;
  int p7Start = 0, p7End = 0;
  int p8Start = 0, p8End = 0;
  int f9Start = 0, f9End = 0;

  bool gradingLoaded = false;

  // Color scheme
  final List<Color> gradeColors = [
    Colors.green.shade700,
    Colors.lightGreen.shade600,
    Colors.lime.shade600,
    Colors.yellow.shade700,
    Colors.orange.shade600,
    Colors.deepOrange.shade600,
    Colors.red.shade400,
    Colors.red.shade700,
    Colors.brown.shade700,
    Colors.grey.shade500,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    
    _loadGrading();
    _extractSubjects();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPerformanceFeedback();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadGrading() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      setState(() {
        d1Start = data['D1Start'] ?? 0;
        d1End = data['D1End'] ?? 0;
        d2Start = data['D2Start'] ?? 0;
        d2End = data['D2End'] ?? 0;
        c3Start = data['c3Start'] ?? 0;
        c3End = data['c3End'] ?? 0;
        c4Start = data['c4Start'] ?? 0;
        c4End = data['c4End'] ?? 0;
        c5Start = data['c5Start'] ?? 0;
        c5End = data['c5End'] ?? 0;
        c6Start = data['c6Start'] ?? 0;
        c6End = data['c6End'] ?? 0;
        p7Start = data['p7Start'] ?? 0;
        p7End = data['p7End'] ?? 0;
        p8Start = data['p8Start'] ?? 0;
        p8End = data['p8End'] ?? 0;
        f9Start = data['f9Start'] ?? 0;
        f9End = data['f9End'] ?? 0;
        gradingLoaded = true;
      });
    } catch (e) {
      print("Error loading grading: $e");
    }
  }

  Future<void> _showPerformanceFeedback() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(DateTime.now().year.toString())
          .collection(widget.model)
          .get();

      if (snapshot.docs.isEmpty) return;

      final students = snapshot.docs
          .map((doc) => StudentModelP4.fromJson(doc.data()))
          .toList();

      Map<String, List<int>> subjectScores = {};
      
      for (var student in students) {
        for (var subject in student.subjectsScore) {
          subjectScores.putIfAbsent(subject.subjectName, () => []);
          if (subject.scoreBOT != -1) {
            subjectScores[subject.subjectName]!.add(subject.scoreBOT.toInt());
          }
        }
      }

      Map<String, double> averages = {};
      subjectScores.forEach((subject, scores) {
        if (scores.isNotEmpty) {
          double avg = scores.reduce((a, b) => a + b) / scores.length;
          averages[subject] = avg;
        }
      });

      if (averages.isEmpty) return;

      String bestSubject = averages.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      String worstSubject = averages.entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 500));
      
      showDialog(
        context: context,
        builder: (context) {
          return AnimationLimiter(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mainColor, mainColor.withOpacity(0.7)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.insights, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Performance Insight",
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInsightCard(
                    "Best Performing Subject",
                    bestSubject,
                    averages[bestSubject]!.round(),
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                  const SizedBox(height: 15),
                  _buildInsightCard(
                    "Needs Improvement",
                    worstSubject,
                    averages[worstSubject]!.round(),
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text("OK", style: TextStyle(fontSize: 16)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Feedback error: $e");
    }
  }

  Widget _buildInsightCard(String title, String subject, int score, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$score%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPerformanceFeedbackMID() async {
    // Similar to _showPerformanceFeedback but for MID
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(DateTime.now().year.toString())
          .collection(widget.model)
          .get();

      if (snapshot.docs.isEmpty) return;

      final students = snapshot.docs
          .map((doc) => StudentModelP4.fromJson(doc.data()))
          .toList();

      Map<String, List<int>> subjectScores = {};

      for (var student in students) {
        for (var subject in student.subjectsScore) {
          subjectScores.putIfAbsent(subject.subjectName, () => []);
          if (subject.scoreMT != -1) {
            subjectScores[subject.subjectName]!.add(subject.scoreMT.toInt());
          }
        }
      }

      Map<String, double> averages = {};
      subjectScores.forEach((subject, scores) {
        if (scores.isNotEmpty) {
          double avg = scores.reduce((a, b) => a + b) / scores.length;
          averages[subject] = avg;
        }
      });

      if (averages.isEmpty) return;

      String worstSubject = averages.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      String bestSubject = averages.entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 500));
      
      showDialog(
        context: context,
        builder: (context) => _buildInsightDialog(bestSubject, worstSubject, averages),
      );
    } catch (e) {
      print("Feedback error: $e");
    }
  }

  Future<void> _showPerformanceFeedbackEND() async {
    // Similar implementation for END
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(DateTime.now().year.toString())
          .collection(widget.model)
          .get();

      if (snapshot.docs.isEmpty) return;

      final students = snapshot.docs
          .map((doc) => StudentModelP4.fromJson(doc.data()))
          .toList();

      Map<String, List<int>> subjectScores = {};

      for (var student in students) {
        for (var subject in student.subjectsScore) {
          subjectScores.putIfAbsent(subject.subjectName, () => []);
          if (subject.scoreEOT != -1) {
            subjectScores[subject.subjectName]!.add(subject.scoreEOT.toInt());
          }
        }
      }

      Map<String, double> averages = {};
      subjectScores.forEach((subject, scores) {
        if (scores.isNotEmpty) {
          double avg = scores.reduce((a, b) => a + b) / scores.length;
          averages[subject] = avg;
        }
      });

      if (averages.isEmpty) return;

      String bestSubject = averages.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      String worstSubject = averages.entries
          .reduce((a, b) => a.value < b.value ? a : b)
          .key;

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 500));
      
      showDialog(
        context: context,
        builder: (context) => _buildInsightDialog(bestSubject, worstSubject, averages),
      );
    } catch (e) {
      print("Feedback error: $e");
    }
  }

  Widget _buildInsightDialog(String bestSubject, String worstSubject, Map<String, double> averages) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mainColor, mainColor.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.insights, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            "Performance Insight",
            style: TextStyle(
              color: mainColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInsightCard(
            "Best Performing Subject",
            bestSubject,
            averages[bestSubject]!.round(),
            Icons.emoji_events,
            Colors.amber,
          ),
          const SizedBox(height: 15),
          _buildInsightCard(
            "Needs Improvement",
            worstSubject,
            averages[worstSubject]!.round(),
            Icons.trending_up,
            Colors.orange,
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: mainColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text("OK", style: TextStyle(fontSize: 16)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _extractSubjects() async {
    setState(() => isLoadingSubjects = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(DateTime.now().year.toString())
          .collection(widget.model)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final student = StudentModelP4.fromJson(snapshot.docs.first.data());
        setState(() {
          subjects = student.subjectsScore
              .map((subject) => subject.subjectName)
              .toList();
          if (subjects.isNotEmpty) selectedSubject = subjects[0];
        });
      }
    } catch (e) {
      print('Error loading subjects: $e');
    } finally {
      setState(() => isLoadingSubjects = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Statistics - Term ${_getTermText()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mainColor, mainColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == "Term2") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatHtTermII(
                      model: widget.model,
                      schoolId: widget.schoolId,
                    ),
                  ),
                );
              }
              if (value == "Term3") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatHtTermIII(
                      model: widget.model,
                      schoolId: widget.schoolId,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "Term2",
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, size: 20),
                    SizedBox(width: 10),
                    Text("Term 2 Statistics"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: "Term3",
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 20),
                    SizedBox(width: 10),
                    Text("Term 3 Statistics"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _getSelectedView(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (value) {
              setState(() {
                currentIndex = value;
                _animationController.reset();
                _animationController.forward();
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: mainColor,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == 0 ? mainColor.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: const Icon(Icons.school),
                ),
                label: 'Beginning',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == 1 ? mainColor.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: const Icon(Icons.timeline),
                ),
                label: 'Mid',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == 2 ? mainColor.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: const Icon(Icons.flag),
                ),
                label: 'End',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTermText() {
    if (currentIndex == 0) return 'One (Beginning)';
    if (currentIndex == 1) return 'One (Mid)';
    return 'One (End)';
  }

  Widget _getSelectedView() {
    if (currentIndex == 0) return _buildBOTView();
    if (currentIndex == 1) return _buildMIDView();
    return _buildENDView();
  }

  Widget _buildBOTView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isLoadingSubjects)
            _buildShimmerLoader()
          else if (subjects.isNotEmpty)
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                  child: _buildSubjectDropdown(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Schools')
                .doc(widget.schoolId)
                .collection('Years')
                .doc(DateTime.now().year.toString())
                .collection(widget.model)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final students = snapshot.data!.docs
                  .map((doc) => StudentModelP4.fromJson(doc.data()))
                  .toList();

              final List<GradeData> chartData = _calculateGradeDistribution(students);
              final List<Map<String, dynamic>> rankingsub =
                  getSubjectRankingBOTTerm2(students, selectedSubject ?? '');

              return Column(
                children: [
                  if (selectedSubject != null)
                    AnimationConfiguration.staggeredList(
                      position: 1,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: _buildChartCard(
                            title: '📊 Subject Performance - $selectedSubject',
                            icon: Icons.assessment,
                            chart: _buildSubjectRankingChart(rankingsub),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  AnimationConfiguration.staggeredList(
                    position: 2,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(
                        child: _buildChartCard(
                          title: 'Grade Distribution Overview',
                          icon: Icons.pie_chart,
                          chart: _buildGradeDistributionChart(chartData),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMIDView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPerformanceFeedbackMID();
    });
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isLoadingSubjects)
            _buildShimmerLoader()
          else if (subjects.isNotEmpty)
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                  child: _buildSubjectDropdown(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Schools')
                .doc(widget.schoolId)
                .collection('Years')
                .doc(DateTime.now().year.toString())
                .collection(widget.model)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final students = snapshot.data!.docs
                  .map((doc) => StudentModelP4.fromJson(doc.data()))
                  .toList();

              final List<GradeData> chartData = _calculateGradeDistributionMID(students);
              final List<Map<String, dynamic>> rankingsub =
                  getSubjectRankingMIDTerm2(students, selectedSubject ?? '');

              return Column(
                children: [
                  if (selectedSubject != null)
                    AnimationConfiguration.staggeredList(
                      position: 1,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: _buildChartCard(
                            title: '📊 Subject Performance - $selectedSubject',
                            icon: Icons.assessment,
                            chart: _buildSubjectRankingChartMID(rankingsub),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  AnimationConfiguration.staggeredList(
                    position: 2,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(
                        child: _buildChartCard(
                          title: 'Grade Distribution Overview',
                          icon: Icons.pie_chart,
                          chart: _buildGradeDistributionChart(chartData),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildENDView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPerformanceFeedbackEND();
    });
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isLoadingSubjects)
            _buildShimmerLoader()
          else if (subjects.isNotEmpty)
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50,
                child: FadeInAnimation(
                  child: _buildSubjectDropdown(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('Schools')
                .doc(widget.schoolId)
                .collection('Years')
                .doc(DateTime.now().year.toString())
                .collection(widget.model)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingState();
              }
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final students = snapshot.data!.docs
                  .map((doc) => StudentModelP4.fromJson(doc.data()))
                  .toList();

              final List<GradeData> chartData = _calculateGradeDistributionEND(students);
              final List<Map<String, dynamic>> rankingsub =
                  getSubjectRankingENDTerm2(students, selectedSubject ?? '');

              return Column(
                children: [
                  if (selectedSubject != null)
                    AnimationConfiguration.staggeredList(
                      position: 1,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50,
                        child: FadeInAnimation(
                          child: _buildChartCard(
                            title: '📊 Subject Performance - $selectedSubject',
                            icon: Icons.assessment,
                            chart: _buildSubjectRankingChartEND(rankingsub),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  AnimationConfiguration.staggeredList(
                    position: 2,
                    duration: const Duration(milliseconds: 500),
                    child: SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(
                        child: _buildChartCard(
                          title: 'Grade Distribution Overview',
                          icon: Icons.pie_chart,
                          chart: _buildGradeDistributionChart(chartData),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: mainColor),
          const SizedBox(height: 16),
          Text(
            'Loading student data...',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, color: Colors.blue.shade400, size: 60),
            const SizedBox(height: 16),
            Text(
              'No Students Found',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add students to see statistics',
              style: TextStyle(color: Colors.blue.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required IconData icon, required Widget chart}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mainColor, mainColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                SizedBox(
                  height: 320,
                  child: chart,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedSubject,
            isExpanded: true,
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_drop_down, color: mainColor),
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            onChanged: (value) {
              setState(() {
                selectedSubject = value;
              });
            },
            items: subjects.map((subject) {
              return DropdownMenuItem(
                value: subject,
                child: Row(
                  children: [
                    Icon(Icons.book, color: mainColor, size: 18),
                    const SizedBox(width: 10),
                    Text(subject),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeDistributionChart(List<GradeData> chartData) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        labelPlacement: LabelPlacement.onTicks,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'Number of Students',
          textStyle: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        interval: 1,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        tooltipPosition: TooltipPosition.pointer,
        textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      series: <CartesianSeries<GradeData, String>>[
        ColumnSeries<GradeData, String>(
          dataSource: chartData,
          xValueMapper: (GradeData data, _) => data.grade,
          yValueMapper: (GradeData data, _) => data.count,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          pointColorMapper: (GradeData data, _) {
            int index = chartData.indexOf(data);
            return gradeColors[index % gradeColors.length];
          },
          borderRadius: BorderRadius.circular(8),
          animationDuration: 1000,
        ),
      ],
    );
  }

  Widget _buildSubjectRankingChart(List<Map<String, dynamic>> rankingsub) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: 'Students',
          textStyle: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelRotation: -45,
        labelStyle: const TextStyle(fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'BOT Score (%)',
          textStyle: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        minimum: 0,
        maximum: 100,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<Map<String, dynamic>, String>>[
        BarSeries<Map<String, dynamic>, String>(
          dataSource: rankingsub,
          xValueMapper: (data, _) => data['studentName'],
          yValueMapper: (data, _) => data['botScore'],
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          color: Colors.teal.shade500,
          borderRadius: BorderRadius.circular(8),
          animationDuration: 1000,
        ),
      ],
    );
  }

  Widget _buildSubjectRankingChartMID(List<Map<String, dynamic>> rankingsub) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: 'Students',
          textStyle: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelRotation: -45,
        labelStyle: const TextStyle(fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'MID Score (%)',
          textStyle: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        minimum: 0,
        maximum: 100,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<Map<String, dynamic>, String>>[
        BarSeries<Map<String, dynamic>, String>(
          dataSource: rankingsub,
          xValueMapper: (data, _) => data['studentName'],
          yValueMapper: (data, _) => data['mtScore'],
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          color: Colors.orange.shade500,
          borderRadius: BorderRadius.circular(8),
          animationDuration: 1000,
        ),
      ],
    );
  }

  Widget _buildSubjectRankingChartEND(List<Map<String, dynamic>> rankingsub) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: 'Students',
          textStyle: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        labelRotation: -45,
        labelStyle: const TextStyle(fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'END Score (%)',
          textStyle: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        minimum: 0,
        maximum: 100,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<Map<String, dynamic>, String>>[
        BarSeries<Map<String, dynamic>, String>(
          dataSource: rankingsub,
          xValueMapper: (data, _) => data['studentName'],
          yValueMapper: (data, _) => data['endScore'],
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          color: Colors.purple.shade500,
          borderRadius: BorderRadius.circular(8),
          animationDuration: 1000,
        ),
      ],
    );
  }

  List<GradeData> _calculateGradeDistribution(List<StudentModelP4> students) {
    Map<String, int> gradeCount = {
      'D1': 0, 'D2': 0, 'C3': 0, 'C4': 0, 'C5': 0, 'C6': 0, 'P7': 0, 'P8': 0, 'F9': 0, 'X': 0,
    };

    for (var student in students) {
      double total = 0;
      int count = 0;
      for (var subject in student.subjectsScore) {
        if (subject.scoreBOT != -1) {
          total += subject.scoreBOT.toDouble();
          count++;
        }
      }
      double average = count == 0 ? -1 : total / count;
      String division = divCalBOT(
        average, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End,
      );
      gradeCount[division] = (gradeCount[division] ?? 0) + 1;
    }

    return gradeCount.entries.map((e) => GradeData(e.key, e.value)).where((data) => data.count > 0).toList();
  }

  List<GradeData> _calculateGradeDistributionMID(List<StudentModelP4> students) {
    Map<String, int> gradeCount = {
      'D1': 0, 'D2': 0, 'C3': 0, 'C4': 0, 'C5': 0, 'C6': 0, 'P7': 0, 'P8': 0, 'F9': 0, 'X': 0,
    };

    for (var student in students) {
      double total = 0;
      int count = 0;
      for (var subject in student.subjectsScore) {
        if (subject.scoreMT != -1) {
          total += subject.scoreMT.toDouble();
          count++;
        }
      }
      double average = count == 0 ? -1 : total / count;
      String division = divCalMid(
        average, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End,
      );
      gradeCount[division] = (gradeCount[division] ?? 0) + 1;
    }

    return gradeCount.entries.map((e) => GradeData(e.key, e.value)).where((data) => data.count > 0).toList();
  }

  List<GradeData> _calculateGradeDistributionEND(List<StudentModelP4> students) {
    Map<String, int> gradeCount = {
      'D1': 0, 'D2': 0, 'C3': 0, 'C4': 0, 'C5': 0, 'C6': 0, 'P7': 0, 'P8': 0, 'F9': 0, 'X': 0,
    };

    for (var student in students) {
      double total = 0;
      int count = 0;
      for (var subject in student.subjectsScore) {
        if (subject.scoreEOT != -1) {
          total += subject.scoreEOT.toDouble();
          count++;
        }
      }
      double average = count == 0 ? -1 : total / count;
      String division = divCalBOT(
        average, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End,
      );
      gradeCount[division] = (gradeCount[division] ?? 0) + 1;
    }

    return gradeCount.entries.map((e) => GradeData(e.key, e.value)).where((data) => data.count > 0).toList();
  }
}