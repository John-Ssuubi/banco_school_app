import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminStafflist extends StatefulWidget {
  final String schoolId;
   final List<StaffMember> staffMembers;


  const AdminStafflist({super.key, required this.staffMembers, required this.schoolId});

  @override
  State<AdminStafflist> createState() => _AdminStafflistState();
}

class _AdminStafflistState extends State<AdminStafflist> {
  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    
    appBar: AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      title: const Text("Linked Staff Members", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      backgroundColor: mainColor,
    ),

    body: widget.staffMembers.isEmpty
        ? const Center(
            child: Text(
              "No staff members linked yet",
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: widget.staffMembers.length,
            itemBuilder: (context, index) {
              final staffMember = widget.staffMembers[index];
              return staffMemberTile(staffMember);
            },
          ),
  );
}


  Future<void> _deleteStaffMember(StaffMember staffMember) async {
    try {
      await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('LinkedStaff')
          .doc(staffMember.uid)
          .delete();

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(staffMember.uid)
          .update({
            'approved': false,
            // 'role': "Unassigned",
          });

      if (!mounted) return;

      setState(() {
        widget.staffMembers.removeWhere(
          (p) => p.uid == staffMember.uid,
        );
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Staff member removed")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error")));
    }
  }

  // Future<void> _updateAccess(String uid, bool value) async {
  //   await FirebaseFirestore.instance.collection('Users').doc(uid).update({
  //     'accessResults': value,
  //   });

  //   if (!mounted) return;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         value ? "Results access granted" : "Results access locked",
  //       ),
  //     ),
  //   );
  // }

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

  void _showStaffMemberOptions(StaffMember staffMember) {
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

              // ListTile(
              //   leading: const Icon(Icons.lock_open, color: Colors.green),
              //   title: const Text("Grant Results Access"),
              //   onTap: () async {
              //     Navigator.pop(context);
              //     await _updateAccess(parent.parentUid, true);
              //   },
              // ),

              // ListTile(
              //   leading: const Icon(Icons.lock, color: Colors.red),
              //   title: const Text("Lock Results"),
              //   onTap: () async {
              //     Navigator.pop(context);
              //     await _updateAccess(parent.parentUid, false);
              //   },
              // ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Remove Staff Member"),
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await _confirmDelete("staff member");

                  if (ok) {
                    await _deleteStaffMember(staffMember);
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

  Widget staffMemberTile(StaffMember staffMember) {
    return InkWell(
      onTap: () => _showStaffMemberOptions(staffMember),
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: mainColor,
            child: Text(
              staffMember.firstName.isNotEmpty ? staffMember.firstName[0] : "?",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            '${staffMember.firstName} ${staffMember.secondName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Phone: ${staffMember.phone.isEmpty ? 'N/A' : staffMember.phone}"),
              // Text("Email: ${staffMember..isEmpty ? 'N/A' : staffMember.email}"),
            ],
          ),
        ),
      ),
    );
  }
}
