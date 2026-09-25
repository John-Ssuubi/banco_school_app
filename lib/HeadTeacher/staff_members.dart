class StaffMember {
  final String firstName;
  final String secondName;
  final String phone;
  final String role;
  final String uid;
  final String? email; // Optional email field

  StaffMember({
    required this.uid,
    required this.firstName,
    required this.secondName,
    required this.phone,
    required this.role,
    this.email,
  });

  factory StaffMember.fromMap(Map<String, dynamic> data) {
    return StaffMember(
      firstName: data['firstName'] ?? '',
      secondName: data['secondName'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
      uid: data['teacherUid'],
      email: data['email'],
    );
  }
}

class LinkedParent {
  // final String parentName;
  final String parentUid;
  final String fcmToken;
  final String phone;
  final String email;
  final String firstName;
  final String secondName;

  LinkedParent({
    // required this.parentName,
    required this.parentUid,
    required this.phone,
    required this.email,
    required this.firstName,
    required this.secondName,
    required this.fcmToken,
  });

  factory LinkedParent.fromMap(Map<String, dynamic> data) {
    return LinkedParent(
     
    
      parentUid: data['parentUid'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      secondName: data['secondName'] ?? '',
      fcmToken: data['fcmToken'] ?? '',
    );
  }
}
