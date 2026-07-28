// ignore_for_file: file_names, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:io';

import 'package:banco_mobile/DataBase/P4/Term%20I/p4_database.dart';
import 'package:banco_mobile/DataBase/P4/Term%20II/p4_database_term2.dart';
import 'package:banco_mobile/DataBase/P4/Term%20III/p4_database_term3.dart';
import 'package:banco_mobile/generate_unique_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';

class ExcelButtonP44Subs extends StatefulWidget {
  final String schoolId;
  final String model;

  const ExcelButtonP44Subs({
    super.key,
    required this.schoolId,
    required this.model,
  });

  @override
  State<ExcelButtonP44Subs> createState() => _ExcelButtonP44SubsT1State();
}

class _ExcelButtonP44SubsT1State extends State<ExcelButtonP44Subs> {
  final String currentYear = DateTime.now().year.toString();
  bool _isLoading = false;

  dynamic getCell(List<Data?> row, int index) {
    try {
      final val = row[index]?.value;
      if (val == null) return "";
      if (val == "x") return "-1";
      return val.toString();
    } catch (_) {
      return "";
    }
  }

  Future<void> showError(BuildContext context, String msg) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Message"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  CollectionReference<Map<String, dynamic>> _collectionRef() {
    return FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('Years')
        .doc(currentYear)
        .collection(widget.model);
  }

  List<Map<String, dynamic>> _term1ToMap(List<P4Subjects> list) => list
      .map((s) => {
            'subjectName': s.subjectName,
            'teacher': s.teacher,
            'scoreBOT': s.scoreBOT,
            'scoreMT': s.scoreMT,
            'scoreEOT': s.scoreEOT,
          })
      .toList();

  List<Map<String, dynamic>> _term2ToMap(List<P4SubjectsTerm2> list) => list
      .map((s) => {
            'subjectName': s.subjectName,
            'teacher': s.teacher,
            'scoreBOT': s.scoreBOT,
            'scoreMT': s.scoreMT,
            'scoreEOT': s.scoreEOT,
          })
      .toList();

  List<Map<String, dynamic>> _term3ToMap(List<P4SubjectsTerm3> list) => list
      .map((s) => {
            'subjectName': s.subjectName,
            'teacher': s.teacher,
            'scoreBOT': s.scoreBOT,
            'scoreMT': s.scoreMT,
            'scoreEOT': s.scoreEOT,
          })
      .toList();

  /// Pick file and return its bytes, works on all platforms
  Future<Uint8List?> _pickExcelBytes() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true, // load bytes in memory — avoids dart:io File entirely
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;

    // Prefer in-memory bytes (works on web + mobile)
    if (file.bytes != null) return file.bytes;

    // Desktop fallback: read from path using dart:io
    if (!kIsWeb && file.path != null) {
      return await File(file.path!).readAsBytes();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.download),
      label: Text(_isLoading ? "Importing..." : "Import Excel 4 Subjects"),
      onPressed: _isLoading
          ? null
          : () async {
              try {
                setState(() => _isLoading = true);

                // ── Pick & read file bytes ────────────────────────────────────
                final Uint8List? bytes = await _pickExcelBytes();
                if (bytes == null) {
                  showError(context, "No file selected or could not read file");
                  return;
                }

                // ── Decode excel ─────────────────────────────────────────────
                final excel = Excel.decodeBytes(bytes);

                // ── Pre-fetch all existing students from Firebase (one read) ──
                final collectionRef = _collectionRef();
                final existingSnap = await collectionRef.get();

                final Map<String, String> existingNames = {
                  for (final doc in existingSnap.docs)
                    if (doc.data().containsKey('studentName'))
                      doc['studentName'] as String: doc.id,
                };

                final Set<String> usedIds =
                    existingSnap.docs.map((d) => d.id).toSet();

                // ── Batch setup ───────────────────────────────────────────────
                WriteBatch batch = FirebaseFirestore.instance.batch();
                int batchCount = 0;
                const int maxBatchSize = 499;

                Future<void> commitBatch() async {
                  if (batchCount > 0) {
                    await batch.commit();
                    batch = FirebaseFirestore.instance.batch();
                    batchCount = 0;
                  }
                }

                for (var table in excel.tables.keys) {
                  final sheet = excel.tables[table];
                  if (sheet == null) continue;

                  for (var row in sheet.rows) {
                    try {
                      // ── READ STUDENT NAME FIRST (unchanged) ───────────────
                      final studentName = getCell(row, 0);
                      if (studentName.trim().isEmpty) continue;

                      // ── TERM 1 (unchanged) ────────────────────────────────
                      List<P4Subjects> term1 = [
                        P4Subjects(
                          subjectName: getCell(row, 1),
                          teacher: getCell(row, 2),
                          scoreBOT: double.parse(getCell(row, 3)),
                          scoreMT: double.parse(getCell(row, 4)),
                          scoreEOT: double.parse(getCell(row, 5)),
                        ),
                        P4Subjects(
                          subjectName: getCell(row, 6),
                          teacher: getCell(row, 7),
                          scoreBOT: double.parse(getCell(row, 8)),
                          scoreMT: double.parse(getCell(row, 9)),
                          scoreEOT: double.parse(getCell(row, 10)),
                        ),
                        P4Subjects(
                          subjectName: getCell(row, 11),
                          teacher: getCell(row, 12),
                          scoreBOT: double.parse(getCell(row, 13)),
                          scoreMT: double.parse(getCell(row, 14)),
                          scoreEOT: double.parse(getCell(row, 15)),
                        ),
                        P4Subjects(
                          subjectName: getCell(row, 16),
                          teacher: getCell(row, 17),
                          scoreBOT: double.parse(getCell(row, 18)),
                          scoreMT: double.parse(getCell(row, 19)),
                          scoreEOT: double.parse(getCell(row, 20)),
                        ),
                      ];

                      // ── TERM 2 (unchanged) ────────────────────────────────
                      List<P4SubjectsTerm2> term2 = [
                        P4SubjectsTerm2(
                          subjectName: getCell(row, 22),
                          teacher: getCell(row, 23),
                          scoreBOT: double.parse(getCell(row, 24)),
                          scoreMT: double.parse(getCell(row, 25)),
                          scoreEOT: double.parse(getCell(row, 26)),
                        ),
                        P4SubjectsTerm2(
                          subjectName: getCell(row, 27),
                          teacher: getCell(row, 28),
                          scoreBOT: double.parse(getCell(row, 29)),
                          scoreMT: double.parse(getCell(row, 30)),
                          scoreEOT: double.parse(getCell(row, 31)),
                        ),
                        P4SubjectsTerm2(
                          subjectName: getCell(row, 32),
                          teacher: getCell(row, 33),
                          scoreBOT: double.parse(getCell(row, 34)),
                          scoreMT: double.parse(getCell(row, 35)),
                          scoreEOT: double.parse(getCell(row, 36)),
                        ),
                        P4SubjectsTerm2(
                          subjectName: getCell(row, 37),
                          teacher: getCell(row, 38),
                          scoreBOT: double.parse(getCell(row, 39)),
                          scoreMT: double.parse(getCell(row, 40)),
                          scoreEOT: double.parse(getCell(row, 41)),
                        ),
                      ];

                      // ── TERM 3 (unchanged) ────────────────────────────────
                      List<P4SubjectsTerm3> term3 = [
                        P4SubjectsTerm3(
                          subjectName: getCell(row, 44),
                          teacher: getCell(row, 45),
                          scoreBOT: double.parse(getCell(row, 46)),
                          scoreMT: double.parse(getCell(row, 47)),
                          scoreEOT: double.parse(getCell(row, 48)),
                        ),
                        P4SubjectsTerm3(
                          subjectName: getCell(row, 49),
                          teacher: getCell(row, 50),
                          scoreBOT: double.parse(getCell(row, 51)),
                          scoreMT: double.parse(getCell(row, 52)),
                          scoreEOT: double.parse(getCell(row, 53)),
                        ),
                        P4SubjectsTerm3(
                          subjectName: getCell(row, 54),
                          teacher: getCell(row, 55),
                          scoreBOT: double.parse(getCell(row, 56)),
                          scoreMT: double.parse(getCell(row, 57)),
                          scoreEOT: double.parse(getCell(row, 58)),
                        ),
                        P4SubjectsTerm3(
                          subjectName: getCell(row, 59),
                          teacher: getCell(row, 60),
                          scoreBOT: double.parse(getCell(row, 61)),
                          scoreMT: double.parse(getCell(row, 62)),
                          scoreEOT: double.parse(getCell(row, 63)),
                        ),
                      ];

                      final now = DateTime.now().toIso8601String();

                      if (existingNames.containsKey(studentName)) {
                        // EXISTS → update scores only
                        final docId = existingNames[studentName]!;
                        batch.update(
                          collectionRef.doc(docId),
                          {
                            'subjectsScore': _term1ToMap(term1),
                            'subjectsScoreTerm2': _term2ToMap(term2),
                            'subjectsScoreTerm3': _term3ToMap(term3),
                            'lastUpdated': now,
                          },
                        );
                      } else {
                        // NEW → create full document
                        final idNin =
                            generateUniqueStudentId(widget.model, usedIds);
                        usedIds.add(idNin);
                        existingNames[studentName] = idNin;

                        batch.set(
                          collectionRef.doc(idNin),
                          {
                            'studentName': studentName,
                            'classIn': widget.model,
                            'stream': 'A',
                            'contactNumber': 'Not Given',
                            'birthDate': 'Not given',
                            'address': 'Not given',
                            'nationality': 'Not given',
                            'emis': 'Not given',
                            'nextofKinName': 'Not given',
                            'nextofKincontactNumberWhatsApp': 'Not given',
                            'nextofKinidEmail': 'Not given',
                            'nextofKinid': 'Not given',
                            'idNin': idNin,
                            'id': null,
                            'image': 'Not given',
                            'parentFcmToken': '',
                            'parentUid': '',
                            'termAdmin': 'Not given',
                            'yearAdmin': 'Not given',
                            'amountTerm1': 0.0,
                            'amountTerm2': null,
                            'amountTerm3': null,
                            'amountOwedTerm1': 0.0,
                            'amountOwedTerm2': null,
                            'amountOwedTerm3': null,
                            'paymentList': [],
                            'extraSub': [],
                            'lastUpdated': now,
                            'subjectsScore': _term1ToMap(term1),
                            'subjectsScoreTerm2': _term2ToMap(term2),
                            'subjectsScoreTerm3': _term3ToMap(term3),
                          },
                        );
                      }

                      batchCount++;
                      if (batchCount >= maxBatchSize) await commitBatch();
                    } catch (e) {
                      showError(
                        context,
                        "Error reading row: ${e.toString().substring(0, 40)}",
                      );
                    }
                  }
                }

                await commitBatch();
                showError(context, "Import completed successfully!");
              } catch (e) {
                showError(context, "Something went wrong: ${e.toString()}");
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
    );
  }
}