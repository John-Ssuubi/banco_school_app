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

// class ExcelButtonP47Subs extends StatefulWidget {
//   const ExcelButtonP47Subs({super.key});

//   @override
//   State<ExcelButtonP47Subs> createState() => _ExcelButtonP47SubsState();
// }

// class _ExcelButtonP47SubsState extends State<ExcelButtonP47Subs> {
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
//               label: const Text("Import Excel 7 Subjects"),
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
//           // try {
//             final studentName = getCell(row, 0).trim();
//             if (studentName.isEmpty) continue;

//             // ----------------- TERM 1 (7 subjects) -----------------
//             List<P4Subjects> term1 = [
//               P4Subjects(
//                 subjectName: getCell(row, 1),
//                 scoreBOT: getCell(row, 2),
//                 scoreEOT: getCell(row, 3),
//                 scoreMT: getCell(row, 4),
//                 teacher: getCell(row, 5),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 6),
//                 scoreBOT: getCell(row, 7),
//                 scoreEOT: getCell(row, 8),
//                 scoreMT: getCell(row, 9),
//                 teacher: getCell(row, 10),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 11),
//                 scoreBOT: getCell(row, 12),
//                 scoreEOT: getCell(row, 13),
//                 scoreMT: getCell(row, 14),
//                 teacher: getCell(row, 15),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 16),
//                 scoreBOT: getCell(row, 17),
//                 scoreEOT: getCell(row, 18),
//                 scoreMT: getCell(row, 19),
//                 teacher: getCell(row, 20),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 21),
//                 scoreBOT: getCell(row, 22),
//                 scoreEOT: getCell(row, 23),
//                 scoreMT: getCell(row, 24),
//                 teacher: getCell(row, 25),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 26),
//                 scoreBOT: getCell(row, 27),
//                 scoreEOT: getCell(row, 28),
//                 scoreMT: getCell(row, 29),
//                 teacher: getCell(row, 30),
//               ),
//               P4Subjects(
//                 subjectName: getCell(row, 31),
//                 scoreBOT: getCell(row, 32),
//                 scoreEOT: getCell(row, 33),
//                 scoreMT: getCell(row, 34),
//                 teacher: getCell(row, 35),
//               ),
              
//               ];

//             // ----------------- TERM 2 (7 subjects) -----------------
//             List<P4SubjectsTerm2> term2 = [
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 37),
//                 scoreBOT: getCell(row, 38),
//                 scoreEOT: getCell(row, 39),
//                 scoreMT: getCell(row, 40),
//                 teacher: getCell(row, 41),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 42),
//                 scoreBOT: getCell(row, 43),
//                 scoreEOT: getCell(row, 44),
//                 scoreMT: getCell(row, 45),
//                 teacher: getCell(row, 46),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 47),
//                 scoreBOT: getCell(row, 48),
//                 scoreEOT: getCell(row, 49),
//                 scoreMT: getCell(row, 50),
//                 teacher: getCell(row, 51),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 52),
//                 scoreBOT: getCell(row, 53),
//                 scoreEOT: getCell(row, 54),
//                 scoreMT: getCell(row, 55),
//                 teacher: getCell(row, 56),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 57),
//                 scoreBOT: getCell(row, 58),
//                 scoreEOT: getCell(row, 59),
//                 scoreMT: getCell(row, 60),
//                 teacher: getCell(row, 61),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 62),
//                 scoreBOT: getCell(row, 63),
//                 scoreEOT: getCell(row, 64),
//                 scoreMT: getCell(row, 65),
//                 teacher: getCell(row, 66),
//               ),
//               P4SubjectsTerm2(
//                 subjectName: getCell(row, 67),
//                 scoreBOT: getCell(row, 68),
//                 scoreEOT: getCell(row, 69),
//                 scoreMT: getCell(row, 70),
//                 teacher: getCell(row, 71),
//               ),
//             ];

//             // ----------------- TERM 3 (7 subjects) -----------------
//             List<P4SubjectsTerm3> term3 = [
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 73),
//                 scoreBOT: getCell(row, 74),
//                 scoreEOT: getCell(row, 75),
//                 scoreMT: getCell(row, 76),
//                 teacher: getCell(row, 77),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 78),
//                 scoreBOT: getCell(row, 79),
//                 scoreEOT: getCell(row, 80),
//                 scoreMT: getCell(row, 81),
//                 teacher: getCell(row, 82),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 83),
//                 scoreBOT: getCell(row, 84),
//                 scoreEOT: getCell(row, 85),
//                 scoreMT: getCell(row, 86),
//                 teacher: getCell(row, 87),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 88),
//                 scoreBOT: getCell(row, 89),
//                 scoreEOT: getCell(row, 90),
//                 scoreMT: getCell(row, 91),
//                 teacher: getCell(row, 92),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 93),
//                 scoreBOT: getCell(row, 94),
//                 scoreEOT: getCell(row, 95),
//                 scoreMT: getCell(row, 96),
//                 teacher: getCell(row, 97),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 98),
//                 scoreBOT: getCell(row, 99),
//                 scoreEOT: getCell(row, 100),
//                 scoreMT: getCell(row, 101),
//                 teacher: getCell(row, 102),
//               ),
//               P4SubjectsTerm3(
//                 subjectName: getCell(row, 103),
//                 scoreBOT: getCell(row, 104),
//                 scoreEOT: getCell(row, 105),
//                 scoreMT: getCell(row, 106),
//                 teacher: getCell(row, 107),
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
//           // }
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
