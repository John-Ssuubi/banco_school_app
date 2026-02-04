import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Nottifications extends StatefulWidget {
  const Nottifications({super.key});

  @override
  State<Nottifications> createState() => _NottificationsState();
}

class _NottificationsState extends State<Nottifications> {

    var user = FirebaseAuth.instance.currentUser!.uid;





  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Users').doc(user).collection('notifications').snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } if (asyncSnapshot.hasError) {
            return Center(child: Text('Error loading notifications'));
          } if (!asyncSnapshot.hasData || asyncSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          } else {
            return ListView.builder(
            itemCount: asyncSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final notification = asyncSnapshot.data!.docs[index];
              final title = notification['title'] ?? 'No Title';
              final subTitle = notification['subTitle'] ?? 'No Subtitle';
              // final dateSent = notification['timeStamp'] ?? 'No Date';
              return Container(
                // margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
          
                    child: Icon(Icons.notifications, color: Colors.white),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  title: Text(title),
                  subtitle: Text('$subTitle. 40mins ago'),
                ),
              );
            },
          );
          }
        }
      ),
    );
  }
}
