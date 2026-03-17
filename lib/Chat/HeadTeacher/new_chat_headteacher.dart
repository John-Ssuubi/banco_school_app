// ignore_for_file: avoid_unnecessary_containers

import 'package:banco_mobile/Chat/HeadTeacher/chatmain_headteacher.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewChatHeadteacher extends StatefulWidget {
  const NewChatHeadteacher({super.key});

  @override
  State<NewChatHeadteacher> createState() => _NewChatHeadteacherState();
}

class _NewChatHeadteacherState extends State<NewChatHeadteacher> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
         leading: InkWell(
          child: Icon(Icons.arrow_back_outlined, color: Colors.white,),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: mainColor,
        title: const Text('New Chat', style: TextStyle(color: Colors.white),)),
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
              return  Center(child: Text('Something went wrong',style: whiteText,));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return  Center(child: Text('User not found', style: whiteText,));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            final List linkedChildren = data['linkedChildren'] ?? [];

            if (linkedChildren.isEmpty) {
              return Center(child: Text('No linked children', style: whiteText,));
            }

            return ListView.builder(
              itemCount: linkedChildren.length,
              itemBuilder: (context, index) {
                final child = linkedChildren[index];

                final String childName = child['studentName'] ?? 'Child';
                final String schoolId = child['schoolId'];

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white
                  ),
                  child: ListTile(
                    title: Text(childName),
                    subtitle: Text(child['schoolId']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatmainHeadteacher(
                            schoolId: schoolId,
                            myRole: 'parent',
                            parentId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
