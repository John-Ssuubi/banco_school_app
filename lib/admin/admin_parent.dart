import 'package:banco_mobile/HeadTeacher/staff_members.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminParent extends StatefulWidget {
  final List<LinkedParent> linkedParents;
  final String schoolId;
  const AdminParent({super.key, required this.linkedParents, required this.schoolId});

  @override
  State<AdminParent> createState() => _AdminParentState();
}

class _AdminParentState extends State<AdminParent> {
  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    
    appBar: AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      title: const Text("Linked Parents", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      backgroundColor: mainColor,
    ),

    body: widget.linkedParents.isEmpty
        ? const Center(
            child: Text(
              "No parents linked yet",
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: widget.linkedParents.length,
            itemBuilder: (context, index) {
              final parent = widget.linkedParents[index];
              return parentsTile(parent);
            },
          ),
  );
}


  Future<void> _deleteParent(LinkedParent parent) async {
    try {
      await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('LinkedParents')
          .doc(parent.parentUid)
          .delete();

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(parent.parentUid)
          .update({
            'approved': false,
            // 'role': "Unassigned",
          });

      if (!mounted) return;

      setState(() {
        widget.linkedParents.removeWhere(
          (p) => p.parentUid == parent.parentUid,
        );
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Parent removed")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error")));
    }
  }

  Future<void> _updateAccess(String uid, bool value) async {
    await FirebaseFirestore.instance.collection('Users').doc(uid).update({
      'accessResults': value,
    });

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
}
