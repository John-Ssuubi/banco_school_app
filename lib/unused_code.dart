// // ignore_for_file: use_build_context_synchronously

// import 'package:banco_mobile/functions.dart';
// import 'package:banco_mobile/main.dart';
// import 'package:banco_mobile/parentFcmToken.dart';
// import 'package:banco_mobile/styles.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ParentForm extends StatefulWidget {
//   const ParentForm({super.key});

//   @override
//   State<ParentForm> createState() => _ParentFormState();
// }

// class _ParentFormState extends State<ParentForm> {
//   final _formKey = GlobalKey<FormState>();

//   List<Map<String, dynamic>> _studentList = [];
//   final List<String> _selectedChildrenIds = [];
//   String? _selectedSchoolId;
//   bool _isLoading = false;

//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _relationController = TextEditingController();
//   final _nationalityController = TextEditingController();
//   final _addressController = TextEditingController();

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _phoneController.dispose();
//     _relationController.dispose();
//     _nationalityController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   /* ----------------------------------------------------
//    CHECK IF STUDENT IS ALREADY LINKED TO ANY PARENT
//   ---------------------------------------------------- */
//   Future<bool> _studentAlreadyLinked(String studentId) async {
//     final usersSnap =
//         await FirebaseFirestore.instance.collection('Users').get();

//     for (final userDoc in usersSnap.docs) {
//       final List children = userDoc['linkedChildren'] ?? [];
//       final exists = children.any((c) => c['studentId'] == studentId);
//       if (exists) return true;
//     }
//     return false;
//   }

//   /* ----------------------------------------------------
//    SUBMIT
//   ---------------------------------------------------- */
//   Future<void> _handleSubmission() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedChildrenIds.isEmpty) return;

//     setState(() => _isLoading = true);

//     try {
//       final user = FirebaseAuth.instance.currentUser!;
//       final firestore = FirebaseFirestore.instance;

//       final userRef = firestore.collection('Users').doc(user.uid);
//       final userSnap = await userRef.get();
//       final List existingChildren = userSnap.data()?['linkedChildren'] ?? [];

//       List<Map<String, dynamic>> childrenToAdd = [];

//       for (final studentId in _selectedChildrenIds) {
//         final student =
//             _studentList.firstWhere((s) => s['id'] == studentId);

//         final alreadyLinked = existingChildren.any(
//           (c) => c['studentId'] == studentId,
//         );

//         if (alreadyLinked) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content:
//                   Text('${student['name']} is already linked to your account'),
//             ),
//           );
//           continue;
//         }

//         final linkedElsewhere = await _studentAlreadyLinked(studentId);
//         if (linkedElsewhere) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                   '${student['name']} is already linked to another parent'),
//             ),
//           );
//           continue;
//         }

//         childrenToAdd.add({
//           'schoolId': _selectedSchoolId,
//           'studentId': studentId,
//           'studentName': student['name'],
//         });
//       }

//       if (childrenToAdd.isEmpty) {
//         setState(() => _isLoading = false);
//         return;
//       }

//       await userRef.set({
//         'role': 'parent',
//         'firstName': _firstNameController.text.trim(),
//         'secondName': _lastNameController.text.trim(),
//         'relation': _relationController.text.trim(),
//         'address': _addressController.text.trim(),
//         'nationality': _nationalityController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'schoolId': _selectedSchoolId,
//         'approved': 'false',
//         'linkedChildren': FieldValue.arrayUnion(childrenToAdd),
//         'createdAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));

//       await addNotification(
//         user.uid,
//         _selectedSchoolId!,
//         'Parent Registration',
//         'New parent request for: ${childrenToAdd.map((e) => e['studentName']).join(', ')}',
//       );

//       await firestore.collection('Schools').doc(_selectedSchoolId).set({
//         'linkedParents.${user.uid}': {
//           'role': 'parent',
//           'firstName': _firstNameController.text.trim(),
//           'secondName': _lastNameController.text.trim(),
//           'phone': _phoneController.text.trim(),
//           'fcmToken': setupFcm(),
//         }
//       }, SetOptions(merge: true));

//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const MyApp()),
//         (_) => false,
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(e.toString())));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   /* ----------------------------------------------------
//    LOAD STUDENTS
//   ---------------------------------------------------- */
//   Future<void> _loadStudents(String schoolId) async {
//     setState(() => _isLoading = true);

//     final firestore = FirebaseFirestore.instance;
//     final classes = List.generate(7, (i) => 'studentModelP${i + 1}');
//     List<Map<String, dynamic>> students = [];

//     for (final col in classes) {
//       final snap = await firestore
//           .collection('Schools')
//           .doc(schoolId)
//           .collection(col)
//           .get();

//       for (final doc in snap.docs) {
//         students.add({
//           'id': doc.id,
//           'name': doc['studentName'],
//           'classIn': doc['classIn'],
//         });
//       }
//     }

//     setState(() {
//       _studentList = students;
//       _selectedChildrenIds.clear();
//       _isLoading = false;
//     });
//   }

//   /* ----------------------------------------------------
//    UI
//   ---------------------------------------------------- */
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Parent Registration')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     _field(_firstNameController, 'First Name'),
//                     _field(_lastNameController, 'Second Name'),
//                     _field(_phoneController, 'Phone'),
//                     _field(_relationController, 'Relationship'),
//                     _field(_addressController, 'Address'),
//                     _field(_nationalityController, 'Nationality'),
//                     const SizedBox(height: 20),
//                     _schoolDropdown(),
//                     if (_selectedSchoolId != null) _studentListWidget(),
//                     const SizedBox(height: 30),
//                     _submitButton(),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _field(TextEditingController c, String label) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: c,
//         validator: (v) => v!.isEmpty ? 'Required' : null,
//         decoration: customDecorationParentForm(labelText: label),
//       ),
//     );
//   }

//   Widget _schoolDropdown() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('Schools').snapshots(),
//       builder: (_, snap) {
//         if (!snap.hasData) return const LinearProgressIndicator();
//         return DropdownButtonFormField<String>(
//           decoration: customDecorationParentForm(labelText: 'Select School'),
//           items: snap.data!.docs
//               .map((d) => DropdownMenuItem(
//                     value: d.id,
//                     child: Text(d['school_name']),
//                   ))
//               .toList(),
//           onChanged: (v) {
//             _selectedSchoolId = v;
//             _loadStudents(v!);
//           },
//         );
//       },
//     );
//   }

//   Widget _studentListWidget() {
//     return ListView.builder(
//       shrinkWrap: true,
//       itemCount: _studentList.length,
//       itemBuilder: (_, i) {
//         final s = _studentList[i];
//         return CheckboxListTile(
//           title: Text(s['name']),
//           subtitle: Text('Class ${s['classIn']}'),
//           value: _selectedChildrenIds.contains(s['id']),
//           onChanged: (v) {
//             setState(() {
//               v!
//                   ? _selectedChildrenIds.add(s['id'])
//                   : _selectedChildrenIds.remove(s['id']);
//             });
//           },
//         );
//       },
//     );
//   }

//   Widget _submitButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: _handleSubmission,
//         child: const Text('Register & Link'),
//       ),
//     );
//   }
// }
