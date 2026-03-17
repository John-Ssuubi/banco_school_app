import 'package:banco_mobile/Chat/Parent/chat_main.dart';
import 'package:banco_mobile/Chat/Parent/new_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewChat()),
          );
        },
        child: const Icon(Icons.messenger_rounded),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Chats')
            .where('participants', arrayContains: userId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }

          final chats = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;

              final String lastMessage = data['lastMessage'] ?? '';
              final Timestamp? time = data['lastMessageTime'];
              final String firstName = data['parentNameFirst'] ?? '';
              final String secondName = data['parentNameSecond'] ?? '';
              final String schoolId = data['schoolId'] ?? '';
              final String schoolName = data['schoolName'] ?? '';

              final DateTime? dateTime = time?.toDate();
              final String formattedTime = dateTime != null
                  ? DateFormat('HH:mm').format(dateTime)
                  : '';

              /// ✅ SAFE participants handling
              final List<String> participants =
                  List<String>.from(data['participants'] ?? []);

              final others =
                  participants.where((id) => id != userId).toList();

              if (others.isEmpty) {
                // broken chat doc → skip rendering
                return const SizedBox();
              }

              final String otherUserId = others.first;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      schoolName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formattedTime,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            schoolId: schoolId,
                            myRole: 'parent',
                            firstName: firstName,
                            secondName: secondName,
                            schoolName: schoolName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
