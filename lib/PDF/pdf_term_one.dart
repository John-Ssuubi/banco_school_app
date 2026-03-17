import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../DataBase/P4/p4_student_model.dart';
import '../division_cal.dart';

class ReportCardPdf {
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
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ---------- HEADER ----------
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      schoolName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      "REPORT CARD",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Divider(thickness: 1.5),

              // ---------- STUDENT INFO ----------
              pw.SizedBox(height: 10),
              _infoRow("NAME", student.studentName ?? ""),
              _infoRow("CLASS", student.classIn ?? ""),
              _infoRow("YEAR", year.toString()),
              _infoRow("TERM", term),
              _infoRow("SID", student.idNin ?? ""),

              pw.SizedBox(height: 16),

              // ---------- RESULTS TABLE ----------
              pw.Text(
                "SUBJECT RESULTS",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  _tableHeader(),
                  ...student.subjectsScore.map(
                    (s) => pw.TableRow(
                      children: [
                        _cell(s.subjectName),
                        _cell("${s.scoreEOT}"),
                        _cell(divEND(s.scoreEOT)),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // ---------- AGGREGATE ----------
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    "AGGREGATE: ",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    gradeEot(student.subjectsScore),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // ---------- FOOTER ----------
              pw.Divider(),
              pw.Text(
                "This report card is invalid without a school stamp",
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                "$address | $pobox | $email",
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  "IN GOD WE TRUST",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
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

  // ---------- HELPERS ----------
  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              "$label:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.TableRow _tableHeader() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      children: [
        _cell("SUBJECT", bold: true),
        _cell("MARKS", bold: true),
        _cell("GRADE", bold: true),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 10,
        ),
      ),
    );
  }
}
