// lib/utils/web_url_helper_web.dart
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

String? getSchoolIdFromUrl() {
  try {
    final uri = Uri.parse(html.window.location.href);
    final rawSchoolId = uri.queryParameters['schoolId'];
    if (rawSchoolId != null && rawSchoolId.isNotEmpty) {
      return Uri.decodeComponent(rawSchoolId);
    }
  } catch (_) {}
  return null;
}