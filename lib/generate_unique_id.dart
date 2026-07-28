import 'dart:math';
String generateUniqueStudentId(String className, Set<dynamic> existingIds)  {

  String newId;
  final random = Random();

  do {
    // Example format: P4-2025-XYZ123
    final randomPart = random.nextInt(999999).toString().padLeft(6, '0');
    newId = '$className$randomPart';
  } while (existingIds.contains(newId));

  return newId;
}
