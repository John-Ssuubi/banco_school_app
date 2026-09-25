// lib/utils/web_url_helper.dart
//
// Stub implementation used on NON-WEB platforms (Android, iOS, desktop).
// This file MUST NOT import 'dart:html' or reference any web-only APIs.
//
// On web, the conditional import in main.dart swaps this file out for
// `web_url_helper_web.dart`, which does the real work.

/// Returns the `schoolId` query parameter from the current URL.
///
/// On non-web platforms there is no browser URL, so this always returns null.
String? getSchoolIdFromUrl() => null;