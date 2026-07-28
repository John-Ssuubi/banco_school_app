// import 'dart:io';
// // ignore: unused_import
// import 'dart:math';
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

// class ExcelButtonP4 extends StatefulWidget {
//   const ExcelButtonP4({super.key});

//   @override
//   State<ExcelButtonP4> createState() => _ExcelButtonP4T1State();
// }

// class _ExcelButtonP4T1State extends State<ExcelButtonP4> {
//   void saveStudentName(StudentModelP4? studentModelP4) {
//     final studentName = HiveBloCStudentModelP4.getStudent();
//     studentName.add(studentModelP4!);

//     if (kDebugMode) {
//       print('Name is ${studentModelP4.studentName}');
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
//         builder: (context, extra1, child) {
//           var xtra1 = extra1.values.toList();

//           return ValueListenableBuilder<Box<StudentModelP4>>(
//               valueListenable: HiveBloCStudentModelP4.getStudent().listenable(),
//               builder: (context, studentsnap, child) {
//                 var listStudent = List.generate(studentsnap.length, ((index) {
//                   var data = studentsnap.getAt(index)!;
//                   return data;
//                 }));

//                 return ElevatedButton.icon(
//                   label: const Text('Import Excel 4 Subjects'),
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

//                           if (kDebugMode) {
//                             print('HAAAAAAAAAAAAAAAAAA $list2');
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
//                           ];

//                           // 2ND TERM

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
//                           var list37 =
//                               row.asMap().values.elementAt(36)!.props.first;
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

//                           if (list25 == 'x') {
//                             list25 = -1.0;
//                           }
//                           if (list26 == 'x') {
//                             list26 = -1.0;
//                           }
//                           if (list27 == 'x') {
//                             list27 = -1.0;
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
//                           if (list35 == 'x') {
//                             list35 = -1.0;
//                           }
//                           if (list36 == 'x') {
//                             list36 = -1.0;
//                           }
//                           if (list37 == 'x') {
//                             list37 = -1.0;
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

//                           var subListTerm2 = [
//                             P4SubjectsTerm2(
//                               subjectName: list23.toString(),
//                               teacher: list24.toString(),
//                               scoreBOT: double.parse(list25.toString()),
//                               scoreMT: double.parse(list26.toString()),
//                               scoreEOT: double.parse(list27.toString()),
//                             ),
//                             P4SubjectsTerm2(
//                               subjectName: list28.toString(),
//                               teacher: list29.toString(),
//                               scoreBOT: double.parse(list30.toString()),
//                               scoreMT: double.parse(list31.toString()),
//                               scoreEOT: double.parse(list32.toString()),
//                             ),
//                             P4SubjectsTerm2(
//                               subjectName: list33.toString(),
//                               teacher: list34.toString(),
//                               scoreBOT: double.parse(list35.toString()),
//                               scoreMT: double.parse(list36.toString()),
//                               scoreEOT: double.parse(list37.toString()),
//                             ),
//                             P4SubjectsTerm2(
//                               subjectName: list38.toString(),
//                               teacher: list39.toString(),
//                               scoreBOT: double.parse(list40.toString()),
//                               scoreMT: double.parse(list41.toString()),
//                               scoreEOT: double.parse(list42.toString()),
//                             ),
//                           ];

//                           // 3RD TERM

//                           var list44 =
//                               row.asMap().values.elementAt(44)!.props.first;
//                           var list45 =
//                               row.asMap().values.elementAt(45)!.props.first;
//                           var list46 =
//                               row.asMap().values.elementAt(46)!.props.first;
//                           var list47 =
//                               row.asMap().values.elementAt(47)!.props.first;
//                           var list48 =
//                               row.asMap().values.elementAt(48)!.props.first;
//                           var list49 =
//                               row.asMap().values.elementAt(49)!.props.first;
//                           var list50 =
//                               row.asMap().values.elementAt(50)!.props.first;
//                           var list51 =
//                               row.asMap().values.elementAt(51)!.props.first;

//                           var list52 =
//                               row.asMap().values.elementAt(52)!.props.first;
//                           var list53 =
//                               row.asMap().values.elementAt(53)!.props.first;

//                           var list54 =
//                               row.asMap().values.elementAt(54)!.props.first;
//                           var list55 =
//                               row.asMap().values.elementAt(55)!.props.first;
//                           var list56 =
//                               row.asMap().values.elementAt(56)!.props.first;
//                           var list57 =
//                               row.asMap().values.elementAt(57)!.props.first;
//                           var list58 =
//                               row.asMap().values.elementAt(58)!.props.first;
//                           var list59 =
//                               row.asMap().values.elementAt(59)!.props.first;
//                           var list60 =
//                               row.asMap().values.elementAt(60)!.props.first;
//                           var list61 =
//                               row.asMap().values.elementAt(61)!.props.first;
//                           var list62 =
//                               row.asMap().values.elementAt(62)!.props.first;
//                           var list63 =
//                               row.asMap().values.elementAt(63)!.props.first;

//                           if (list46 == 'x') {
//                             list46 = -1.0;
//                           }
//                           if (list47 == 'x') {
//                             list47 = -1.0;
//                           }
//                           if (list48 == 'x') {
//                             list48 = -1.0;
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
//                           if (list56 == 'x') {
//                             list56 = -1.0;
//                           }
//                           if (list57 == 'x') {
//                             list57 = -1.0;
//                           }
//                           if (list58 == 'x') {
//                             list58 = -1.0;
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

//                           var subListTerm3 = [
//                             P4SubjectsTerm3(
//                               subjectName: list44.toString(),
//                               teacher: list45.toString(),
//                               scoreBOT: double.parse(list46.toString()),
//                               scoreMT: double.parse(list47.toString()),
//                               scoreEOT: double.parse(list48.toString()),
//                             ),
//                             P4SubjectsTerm3(
//                               subjectName: list49.toString(),
//                               teacher: list50.toString(),
//                               scoreBOT: double.parse(list51.toString()),
//                               scoreMT: double.parse(list52.toString()),
//                               scoreEOT: double.parse(list53.toString()),
//                             ),
//                             P4SubjectsTerm3(
//                               subjectName: list54.toString(),
//                               teacher: list55.toString(),
//                               scoreBOT: double.parse(list56.toString()),
//                               scoreMT: double.parse(list57.toString()),
//                               scoreEOT: double.parse(list58.toString()),
//                             ),
//                             P4SubjectsTerm3(
//                               subjectName: list59.toString(),
//                               teacher: list60.toString(),
//                               scoreBOT: double.parse(list61.toString()),
//                               scoreMT: double.parse(list62.toString()),
//                               scoreEOT: double.parse(list63.toString()),
//                             ),
//                           ];
//                           //

//                           if (listStudent.isEmpty) {
//                             saveStudentName(
//                               StudentModelP4(
//                                 extraSub: xtra1,
//                                 studentName: list.toString(),
//                                 classIn: 'P4',
//                                 contactNumber: 'Contact not given',
//                                 stream: 'A',
//                                 subjectsScore: subList,
//                                 subjectsScoreTerm2: subListTerm2,
//                                 subjectsScoreTerm3: subListTerm3,
//                                 image: 'null',
//                                 address: 'Address not given',
//                                 birthDate: 'Birth date not given',
//                                 nationality: 'Nationality not given',
//                                 emis: 'Emis not given',
//                                 idNin: 'Id nin not given',
//                                 id: 0,
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
//                                   amountOwedTerm1: value.amountOwedTerm1,
//                                   amountOwedTerm2: value.amountOwedTerm2,
//                                   amountOwedTerm3: value.amountOwedTerm3,
//                                   amountTerm1: value.amountTerm1,
//                                   amountTerm2: value.amountTerm2,
//                                   amountTerm3: value.amountTerm3,
//                                   nextofKinName: value.nextofKinName,
//                                   yearAdmin: value.yearAdmin,
//                                   termAdmin: value.termAdmin,
//                                   nextofKincontactNumberWhatsApp:
//                                       value.nextofKincontactNumberWhatsApp,
//                                   nextofKinid: value.nextofKinName,
//                                   nextofKinidEmail: value.nextofKinidEmail,
//                                   extraSub: value.extraSub,
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
//                             if (kDebugMode) {
//                               print('SETT: ___ finalData');
//                             }
//                             saveStudentName(
//                               StudentModelP4(
//                                 extraSub: xtra1,
//                                 studentName: list.toString(),
//                                 classIn: 'P4',
//                                 contactNumber: 'Contact not given',
//                                 stream: 'A',
//                                 subjectsScore: subList,
//                                 subjectsScoreTerm2: subListTerm2,
//                                 subjectsScoreTerm3: subListTerm3,
//                                 image: 'null',
//                                 address: 'Address not given',
//                                 birthDate: 'Birth date not given',
//                                 nationality: 'Nationality not given',
//                                 emis: 'Emis not given',
//                                 idNin: 'Id nin not given',
//                                 id: 0,
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
//                         }
//                       }
//                     } else {
//                       if (kDebugMode) {
//                         print('NULLLLLLLLLLLLLLL');
//                       }
//                     }
//                   },
//                 );
//               });
//         });
//   }
// }
