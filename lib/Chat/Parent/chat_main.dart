// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/Chat/chat_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String schoolId;
  final String myRole;
  final String firstName;
  final String secondName;
  final String schoolName;

  const ChatScreen({
    super.key,
    required this.schoolName,
    required this.schoolId,
    required this.myRole,
    required this.firstName,
    required this.secondName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _controller = TextEditingController();

  String? chatId;
  bool isLoading = true;

  /// Reply state
  String? replyingTo;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final id = await getOrCreateChatId(
      schoolName: widget.schoolName,
      schoolId: widget.schoolId,
      parentId: userId,
      parentNameFirst: widget.firstName,
      parentNameSecond: widget.secondName,
    );

    if (mounted) {
      setState(() {
        chatId = id;
        isLoading = false;
      });
    }
  }

  /// SEND MESSAGE
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || chatId == null) return;

    final text = _controller.text.trim();
    _controller.clear();

    final chatRef =
        FirebaseFirestore.instance.collection('Chats').doc(chatId);

    await chatRef.collection('messages').add({
      'replyTo': '',
      'message': text,
      'senderId': userId,
      'senderRole': widget.myRole,
      'timestamp': FieldValue.serverTimestamp(),
      'deleted': false,
      'edited': false,
      if (replyingTo != '') 'replyTo': replyingTo,
    });

    await chatRef.update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    setState(() => replyingTo = null);
  }

  /// 🔐 PRO TIP: SOFT DELETE (audit-safe)
  Future<void> _deleteMessage(String msgId) async {
    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .doc(msgId)
        .update({
      'deleted': true,
      'message': 'This message was deleted',
    });
  }

  /// ✏ EDIT MESSAGE
  void _editMessage(String msgId, String oldMessage) {
    final editController = TextEditingController(text: oldMessage);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: editController,
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(chatId)
                  .collection('messages')
                  .doc(msgId)
                  .update({
                'message': editController.text.trim(),
                'edited': true,
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// 📎 MESSAGE OPTIONS (LONG PRESS)
  void _showMessageOptions({
    required String msgId,
    required String message,
    required bool isMe,
    required bool isDeleted,
  }) {
    if (isDeleted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: () {
              Navigator.pop(context);
              setState(() => replyingTo = message);
            },
          ),
          if (isMe) ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editMessage(msgId, message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(msgId);
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(
        children: [
          /// 🔁 REPLY PREVIEW
          if (replyingTo != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to: "$replyingTo"',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => replyingTo = null),
                  ),
                ],
              ),
            ),

          /// 💬 MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg['senderId'] == userId;
                    final bool isDeleted = msg['deleted'] ?? false;

                    return GestureDetector(
                      onLongPress: () => _showMessageOptions(
                        msgId: msg.id,
                        message: msg['message'],
                        isMe: isMe,
                        isDeleted: isDeleted,
                      ),
                      child: _ChatBubble(
                        message: msg['message'],
                        isMe: isMe,
                        time: msg['timestamp'],
                        edited: msg['edited'] ?? false,
                        replyTo: msg['replyTo'] ?? '',
                        deleted: isDeleted,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// ✍ INPUT BAR
          _inputBar(),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

/// 💬 CHAT BUBBLE
class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final Timestamp? time;
  final bool edited;
  final String replyTo;
  final bool deleted;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.time,
    required this.edited,
    required this.replyTo,
    required this.deleted,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime? dateTime = time?.toDate();
    final String formattedTime =
        dateTime != null ? DateFormat('HH:mm').format(dateTime) : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (replyTo != '')
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  replyTo,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontStyle: deleted ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              edited ? '$formattedTime • edited' : formattedTime,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
