import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getOrCreateChatId({
  required String schoolId,
  required String parentId,
  required String parentNameFirst,
  required String parentNameSecond,
  required String schoolName,
}) async {
  final chatsRef = FirebaseFirestore.instance.collection('Chats');

  // 🔍 Check if chat already exists
  final query = await chatsRef
      .where('schoolId', isEqualTo: schoolId)
      .where('parentId', isEqualTo: parentId)
      .limit(1)
      .get();

  if (query.docs.isNotEmpty) {
    // ✅ Reuse existing chat
    return query.docs.first.id;
  }

  // 🆕 Create new chat with AUTO ID
  final newChat = chatsRef.doc();

  await newChat.set({
    'schoolId': schoolId,
    'parentId': parentId,
    'parentNameFirst': parentNameFirst,
    'parentNameSecond': parentNameSecond,
    'schoolName': schoolName,
    'participants': [schoolId, parentId],
    'lastMessage': '',
    'lastMessageTime': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
  });

  return newChat.id;
}


Future<String> getOrCreateChatIdHeadTeacher({
  required String schoolId,
  required String parentId,
  // required String senderName
}) async {
  final chatsRef = FirebaseFirestore.instance.collection('Chats');

  // 🔍 Check if chat already exists
  final query = await chatsRef
      .where('schoolId', isEqualTo: schoolId)
      .where('parentId', isEqualTo: parentId)
      .limit(1)
      .get();

  if (query.docs.isNotEmpty) {
    // ✅ Reuse existing chat
    return query.docs.first.id;
  }

  // 🆕 Create new chat with AUTO ID
  final newChat = chatsRef.doc();

  await newChat.set({
    'schoolId': schoolId,
    'parentId': parentId,
    // 'senderName': senderName,
    'participants': [schoolId, parentId],
    'lastMessage': '',
    'lastMessageTime': FieldValue.serverTimestamp(),
    'createdAt': FieldValue.serverTimestamp(),
  });

  return newChat.id;
}
