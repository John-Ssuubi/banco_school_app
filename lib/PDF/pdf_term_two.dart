import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../DataBase/P4/p4_student_model.dart';
import '../division_cal.dart';

class ReportCardPdfTermII {static Future<void> generate({
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

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            // ================= HEADER =================
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    schoolName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
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

            pw.Divider(thickness: 2),

            pw.SizedBox(height: 10),

            // ================= STUDENT INFO =================
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.8),
              ),
              child: pw.Column(
                children: [

                  _infoRow("NAME", student.studentName ?? ""),
                  _infoRow("CLASS", student.classIn ?? ""),
                  _infoRow("YEAR", year.toString()),
                  _infoRow("TERM", term),
                  _infoRow("LIN", student.idNin ?? ""),
                ],
              ),
            ),

            pw.SizedBox(height: 15),

            // ================= RESULTS SECTION =================
            pw.Text(
              "END OF TERM RESULTS",
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(width: 0.8),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
              children: [

                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [
                    _cell("SUBJECT", bold: true),
                    _cell("MARKS", bold: true),
                    _cell("GRADE", bold: true),
                  ],
                ),

                // Data Rows
                ...student.subjectsScoreTerm2.map(
                  (s) => pw.TableRow(
                    children: [
                      _cell(s.subjectName),
                      _cell("${s.scoreEOT}"),
                      _cell(divEND(s.scoreEOT, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End)),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            // ================= AGGREGATE & DIVISION =================
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "TERM AGGREGATE: ${gradeEotTerm2(student.subjectsScoreTerm2, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End)}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "DIVISION: ${gradeEotTerm2(student.subjectsScoreTerm2, d1Start, d2Start, c3Start, c4Start, c5Start, c6Start, p7Start, p8Start, f9Start, f9End)}",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            pw.Spacer(),

            // ================= FOOTER =================
            pw.Divider(),

            pw.Center(
              child: pw.Text(
                "This report card is invalid without a school stamp",
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),

            pw.SizedBox(height: 6),

            pw.Center(
              child: pw.Text(
                "$address | PO BOX $pobox | $email",
                style: const pw.TextStyle(fontSize: 9),
              ),
            ),

            pw.SizedBox(height: 6),

            pw.Center(
              child: pw.Text(
                moto.toUpperCase(),
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
