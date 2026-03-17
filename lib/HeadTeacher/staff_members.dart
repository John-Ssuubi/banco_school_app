class StaffMember {
  final String firstName;
  final String secondName;
  final String phone;
  final String role;

  StaffMember({
    required this.firstName,
    required this.secondName,
    required this.phone,
    required this.role,
  });

  factory StaffMember.fromMap(Map<String, dynamic> data) {
    return StaffMember(
      firstName: data['firstName'] ?? '',
      secondName: data['secondName'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? '',
    );
  }
}

class LinkedParent {
  final String parentName;
 
  final String fcmToken;

  LinkedParent({
    required this.parentName,
    required this.fcmToken,
  });

  factory LinkedParent.fromMap(Map<String, dynamic> data) {
    return LinkedParent(
      parentName: data['firstName'] ?? '',
     
      fcmToken: data['fcmToken'] ?? '',
    );
  }
}

