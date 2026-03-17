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
      // floatingActionButton: FloatingActionButton,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewChat(
                // or 'school'
              ),
            ),
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
          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return const Center(child: Text('No conversations yet'));
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];

              // final String chatId = chat.id;
              final String lastMessage = chat['lastMessage'] ?? '';
              final Timestamp? time = chat['lastMessageTime'];
              final String firstName = chat['parentNameFirst'] ?? '';
              final String secondName = chat['parentNameSecond'] ?? '';

              final DateTime? dateTime = time?.toDate();
              final String formattedTime = dateTime != null
                  ? DateFormat('HH:mm').format(dateTime)
                  : '';

              /// 🔹 Determine other participant
              final List participants = List<String>.from(chat['participants']);
              final String otherUserId = participants.firstWhere(
                (id) => id != userId,
              );

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users') // or Schools / Parents
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  // final otherName = userSnapshot.data?['name'] ?? 'Chat';

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      chat['schoolId'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                        // if (chat['unreadCount_parent'] > 0)
                        //   CircleAvatar(
                        //     radius: 10,
                        //     backgroundColor: Colors.red,
                        //     child: Text(
                        //       chat['unreadCount_parent'].toString(),
                        //       style: const TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 12,
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            schoolId: chat['schoolId'],

                            myRole: 'parent',
                            firstName: firstName,
                            secondName: secondName,
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
