import 'package:hive/hive.dart';
part 'extra_sub_p4.g.dart';

@HiveType(typeId: 72)
class ExtraSubP4 extends HiveObject {
  @HiveField(0)
  String? subjectName;

  ExtraSubP4({
    this.subjectName,
  });

  Map<String, dynamic> toMap() {
    return {
      'subjectName': subjectName,
    };
  }

  @override
  String toString() {
    return 'ExtraSubP4(subjectName: $subjectName)';
  }
   factory ExtraSubP4.fromJson(Map<String, dynamic> json) => ExtraSubP4(
    subjectName: json['subjectName'],
    );
}

class HiveBloCExtraSubP4 {
  String boxName = 'extraSubp4';

  Future<Box> openBox() async {
    Box box = await Hive.openBox<ExtraSubP4>(boxName);
    return box;
  }

  static Box<ExtraSubP4> getSubjectScore() =>
      Hive.box<ExtraSubP4>('extraSubp4');

  addSchoolName(ExtraSubP4 extraSubp4) {}

  updateSchoolName(ExtraSubP4 extraSubp4) {}

  deleteSchoolName(ExtraSubP4 extraSubp4) {}

  deleteAllSchoolName(ExtraSubP4 extraSubp4) {}
}
