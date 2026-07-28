// ignore_for_file: deprecated_member_use

import 'package:banco_mobile/Parents/ChildrenResults/child_results.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ChildrenResults extends StatefulWidget {
  final String approve;

  const ChildrenResults({super.key, required this.approve});

  @override
  State<ChildrenResults> createState() => _ChildrenResultsState();
}

class _ChildrenResultsState extends State<ChildrenResults> with SingleTickerProviderStateMixin {
  final String year = DateTime.now().year.toString();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<String?> getStudentCollection(
    String schoolId,
    String studentId,
  ) async {
    final possibleCollections = [
      'studentModelP1',
      'studentModelP2',
      'studentModelP3',
      'studentModelP4',
      'studentModelP5',
      'studentModelP6',
      'studentModelP7',
    ];

    for (final col in possibleCollections) {
      final docSnap = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('Years')
          .doc(year)
          .collection(col)
          .doc(studentId)
          .get();

      if (docSnap.exists) {
        if (kDebugMode) {
          print("Found student in $col");
        }
        return col;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("User not logged in"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, parentSnapshot) {
        if (parentSnapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }

        if (!parentSnapshot.hasData || !parentSnapshot.data!.exists) {
          return _buildEmptyState(
            icon: Icons.error_outline,
            message: 'No linked children found.',
            color: Colors.orange,
          );
        }

        final parentData = parentSnapshot.data!.data() as Map<String, dynamic>? ?? {};
        final rawChildren = parentData['linkedChildren'];
        final List<Map<String, dynamic>> children = [];

        if (rawChildren is List) {
          for (var item in rawChildren) {
            if (item is Map) {
              children.add(Map<String, dynamic>.from(item));
            }
          }
        }

        if (children.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            message: 'You have no linked children.\nAdd children to get started.',
            color: Colors.blue,
          );
        }

        if (widget.approve != 'true') {
          return _buildPendingApprovalState();
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          color: mainColor,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                final schoolId = child['schoolId'];
                final studentId = child['studentId'];

                if (schoolId == null || studentId == null) {
                  return _buildErrorCard('Invalid child data');
                }

                return FutureBuilder<String?>(
                  future: getStudentCollection(schoolId, studentId),
                  builder: (context, classSnapshot) {
                    if (classSnapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingCard();
                    }

                    final collectionName = classSnapshot.data;

                    if (collectionName == null) {
                      return _buildErrorCard('Student record not found.');
                    }

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Schools')
                          .doc(schoolId)
                          .collection('Years')
                          .doc(year)
                          .collection(collectionName)
                          .doc(studentId)
                          .snapshots(),
                      builder: (context, studentSnap) {
                        if (studentSnap.connectionState == ConnectionState.waiting) {
                          return _buildLoadingCard();
                        }

                        if (!studentSnap.hasData || !studentSnap.data!.exists) {
                          return _buildErrorCard('Student data not found.');
                        }

                        final student = studentSnap.data!;
                        final studentName = student['studentName'] ?? 'Unknown';
                        final classIn = student['classIn'] ?? '';
                        final stream = student['stream'] ?? '';
                        // final gender = student['gender'] ?? '';

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50,
                            child: FadeInAnimation(
                              child: _buildStudentCard(
                                studentId: studentId,
                                schoolId: schoolId,
                                collectionName: collectionName,
                                studentName: studentName,
                                classIn: classIn,
                                stream: stream,
                                // gender: gender,
                                schoolIdDisplay: schoolId,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Student Card Widget
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStudentCard({
    required String studentId,
    required String schoolId,
    required String collectionName,
    required String studentName,
    required String classIn,
    required String stream,
    // required String gender,
    required String schoolIdDisplay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 0,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChildResults(
                  studentId: studentId,
                  schoolId: schoolId,
                  collectionName: collectionName,
                  snp: FirebaseFirestore.instance
                      .collection('Schools')
                      .doc(schoolId)
                      .collection('Years')
                      .doc(year)
                      .collection(collectionName)
                      .where(FieldPath.documentId, isEqualTo: studentId)
                      .snapshots(),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar Section
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mainColor, mainColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: mainColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.transparent,
                    child: Text(
                      _getInitials(studentName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.class_, size: 12, color: mainColor),
                                const SizedBox(width: 4),
                                Text(
                                  "$classIn $stream",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                               
                                const SizedBox(width: 4),
                              
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.school, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              schoolIdDisplay,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow Indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: mainColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 90,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: color),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pending_actions, size: 60, color: Colors.orange),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Column(
              children: [
                Text(
                  'Pending Approval',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Waiting for Admin to approve you.\nPlease contact the school.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper animation widgets
class SlideAnimation extends StatelessWidget {
  final Widget child;
  final double verticalOffset;

  const SlideAnimation({
    super.key,
    required this.child,
    this.verticalOffset = 50,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(begin: Offset(0, verticalOffset), end: Offset.zero),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, Offset offset, child) => Transform.translate(
        offset: offset,
        child: child,
      ),
      child: child,
    );
  }
}

class FadeInAnimation extends StatelessWidget {
  final Widget child;

  const FadeInAnimation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeIn,
      builder: (context, double opacity, child) => Opacity(
        opacity: opacity,
        child: child,
      ),
      child: child,
    );
  }
}