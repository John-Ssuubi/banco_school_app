// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SettingsTeacher extends StatefulWidget {
  const SettingsTeacher({super.key});

  @override
  State<SettingsTeacher> createState() => _SettingsTeacherState();
}

class _SettingsTeacherState extends State<SettingsTeacher> {
  List<ClassesModel> classesList = [];
  List<ClassesModel> selectedClasses = [];
  String? selectedSchoolId;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // ---------------- LOAD DATA ----------------

  @override
  void initState() {
    super.initState();
    loadTeacherData();
  }

  Future<void> loadTeacherData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    setState(() {
      _firstNameController.text = data['firstName'] ?? '';
      _secondNameController.text = data['secondName'] ?? '';
      _phoneController.text = data['phone'] ?? '';

      if (data['linkedClasses'] != null &&
          (data['linkedClasses'] as List).isNotEmpty) {
        selectedSchoolId = data['linkedClasses'][0]['schoolId'];
        selectedClasses = (data['linkedClasses'] as List)
            .map((c) => ClassesModel(
                  model: c['classModel'],
                  className: c['className'],
                ))
            .toList();

        loadClassesFromSchool(selectedSchoolId!);
      }
    });
  }

  // ---------------- CLASSES ----------------

  Future<void> loadClassesFromSchool(String schoolId) async {
    setState(() {
      classesList = [
        ClassesModel(model: 'studentModelP1', className: 'P1'),
        ClassesModel(model: 'studentModelP2', className: 'P2'),
        ClassesModel(model: 'studentModelP3', className: 'P3'),
        ClassesModel(model: 'studentModelP4', className: 'P4'),
        ClassesModel(model: 'studentModelP5', className: 'P5'),
        ClassesModel(model: 'studentModelP6', className: 'P6'),
        ClassesModel(model: 'studentModelP7', className: 'P7'),
      ];
    });
  }

  // ---------------- SAVE ----------------

  Future<void> saveTeacherSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final linkedClasses = selectedClasses.map((c) {
      return {
        "schoolId": selectedSchoolId,
        "classModel": c.model,
        "className": c.className,
      };
    }).toList();

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .set({
      'role': 'teacher',
      'firstName': _firstNameController.text.trim(),
      'secondName': _secondNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'linkedClasses': linkedClasses,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Settings saved successfully')),
    );
  }

  // ---------------- LOGOUT ----------------

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .update({
        'fcmToken': FieldValue.delete(),
        'lastLogout': FieldValue.serverTimestamp(),
      });
    }

    await FirebaseMessaging.instance.unsubscribeFromTopic("teachers");

    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget section(String title, Widget child) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: normalFontSize + 2,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
         leading: InkWell(
          child: Icon(Icons.arrow_back_outlined, color: Colors.white,),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Settings", style: TextStyle(color: Colors.white),)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PROFILE
            section(
              "Profile",
              Column(
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration:
                        customDecorationParentForm(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _secondNameController,
                    decoration:
                        customDecorationParentForm(labelText: 'Second Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration:
                        customDecorationParentForm(labelText: 'Phone Number'),
                  ),
                ],
              ),
            ),

            // SCHOOL & CLASSES
            section(
              "School & Classes",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Schools')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      return DropdownButtonFormField<String>(
                        value: selectedSchoolId,
                        decoration: const InputDecoration(
                          labelText: "School",
                          border: OutlineInputBorder(),
                        ),
                        items: snapshot.data!.docs.map((school) {
                          return DropdownMenuItem(
                            value: school.id,
                            child: Text(school['schoolId']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedSchoolId = val;
                              selectedClasses.clear();
                            });
                            loadClassesFromSchool(val);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  ...classesList.map((c) {
                    return CheckboxListTile(
                      title: Text(c.className),
                      value: selectedClasses.contains(c),
                      onChanged: (val) {
                        setState(() {
                          val == true
                              ? selectedClasses.add(c)
                              : selectedClasses.remove(c);
                        });
                      },
                    );
                  }),
                ],
              ),
            ),

            // ACCOUNT
            section(
              "Account",
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Reset Password"),
                    onTap: () {
                      FirebaseAuth.instance.sendPasswordResetEmail(
                        email: FirebaseAuth
                            .instance.currentUser!.email!,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Password reset email sent")),
                      );
                    },
                  ),
                  // const Divider(),
                  // ListTile(
                  //   leading:
                  //       const Icon(Icons.logout, color: Colors.red),
                  //   title: const Text(
                  //     "Logout",
                  //     style: TextStyle(color: Colors.red),
                  //   ),
                  //   onTap: () => logout(context),
                  // ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: saveTeacherSettings,
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- MODEL ----------------

class ClassesModel {
  final String model;
  final String className;

  ClassesModel({required this.model, required this.className});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassesModel &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => model.hashCode;
}
