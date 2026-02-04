// ignore_for_file: use_build_context_synchronously

import 'package:banco_mobile/Auth/create_account_parent.dart';
import 'package:banco_mobile/Auth/staff_select.dart';
import 'package:banco_mobile/main.dart';
import 'package:banco_mobile/parentFcmToken.dart';
import 'package:banco_mobile/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthStudent extends StatefulWidget {
  const AuthStudent({super.key});

  @override
  State<AuthStudent> createState() => _AuthStudentState();
}

class _AuthStudentState extends State<AuthStudent> {
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String error = '';

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        title: Text("Banco Mobile"),
      ),
      body: ListView(children: [
        Column(
          //  mainAxisAlignment: MainAxisAlignment.,
          children: [Text('LogIn', style: TextStyle(color: mainColor, fontSize: largefonts, fontWeight: FontWeight.bold),)
          ,
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: TextField(
                controller: _emailController,
                decoration:  InputDecoration(labelText: 'Email',
                  labelStyle: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: normalFontSize), // label color
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: mainColor,
                    ), // border when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: mainColor,
                    ), // border when focused
                  ),
                ),
                 style: TextStyle(color: mainColor),
              ),
           ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                labelStyle: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: normalFontSize), 
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: mainColor,
                    ), // border when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: mainColor,
                    ), // border when focused
                  ),
                  labelText: 'Password', 
                  
                  ),
              ),
            ),
           ElevatedButton(onPressed: () async {
 try {
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        setupFcm();

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
        } catch (e) {
          setState(() {
            error = e.toString(); 
          });
        }
           }, child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Text('Log In', style: TextStyle(fontSize: normalFontSize),),
           )),
           SizedBox(height: 25,),
           InkWell(
            onTap: () {
              showTextCard(context);
              },
            child: Text('Don\'t have an account? Sign Up')),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.red)),
          ],
        )
      ],),
    );
  }
  Future<void> showTextCard(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: Text("Choose Service Provider", style: ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          backgroundColor: mainColor,
          content: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                     
                    ),
                    child: Icon(Icons.school, size: 80, color: Colors.white,),

                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAccountParent(),
                      ),
                    );
                  },
                ),
                const Text(
                  "Parent",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: mainColor,
                  
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.people, size: 80, color: Colors.white,),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StaffSelect(),
                      ),
                    );
                  },
                ),

                const Text(
                  "Staff",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}