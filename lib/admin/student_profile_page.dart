import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentProfilePage extends StatefulWidget {
  final String schoolId;
  final String year;
  final String classModel;
  final String studentId; // idNin / doc id

  const StudentProfilePage({
    super.key,
    required this.schoolId,
    required this.year,
    required this.classModel,
    required this.studentId,
  });

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  Map<String, dynamic>? studentData;
  Map<String, dynamic>? parentData;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadStudent();
  }

  // 🔹 Load Student + Parent
  Future<void> loadStudent() async {
    try {
      final schoolRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId);

      // Student
      final studentSnap = await schoolRef
          .collection('Years')
          .doc(widget.year)
          .collection(widget.classModel)
          .doc(widget.studentId)
          .get();

      if (!studentSnap.exists) return;

      final data = studentSnap.data()!;
      final parentUid = data['parentUid'];

      Map<String, dynamic>? parent;

      // Parent
      if (parentUid != null && parentUid.toString().isNotEmpty) {
        final parentSnap = await schoolRef
            .collection('linkedParents')
            .doc(parentUid)
            .get();

        if (parentSnap.exists) {
          parent = parentSnap.data();
        }
      }

      setState(() {
        studentData = data;
        parentData = parent;
        loading = false;
      });
    } catch (e) {
      debugPrint("Profile Error: $e");
      setState(() => loading = false);
    }
  }

  // 🔹 Row Builder
  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Student Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : studentData == null
          ? const Center(child: Text("Student not found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔹 Header
                  CircleAvatar(
                    radius: 55,
                    backgroundImage:
                        (studentData!['image'] != null &&
                            studentData!['image'] != "null")
                        ? NetworkImage(studentData!['image'])
                        : null,
                    child:
                        (studentData!['image'] == null ||
                            studentData!['image'] == "null")
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    studentData!['studentName'] ?? "",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Class: ${studentData!['classIn']}  |  Stream: ${studentData!['stream']}",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 25),

                  // 🔹 Bio Data
                  profileCard("Bio Data", [
                    infoRow("SID", studentData!['idNin'] ?? "Not given"),
                    infoRow(
                      "Birth Date",
                      studentData!['birthDate'] ?? "Not given",
                    ),
                    infoRow(
                      "Nationality",
                      studentData!['nationality'] ?? "Not given",
                    ),
                    infoRow("Address", studentData!['address'] ?? "Not given"),
                    infoRow(
                      "Contact",
                      studentData!['contactNumber'] ?? "Not given",
                    ),
                    infoRow("EMIS", studentData!['emis'] ?? "Not given"),
                  ]),

                  const SizedBox(height: 20),

                  // 🔹 Next Of Kin
                  profileCard("Next Of Kin", [
                    infoRow(
                      "Name",
                      studentData!['nextofKinName'] ?? "Not given",
                    ),
                    infoRow(
                      "Phone",
                      studentData!['nextofKincontactNumberWhatsApp'] ??
                          "Not given",
                    ),
                    infoRow(
                      "Email",
                      studentData!['nextofKinidEmail'] ?? "Not given",
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // 🔹 Linked Parent
                  profileCard(
                    "Linked Parent",
                    parentData == null
                        ? [const Text("No parent linked")]
                        : [
                            infoRow(
                              "Name",
                              "${parentData!['firstName']} ${parentData!['secondName']}",
                            ),
                            infoRow("Phone", parentData!['phone'] ?? ""),
                            infoRow("Email", parentData!['email'] ?? ""),
                            infoRow(
                              "Approved",
                              parentData!['approved'] == true ? "Yes" : "No",
                            ),
                          ],
                  ),
                ],
              ),
            ),
    );
  }

  // 🔹 Card Widget
  Widget profileCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}
