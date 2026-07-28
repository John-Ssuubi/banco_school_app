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

// class ExcelButtonP45Subs extends StatefulWidget {
//   const ExcelButtonP45Subs({super.key});

//   @override
//   State<ExcelButtonP45Subs> createState() => _ExcelButtonP45SubsState();
// }

// class _ExcelButtonP45SubsState extends State<ExcelButtonP45Subs> {
//   // ---------------------------------------------------------------
//   // DIALOG FOR ERRORS (WORKS ON WINDOWS / DESKTOP / MOBILE)
//   // ---------------------------------------------------------------
//     Future<void> showMessage(BuildContext context, String msg) async {
//       await showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text("Message"),
//           content: Text(msg),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             ),
//           ],
//         ),
//       );
//     }

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
//               label: const Text("Import Excel 5 Subjects"),
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
//       // Pick File
//       final fileResult = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ["xlsx"],
//       );

//       if (fileResult == null) {
//         return showMessage(context, "No file selected");
//       }

//       final path = fileResult.files.single.path;
//       if (path == null) {
//         return showMessage(context, "Invalid file path");
//       }

//       // Read Excel
//       final bytes = File(path).readAsBytesSync();
//       final excel = Excel.decodeBytes(bytes);

//       for (var table in excel.tables.keys) {
//         final sheet = excel.tables[table];
//         if (sheet == null) continue;

//         for (var row in sheet.rows) {
//           try {
//             final studentName = getCell(row, 0).trim();
//             if (studentName.isEmpty) continue;

//             // ----------------- TERM 1 (5 subjects) -----------------
//             List<P4Subjects> term1 = [
//               P4Subjects(
//                 subjectName: getCell(row, 1),
//                 teacher: getCell(row, 2),
//                 scoreBOT: double.parse(getCell(row, 3)),
//                 scoreMT: double.parse(getCell(row, 4)),
//                 scoreEOT: double.parse(getCell(row, 5)),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 6),
//                 teacher: getCell(row, 7),
//                 scoreBOT: double.parse(getCell(row, 8)),
//                 scoreMT: double.parse(getCell(row, 9)),
//                 scoreEOT: double.parse(getCell(row, 10)),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 11),
//                 teacher: getCell(row, 12),
//                 scoreBOT: double.parse(getCell(row, 13)),
//                 scoreMT: double.parse(getCell(row, 14)),
//                 scoreEOT: double.parse(getCell(row, 15)),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 16),
//                 teacher: getCell(row, 17),
//                 scoreBOT: double.parse(getCell(row, 18)),
//                 scoreMT: double.parse(getCell(row, 19)),
//                 scoreEOT: double.parse(getCell(row, 20)),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 21),
//                 teacher: getCell(row, 22),
//                 scoreBOT: double.parse(getCell(row, 23)),
//                 scoreMT: double.parse(getCell(row, 24)),
//                 scoreEOT: double.parse(getCell(row, 25)),
//               ),
//             ];

//             // ----------------- TERM 2 -----------------
//             List<P4SubjectsTerm2> term2 = [
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 27),
//                 teacher: getCell(row, 28),
//                 scoreBOT: double.parse(getCell(row, 29)),
//                 scoreMT: double.parse(getCell(row, 30)),
//                 scoreEOT: double.parse(getCell(row, 31)),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 32),
//                 teacher: getCell(row, 33),
//                 scoreBOT: double.parse(getCell(row, 34)),
//                 scoreMT: double.parse(getCell(row, 35)),
//                 scoreEOT: double.parse(getCell(row, 36)),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 37),
//                 teacher: getCell(row, 38),
//                 scoreBOT: double.parse(getCell(row, 39)),
//                 scoreMT: double.parse(getCell(row, 40)),
//                 scoreEOT: double.parse(getCell(row, 41)),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 42),
//                 teacher: getCell(row, 43),
//                 scoreBOT: double.parse(getCell(row, 44)),
//                 scoreMT: double.parse(getCell(row, 45)),
//                 scoreEOT: double.parse(getCell(row, 46)),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 47),
//                 teacher: getCell(row, 48),
//                 scoreBOT: double.parse(getCell(row, 49)),
//                 scoreMT: double.parse(getCell(row, 50)),
//                 scoreEOT: double.parse(getCell(row, 51)),
//               ),
//             ];

//             // ----------------- TERM 3 -----------------
//             List<P4SubjectsTerm3> term3 = [
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 54),
//                 teacher: getCell(row, 55),
//                 scoreBOT: double.parse(getCell(row, 56)),
//                 scoreMT: double.parse(getCell(row, 57)),
//                 scoreEOT: double.parse(getCell(row, 58)),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 59),
//                 teacher: getCell(row, 60),
//                 scoreBOT: double.parse(getCell(row, 61)),
//                 scoreMT: double.parse(getCell(row, 62)),
//                 scoreEOT: double.parse(getCell(row, 63)),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 64),
//                 teacher: getCell(row, 65),
//                 scoreBOT: double.parse(getCell(row, 66)),
//                 scoreMT: double.parse(getCell(row, 67)),
//                 scoreEOT: double.parse(getCell(row, 68)),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 69),
//                 teacher: getCell(row, 70),
//                 scoreBOT: double.parse(getCell(row, 71)),
//                 scoreMT: double.parse(getCell(row, 72)),
//                 scoreEOT: double.parse(getCell(row, 73)),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 74),
//                 teacher: getCell(row, 75),
//                 scoreBOT: double.parse(getCell(row, 76)),
//                 scoreMT: double.parse(getCell(row, 77)),
//                 scoreEOT: double.parse(getCell(row, 78)),
//               ),
//             ];

//             // ----------------- SAVE / UPDATE STUDENT -----------------
//             final existing = studentBox.values
//                 .where((s) => s.studentName == studentName)
//                 .toList();

//             if (existing.isEmpty) {
//               String id = await generateUniqueStudentId('538105','P4');

//               saveStudent(
//                 StudentModelP4(
//                   id: 0,
//                   studentName: studentName,
//                   classIn: "P4",
//                   stream: "A",
//                   contactNumber: "Not Given",
//                   image: "null",
//                   address: "Not given",
//                   birthDate: "Not given",
//                   nationality: "Not given",
//                   emis: "Not given",
//                   idNin: id,
//                   nextofKinName: "Not given",
//                   nextofKincontactNumberWhatsApp: "Not given",
//                   nextofKinid: "Not given",
//                   nextofKinidEmail: "Not given",
//                   yearAdmin: "Not given",
//                   termAdmin: "Not given",
//                   subjectsScore: term1,
//                   subjectsScoreTerm2: term2,
//                   subjectsScoreTerm3: term3,
//                   extraSub: extraSubs,
//                 ),
//               );
//             } else {
//               final key = existing.first.key;
//               studentBox.put(
//                 key,
//                 existing.first.copyWith(
//                   subjectsScore: term1,
//                   subjectsScoreTerm2: term2,
//                   subjectsScoreTerm3: term3,
//                 ),
//               );
//             }
//           } catch (e) {
//             showMessage(context, "Error reading row: ${e.toString()}");
//           }
//         }
//       }

//        showMessage(context, "Import completed successfully!");}
//     on FormatException {
//       showMessage(context, "An entry was placed in the wrong cell or has an invalid format.");}
//      catch
    
//      (e) {
//       showMessage(context, "Fatal error during import.");
//     }
//   }
//   }

