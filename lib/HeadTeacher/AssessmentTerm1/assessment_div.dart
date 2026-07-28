
import 'package:banco_mobile/HeadTeacher/AssessmentTerm1/class_assessment.dart';
import 'package:banco_mobile/HeadTeacher/AssessmentTerm2/class_assessment_term2.dart';
import 'package:banco_mobile/HeadTeacher/AssessmentTerm3/class_assessment_term3.dart';
// import 'package:banco_mobile/P4/student_p4.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';

  String searchQuery = "";


class AssessmentDiv extends StatefulWidget {
  final String model;
  final String schoolId;

  const AssessmentDiv({
    super.key,
    required this.model,
    required this.schoolId,
  });

  @override
  State<AssessmentDiv> createState() => _AssessmentDivState();
}

class _AssessmentDivState extends State<AssessmentDiv> {
  String currentYear = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    // loadCurrentYear();
  }

  TextEditingController searchController = TextEditingController();

 
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            child: const Icon(Icons.arrow_back_outlined, color: Colors.white),
            onTap: () => Navigator.pop(context),
          ),
          backgroundColor: mainColor,
          title: isSearching
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    cursorColor: Colors.white,
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search student...",
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      
                      // CLEAR BUTTON
                      // suffixIcon: searchQuery.isNotEmpty
                      //     ? IconButton(
                      //         icon: const Icon(Icons.clear, color: Colors.white),
                      //         onPressed: () {
                      //           searchController.clear();
                      //           setState(() {
                      //             searchQuery = "";
                      //           });
                      //         },
                      //       )
                      //     : null,
                      border: InputBorder.none,
                    ),
      
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                )
              : Text('Class Assessment', style: whiteText),
      
          actions: [
            IconButton(
              icon: Icon(
                isSearching ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  searchController.clear();
                  searchQuery = "";
                });
              },
            ),
          ],
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Color.fromARGB(255, 151, 151, 151),
            indicatorWeight: 3,
            indicatorColor: Colors.amber,
            tabs: [
              Tab(icon: Icon(Icons.school), text: "Term 1"),
              Tab(icon: Icon(Icons.school), text: "Term 2"),
              Tab(icon: Icon(Icons.school), text: "Term 3"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ClassAssessment(model: widget.model, schoolId: widget.schoolId),
            ClassAssessmentTerm2(model: widget.model, schoolId: widget.schoolId),
            ClassAssessmentTerm3(model: widget.model, schoolId: widget.schoolId),
          ],
        ),
      ),
    );
  }


}
