import 'package:banco_mobile/Notifications/firebase_notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

        final possibleCollections = [
          'studentModelP1',
          'studentModelP2',
          'studentModelP3',
          'studentModelP4',
          'studentModelP5',
          'studentModelP6',
          'studentModelP7',
        ];

        DocumentSnapshot? foundStudent;
        String? foundCollection;

        /// 🔍 Search student in all classes
        for (final collectionName in possibleCollections) {
          final query = await FirebaseFirestore.instance
              .collection('Schools')
              .doc(widget.schoolId)
              .collection(collectionName)
              .where('idNin', isEqualTo: cleanId)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            foundStudent = query.docs.first;
            foundCollection = collectionName;
            break;
          }
        }

        if (foundStudent == null) {
          _showMessage("No student found for this ID.");
          return;
        }

        /// ✅ SAFE DATA ACCESS
        final data = foundStudent.data() as Map<String, dynamic>;

        final studentName = data['studentName'] ?? 'Unknown';
        final classIn = data['classIn'] ?? '';
        final String parentFcmToken =
            (data['parentFcmToken'] ?? '').toString();

      
        final attendanceRef = FirebaseFirestore.instance
            .collection('Schools')
            .doc(widget.schoolId)
            .collection('attendance')
            .doc(today)
            .collection('students')
            .doc(foundStudent.id);

            final notificationRef = FirebaseFirestore.instance
            .collection('Schools').doc(widget.schoolId).collection('notifications').doc();

        final attendanceSnap = await attendanceRef.get();

        if (attendanceSnap.exists) {
          _showMessage("$studentName is already marked present today.");
          return;
        }

        /// 💾 Save attendance
        await attendanceRef.set({
          'studentName': studentName,
          'idNin': cleanId,
          'classCollection': foundCollection,
          'classIn': classIn,
          'timeIn': DateTime.now(),
          'status': 'present',
          'parentFcmToken': parentFcmToken,
        });

        _showMessage("$studentName marked present.");

      /// 📝 Log notification in Firestore
        await notificationRef.set({
          'title': 'Attendance',
          'message': '$studentName has arrived at school',
          'timestamp': DateTime.now(),
          'studentId': foundStudent.id,
          'studentName': studentName,
        });

      /// 🔔 Send notification ONLY if token exists
      if (parentFcmToken.isNotEmpty) {
        sendNotification(
          // ignore: use_build_context_synchronously
          context: context,
          title: 'Attendance',
          body: '$studentName has arrived at school',
          token: parentFcmToken,
        );
      } else {
        _showMessage("Attendance saved (no parent notification).");
      }
    } catch (e) {
      _showMessage("Error: $e");
    } finally {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      });
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
                        style:
                            const TextStyle(color: Colors.white),
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
                  const Icon(Icons.camera_alt_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                      "Camera permission is required to scan."),
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
