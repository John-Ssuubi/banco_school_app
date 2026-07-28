// ignore_for_file: depend_on_referenced_packages, unused_local_variable, use_build_context_synchronously

import 'dart:io';
import 'dart:developer' as developer;

import 'package:banco_mobile/DataBase/P4/Term%20II/p4_database_term2.dart';
import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/Reports/comments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class BulkPrintP4Term2 extends StatefulWidget {
  final String schoolId;
  final String model;
  final int d1Start;
  final int d2Start;
  final int c3Start;
  final int c4Start;
  final int c5Start;
  final int c6Start;
  final int p7Start;
  final int p8Start;
  final int f9Start;
  final int f9End;
  final int d1End;
  final int d2End;
  final int c3End;
  final int c4End;
  final int c5End;
  final int c6End;
  final int p7End;
  final int p8End;

  const BulkPrintP4Term2({
    super.key,
    required this.schoolId,
    required this.model,
    required this.d1Start,
    required this.d2Start,
    required this.c3Start,
    required this.c4Start,
    required this.c5Start,
    required this.c6Start,
    required this.p7Start,
    required this.p8Start,
    required this.f9Start,
    required this.f9End,
    required this.d1End,
    required this.d2End,
    required this.c3End,
    required this.c4End,
    required this.c5End,
    required this.c6End,
    required this.p7End,
    required this.p8End,
  });

  @override
  State<BulkPrintP4Term2> createState() => _BulkPrintP4Term2T3State();
}

class _BulkPrintP4Term2T3State extends State<BulkPrintP4Term2> {
  final String currentYear = DateTime.now().year.toString();
  bool _isPrinting = false;

  int _gradeFor(double score) {
    // Handle zero or negative scores (missing data)
    if (score == -1) return 9;
  if (score <= widget.p8Start) {
    return 8;
  }
  if (score <= widget.p7Start) {
    return 7;
  }
  if (score <= widget.c6Start) {
    return 6;
  }
  if (score <= widget.c5Start) {
    return 5;
  }
  if (score <= widget.c4Start) {
    return 4;
  }
  if (score <= widget.c3Start) {
    return 3;
  }
  if (score <= widget.d2Start) {
    return 2;
  }
  if (score <= widget.d1Start) {
    return 1;
  }
  return 9;
  }

  /// Returns the letter label for a grade, e.g. 1 → "D1", 5 → "C5".
  String _gradeLabel(int grade) {
    const labels = {
      1: 'D1',
      2: 'D2',
      3: 'C3',
      4: 'C4',
      5: 'C5',
      6: 'C6',
      7: 'P7',
      8: 'P8',
      9: 'F9',
    };
    return labels[grade] ?? 'F9';
  }

  // ─── Firestore fetch ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _fetchData() async {
    final schoolDoc = await FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .get();

    final studentsSnap = await FirebaseFirestore.instance
        .collection('Schools')
        .doc(widget.schoolId)
        .collection('Years')
        .doc(currentYear)
        .collection(widget.model)
        .get();

    final List<StudentModelP4> students = studentsSnap.docs.map((doc) {
      final data = doc.data();

      List<P4SubjectsTerm2> parseSubjects(dynamic raw) {
        if (raw == null) return [];
        return (raw as List).map((e) {
          final m = e as Map<String, dynamic>;
          return P4SubjectsTerm2(
            subjectName: m['subjectName'] ?? '',
            teacher: m['teacher'] ?? '',
            scoreBOT: (m['scoreBOT'] as num?)?.toDouble() ?? 0.0,
            scoreMT: (m['scoreMT'] as num?)?.toDouble() ?? 0.0,
            scoreEOT: (m['scoreEOT'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
      }

      return StudentModelP4(
        studentName: data['studentName'] ?? '',
        classIn: data['classIn'] ?? '',
        stream: data['stream'] ?? '',
        contactNumber: data['contactNumber'] ?? '',
        idNin: data['idNin'] ?? '',
        id: null,
        extraSub: [],
        subjectsScore: [],
        subjectsScoreTerm2: parseSubjects(data['subjectsScoreTerm2']),
        subjectsScoreTerm3: [],
      );
    }).toList();

    return {'school': schoolDoc.data() ?? {}, 'students': students};
  }

  // ─── PDF colours & styles ─────────────────────────────────────────────────────
  static const _headerBlue = PdfColor.fromInt(0xFF295FA6);
  static const _lightBlue = PdfColor.fromInt(0xFFDDE8F5);
  static const _accentGold = PdfColor.fromInt(0xFFF0A500);
  static const _rowAlt = PdfColor.fromInt(0xFFF5F8FD);
  static const _borderColor = PdfColor.fromInt(0xFFB0C4DE);
  static const _textDark = PdfColor.fromInt(0xFF1A1A2E);

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: _isPrinting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.print_rounded),
      label: Text(_isPrinting ? 'Preparing...' : 'Print Term II'),
      onPressed: _isPrinting ? null : _onPrint,
    );
  }

  // ─── Print handler ────────────────────────────────────────────────────────────
  Future<void> _onPrint() async {
    if (kDebugMode) {
      print("Starting print process...");
    }

    if (kDebugMode) {
      print(widget.d1Start);
      print(widget.d2Start);
      print(widget.c3Start);
      print(widget.c4Start);
      print(widget.c5Start);
      print(widget.c6Start);
      print(widget.p7Start);
      print(widget.p8Start);
      print(widget.f9Start);
    }
    try {
      setState(() => _isPrinting = true);

      final fetched = await _fetchData();
      final schoolData = fetched['school'] as Map<String, dynamic>;
      final students = fetched['students'] as List<StudentModelP4>;

      if (students.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No students found')));
        }
        return;
      }

      final doc = pw.Document();

      for (final student in students) {
        _addStudentPage(doc, student, schoolData);
      }

      final Uint8List pdfBytes = await doc.save();

      try {
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: 'P4_Term_I_Reports.pdf',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF created successfully!')),
          );
        }
      } catch (e) {
        developer.log('Share failed: $e', name: 'Print');
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/P4_Term_I_Reports.pdf');
        await file.writeAsBytes(pdfBytes);
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('PDF Saved'),
              content: Text('Saved to: ${file.path}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      developer.log('Print error: $e', name: 'Print', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  // ─── Per-student page ─────────────────────────────────────────────────────────
  void _addStudentPage(
    pw.Document doc,
    StudentModelP4 student,
    Map<String, dynamic> schoolData,
  ) {
    // ── 1. Calculate per-subject grades ────────────────────────────────────────
    // Use only the first 4 subjects for aggregate/division (UCE rules)
    final allSubjects = student.subjectsScoreTerm2;
    final coreSubjects = allSubjects.length > 4
        ? allSubjects.sublist(0, 4)
        : allSubjects;

    bool hasMissingBOT = allSubjects.any((s) => s.scoreBOT == -1.0);
    bool hasMissingMID = allSubjects.any((s) => s.scoreMT == -1.0);
    bool hasMissingEOT = allSubjects.any((s) => s.scoreEOT == -1.0);

    // Per-subject grade objects (for the table rows)
    final List<Map<String, dynamic>> subjectRows = allSubjects.map((s) {
      final botGrade = _gradeFor(s.scoreBOT);
      final midGrade = _gradeFor(s.scoreMT);
      final eotGrade = _gradeFor(s.scoreEOT);
      final avgScore = (s.scoreBOT + s.scoreMT + s.scoreEOT) / 3;
      final avgGrade = _gradeFor(avgScore);
      if (kDebugMode) {
        print(botGrade);
      }
      return {
        'subject': s.subjectName,
        'teacher': s.teacher,
        'scoreBOT': s.scoreBOT,
        'botGrade': botGrade,
        'botLabel': _gradeLabel(botGrade),
        'scoreMT': s.scoreMT,
        'midGrade': midGrade,
        'midLabel': _gradeLabel(midGrade),
        'scoreEOT': s.scoreEOT,
        'eotGrade': eotGrade,
        'eotLabel': _gradeLabel(eotGrade),
        'avgGrade': avgGrade,
        'avgLabel': _gradeLabel(avgGrade),
      };
    }).toList();

    // ── 2. Total aggregates (sum of per-subject grades, core subjects only) ────
    // ── 2. Total aggregates (sum of per-subject grades, core subjects only) ────
    int agg1 = 0; // BOT total aggregate
    int agg2 = 0; // MID total aggregate
    int agg3 = 0; // EOT total aggregate

    // Calculate BOT aggregate
    if (!hasMissingBOT) {
      for (final s in coreSubjects) {
        agg1 += _gradeFor(s.scoreBOT);
      }
    }

    // Calculate MID aggregate
    if (!hasMissingMID) {
      for (final s in coreSubjects) {
        agg2 += _gradeFor(s.scoreMT);
      }
    }

    // Calculate EOT aggregate (always calculate, even with missing EOT)
    for (final s in coreSubjects) {
      // If score is -1.0 (missing), treat as grade 9 (fail)
      double score = s.scoreEOT;
      if (score == -1.0) {
        score = 0.0; // This will map to grade 9
      }
      agg3 += _gradeFor(score);
    }

    // ── 3. Division from EOT aggregate ─────────────────────────────────────────
    // ── 3. Division from EOT aggregate ─────────────────────────────────────────
    // Standard UCE grading system:
    // Division I:   Aggregate 4-12  (no grade 9)
    // Division II:  Aggregate 13-24 (no grade 9)
    // Division III: Aggregate 25-28 (no grade 9)
    // Division IV:  Aggregate 29-32 (no grade 9)
    // Division U:   Aggregate 33+ OR any subject with grade 9
    // Note: If any subject has grade 9, student automatically gets Division U

    bool hasF9 = coreSubjects.any((s) => _gradeFor(s.scoreEOT) == 9);
    String division = 'U';

    if (hasF9) {
      division = 'U';
    } else {
      // No grade 9s, determine division by aggregate
      if (agg3 >= 4 && agg3 <= 12) {
        division = 'I';
      } else if (agg3 >= 13 && agg3 <= 24) {
        division = 'II';
      } else if (agg3 >= 25 && agg3 <= 28) {
        division = 'III';
      } else if (agg3 >= 29 && agg3 <= 32) {
        division = 'IV';
      } else {
        division = 'U';
      }
    }

    // ── 4. Percent & comments (based on average EOT across all subjects) ────────
    double eotSum = 0;
    for (final s in allSubjects) {
      if (s.scoreEOT > 0) eotSum += s.scoreEOT;
    }
    double percent = allSubjects.isNotEmpty ? eotSum / allSubjects.length : 0;

    String comment = "More effort is needed";
    String hTComment = "A need for improvement is required";

    if (agg3 == 0) {
      comment =
          'You are advised to sit all the exams in order to attain a reasonable grade.';
      hTComment =
          'Please, always ensure that you are present at school during exams!';
    } else {
      // cascade from highest to lowest so the lowest matching wins
      if (percent <= 100) {
        comment = comment1;
        hTComment = hTComment1;
      }
      if (percent <= 98) {
        comment = comment2;
        hTComment = hTComment2;
      }
      if (percent <= 96) {
        comment = comment3;
        hTComment = hTComment3;
      }
      if (percent <= 94) {
        comment = comment4;
        hTComment = hTComment4;
      }
      if (percent <= 92) {
        comment = comment5;
        hTComment = hTComment5;
      }
      if (percent <= 90) {
        comment = comment6;
        hTComment = hTComment6;
      }
      if (percent <= 88) {
        comment = comment7;
        hTComment = hTComment7;
      }
      if (percent <= 86) {
        comment = comment8;
        hTComment = hTComment8;
      }
      if (percent <= 84) {
        comment = comment9;
        hTComment = hTComment9;
      }
      if (percent <= 78) {
        comment = comment12;
        hTComment = hTComment12;
      }
      if (percent <= 76) {
        comment = comment13;
        hTComment = hTComment13;
      }
      if (percent <= 74) {
        comment = comment14;
        hTComment = hTComment14;
      }
      if (percent <= 72) {
        comment = comment15;
        hTComment = hTComment15;
      }
      if (percent <= 70) {
        comment = comment16;
        hTComment = hTComment16;
      }
      if (percent <= 68) {
        comment = comment17;
        hTComment = hTComment17;
      }
      if (percent <= 66) {
        comment = comment18;
        hTComment = hTComment18;
      }
      if (percent <= 64) {
        comment = comment19;
        hTComment = hTComment19;
      }
      if (percent <= 62) {
        comment = comment20;
        hTComment = hTComment20;
      }
      if (percent <= 58) {
        comment = comment22;
        hTComment = hTComment22;
      }
      if (percent <= 56) {
        comment = comment23;
        hTComment = hTComment23;
      }
      if (percent <= 54) {
        comment = comment24;
        hTComment = hTComment24;
      }
      if (percent <= 52) {
        comment = comment25;
        hTComment = hTComment25;
      }
      if (percent <= 50) {
        comment = comment21;
        hTComment = hTComment21;
      }
      if (percent <= 48) {
        comment = comment27;
        hTComment = hTComment27;
      }
      if (percent <= 46) {
        comment = comment28;
        hTComment = hTComment28;
      }
      if (percent <= 44) {
        comment = comment29;
        hTComment = hTComment29;
      }
      if (percent <= 42) {
        comment = comment30;
        hTComment = hTComment30;
      }
      if (percent <= 40) {
        comment = comment31;
        hTComment = hTComment31;
      }
      if (percent <= 38) {
        comment = comment32;
        hTComment = hTComment32;
      }
      if (percent <= 36) {
        comment = comment33;
        hTComment = hTComment33;
      }
      if (percent <= 34) {
        comment = comment34;
        hTComment = hTComment34;
      }
      if (percent <= 32) {
        comment = comment35;
        hTComment = hTComment35;
      }
      if (percent <= 30) {
        comment = comment36;
        hTComment = hTComment36;
      }
      if (percent <= 28) {
        comment = comment37;
        hTComment = hTComment37;
      }
      if (percent <= 26) {
        comment = comment38;
        hTComment = hTComment38;
      }
      if (percent <= 24) {
        comment = comment39;
        hTComment = hTComment39;
      }
      if (percent <= 22) {
        comment = comment40;
        hTComment = hTComment40;
      }
      if (percent <= 20) {
        comment = comment41;
        hTComment = hTComment41;
      }
      if (percent <= 18) {
        comment = comment42;
        hTComment = hTComment42;
      }
      if (percent <= 16) {
        comment = comment43;
        hTComment = hTComment43;
      }
      if (percent <= 14) {
        comment = comment44;
        hTComment = hTComment44;
      }
      if (percent <= 12) {
        comment = comment45;
        hTComment = hTComment45;
      }
      if (percent <= 10) {
        comment = comment46;
        hTComment = hTComment46;
      }
      if (percent <= 8) {
        comment = comment47;
        hTComment = hTComment47;
      }
      if (percent <= 6) {
        comment = comment48;
        hTComment = hTComment48;
      }
      if (percent <= 4) {
        comment = comment49;
        hTComment = hTComment49;
      }
      if (percent <= 2) {
        comment = comment50;
        hTComment = hTComment50;
      }
    }

    // ── 5. Build the PDF page ───────────────────────────────────────────────────
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── Header band ──────────────────────────────────────────────────
              pw.Container(
                decoration: const pw.BoxDecoration(
                  color: _headerBlue,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      schoolData['school_name']?.toString().toUpperCase() ??
                          'SCHOOL NAME',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      schoolData['moto']?.toString() ?? '',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 3,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _accentGold,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Text(
                        'TERM II PROGRESS REPORT ${DateTime.now().year}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ── Student info card ────────────────────────────────────────────
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _borderColor),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                  color: _lightBlue,
                ),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            'Student Name',
                            student.studentName.toString(),
                          ),
                          _infoRow('Class', student.classIn.toString()),
                          _infoRow('Stream', student.stream.toString()),
                          _infoRow('Year', currentYear.toString()),
                        ],
                      ),
                    ),
                    pw.Container(
                      width: 70,
                      height: 70,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _headerBlue, width: 1.5),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                        color: PdfColors.white,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'PHOTO',
                          style: const pw.TextStyle(
                            fontSize: 7,
                            color: _borderColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ── BOT & MID table ──────────────────────────────────────────────
              _sectionLabel('Beginning of Term (BOT) & Mid-Term (MID) Results'),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: _borderColor, width: 0.6),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3.5),
                  1: const pw.FlexColumnWidth(1.5),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(2.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: _headerBlue),
                    children: [
                      _th('SUBJECT'),
                      _th('BOT'),
                      _th('AGG'),
                      _th('MID'),
                      _th('AGG'),
                      _th('TEACHER'),
                    ],
                  ),
                  // Data rows
                  ...List.generate(subjectRows.length, (i) {
                    final row = subjectRows[i];
                    final isAlt = i.isOdd;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isAlt ? _rowAlt : PdfColors.white,
                      ),
                      children: [
                        _td(row['subject'].toString()),
                        _tdCenter(row['scoreBOT'].toStringAsFixed(0)),
                        _tdGrade(row['botLabel'].toString()),
                        _tdCenter(row['scoreMT'].toStringAsFixed(0)),
                        _tdGrade(row['midLabel'].toString()),
                        _td(row['teacher'].toString()),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 4),
              // BOT / MID totals bar
              pw.Container(
                color: _lightBlue,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Aggregate BOT: $agg1',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        color: _headerBlue,
                      ),
                    ),
                    pw.Text(
                      'Total Aggregate MID: $agg2',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        color: _headerBlue,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ── EOT table ────────────────────────────────────────────────────
              _sectionLabel('End of Term (EOT) Results'),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: _borderColor, width: 0.6),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3.5),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: _headerBlue),
                    children: [
                      _th('SUBJECT'),
                      _th('MARKS'),
                      _th('AGG'),
                      _th('TEACHER'),
                    ],
                  ),
                  ...List.generate(subjectRows.length, (i) {
                    final row = subjectRows[i];
                    final isAlt = i.isOdd;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isAlt ? _rowAlt : PdfColors.white,
                      ),
                      children: [
                        _td(row['subject'].toString()),
                        _tdCenter(row['scoreEOT'].toStringAsFixed(0)),
                        _tdGrade(row['eotLabel'].toString()),
                        _td(row['teacher'].toString()),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 4),
              // EOT totals + division bar
              pw.Container(
                decoration: const pw.BoxDecoration(color: _headerBlue),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Aggregate (EOT): $agg3',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: pw.BoxDecoration(
                        color: _accentGold,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(3),
                        ),
                      ),
                      child: pw.Text(
                        'DIVISION  $division',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: _textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ── Comments section ─────────────────────────────────────────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _borderColor),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Class Teacher's Comment",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                              color: _headerBlue,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            comment,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _borderColor),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Head Teacher's Comment",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 8,
                              color: _headerBlue,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            hTComment,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // ── Signatures ───────────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _signatureBlock('Class Teacher'),
                  _signatureBlock('Head Teacher'),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Small layout helpers ─────────────────────────────────────────────────────

  pw.Widget _infoRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label:  ',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8.5,
              color: _headerBlue,
            ),
          ),
          pw.TextSpan(
            text: value,
            style: const pw.TextStyle(fontSize: 8.5, color: _textDark),
          ),
        ],
      ),
    ),
  );

  pw.Widget _sectionLabel(String text) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: pw.BoxDecoration(
      color: _lightBlue,
      border: pw.Border(left: pw.BorderSide(color: _accentGold, width: 3)),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 8.5,
        color: _headerBlue,
      ),
    ),
  );

  /// Table header cell
  pw.Widget _th(String text) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 7.5,
        color: PdfColors.white,
      ),
      textAlign: pw.TextAlign.center,
    ),
  );

  /// Normal data cell (left-aligned)
  pw.Widget _td(String text) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 7.5, color: _textDark),
    ),
  );

  /// Centre-aligned data cell
  pw.Widget _tdCenter(String text) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: pw.Text(
      text,
      style: const pw.TextStyle(fontSize: 7.5, color: _textDark),
      textAlign: pw.TextAlign.center,
    ),
  );

  /// Grade cell – colour-coded by grade letter
  pw.Widget _tdGrade(String label) {
    PdfColor bg;
    if (label.startsWith('D')) {
      bg = const PdfColor.fromInt(0xFFD4EDDA); // green tint
    } else if (label.startsWith('C')) {
      bg = const PdfColor.fromInt(0xFFFFF3CD); // amber tint
    } else if (label.startsWith('P')) {
      bg = const PdfColor.fromInt(0xFFFFE0B2); // orange tint
    } else {
      bg = const PdfColor.fromInt(0xFFFFCDD2); // red tint
    }

    return pw.Container(
      color: bg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: _textDark,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _signatureBlock(String role) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Text(
        role,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 8.5,
          color: _headerBlue,
        ),
      ),
      pw.SizedBox(height: 24),
      pw.Container(width: 140, height: 0.8, color: _borderColor),
      pw.SizedBox(height: 3),
      pw.Text(
        'Signature',
        style: const pw.TextStyle(fontSize: 7, color: _borderColor),
      ),
    ],
  );
}
