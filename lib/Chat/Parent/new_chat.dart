import 'package:banco_mobile/Chat/Parent/chat_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewChat extends StatefulWidget {
  const NewChat({super.key});

  @override
  State<NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<NewChat> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      // ignore: avoid_unnecessary_containers
      body: Container(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User not found'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final List linkedChildren = data['linkedChildren'] ?? [];

            if (linkedChildren.isEmpty) {
              return const Center(child: Text('No linked children'));
            }

            return ListView.builder(
              itemCount: linkedChildren.length,
              itemBuilder: (context, index) {
                final child = linkedChildren[index];

                final String childName = child['studentName'] ?? 'Child';
                final String schoolId = child['schoolId'];
                final String parentFirstName = data['firstName'] ?? '';
                final String parentSecondName = data['secondName'] ?? '';

                return ListTile(
                  title: Text(childName),
                  subtitle: Text(child['schoolId']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          schoolId: schoolId,
                          myRole: 'parent',
                          firstName: parentFirstName,
                          secondName: parentSecondName,
                          // parentId: userId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
