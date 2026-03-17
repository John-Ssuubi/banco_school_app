import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';

class AboutSchool extends StatelessWidget {
  final String schoolName;
  final String pobox;
  final String address;
  final String moto;
  final String contact;
  final String email;
  final String subscription;

  // Grading ranges
  final int d1Start, d1End;
  final int d2Start, d2End;
  final int c3Start, c3End;
  final int c4Start, c4End;
  final int c5Start, c5End;
  final int c6Start, c6End;
  final int p7Start, p7End;
  final int p8Start, p8End;
  final int f9Start, f9End;

  final List<StaffMember> staffMembers;
  final List<LinkedParent> linkedParents;


  const AboutSchool({
    super.key,
    required this.schoolName,
    required this.pobox,
    required this.address,
    required this.moto,
    required this.contact,
    required this.email,
    required this.subscription,
    required this.d1Start,
    required this.d1End,
    required this.d2Start,
    required this.d2End,
    required this.c3Start,
    required this.c3End,
    required this.c4Start,
    required this.c4End,
    required this.c5Start,
    required this.c5End,
    required this.c6Start,
    required this.c6End,
    required this.p7Start,
    required this.p7End,
    required this.p8Start,
    required this.p8End,
    required this.f9Start,
    required this.f9End,
    required this.staffMembers, required this.linkedParents,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          'About School',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionTitle("School Information"),
          _infoCard(
            children: [
              infoTile(Icons.school, "School Name", schoolName),
              infoTile(Icons.location_on, "Address", address),
              infoTile(Icons.markunread_mailbox, "P.O Box / Website", pobox),
              infoTile(Icons.flag, "Motto", moto),
            ],
          ),

          _sectionTitle("Contact Information"),
          _infoCard(
            children: [
              infoTile(Icons.phone, "Contact", contact),
              infoTile(Icons.email, "Email", email),
            ],
          ),

          _sectionTitle("Grading System"),
          _infoCard(
            children: [
              gradeTile("D1", d1Start, d1End),
              gradeTile("D2", d2Start, d2End),
              gradeTile("C3", c3Start, c3End),
              gradeTile("C4", c4Start, c4End),
              gradeTile("C5", c5Start, c5End),
              gradeTile("C6", c6Start, c6End),
              gradeTile("P7", p7Start, p7End),
              gradeTile("P8", p8Start, p8End),
              gradeTile("F9", f9Start, f9End),
            ],
          ),

          

           _sectionTitle("Staff Members"),
          _infoCard(
            children: staffMembers.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("No staff members available"),
                    )
                  ]
                : staffMembers.map(staffTile).toList(),
          ),

          // _sectionTitle("Parents"),
          // _infoCard(
          //   children: linkedParents.isEmpty
          //       ? [
          //           const Padding(
          //             padding: EdgeInsets.all(8),
          //             child: Text("No parents available"),
          //           )
          //         ]
          //       : linkedParents.map(parentsTile).toList(),
          // ),

          _sectionTitle("System Status"),
          _infoCard(
            children: [
              infoTile(
                Icons.verified,
                "Subscription",
                subscription,
                valueColor:
                    subscription == "Paid" ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- UI COMPONENTS ----------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }

  Widget infoTile(
    IconData icon,
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: mainColor),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        value.isEmpty ? "N/A" : value,
        style: TextStyle(color: valueColor, fontSize: 16),
      ),
    );
  }

  Widget gradeTile(String grade, int start, int end) {
    return ListTile(
      leading: const Icon(Icons.bar_chart, color: Colors.blue),
      title: Text(grade,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text(
        "$start - $end",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget staffTile(StaffMember staff) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: mainColor,
          child: Text(
            staff.firstName.isNotEmpty ? staff.firstName[0] : "?",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          "${staff.firstName} ${staff.secondName}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Role: ${staff.role}"),
            Text("Phone: ${staff.phone.isEmpty ? 'N/A' : staff.phone}"),
          ],
        ),
      ),
    );
  }
}


Widget parentsTile(LinkedParent parent) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: mainColor,
          child: Text(
            parent.parentName,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      
        
      ),
    );
  }
