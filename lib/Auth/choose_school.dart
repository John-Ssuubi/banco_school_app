import 'package:banco_mobile/Auth/auth_student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:banco_mobile/styles.dart';

class ChooseSchoolScreen extends StatelessWidget {
  const ChooseSchoolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Select your school'),
        backgroundColor: mainColor,
      ),

      body:  Column(
  children: [
    const SizedBox(height: 20),

    

    Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Schools')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No schools found'));
          }

          final schools = snapshot.data!.docs;

          return ListView.builder(
            itemCount: schools.length,
            itemBuilder: (context, index) {
              final school = schools[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(
                    school.id,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AuthStudent()));
                  },
                ),
              );
            },
          );
        },
      ),
    ),

    // 👇 NEW TEXT
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Contact developer to register your school',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
    ),
  ],
),

    );
  }
}
