import 'package:banco_mobile/Reports/comments.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../DataBase/P4/p4_student_model.dart';

class ReportCardPdfTermII {
  static Future<void> generate({
    required String moto,
    required String address,
    required contacts,
    required String pobox,
    required String email,
    required StudentModelP4 student,
    required String schoolName,
    required String term,
    required int year,
    required int d1Start,
    required int d2Start,
    required int c3Start,
    required int c4Start,
    required int c5Start,
    required int c6Start,
    required int p7Start,
    required int p8Start,
    required int f9Start,
    required int f9End,
  }) async {
    final pdf = pw.Document();

    // ─── PDF colours styles──
    const headerBlue = PdfColor.fromInt(0xFF295FA6);
    const lightBlue = PdfColor.fromInt(0xFFDDE8F5);
    const accentGold = PdfColor.fromInt(0xFFF0A500);
    const rowAlt = PdfColor.fromInt(0xFFF5F8FD);
    const borderColor = PdfColor.fromInt(0xFFB0C4DE);
    const textDark = PdfColor.fromInt(0xFF1A1A2E);
    final String currentYear = DateTime.now().year.toString();
    const headerBlue0 = PdfColor.fromInt(0xFF295FA6);
    const lightBlue0 = PdfColor.fromInt(0xFFDDE8F5);
    const accentGold0 = PdfColor.fromInt(0xFFF0A500);
    const borderColor0 = PdfColor.fromInt(0xFFB0C4DE);
    const textDark0 = PdfColor.fromInt(0xFF1A1A2E);

    


    pw.Widget sectionLabel(String text) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: lightBlue0,
        border: pw.Border(left: pw.BorderSide(color: accentGold0, width: 3)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 8.5,
          color: headerBlue0,
        ),
      ),
    );

    /// Table header cell
    pw.Widget th(String text) => pw.Padding(
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
    pw.Widget td(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7.5, color: textDark0),
      ),
    );

    /// Centre-aligned data cell
    pw.Widget tdCenter(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7.5, color: textDark0),
        textAlign: pw.TextAlign.center,
      ),
    );

    /// Grade cell – colour-coded by grade letter
    pw.Widget tdGrade(String label) {
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
            color: textDark0,
          ),
          textAlign: pw.TextAlign.center,
        ),
      );
    }

    pw.Widget signatureBlock(String role) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          role,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 8.5,
            color: headerBlue0,
          ),
        ),
        pw.SizedBox(height: 24),
        pw.Container(width: 140, height: 0.8, color: borderColor0),
        pw.SizedBox(height: 3),
        pw.Text(
          'Signature',
          style: const pw.TextStyle(fontSize: 7, color: borderColor0),
        ),
      ],
    );
 int gradeFor(double score) {
    // Handle zero or negative scores (missing data)
    if (score == -1) return 9;
  if (score <= p8Start) {
    return 8;
  }
  if (score <= p7Start) {
    return 7;
  }
  if (score <= c6Start) {
    return 6;
  }
  if (score <= c5Start) {
    return 5;
  }
  if (score <= c4Start) {
    return 4;
  }
  if (score <= c3Start) {
    return 3;
  }
  if (score <= d2Start) {
    return 2;
  }
  if (score <= d1Start) {
    return 1;
  }
  return 9;
  }

  /// Returns the letter label for a grade, e.g. 1 → "D1", 5 → "C5".
  String gradeLabel(int grade) {
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

   final allSubjects = student.subjectsScoreTerm2;

   final coreSubjects = allSubjects.length > 4
        ? allSubjects.sublist(0, 4)
        : allSubjects;

    bool hasMissingBOT = allSubjects.any((s) => s.scoreBOT == -1.0);
    bool hasMissingMID = allSubjects.any((s) => s.scoreMT == -1.0);
    allSubjects.any((s) => s.scoreEOT == -1.0);

    // ── 2. Total aggregates (sum of per-subject grades, core subjects only) ────
    int agg1 = 0; // BOT total aggregate
    int agg2 = 0; // MID total aggregate
    int agg3 = 0; // EOT total aggregate

    // Calculate BOT aggregate
    if (!hasMissingBOT) {
      for (final s in coreSubjects) {
        agg1 += gradeFor(s.scoreBOT);
      }
    }

    // Calculate MID aggregate
    if (!hasMissingMID) {
      for (final s in coreSubjects) {
        agg2 += gradeFor(s.scoreMT);
      }
    }

    // Calculate EOT aggregate (always calculate, even with missing EOT)
    for (final s in coreSubjects) {
      // If score is -1.0 (missing), treat as grade 9 (fail)
      double score = s.scoreEOT;
      if (score == -1.0) {
        score = 0.0; // This will map to grade 9
      }
      agg3 += gradeFor(score);
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

    bool hasF9 = coreSubjects.any((s) => gradeFor(s.scoreEOT) == 9);
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
final List<Map<String, dynamic>> subjectRows = allSubjects.map((s) {
      final botGrade = gradeFor(s.scoreBOT);
      final midGrade = gradeFor(s.scoreMT);
      final eotGrade = gradeFor(s.scoreEOT);
      final avgScore = (s.scoreBOT + s.scoreMT + s.scoreEOT) / 3;
      final avgGrade = gradeFor(avgScore);
      if (kDebugMode) {
        print(botGrade);
      }
      return {
        'subject': s.subjectName,
        'teacher': s.teacher,
        'scoreBOT': s.scoreBOT,
        'botGrade': botGrade,
        'botLabel': gradeLabel(botGrade),
        'scoreMT': s.scoreMT,
        'midGrade': midGrade,
        'midLabel': gradeLabel(midGrade),
        'scoreEOT': s.scoreEOT,
        'eotGrade': eotGrade,
        'eotLabel': gradeLabel(eotGrade),
        'avgGrade': avgGrade,
        'avgLabel': gradeLabel(avgGrade),
      };
    }).toList();
   
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        build: (pw.Context ctx) {
          pw.Widget infoRow(String label, String value) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '$label:  ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8.5,
                      color: headerBlue,
                    ),
                  ),
                  pw.TextSpan(
                    text: value,
                    style: const pw.TextStyle(fontSize: 8.5, color: textDark),
                  ),
                ],
              ),
            ),
          );
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── Header band ──────────────────────────────────────────────────
              pw.Container(
                decoration: const pw.BoxDecoration(
                  color: headerBlue,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      schoolName.toString().toUpperCase(),
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
                      moto.toString(),
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
                        color: accentGold,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: pw.Text(
                        'TERM I PROGRESS REPORT ${DateTime.now().year}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: textDark,
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
                  border: pw.Border.all(color: borderColor),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                  color: lightBlue,
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
                          infoRow(
                            'Student Name',
                            student.studentName.toString(),
                          ),
                          infoRow('Class', student.classIn.toString()),
                          infoRow('Stream', student.stream.toString()),
                          infoRow('Year', currentYear.toString()),
                        ],
                      ),
                    ),
                    pw.Container(
                      width: 70,
                      height: 70,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: headerBlue, width: 1.5),
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
                            color: borderColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ── BOT & MID table ──────────────────────────────────────────────
              sectionLabel('Beginning of Term (BOT) & Mid-Term (MID) Results'),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: borderColor, width: 0.6),
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
                    decoration: const pw.BoxDecoration(color: headerBlue),
                    children: [
                      th('SUBJECT'),
                      th('BOT'),
                      th('AGG'),
                      th('MID'),
                      th('AGG'),
                      th('TEACHER'),
                    ],
                  ),
                  // Data rows
                  ...List.generate(subjectRows.length, (i) {
                    final row = subjectRows[i];
                    final isAlt = i.isOdd;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isAlt ? rowAlt : PdfColors.white,
                      ),
                      children: [
                        td(row['subject'].toString()),
                        tdCenter(row['scoreBOT'].toStringAsFixed(0)),
                        tdGrade(row['botLabel'].toString()),
                        tdCenter(row['scoreMT'].toStringAsFixed(0)),
                        tdGrade(row['midLabel'].toString()),
                        td(row['teacher'].toString()),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 4),
              // BOT / MID totals bar
              pw.Container(
                color: lightBlue,
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
                        color: headerBlue,
                      ),
                    ),
                    pw.Text(
                      'Total Aggregate MID: $agg2',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        color: headerBlue,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // ── table─
              sectionLabel('End of Term (EOT) Results'),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: borderColor, width: 0.6),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3.5),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: headerBlue),
                    children: [
                      th('SUBJECT'),
                      th('MARKS'),
                      th('AGG'),
                      th('TEACHER'),
                    ],
                  ),
                  ...List.generate(subjectRows.length, (i) {
                    final row = subjectRows[i];
                    final isAlt = i.isOdd;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isAlt ? rowAlt : PdfColors.white,
                      ),
                      children: [
                        td(row['subject'].toString()),
                        tdCenter(row['scoreEOT'].toStringAsFixed(0)),
                        tdGrade(row['eotLabel'].toString()),
                        td(row['teacher'].toString()),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 4),
              // EOT totals + division bar
              pw.Container(
                decoration: const pw.BoxDecoration(color: headerBlue),
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
                        color: accentGold,
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(3),
                        ),
                      ),
                      child: pw.Text(
                        'DIVISION  $division',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: textDark,
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
                        border: pw.Border.all(color: borderColor),
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
                              color: headerBlue,
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
                        border: pw.Border.all(color: borderColor),
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
                              color: headerBlue,
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

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  signatureBlock('Class Teacher'),
                  signatureBlock('Head Teacher'),
                ],
              ),
            ],
          );
          
        },
      ),
    );
     await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
  );
  }
  
}
