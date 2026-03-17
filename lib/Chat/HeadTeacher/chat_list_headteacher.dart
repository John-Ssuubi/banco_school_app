// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:banco_mobile/Chat/HeadTeacher/chatmain_headteacher.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListHeadteacher extends StatefulWidget {
  final String schoolId;
  const ChatListHeadteacher({super.key, required this.schoolId});

  @override
  State<ChatListHeadteacher> createState() => _ChatListHeadteacherState();
}

class _ChatListHeadteacherState extends State<ChatListHeadteacher> {
  // final String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: InkWell(
          child: Icon(Icons.arrow_back_outlined, color: Colors.white),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
      ),
      // floatingActionButton: FloatingActionButton,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (_) => NewChatHeadteacher(
      //           // or 'school'
      //         ),
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.messenger_rounded),
      // ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Chats')
            .where('participants', arrayContains: widget.schoolId)
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

              final DateTime? dateTime = time?.toDate();
              final String formattedTime = dateTime != null
                  ? DateFormat('HH:mm').format(dateTime)
                  : '';

              /// 🔹 Determine other participant
              final List participants = List<String>.from(chat['participants']);
              final String otherUserId = participants.firstWhere(
                (id) => id != widget.schoolId,
              );

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users') // or Schools / Parents
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  // final otherName = userSnapshot.data?['name'] ?? 'Chat';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(
                          chat['parentNameFirst'] +
                              ' ' +
                              chat['parentNameSecond'],
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
                              builder: (_) => ChatmainHeadteacher(
                                schoolId: chat['schoolId'],
                                parentId: chat['parentId'],
                                myRole: 'school', // or 'school'
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
