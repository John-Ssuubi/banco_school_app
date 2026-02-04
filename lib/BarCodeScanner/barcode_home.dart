import 'package:banco_mobile/BarCodeScanner/barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BarcodeHome extends StatefulWidget {
  const BarcodeHome({super.key});

  @override
  State<BarcodeHome> createState() => _BarcodeHomeState();
}

class _BarcodeHomeState extends State<BarcodeHome> {
  String? schoolId;
  List<Map<String, dynamic>> linkedClasses = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        final classes = List<Map<String, dynamic>>.from(data['linkedClasses'] ?? []);
        setState(() {
          linkedClasses = classes;
          // pick the first school's ID
          if (classes.isNotEmpty) {
            schoolId = classes.first['schoolId'];
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bar Code')),
      body: schoolId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('School: $schoolId'),
                const SizedBox(height: 16),
                Text('Classes linked:'),
                for (var cls in linkedClasses)
                  ListTile(
                    title: Text(cls['className']),
                    subtitle: Text(cls['classModel']),
                  ),
                const SizedBox(height: 24),
                
              ],
              
            ),floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  BarcodeScannerPage(schoolId: schoolId!),
                      ),
                    );
                  },
                  child: const Icon(Icons.arrow_forward_sharp),
                ),
    );
  }
}
