import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AboutSchool extends StatefulWidget {
  final String schoolId;
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
    required this.schoolId,
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
    required this.staffMembers,
    required this.linkedParents,
  });

  @override
  State<AboutSchool> createState() => _AboutSchoolState();
}

class _AboutSchoolState extends State<AboutSchool> {
  /* ---------------- UPDATE ACCESS ---------------- */

  Future<void> _updateAccess(String uid, bool value) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .update({'accessResults': value});

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? "Results access granted" : "Results access locked",
        ),
      ),
    );
  }

  /* ---------------- CONFIRM DELETE ---------------- */

  Future<bool> _confirmDelete(String type) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: Text("Remove this $type?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /* ---------------- DELETE PARENT ---------------- */

    Future<void> _deleteParent(LinkedParent parent) async {
      try {
        // await FirebaseFirestore.instance
        //     .collection('Schools')
        //     .doc(widget.schoolId)
        //     .collection('LinkedParents')
        //     .doc(parent.parentUid)
        //     .delete();

            await FirebaseFirestore.instance
            .collection('Users').doc(parent.parentUid).update({
              'approved': false,
              // 'role': "Unassigned",
            });

        if (!mounted) return;

        setState(() {
          widget.linkedParents
              .removeWhere((p) => p.parentUid == parent.parentUid);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Parent removed")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error")),
        );
      }
    }

  /* ---------------- DELETE STAFF ---------------- */

  Future<void> _deleteStaff(StaffMember staff) async {
    try {
      // await FirebaseFirestore.instance
      //     .collection('Schools')
      //     .doc(widget.schoolId)
      //     .collection('StaffMembers')
      //     .doc(staff.uid) // must exist
      //     .delete();

          await FirebaseFirestore.instance
          .collection('Users').doc(staff.uid).update({
            'approved': false,
            // 'role': "Unassigned",
          });

      if (!mounted) return;

      setState(() {
        widget.staffMembers
            .removeWhere((s) => s.uid == staff.uid);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Staff removed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error removing staff")),
      );
    }
  }

  /* ---------------- PARENT OPTIONS ---------------- */

  void _showParentOptions(LinkedParent parent) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Parent Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.lock_open, color: Colors.green),
                title: const Text("Grant Results Access"),
                onTap: () async {
                  Navigator.pop(context);
                  await _updateAccess(parent.parentUid, true);
                },
              ),

              ListTile(
                leading: const Icon(Icons.lock, color: Colors.red),
                title: const Text("Lock Results"),
                onTap: () async {
                  Navigator.pop(context);
                  await _updateAccess(parent.parentUid, false);
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Remove Parent"),
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await _confirmDelete("parent");

                  if (ok) {
                    await _deleteParent(parent);
                  }
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ---------------- STAFF OPTIONS ---------------- */

  void _showStaffOptions(StaffMember staff) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Staff Options",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Remove Staff"),
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await _confirmDelete("staff");

                  if (ok) {
                    await _deleteStaff(staff);
                  }
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  /* ---------------- UI ---------------- */

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
              infoTile(Icons.school, "School Name", widget.schoolName),
              infoTile(Icons.location_on, "Address", widget.address),
              infoTile(Icons.markunread_mailbox, "P.O Box", widget.pobox),
              infoTile(Icons.flag, "Motto", widget.moto),
            ],
          ),

          _sectionTitle("Contact Information"),
          _infoCard(
            children: [
              infoTile(Icons.phone, "Contact", widget.contact),
              infoTile(Icons.email, "Email", widget.email),
            ],
          ),

          _sectionTitle("Staff Members"),
          _infoCard(
            children: widget.staffMembers.isEmpty
                ? const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("No staff members"),
                    ),
                  ]
                : widget.staffMembers.map(staffTile).toList(),
          ),

          _sectionTitle("Parents"),
          _infoCard(
            children: widget.linkedParents.isEmpty
                ? const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("No parents"),
                    ),
                  ]
                : widget.linkedParents.map(parentsTile).toList(),
          ),

          _sectionTitle("Grading System"),
          _infoCard(
            children: [
              gradeTile("D1", widget.d1Start, widget.d1End),
              gradeTile("D2", widget.d2Start, widget.d2End),
              gradeTile("C3", widget.c3Start, widget.c3End),
              gradeTile("C4", widget.c4Start, widget.c4End),
              gradeTile("C5", widget.c5Start, widget.c5End),
              gradeTile("C6", widget.c6Start, widget.c6End),
              gradeTile("P7", widget.p7Start, widget.p7End),
              gradeTile("P8", widget.p8Start, widget.p8End),
              gradeTile("F9", widget.f9Start, widget.f9End),
            ],
          ),

          _sectionTitle("System Status"),
          _infoCard(
            children: [
              infoTile(
                Icons.verified,
                "Subscription",
                widget.subscription,
                valueColor:
                    widget.subscription == "Paid" ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /* ---------------- COMPONENTS ---------------- */

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget staffTile(StaffMember staff) {
    return InkWell(
      onTap: () => _showStaffOptions(staff),
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      ),
    );
  }

  Widget parentsTile(LinkedParent parent) {
    return InkWell(
      onTap: () => _showParentOptions(parent),
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: mainColor,
            child: Text(
              parent.firstName.isNotEmpty ? parent.firstName[0] : "?",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            '${parent.firstName} ${parent.secondName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Phone: ${parent.phone.isEmpty ? 'N/A' : parent.phone}"),
              Text("Email: ${parent.email.isEmpty ? 'N/A' : parent.email}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget gradeTile(String grade, int start, int end) {
    return ListTile(
      leading: const Icon(Icons.bar_chart, color: Colors.blue),
      title: Text(grade,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: Text("$start - $end",
          style: const TextStyle(fontSize: 16)),
    );
  }
}
