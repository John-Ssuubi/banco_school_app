// // ignore_for_file: file_names, use_build_context_synchronously, depend_on_referenced_packages

// import 'dart:io';

// import 'package:banco_pro/PrimaryFour/ExtraSub/extra_sub_p4.dart';
// import 'package:banco_pro/PrimaryFour/Term%20II/p4_database_term2.dart';
// import 'package:banco_pro/PrimaryFour/Term%20III/p4_database_term3.dart';
// import 'package:banco_pro/PrimaryFour/p4_database.dart';
// import 'package:banco_pro/PrimaryFour/p4_hive_bloc.dart';
// import 'package:banco_pro/PrimaryFour/p4_student_model.dart';
// import 'package:banco_pro/generate_unique_id.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_excel/excel.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class ExcelButtonP46Subs extends StatefulWidget {
//   const ExcelButtonP46Subs({super.key});

//   @override
//   State<ExcelButtonP46Subs> createState() => _ExcelButtonP46SubsState();
// }

// class _ExcelButtonP46SubsState extends State<ExcelButtonP46Subs> {
//   // ---------------------------------------------------------------
//   // DIALOG FOR ERRORS (WORKS ON WINDOWS / DESKTOP / MOBILE)
//   // ---------------------------------------------------------------
//   Future<void> showMessage(BuildContext context, String msg) async {
//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Message"),
//         content: Text(msg),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------------------------------------------------------
//   // SAFE CELL READER
//   // ---------------------------------------------------------------
//   dynamic getCell(List<Data?> row, int index) {
//     try {
//       final val = row[index]?.value;
//       if (val == null) return "";
//       if (val == "x") return "-1";
//       return val.toString();
//     } catch (_) {
//       return "";
//     }
//   }

//   // ---------------------------------------------------------------
//   // SAVE NEW STUDENT
//   // ---------------------------------------------------------------
//   void saveStudent(StudentModelP4 model) {
//     final box = HiveBloCStudentModelP4.getStudent();
//     box.add(model);
//   }

//   // ---------------------------------------------------------------
//   // MAIN UI
//   // ---------------------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<Box<ExtraSubP4>>(
//       valueListenable: HiveBloCExtraSubP4.getSubjectScore().listenable(),
//       builder: (_, extraBox, __) {
//         final extraSubs = extraBox.values.toList();

//         return ValueListenableBuilder<Box<StudentModelP4>>(
//           valueListenable: HiveBloCStudentModelP4.getStudent().listenable(),
//           builder: (_, studentBox, __) {
//             return ElevatedButton.icon(
//               icon: const Icon(Icons.download),
//               label: const Text("Import Excel 6 Subjects"),
//               onPressed: () => _importExcel(context, studentBox, extraSubs),
//             );
//           },
//         );
//       },
//     );
//   }

//   // ---------------------------------------------------------------
//   // IMPORT EXCEL FUNCTION
//   // ---------------------------------------------------------------
//   Future<void> _importExcel(
//     BuildContext context,
//     Box<StudentModelP4> studentBox,
//     List<ExtraSubP4> extraSubs,
//   ) async {
//     try {
//     // Pick File
//     final fileResult = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ["xlsx"],
//     );

//     if (fileResult == null) {
//       return showMessage(context, "No file selected");
//     }

//     final path = fileResult.files.single.path;
//     if (path == null) {
//       return showMessage(context, "Invalid file path");
//     }

//     // Read Excel
//     final bytes = File(path).readAsBytesSync();
//     final excel = Excel.decodeBytes(bytes);

//     for (var table in excel.tables.keys) {
//       final sheet = excel.tables[table];
//       if (sheet == null) continue;

//       for (var row in sheet.rows) {
//         try {
//         final studentName = getCell(row, 0).trim();
//         if (studentName.isEmpty) continue;

//         // ----------------- TERM 1 (6 subjects) -----------------
//         List<P4Subjects> term1 = [
//           P4Subjects(
//             subjectName: getCell(row, 1),
//             teacher: getCell(row, 2),
//             scoreBOT: double.parse(getCell(row, 3)),
//             scoreMT: double.parse(getCell(row, 4)),
//             scoreEOT: double.parse(getCell(row, 5)),
//           ),
//           P4Subjects(
//             subjectName: getCell(row, 6),
//             teacher: getCell(row, 7),
//             scoreBOT: double.parse(getCell(row, 8)),
//             scoreMT: double.parse(getCell(row, 9)),
//             scoreEOT: double.parse(getCell(row, 10)),
//           ),
//           P4Subjects(
//             subjectName: getCell(row, 11),
//             teacher: getCell(row, 12),
//             scoreBOT: double.parse(getCell(row, 13)),
//             scoreMT: double.parse(getCell(row, 14)),
//             scoreEOT: double.parse(getCell(row, 15)),
//           ),
//           P4Subjects(
//             subjectName: getCell(row, 16),
//             teacher: getCell(row, 17),
//             scoreBOT: double.parse(getCell(row, 18)),
//             scoreMT: double.parse(getCell(row, 19)),
//             scoreEOT: double.parse(getCell(row, 20)),
//           ),
//           P4Subjects(
//             subjectName: getCell(row, 21),
//             teacher: getCell(row, 22),
//             scoreBOT: double.parse(getCell(row, 23)),
//             scoreMT: double.parse(getCell(row, 24)),
//             scoreEOT: double.parse(getCell(row, 25)),
//           ),
//           P4Subjects(
//             subjectName: getCell(row, 26),
//             teacher: getCell(row, 27),
//             scoreBOT: double.parse(getCell(row, 28)),
//             scoreMT: double.parse(getCell(row, 29)),
//             scoreEOT: double.parse(getCell(row, 30)),
//           ),
//         ];

//         // ----------------- TERM 2 (6 subjects) -----------------
//         List<P4SubjectsTerm2> term2 = [
//           P4SubjectsTerm2(
//             subjectName: getCell(row, 32),
//             teacher: getCell(row, 33),
//             scoreBOT: double.parse(getCell(row, 34)),
//             scoreMT: double.parse(getCell(row, 35)),
//             scoreEOT: double.parse(getCell(row, 36)),
//           ),
//           P4SubjectsTerm2(
//             subjectName: getCell(row, 37),
//             teacher: getCell(row, 38),
//             scoreBOT: double.parse(getCell(row, 39)),
//             scoreMT: double.parse(getCell(row, 40)),
//             scoreEOT: double.parse(getCell(row, 41)),
//           ),
//           P4SubjectsTerm2(
//             subjectName: getCell(row, 42),
//             teacher: getCell(row, 43),
//             scoreBOT: double.parse(getCell(row, 44)),
//             scoreMT: double.parse(getCell(row, 45)),
//             scoreEOT: double.parse(getCell(row, 46)),
//           ),
//           P4SubjectsTerm2(
//             subjectName: getCell(row, 47),
//             teacher: getCell(row, 48),
//             scoreBOT: double.parse(getCell(row, 49)),
//             scoreMT: double.parse(getCell(row, 50)),
//             scoreEOT: double.parse(getCell(row, 51)),
//           ),
//           P4SubjectsTerm2(
//             subjectName: getCell(row, 52),
//             teacher: getCell(row, 53),
//             scoreBOT: double.parse(getCell(row, 54)),
//             scoreMT: double.parse(getCell(row, 55)),
//             scoreEOT: double.parse(getCell(row, 56)),
//           ),
//           P4SubjectsTerm2(
//             subjectName: getCell(row, 57),
//             teacher: getCell(row, 58),
//             scoreBOT: double.parse(getCell(row, 59)),
//             scoreMT: double.parse(getCell(row, 60)),
//             scoreEOT: double.parse(getCell(row, 61)),
//           ),
//         ];

//         // ----------------- TERM 3 (6 subjects) -----------------
//         List<P4SubjectsTerm3> term3 = [
//           P4SubjectsTerm3(
//             subjectName: getCell(row, 63),
//             teacher: getCell(row, 64),
//             scoreBOT: double.parse(getCell(row, 65)),
//             scoreMT: double.parse(getCell(row, 66)),
//             scoreEOT: double.parse(getCell(row, 67)),
//           ),
//           P4SubjectsTerm3(
//             subjectName: getCell(row, 68),
//             teacher: getCell(row, 69),
//             scoreBOT: double.parse(getCell(row, 70)),
//             scoreMT: double.parse(getCell(row, 71)),
//             scoreEOT: double.parse(getCell(row, 72)),
//           ),
//           P4SubjectsTerm3(
//             subjectName: getCell(row, 73),
//             teacher: getCell(row, 74),
//             scoreBOT: double.parse(getCell(row, 75)),
//             scoreMT: double.parse(getCell(row, 76)),
//             scoreEOT: double.parse(getCell(row, 77)),
//           ),
//           P4SubjectsTerm3(
//             subjectName: getCell(row, 78),
//             teacher: getCell(row, 79),
//             scoreBOT: double.parse(getCell(row, 80)),
//             scoreMT: double.parse(getCell(row, 81)),
//             scoreEOT: double.parse(getCell(row, 82)),
//           ),
//           P4SubjectsTerm3(
//             subjectName: getCell(row, 83),
//             teacher: getCell(row, 84),
//             scoreBOT: double.parse(getCell(row, 85)),
//             scoreMT: double.parse(getCell(row, 86)),
//             scoreEOT: double.parse(getCell(row, 87)),
//           ),
//           P4SubjectsTerm3(
//             subjectName: getCell(row, 88),
//             teacher: getCell(row, 89),
//             scoreBOT: double.parse(getCell(row, 90)),
//             scoreMT: double.parse(getCell(row, 91)),
//             scoreEOT: double.parse(getCell(row, 92)),
//           ),
//         ];

//         // ----------------- SAVE / UPDATE STUDENT -----------------
//         final existing = studentBox.values
//             .where((s) => s.studentName == studentName)
//             .toList();

//         if (existing.isEmpty) {
//           String id = await generateUniqueStudentId('538105','P4');

//           saveStudent(
//             StudentModelP4(
//               id: 0,
//               studentName: studentName,
//               classIn: "P4",
//               stream: "A",
//               contactNumber: "Not Given",
//               image: "null",
//               address: "Not given",
//               birthDate: "Not given",
//               nationality: "Not given",
//               emis: "Not given",
//               idNin: id,
//               nextofKinName: "Not given",
//               nextofKincontactNumberWhatsApp: "Not given",
//               nextofKinid: "Not given",
//               nextofKinidEmail: "Not given",
//               yearAdmin: "Not given",
//               termAdmin: "Not given",
//               subjectsScore: term1,
//               subjectsScoreTerm2: term2,
//               subjectsScoreTerm3: term3,
//               extraSub: extraSubs,
//             ),
//           );
//         } else {
//           final key = existing.first.key;
//           studentBox.put(
//             key,
//             existing.first.copyWith(
//               subjectsScore: term1,
//               subjectsScoreTerm2: term2,
//               subjectsScoreTerm3: term3,
//             ),
//           );
//         }
//         } catch (e) {
//           showMessage(context, "Error reading row: ${e.toString()}");
//         }
//       }
//     }

//      showMessage(context, "Import completed successfully!");}
//     on FormatException {
//       showMessage(context, "An entry was placed in the wrong cell or has an invalid format.");}
//      catch
    
//      (e) {
//       showMessage(context, "Fatal error during import.");
//     }
//   }
//   }
