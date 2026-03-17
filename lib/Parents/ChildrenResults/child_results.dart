import 'package:banco_mobile/Parents/ChildrenResults/parent_child_results_term2.dart';
import 'package:banco_mobile/Parents/ChildrenResults/parent_child_results_term3.dart';
import 'package:banco_mobile/Parents/ChildrenResults/parents_child_profile.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChildResults extends StatefulWidget {
  final String studentId;
  final String schoolId;
  final String collectionName;
  Stream<QuerySnapshot<Map<String, dynamic>>> snp;

  ChildResults({
    super.key,
    required this.snp,
    required this.schoolId,
    required this.collectionName,
    required this.studentId,
  });

  @override
  State<ChildResults> createState() => _ChildResultsState();
}

class _ChildResultsState extends State<ChildResults> {
  int _currentIndex = 0;
  late List<Widget> _termPages;

  bool _loadingAccess = true;
  bool _canAccessResults = false;

  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    _checkAccess();
  }

  /* ---------------- CHECK ACCESS ---------------- */

  Future<void> _checkAccess() async {
    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_uid)
        .get();

    final data = doc.data();

    _canAccessResults = data?['accessResults'] ?? false;

    if (_canAccessResults) {
      _initPages();
    }

    if (mounted) {
      setState(() {
        _loadingAccess = false;
      });
    }
  }

  /* ---------------- INIT PAGES ---------------- */

  void _initPages() {
    _termPages = [
      ParentsChildProfileTerm1(snp: widget.snp, schoolId: widget.schoolId),

      ParentChildResultsTerm2(
        schoolId: widget.schoolId,
        snp: FirebaseFirestore.instance
            .collection('Schools')
            .doc(widget.schoolId)
            .collection('Years')
            .doc(DateTime.now().year.toString())
            .collection(widget.collectionName)
            .where(FieldPath.documentId,
                isEqualTo: widget.studentId)
            .snapshots(),
      ),

      ParentChildResultsTerm3(
        schoolId: widget.schoolId,  
        snp: FirebaseFirestore.instance
            .collection('Schools')
            .doc(widget.schoolId)
            .collection('Years')
            .doc(DateTime.now().year.toString())
            .collection(widget.collectionName)
            .where(FieldPath.documentId,
                isEqualTo: widget.studentId)
            .snapshots(),
      ),
    ];
  }

  /* ---------------- BLOCKED UI ---------------- */

  Widget _blockedUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 20),

            const Text(
              "Results Locked",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Your child’s results are temporarily unavailable due to school fees balance.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 15),

            const Text(
              "Please contact the school administration.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text("Contact School"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: InkWell(
          child:
              const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onTap: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          schoolname,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),

        elevation: 0,
        backgroundColor: mainColor,
      ),

      /* ---------------- BODY ---------------- */

      body: _loadingAccess
          ? const Center(child: CircularProgressIndicator())
          : _canAccessResults
              ? _termPages[_currentIndex]
              : _blockedUI(),

      /* ---------------- NAV BAR ---------------- */

      bottomNavigationBar: _canAccessResults
          ? BottomNavigationBar(
              backgroundColor: mainColor,
              unselectedItemColor:
                  const Color.fromARGB(255, 124, 124, 124),
              selectedItemColor: Colors.white,
              currentIndex: _currentIndex,

              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },

              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.school), label: 'Term I'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.school), label: 'Term II'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.school), label: 'Term III'),
              ],
            )
          : null,
    );
  }
}
