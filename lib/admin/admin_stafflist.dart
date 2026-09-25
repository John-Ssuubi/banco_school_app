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
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedRole = 'staff';
  bool _isAddingStaff = false;
  bool _isLoading = false;

  final List<String> _roles = ['staff', 'teacher', 'headteacher'];

  @override
  void initState() {
    super.initState();
    // Refresh the staff list when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshStaffList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Linked Staff Members", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshStaffList,
            tooltip: 'Refresh Staff List',
          ),
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: _showAddStaffDialog,
            tooltip: 'Add Staff Member',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : widget.staffMembers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No staff members linked yet",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tap the + button to add staff",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshStaffList,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.staffMembers.length,
                    itemBuilder: (context, index) {
                      final staffMember = widget.staffMembers[index];
                      return staffMemberTile(staffMember);
                    },
                  ),
                ),
    );
  }

  // Method to refresh staff list from Firebase
  Future<void> _refreshStaffList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot staffSnapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('LinkedStaff')
          .get();

      final List<StaffMember> fetchedStaff = [];

      for (var doc in staffSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        final staffMember = StaffMember(
          uid: doc.id, // Use the document ID as the UID
          firstName: data['firstName'] ?? '',
          secondName: data['secondName'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? 'staff',
        );
        
        fetchedStaff.add(staffMember);
      }

      // Update the staff list
      setState(() {
        widget.staffMembers.clear();
        widget.staffMembers.addAll(fetchedStaff);
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${fetchedStaff.length} staff members'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading staff: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddStaffDialog() {
    // Clear controllers
    _uidController.clear();
    _firstNameController.clear();
    _secondNameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _selectedRole = 'staff';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Staff Member"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Enter staff member details",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                
                // UID Field
                TextField(
                  controller: _uidController,
                  decoration: const InputDecoration(
                    labelText: "Staff UID *",
                    hintText: "Enter unique ID (e.g., S001429)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 12),
                
                // First Name
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: "First Name *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Second Name
                TextField(
                  controller: _secondNameController,
                  decoration: const InputDecoration(
                    labelText: "Second Name *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Phone
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                
                // Email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                
                // Role Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: "Role *",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.work),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isAddingStaff ? null : () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: _isAddingStaff ? null : _addStaffMember,
              child: _isAddingStaff
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Add Staff", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addStaffMember() async {
    // Validate inputs
    final uid = _uidController.text.trim();
    final firstName = _firstNameController.text.trim();
    final secondName = _secondNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (uid.isEmpty || firstName.isEmpty || secondName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields (*)")),
      );
      return;
    }

    setState(() {
      _isAddingStaff = true;
    });

    try {
      // Check if user already exists in Users collection
      final existingUser = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      if (existingUser.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("A user with this UID already exists")),
        );
        setState(() {
          _isAddingStaff = false;
        });
        return;
      }

      // Check if staff is already linked to this school
      final existingStaff = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('LinkedStaff')
          .doc(uid)
          .get();

      if (existingStaff.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Staff member already linked to this school")),
        );
        setState(() {
          _isAddingStaff = false;
        });
        return;
      }

      // Create user document in Users collection
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .set({
        'uid': uid,
        'firstName': firstName,
        'secondName': secondName,
        'phone': phone,
        'email': email,
        'role': _selectedRole,
        'approved': true,
        'schoolId': widget.schoolId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add to LinkedStaff collection
      await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('LinkedStaff')
          .doc(uid)
          .set({
        'firstName': firstName,
        'secondName': secondName,
        'phone': phone,
        'email': email,
        'role': _selectedRole,
        'teacherUid': uid,
        'linkedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Create staff member object and add to local list
      final staffMember = StaffMember(
        uid: uid,
        firstName: firstName,
        secondName: secondName,
        phone: phone,
        email: email,
        role: _selectedRole,
      );

      setState(() {
        widget.staffMembers.add(staffMember);
        _isAddingStaff = false;
        // Clear controllers
        _uidController.clear();
        _firstNameController.clear();
        _secondNameController.clear();
        _phoneController.clear();
        _emailController.clear();
      });

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Staff member added successfully")),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding staff member: ${e.toString()}")),
      );
      setState(() {
        _isAddingStaff = false;
      });
    }
  }

  Future<void> _deleteStaffMember(StaffMember staffMember) async {
    try {
      // Delete from LinkedStaff collection
      await FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('LinkedStaff')
          .doc(staffMember.uid)
          .delete();

      // Update user document
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(staffMember.uid)
          .update({
            'approved': false,
            'schoolId': FieldValue.delete(),
          });

      if (!mounted) return;

      setState(() {
        widget.staffMembers.removeWhere(
          (p) => p.uid == staffMember.uid,
        );
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Staff member removed successfully")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

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
              Text(
                '${staffMember.firstName} ${staffMember.secondName}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Role: ${staffMember.role.toUpperCase()}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
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
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getRoleColor(staffMember.role),
            child: Text(
              staffMember.firstName.isNotEmpty ? staffMember.firstName[0].toUpperCase() : "?",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            '${staffMember.firstName} ${staffMember.secondName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (staffMember.phone.isNotEmpty) 
                Text("Phone: ${staffMember.phone}"),
              if (staffMember.email != null) 
                Text("Email: ${staffMember.email}"),
              Text("UID: ${staffMember.uid}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          trailing: Chip(
            label: Text(
              staffMember.role.toUpperCase(),
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: _getRoleColor(staffMember.role),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'headteacher':
        return Colors.blue;
      case 'teacher':
        return Colors.green;
      case 'staff':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}