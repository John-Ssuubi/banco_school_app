import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerPage extends StatefulWidget {
  final String schoolId;
  const BarcodeScannerPage({super.key, required this.schoolId});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String? barcodeValue;
  bool _cameraGranted = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isGranted) {
      setState(() => _cameraGranted = true);
    } else {
      status = await Permission.camera.request();
      if (status.isGranted) {
        setState(() => _cameraGranted = true);
      } else if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  final today =
      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

  Future<void> _handleScannedId(String scannedId) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final cleanId = scannedId.trim().replaceAll('\n', '');

      if (kDebugMode) {
        print(widget.schoolId);
      }

      final schoolRef = FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId);

      /// 1️⃣ FAST LOOKUP (studentIndex)
      final indexSnap = await schoolRef
          .collection('studentIndex')
          .doc(cleanId)
          .get();

      if (!indexSnap.exists) {
        _showMessage("No student found for this ID.");
        return;
      }

      final indexData = indexSnap.data()!;
      final String classCollection = indexData['classCollection'];
      final String studentDocId = indexData['studentDocId'];

      if (kDebugMode) {
        print('Class Collection: $classCollection, Student Doc ID: $studentDocId');
      }

      /// 2️⃣ FETCH STUDENT (single read)
      final studentSnap = await schoolRef
          .collection(classCollection)
          .doc(studentDocId)
          .get();

      if (!studentSnap.exists) {
        _showMessage("Student record missing.");
        return;
      }

      final data = studentSnap.data()!;
      final studentName = data['studentName'] ?? 'Unknown';
      final classIn = data['classIn'] ?? '';
      final String parentFcmToken = (data['parentFcmToken'] ?? '').toString();
      final String parentUid = data['parentUid'] ?? '';

      final today = DateTime.now().toIso8601String().split('T').first;

      // final notificationRef = schoolRef
      //     .collection('notifications')
      //     .doc();

      // final notificationRef = FirebaseFirestore.instance
      //     .collection('Users')
      //     .doc(parentUid)
      //     .collection('inbox')
      //     .doc();

      final attendanceRef = schoolRef
          .collection('attendance')
          .doc(today)
          .collection('students')
          .doc(cleanId);

      /// 3️⃣ IDEMPOTENT ATTENDANCE WRITE (NO READ)
      await attendanceRef.set({
        'studentName': studentName,
        'idNin': cleanId,
        'classCollection': classCollection,
        'classIn': classIn,
        'timeIn': FieldValue.serverTimestamp(),
        'status': 'present',
        'schoolFrom': widget.schoolId,
        'parentFcmToken': parentFcmToken,
      }, SetOptions(merge: true));

      _showMessage("$studentName marked present.");

      /// 4️⃣ LOG NOTIFICATION (Cloud Function can listen here)
      if (parentUid.isNotEmpty) {
        final notificationRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(parentUid)
            .collection('inbox')
            .doc();

        await notificationRef.set({
          'title': 'Attendance',
          'body': '$studentName has arrived at school',
          'timestamp': FieldValue.serverTimestamp(),
          'studentId': cleanId,
          'studentName': studentName,
          'schoolFrom': widget.schoolId,
          'status': 'pending',
          'fcmToken': parentFcmToken,
          'type': 'Attendance',
        });
      } else {
        debugPrint('⚠️ parentUid missing for student $cleanId');
      }

      // if (parentFcmToken.isNotEmpty) {
      //   sendNotification(
      //     context: context,
      //     title: 'Attendance',
      //     body: '$studentName has arrived at school',
      //     token: parentFcmToken,
      //   );
      // }
    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Student ID")),
      body: _cameraGranted
          ? Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.first;
                    final String? scannedCode = barcode.rawValue;

                    if (scannedCode != null && !_isProcessing) {
                      setState(() => barcodeValue = scannedCode);
                      _handleScannedId(scannedCode);
                    }
                  },
                ),
                if (barcodeValue != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      color: Colors.black54,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Scanned Code: $barcodeValue",
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text("Camera permission is required to scan."),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _checkCameraPermission,
                    child: const Text("Grant Permission"),
                  ),
                ],
              ),
            ),
    );
  }
}
