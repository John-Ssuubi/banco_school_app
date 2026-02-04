import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectStudentParent extends StatefulWidget {
  const SelectStudentParent({super.key});

  @override
  State<SelectStudentParent> createState() => _SelectStudentParentState();
}

class _SelectStudentParentState extends State<SelectStudentParent> {
  var dummyListSchools =[ 'Banco Primary School', 'Ndejje View Nursery and Primary School Ndejje', 'Nippon Nursery and Primary School Ndejje' , 'St. Peters Nursery and Primary School Seguku'];
  bool isCHecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Banco Mobile"),),
      body: Column(children: [
        Text("Select your Children", style: TextStyle(fontSize: normalFontSize, fontWeight: FontWeight.bold),),
        Expanded(
          child: SizedBox(
            height: 500,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                    .collection('studentModelP4')
                    .snapshots(),
                    
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('No students found.'));
                  }

                  final students = snapshot.data!.docs
                      .map((doc) => StudentModelP4.fromJson(doc.data()))
                      .toList();
              // builder: (context, asyncSnapshot) {
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    var student = students[index]; 
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        
                        child: ListTile(
                          
                          leading: Icon(Icons.person),
                          title: Text(student.studentName.toString()),
                          trailing: Checkbox(value: isCHecked, onChanged: (i) {}),
                        ),
                      ),
                    );
                  },
                );
              }
            ),
          ),
        ),
        ElevatedButton(onPressed: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => ParentsChildProfile()));
           }, child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Text('Done', style: TextStyle(fontSize: normalFontSize),),
           )),
           SizedBox(height: 25,),
          
      ],),
    );
    
  }
}