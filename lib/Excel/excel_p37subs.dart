// // ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously

// import 'dart:io';
// // ignore: unused_import
// import 'package:banco_pro/Finance/payments_p4_model.dart';
// import 'package:banco_pro/PrimaryFour/ExtraSub/extra_sub_p4.dart';
// import 'package:banco_pro/PrimaryFour/Term%20II/p4_database_term2.dart';
// import 'package:banco_pro/PrimaryFour/Term%20III/p4_database_term3.dart';
// import 'package:banco_pro/PrimaryFour/p4_database.dart';
// import 'package:banco_pro/PrimaryFour/p4_hive_bloc.dart';
// import 'package:banco_pro/PrimaryFour/p4_student_model.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_excel/excel.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:image_picker/image_picker.dart';

// class ExcelButtonP47Subs extends StatefulWidget {
//   const ExcelButtonP47Subs({super.key});

//   @override
//   State<ExcelButtonP47Subs> createState() => _ExcelButtonP47SubsT1State();
// }

// class _ExcelButtonP47SubsT1State extends State<ExcelButtonP47Subs> {
//   void saveStudentName(StudentModelP4? studentModelP4) {
//     final studentName = HiveBloCStudentModelP4.getStudent();
//     studentName.add(studentModelP4!);

//     if (kDebugMode) {
//       // print('Name is ${studentModelP4.studentName}');
//       // print('Score is ${studentModelP4.subjectsScore}');
//     }
//   }

//   P4SubjectsTerm2 saveSubjectScoreTrem2(P4SubjectsTerm2 p4subjectsTerm2) {
//     final subjectData = HiveBloCSubjectScoreP4Term2.getSubjectScore();
//     subjectData.add(p4subjectsTerm2);

//     return p4subjectsTerm2;
//   }

//   P4SubjectsTerm3 saveSubjectScoreTrem3(P4SubjectsTerm3 p4subjectsTerm3) {
//     final subjectData = HiveBloCSubjectScoreP4Term3.getSubjectScore();
//     subjectData.add(p4subjectsTerm3);

//     return p4subjectsTerm3;
//   }

//   XFile? image;
//   // final ImagePicker _picker = ImagePicker();
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<Box<ExtraSubP4>>(
//         valueListenable: HiveBloCExtraSubP4.getSubjectScore().listenable(),
//         builder: (context, extra3, child) {
//           return ValueListenableBuilder<Box<StudentModelP4>>(
//               valueListenable: HiveBloCStudentModelP4.getStudent().listenable(),
//               builder: (context, studentsnap, child) {
//                 var listStudent = List.generate(studentsnap.length, ((index) {
//                   var data = studentsnap.getAt(index)!;
//                   return data;
//                 }));

//                 return ElevatedButton.icon(
//                   label: const Text('Import Excel 7 Subjects'),
//                   icon: const Icon(Icons.download),
//                   onPressed: () async {
//                     FilePickerResult? pickedFile =
//                         await FilePicker.platform.pickFiles(
//                       type: FileType.custom,
//                       allowedExtensions: ['xlsx'],
//                       allowMultiple: false,
//                     );

//                     if (pickedFile != null) {
//                       var file = pickedFile.files.single.path.toString();

//                       var bytes = File(file).readAsBytesSync();
//                       var excel = Excel.decodeBytes(bytes);
// try {
//                       for (var table in excel.tables.keys) {
//                         for (var row in excel.tables[table]!.rows) {
//                           // 1ST TERM

//                           var list =
//                               row.asMap().values.elementAt(0)!.props.first;
//                           var list2 =
//                               row.asMap().values.elementAt(1)!.props.first;
//                           var list3 =
//                               row.asMap().values.elementAt(2)!.props.first;
//                           var list4 =
//                               row.asMap().values.elementAt(3)!.props.first;
//                           var list5 =
//                               row.asMap().values.elementAt(4)!.props.first;
//                           var list6 =
//                               row.asMap().values.elementAt(5)!.props.first;
//                           var list7 =
//                               row.asMap().values.elementAt(6)!.props.first;
//                           var list8 =
//                               row.asMap().values.elementAt(7)!.props.first;
//                           var list9 =
//                               row.asMap().values.elementAt(8)!.props.first;
//                           var list10 =
//                               row.asMap().values.elementAt(9)!.props.first;
//                           var list11 =
//                               row.asMap().values.elementAt(10)!.props.first;
//                           var list12 =
//                               row.asMap().values.elementAt(11)!.props.first;
//                           var list13 =
//                               row.asMap().values.elementAt(12)!.props.first;

//                           var list14 =
//                               row.asMap().values.elementAt(13)!.props.first;
//                           var list15 =
//                               row.asMap().values.elementAt(14)!.props.first;
//                           var list16 =
//                               row.asMap().values.elementAt(15)!.props.first;
//                           var list17 =
//                               row.asMap().values.elementAt(16)!.props.first;
//                           var list18 =
//                               row.asMap().values.elementAt(17)!.props.first;
//                           var list19 =
//                               row.asMap().values.elementAt(18)!.props.first;
//                           var list20 =
//                               row.asMap().values.elementAt(19)!.props.first;
//                           var list21 =
//                               row.asMap().values.elementAt(20)!.props.first;
//                           var list22 =
//                               row.asMap().values.elementAt(21)!.props.first;
//                           var list23 =
//                               row.asMap().values.elementAt(22)!.props.first;
//                           var list24 =
//                               row.asMap().values.elementAt(23)!.props.first;
//                           var list25 =
//                               row.asMap().values.elementAt(24)!.props.first;
//                           var list26 =
//                               row.asMap().values.elementAt(25)!.props.first;

//                           var list27 =
//                               row.asMap().values.elementAt(26)!.props.first;
//                           var list28 =
//                               row.asMap().values.elementAt(27)!.props.first;
//                           var list29 =
//                               row.asMap().values.elementAt(28)!.props.first;
//                           var list30 =
//                               row.asMap().values.elementAt(29)!.props.first;
//                           var list31 =
//                               row.asMap().values.elementAt(30)!.props.first;

//                           var list32 =
//                               row.asMap().values.elementAt(31)!.props.first;
//                           var list33 =
//                               row.asMap().values.elementAt(32)!.props.first;
//                           var list34 =
//                               row.asMap().values.elementAt(33)!.props.first;
//                           var list35 =
//                               row.asMap().values.elementAt(34)!.props.first;
//                           var list36 =
//                               row.asMap().values.elementAt(35)!.props.first;

//                           // print('HAAAAAAAAAAAAAAAAAA $list2');
//                           if (list2 == 'x') {
//                             list2 = -1.0;
//                           }
//                           if (list3 == 'x') {
//                             list3 = -1.0;
//                           }
//                           if (list4 == 'x') {
//                             list4 = -1.0;
//                           }
//                           if (list5 == 'x') {
//                             list5 = -1.0;
//                           }
//                           if (list6 == 'x') {
//                             list6 = -1.0;
//                           }
//                           if (list9 == 'x') {
//                             list9 = -1.0;
//                           }
//                           if (list10 == 'x') {
//                             list10 = -1.0;
//                           }
//                           if (list11 == 'x') {
//                             list11 = -1.0;
//                           }
//                           if (list14 == 'x') {
//                             list14 = -1.0;
//                           }
//                           if (list15 == 'x') {
//                             list15 = -1.0;
//                           }
//                           if (list16 == 'x') {
//                             list16 = -1.0;
//                           }
//                           if (list19 == 'x') {
//                             list19 = -1.0;
//                           }
//                           if (list20 == 'x') {
//                             list20 = -1.0;
//                           }
//                           if (list21 == 'x') {
//                             list21 = -1.0;
//                           }
//                           if (list24 == 'x') {
//                             list24 = -1.0;
//                           }
//                           if (list25 == 'x') {
//                             list25 = -1.0;
//                           }
//                           if (list26 == 'x') {
//                             list26 = -1.0;
//                           }
//                           if (list27 == 'x') {
//                             list27 = -1.0;
//                           }
//                           if (list28 == 'x') {
//                             list28 = -1.0;
//                           }
//                           if (list29 == 'x') {
//                             list29 = -1.0;
//                           }
//                           if (list30 == 'x') {
//                             list30 = -1.0;
//                           }
//                           if (list31 == 'x') {
//                             list31 = -1.0;
//                           }
//                           if (list32 == 'x') {
//                             list32 = -1.0;
//                           }
//                           if (list33 == 'x') {
//                             list33 = -1.0;
//                           }
//                           if (list34 == 'x') {
//                             list34 = -1.0;
//                           }
//                           if (list35 == 'x') {
//                             list35 = -1.0;
//                           }
//                           if (list36 == 'x') {
//                             list36 = -1.0;
//                           }

//                           var subList = [
//                             P4Subjects(
//                               subjectName: list2.toString(),
//                               teacher: list3.toString(),
//                               scoreBOT: double.parse(list4.toString()),
//                               scoreMT: double.parse(list5.toString()),
//                               scoreEOT: double.parse(list6.toString()),
//                             ),
//                             P4Subjects(
//                               subjectName: list7.toString(),
//                               teacher: list8.toString(),
//                               scoreBOT: double.parse(list9.toString()),
//                               scoreMT: double.parse(list10.toString()),
//                               scoreEOT: double.parse(list11.toString()),
//                             ),
//                             P4Subjects(
//                               subjectName: list12.toString(),
//                               teacher: list13.toString(),
//                               scoreBOT: double.parse(list14.toString()),
//                               scoreMT: double.parse(list15.toString()),
//                               scoreEOT: double.parse(list16.toString()),
//                             ),
//                             P4Subjects(
//                               subjectName: list17.toString(),
//                               teacher: list18.toString(),
//                               scoreBOT: double.parse(list19.toString()),
//                               scoreMT: double.parse(list20.toString()),
//                               scoreEOT: double.parse(list21.toString()),
//                             ),
//                             P4Subjects(
//                               subjectName: list22.toString(),
//                               teacher: list23.toString(),
//                               scoreBOT: double.parse(list24.toString()),
//                               scoreMT: double.parse(list25.toString()),
//                               scoreEOT: double.parse(list26.toString()),
//                             ),
//                             P4Subjects(
//                               subjectName: list27.toString(),
//                               teacher: list28.toString(),
//                               scoreBOT: double.parse(list29.toString()),
//                               scoreMT: double.parse(list30.toString()),
//                               scoreEOT: double.parse(list31.toString()),
//                             ),
//                             P4Subjects(
//                               subjectName: list32.toString(),
//                               teacher: list33.toString(),
//                               scoreBOT: double.parse(list34.toString()),
//                               scoreMT: double.parse(list35.toString()),
//                               scoreEOT: double.parse(list36.toString()),
//                             ),
//                           ];

//                           // 2ND TERM

//                           var list38 =
//                               row.asMap().values.elementAt(37)!.props.first;
//                           var list39 =
//                               row.asMap().values.elementAt(38)!.props.first;
//                           var list40 =
//                               row.asMap().values.elementAt(39)!.props.first;
//                           var list41 =
//                               row.asMap().values.elementAt(40)!.props.first;
//                           var list42 =
//                               row.asMap().values.elementAt(41)!.props.first;

//                           var list43 =
//                               row.asMap().values.elementAt(42)!.props.first;
//                           var list44 =
//                               row.asMap().values.elementAt(43)!.props.first;
//                           var list45 =
//                               row.asMap().values.elementAt(44)!.props.first;
//                           var list46 =
//                               row.asMap().values.elementAt(45)!.props.first;
//                           var list47 =
//                               row.asMap().values.elementAt(46)!.props.first;

//                           var list48 =
//                               row.asMap().values.elementAt(47)!.props.first;
//                           var list49 =
//                               row.asMap().values.elementAt(48)!.props.first;
//                           var list50 =
//                               row.asMap().values.elementAt(49)!.props.first;
//                           var list51 =
//                               row.asMap().values.elementAt(50)!.props.first;
//                           var list52 =
//                               row.asMap().values.elementAt(51)!.props.first;

//                           var list53 =
//                               row.asMap().values.elementAt(52)!.props.first;
//                           var list54 =
//                               row.asMap().values.elementAt(53)!.props.first;
//                           var list55 =
//                               row.asMap().values.elementAt(54)!.props.first;
//                           var list56 =
//                               row.asMap().values.elementAt(55)!.props.first;
//                           var list57 =
//                               row.asMap().values.elementAt(56)!.props.first;

//                           var list58 =
//                               row.asMap().values.elementAt(57)!.props.first;
//                           var list59 =
//                               row.asMap().values.elementAt(58)!.props.first;
//                           var list60 =
//                               row.asMap().values.elementAt(59)!.props.first;
//                           var list61 =
//                               row.asMap().values.elementAt(60)!.props.first;
//                           var list62 =
//                               row.asMap().values.elementAt(61)!.props.first;

//                           var list63 =
//                               row.asMap().values.elementAt(62)!.props.first;
//                           var list64 =
//                               row.asMap().values.elementAt(63)!.props.first;
//                           var list65 =
//                               row.asMap().values.elementAt(64)!.props.first;
//                           var list66 =
//                               row.asMap().values.elementAt(65)!.props.first;
//                           var list67 =
//                               row.asMap().values.elementAt(66)!.props.first;

//                           var list68 =
//                               row.asMap().values.elementAt(67)!.props.first;
//                           var list69 =
//                               row.asMap().values.elementAt(68)!.props.first;
//                           var list70 =
//                               row.asMap().values.elementAt(69)!.props.first;
//                           var list71 =
//                               row.asMap().values.elementAt(70)!.props.first;
//                           var list72 =
//                               row.asMap().values.elementAt(71)!.props.first;

//                           if (list38 == 'x') {
//                             list38 = -1.0;
//                           }

//                           if (list39 == 'x') {
//                             list39 = -1.0;
//                           }
//                           if (list40 == 'x') {
//                             list40 = -1.0;
//                           }
//                           if (list41 == 'x') {
//                             list41 = -1.0;
//                           }
//                           if (list42 == 'x') {
//                             list42 = -1.0;
//                           }
//                           if (list43 == 'x') {
//                             list43 = -1.0;
//                           }
//                           if (list44 == 'x') {
//                             list44 = -1.0;
//                           }
//                           if (list45 == 'x') {
//                             list45 = -1.0;
//                           }
//                           if (list46 == 'x') {
//                             list46 = -1.0;
//                           }
//                           if (list47 == 'x') {
//                             list47 = -1.0;
//                           }
//                           if (list48 == 'x') {
//                             list48 = -1.0;
//                           }
//                           if (list49 == 'x') {
//                             list49 = -1.0;
//                           }
//                           if (list50 == 'x') {
//                             list50 = -1.0;
//                           }
//                           if (list51 == 'x') {
//                             list51 = -1.0;
//                           }
//                           if (list52 == 'x') {
//                             list52 = -1.0;
//                           }
//                           if (list53 == 'x') {
//                             list53 = -1.0;
//                           }
//                           if (list54 == 'x') {
//                             list54 = -1.0;
//                           }
//                           if (list55 == 'x') {
//                             list55 = -1.0;
//                           }
//                           if (list56 == 'x') {
//                             list56 = -1.0;
//                           }
//                           if (list57 == 'x') {
//                             list57 = -1.0;
//                           }
//                           if (list58 == 'x') {
//                             list58 = -1.0;
//                           }
//                           if (list59 == 'x') {
//                             list59 = -1.0;
//                           }
//                           if (list60 == 'x') {
//                             list60 = -1.0;
//                           }
//                           if (list61 == 'x') {
//                             list61 = -1.0;
//                           }
//                           if (list62 == 'x') {
//                             list62 = -1.0;
//                           }
//                           if (list63 == 'x') {
//                             list63 = -1.0;
//                           }
//                           if (list64 == 'x') {
//                             list64 = -1.0;
//                           }
//                           if (list65 == 'x') {
//                             list65 = -1.0;
//                           }
//                           if (list66 == 'x') {
//                             list66 = -1.0;
//                           }
//                           if (list67 == 'x') {
//                             list67 = -1.0;
//                           }
//                           if (list68 == 'x') {
//                             list68 = -1.0;
//                           }
//                           if (list69 == 'x') {
//                             list69 = -1.0;
//                           }
//                           if (list70 == 'x') {
//                             list70 = -1.0;
//                           }

//                           if (list71 == 'x') {
//                             list71 = -1.0;
//                           }
//                           if (list72 == 'x') {
//                             list72 = -1.0;
//                           }
//                           var subListTerm2 = [
//                             P4SubjectsTerm2(
//                               subjectName: list38.toString(),
//                               teacher: list39.toString(),
//                               scoreBOT: double.parse(list40.toString()),
//                               scoreMT: double.parse(list41.toString()),
//                               scoreEOT: double.parse(list42.toString()),
//                             ),
//                             P4SubjectsTerm2(
//                               subjectName: list43.toString(),
//                               teacher: list44.toString(),
//                               scoreBOT: double.parse(list45.toString()),
//                               scoreMT: double.parse(list46.toString()),
//                               scoreEOT: double.parse(list47.toString()),
//                             ),
//                             P4SubjectsTerm2(
//                               subjectName: list48.toString(),
//                               teacher: list49.toString(),
//                               scoreBOT: double.parse(list50.toString()),
//                               scoreMT: double.parse(list51.toString()),
//                               scoreEOT: double.parse(list52.toString()),
//                             ),
//                             P4SubjectsTerm2(
//                               subjectName: list53.toString(),
//                               teacher: list54.toString(),
//                               scoreBOT: double.parse(list55.toString()),
//                               scoreMT: double.parse(list56.toString()),
//                               scoreEOT: double.parse(list57.toString()),
//                             ),
//                             P4SubjectsTerm2(
//                               subjectName: list58.toString(),
//                               teacher: list59.toString(),
//                               scoreBOT: double.parse(list60.toString()),
//                               scoreMT: double.parse(list61.toString()),
//                               scoreEOT: double.parse(list62.toString()),
//                             ),
//                             P4SubjectsTerm2(
//                               subjectName: list63.toString(),
//                               teacher: list64.toString(),
//                               scoreBOT: double.parse(list65.toString()),
//                               scoreMT: double.parse(list66.toString()),
//                               scoreEOT: double.parse(list67.toString()),
//                             ),
//                             P4SubjectsTerm2(
//                               subjectName: list68.toString(),
//                               teacher: list69.toString(),
//                               scoreBOT: double.parse(list70.toString()),
//                               scoreMT: double.parse(list71.toString()),
//                               scoreEOT: double.parse(list72.toString()),
//                             ),
//                           ];

//                           // 3RD TERM

//                           // 2
//                           var list74 =
//                               row.asMap().values.elementAt(73)!.props.first;
//                           var list75 =
//                               row.asMap().values.elementAt(74)!.props.first;
//                           var list76 =
//                               row.asMap().values.elementAt(75)!.props.first;
//                           var list77 =
//                               row.asMap().values.elementAt(76)!.props.first;
//                           var list78 =
//                               row.asMap().values.elementAt(77)!.props.first;
//                           // 3

//                           var list79 =
//                               row.asMap().values.elementAt(78)!.props.first;
//                           var list80 =
//                               row.asMap().values.elementAt(79)!.props.first;
//                           var list81 =
//                               row.asMap().values.elementAt(80)!.props.first;
//                           var list82 =
//                               row.asMap().values.elementAt(81)!.props.first;
//                           var list83 =
//                               row.asMap().values.elementAt(82)!.props.first;
//                           // 4

//                           var list84 =
//                               row.asMap().values.elementAt(83)!.props.first;
//                           var list85 =
//                               row.asMap().values.elementAt(84)!.props.first;
//                           var list86 =
//                               row.asMap().values.elementAt(85)!.props.first;
//                           var list87 =
//                               row.asMap().values.elementAt(86)!.props.first;
//                           var list88 =
//                               row.asMap().values.elementAt(87)!.props.first;
//                           // 5

//                           var list89 =
//                               row.asMap().values.elementAt(88)!.props.first;
//                           var list90 =
//                               row.asMap().values.elementAt(89)!.props.first;
//                           var list91 =
//                               row.asMap().values.elementAt(90)!.props.first;
//                           var list92 =
//                               row.asMap().values.elementAt(91)!.props.first;
//                           var list93 =
//                               row.asMap().values.elementAt(92)!.props.first;

// // 6

//                           var list94 =
//                               row.asMap().values.elementAt(93)!.props.first;
//                           var list95 =
//                               row.asMap().values.elementAt(94)!.props.first;
//                           var list96 =
//                               row.asMap().values.elementAt(95)!.props.first;
//                           var list97 =
//                               row.asMap().values.elementAt(96)!.props.first;
//                           var list98 =
//                               row.asMap().values.elementAt(97)!.props.first;
//                           // 7

//                           var list99 =
//                               row.asMap().values.elementAt(98)!.props.first;
//                           var list100 =
//                               row.asMap().values.elementAt(99)!.props.first;
//                           var list101 =
//                               row.asMap().values.elementAt(100)!.props.first;
//                           var list102 =
//                               row.asMap().values.elementAt(101)!.props.first;
//                           var list103 =
//                               row.asMap().values.elementAt(102)!.props.first;

//                           // 7
//                           var list104 =
//                               row.asMap().values.elementAt(103)!.props.first;
//                           var list105 =
//                               row.asMap().values.elementAt(104)!.props.first;
//                           var list106 =
//                               row.asMap().values.elementAt(105)!.props.first;
//                           var list107 =
//                               row.asMap().values.elementAt(106)!.props.first;
//                           var list108 =
//                               row.asMap().values.elementAt(107)!.props.first;

//                           if (list74 == 'x') {
//                             list74 = -1.0;
//                           }
//                           if (list75 == 'x') {
//                             list75 = -1.0;
//                           }
//                           if (list76 == 'x') {
//                             list76 = -1.0;
//                           }
//                           if (list77 == 'x') {
//                             list77 = -1.0;
//                           }
//                           if (list78 == 'x') {
//                             list78 = -1.0;
//                           }
//                           if (list79 == 'x') {
//                             list79 = -1.0;
//                           }
//                           if (list80 == 'x') {
//                             list80 = -1.0;
//                           }
//                           if (list81 == 'x') {
//                             list81 = -1.0;
//                           }
//                           if (list82 == 'x') {
//                             list82 = -1.0;
//                           }
//                           if (list83 == 'x') {
//                             list83 = -1.0;
//                           }
//                           if (list84 == 'x') {
//                             list84 = -1.0;
//                           }
//                           if (list85 == 'x') {
//                             list85 = -1.0;
//                           }
//                           if (list86 == 'x') {
//                             list86 = -1.0;
//                           }
//                           if (list87 == 'x') {
//                             list87 = -1.0;
//                           }
//                           if (list88 == 'x') {
//                             list88 = -1.0;
//                           }
//                           if (list89 == 'x') {
//                             list89 = -1.0;
//                           }
//                           if (list90 == 'x') {
//                             list90 = -1.0;
//                           }
//                           if (list91 == 'x') {
//                             list91 = -1.0;
//                           }
//                           if (list92 == 'x') {
//                             list92 = -1.0;
//                           }
//                           if (list93 == 'x') {
//                             list93 = -1.0;
//                           }
//                           if (list94 == 'x') {
//                             list94 = -1.0;
//                           }
//                           if (list95 == 'x') {
//                             list95 = -1.0;
//                           }
//                           if (list96 == 'x') {
//                             list96 = -1.0;
//                           }
//                           if (list97 == 'x') {
//                             list97 = -1.0;
//                           }
//                           if (list98 == 'x') {
//                             list98 = -1.0;
//                           }
//                           if (list99 == 'x') {
//                             list99 = -1.0;
//                           }
//                           if (list100 == 'x') {
//                             list100 = -1.0;
//                           }
//                           if (list101 == 'x') {
//                             list101 = -1.0;
//                           }
//                           if (list102 == 'x') {
//                             list102 = -1.0;
//                           }
//                           if (list103 == 'x') {
//                             list103 = -1.0;
//                           }
//                           if (list104 == 'x') {
//                             list104 = -1.0;
//                           }
//                           if (list105 == 'x') {
//                             list105 = -1.0;
//                           }
//                           if (list106 == 'x') {
//                             list106 = -1.0;
//                           }
//                           if (list107 == 'x') {
//                             list107 = -1.0;
//                           }
//                           if (list108 == 'x') {
//                             list108 = -1.0;
//                           }
//                           var subListTerm3 = [
//                             P4SubjectsTerm3(
//                               subjectName: list74.toString(),
//                               teacher: list75.toString(),
//                               scoreBOT: double.parse(list76.toString()),
//                               scoreMT: double.parse(list77.toString()),
//                               scoreEOT: double.parse(list78.toString()),
//                             ),
//                             P4SubjectsTerm3(
//                               subjectName: list79.toString(),
//                               teacher: list80.toString(),
//                               scoreBOT: double.parse(list81.toString()),
//                               scoreMT: double.parse(list82.toString()),
//                               scoreEOT: double.parse(list83.toString()),
//                             ),
//                             P4SubjectsTerm3(
//                               subjectName: list84.toString(),
//                               teacher: list85.toString(),
//                               scoreBOT: double.parse(list86.toString()),
//                               scoreMT: double.parse(list87.toString()),
//                               scoreEOT: double.parse(list88.toString()),
//                             ),
//                             P4SubjectsTerm3(
//                               subjectName: list89.toString(),
//                               teacher: list90.toString(),
//                               scoreBOT: double.parse(list91.toString()),
//                               scoreMT: double.parse(list92.toString()),
//                               scoreEOT: double.parse(list93.toString()),
//                             ),
//                             P4SubjectsTerm3(
//                               subjectName: list94.toString(),
//                               teacher: list95.toString(),
//                               scoreBOT: double.parse(list96.toString()),
//                               scoreMT: double.parse(list97.toString()),
//                               scoreEOT: double.parse(list98.toString()),
//                             ),
//                             P4SubjectsTerm3(
//                               subjectName: list99.toString(),
//                               teacher: list100.toString(),
//                               scoreBOT: double.parse(list101.toString()),
//                               scoreMT: double.parse(list102.toString()),
//                               scoreEOT: double.parse(list103.toString()),
//                             ),
//                             P4SubjectsTerm3(
//                               subjectName: list104.toString(),
//                               teacher: list105.toString(),
//                               scoreBOT: double.parse(list106.toString()),
//                               scoreMT: double.parse(list107.toString()),
//                               scoreEOT: double.parse(list108.toString()),
//                             ),
//                           ];

//                           if (listStudent.isEmpty) {
//                             saveStudentName(
//                               StudentModelP4(
//                                 studentName: list.toString(),
//                                 classIn: 'P4',
//                                 contactNumber: 'Contact not given',
//                                 stream: 'A',
//                                 address: 'Address not given',
//                                 birthDate: 'Birth date not given',
//                                 nationality: 'Nationality not given',
//                                 emis: 'Emis not given',
//                                 idNin: 'Id nin not given',
//                                 id: 0,
//                                 subjectsScore: subList,
//                                 subjectsScoreTerm2: subListTerm2,
//                                 subjectsScoreTerm3: subListTerm3,
//                                 image: 'null',
//                                 paymentList: [
//                                   PaymentsP4(
//                                       paymentDate: DateTime.now().toString(),
//                                       recipt: 'recipt',
//                                       amount: 0)
//                                 ],
//                                 amountOwedTerm1: 0,
//                                 amountOwedTerm2: 0,
//                                 amountOwedTerm3: 0,
//                                 amountTerm1: 0,
//                                 amountTerm2: 0,
//                                 amountTerm3: 0,
//                                 extraSub: [],
//                                 nextofKinName: 'Next of kin name not given',
//                                 yearAdmin: 'Year of Admision',
//                                 termAdmin: 'Term of Admision',
//                                 nextofKincontactNumberWhatsApp:
//                                     'Next of kin Whats App not given',
//                                 nextofKinid: 'Next of kin Id nin not given',
//                                 nextofKinidEmail: 'Next of kin Email not given',
//                               ),
//                             );
//                           }

//                           listStudent.asMap().forEach((key, value) {
//                             if (list == value.studentName) {
//                               value.box?.putAt(
//                                 key,
//                                 StudentModelP4(
//                                   studentName: list.toString(),
//                                   classIn: 'P4',
//                                   contactNumber: value.contactNumber,
//                                   stream: value.stream,
//                                   address: value.address,
//                                   birthDate: value.birthDate,
//                                   nationality: value.nationality,
//                                   emis: value.emis,
//                                   idNin: value.idNin,
//                                   id: 0,
//                                   subjectsScore: subList,
//                                   subjectsScoreTerm2: subListTerm2,
//                                   subjectsScoreTerm3: subListTerm3,
//                                   image: value.image,
//                                   paymentList: [
//                                     PaymentsP4(
//                                         paymentDate: DateTime.now().toString(),
//                                         recipt: 'recipt',
//                                         amount: 0)
//                                   ],
//                                   amountOwedTerm1: 0,
//                                   amountOwedTerm2: 0,
//                                   amountOwedTerm3: 0,
//                                   amountTerm1: 0,
//                                   amountTerm2: 0,
//                                   amountTerm3: 0,
//                                   extraSub: [],
//                                   nextofKinName: value.nextofKinName,
//                                   yearAdmin: value.yearAdmin,
//                                   termAdmin: value.termAdmin,
//                                   nextofKincontactNumberWhatsApp:
//                                       value.nextofKincontactNumberWhatsApp,
//                                   nextofKinid: value.nextofKinName,
//                                   nextofKinidEmail: value.nextofKinidEmail,
//                                 ),
//                               );
//                             }
//                             setState(() {});
//                           });
//                           var setData =
//                               List.generate(studentsnap.length, ((index) {
//                             var data = studentsnap.getAt(index)!;
//                             return data.studentName;
//                           }));

//                           var finalData = setData.where((element) {
//                             return element!.contains(list.toString());
//                           });

//                           if (finalData.isEmpty) {
//                             // print('SETT: ___ finalData');
//                             saveStudentName(
//                               StudentModelP4(
//                                 studentName: list.toString(),
//                                 classIn: 'P4',
//                                 contactNumber: 'Contact not given',
//                                 stream: 'A',
//                                 address: 'Address not given',
//                                 birthDate: 'Birth date not given',
//                                 nationality: 'Nationality not given',
//                                 emis: 'Emis not given',
//                                 idNin: 'Id nin not given',
//                                 id: 0,
//                                 subjectsScore: subList,
//                                 subjectsScoreTerm2: subListTerm2,
//                                 subjectsScoreTerm3: subListTerm3,
//                                 image: 'null',
//                                 paymentList: [
//                                   PaymentsP4(
//                                       paymentDate: DateTime.now().toString(),
//                                       recipt: 'recipt',
//                                       amount: 0)
//                                 ],
//                                 amountOwedTerm1: 0,
//                                 amountOwedTerm2: 0,
//                                 amountOwedTerm3: 0,
//                                 amountTerm1: 0,
//                                 amountTerm2: 0,
//                                 amountTerm3: 0,
//                                 extraSub: [],
//                                 nextofKinName: 'Next of kin name not given',
//                                 yearAdmin: 'Year of Admision',
//                                 termAdmin: 'Term of Admision',
//                                 nextofKincontactNumberWhatsApp:
//                                     'Next of kin Whats App not given',
//                                 nextofKinid: 'Next of kin Id nin not given',
//                                 nextofKinidEmail: 'Next of kin Email not given',
//                               ),
//                             );
//                           }
//                           // var setData2 =
//                           //     List.generate(row.length, (index) {
//                           //   return list.toString();
//                           // });
//                           // print('SETT2 ${setData2.toSet()}');

//                           // for (var element in listStudent) {
//                           //   if (list ==
//                           //       element.studentName.toString()) {
//                           //     element.delete();

//                           //     // print(
//                           //     // 'Dups are ===== ${element.studentName}');
//                           //   }
//                           // }
//                         }
//                       }
//                      } catch (e)  {
//   if (e.toString() == "Null check operator used on a null value") {
//      showDialog(
//                                             context: context,
//                                             builder: (context) {
//                                               return AlertDialog(
//                                                 actionsAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceEvenly,
//                                                 content: Container(
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             20),
//                                                   ),
//                                                   height: 50,
//                                                   width: 70,
//                                                   child: Text('An empty spreadsheet was found.')));});
//   // print('objectttttttttttttttttttttttttttttttttttt An empty spreadsheet was found.');
//   if (e.toString().length == 33 ) {
//      showDialog(
//                                             context: context,
//                                             builder: (context) {
//                                               return AlertDialog(
//                                                 actionsAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceEvenly,
//                                                 content: Container(
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             20),
//                                                   ),
//                                                   height: 50,
//                                                   width: 70,
//                                                   child: Text('A spreadsheet has invalid data.')));});
//   if (kDebugMode) {
//     print('objectttttttttttttttttttttttttttttttttttt A spreadsheet has invalid data.');
//   }

//   }

//   } else  {
//                                                   if (kDebugMode) {
//                                                     print(e.toString().length);
//                                                   }

//     return  showDialog(
//                                             context: context,
//                                             builder: (context) {
//                                               return AlertDialog(
//                                                 actionsAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceEvenly,
//                                                 content: Container(
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             20),
//                                                   ),
//                                                   height: 50,
//                                                   width: 70,
//                                                   child: Text(e.toString())));});
//   }
// }
//                     }
//                   },
//                 );
//               });
//         });
//   }
// }
