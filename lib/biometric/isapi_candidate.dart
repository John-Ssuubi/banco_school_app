import 'dart:convert';
import 'dart:math';

import 'package:banco_mobile/biometric/attendance_event.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class IsapiClient {
  final String ip;
  final String user;
  final String pass;

  /// If true, verbose diagnostic output is printed to the console.
  /// Set to `kDebugMode` in production callers so release builds stay quiet.
  final bool verbose;

  late final Dio _dio;

  String? _realm;
  String? _nonce;
  String? _opaque;
  String? _qop;

  int _nonceCount = 0;

  IsapiClient({
    required this.ip,
    required this.user,
    required this.pass,
    this.verbose = false,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://$ip',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
        // Global defaults:
        //   * ResponseType.plain → don't JSON-decode Hikvision's XML
        //     bodies (fixes "FormatException at offset 0").
        //   * validateStatus   → let 4xx responses through so the
        //     digest challenge can be read.
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
      ),
    );
  }

  // -----------------------------------------------------------------
  // Developer logging
  // -----------------------------------------------------------------

  void _debug(String m) {
    if (verbose) {
      // ignore: avoid_print
      print('[IsapiClient] $m');
    }
  }

  // ============================================================
  // PUBLIC: TEST CONNECTION
  // ============================================================

  Future<bool> testConnection() async {
    try {
      final response = await _authenticatedRequest(
        method: 'POST',
        path: '/ISAPI/AccessControl/AcsEvent?format=json',
        data: {
          "AcsEventCond": {
            "searchID": "test-${DateTime.now().millisecondsSinceEpoch}",
            "searchResultPosition": 0,
            "maxResults": 30,
            "major": 5,
            "minor": 0,
            "startTime": "2024-01-01T00:00:00+03:00",
            "endTime": "2030-12-31T23:59:59+03:00",
            "timeReverseOrder": true,
          },
        },
      );

      _debug('testConnection status=${response.statusCode}');
      _debug('testConnection body=${response.data}');

      return response.statusCode == 200;
    } catch (e) {
      _debug('testConnection error: $e');
      return false;
    }
  }

  // ============================================================
  // PUBLIC: FETCH ATTENDANCE EVENTS
  // ============================================================

  Future<List<DeviceEvent>> fetchEvents({
    required String sinceIso,
    int maxResults = 30,
  }) async {
    final body = {
      "AcsEventCond": {
        "searchID": "banco-${DateTime.now().millisecondsSinceEpoch}",
        "searchResultPosition": 0,
        "maxResults": maxResults,
        "major": 5,
        "minor": 0,
        "startTime": sinceIso,
        "endTime": _iso(DateTime.now()),
        "timeReverseOrder": true,
      },
    };

    _debug('fetchEvents sinceIso=$sinceIso');

    final response = await _authenticatedRequest(
      method: 'POST',
      path: '/ISAPI/AccessControl/AcsEvent?format=json',
      data: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Hikvision returned HTTP ${response.statusCode}: ${response.data}',
      );
    }

    final data = response.data is String
        ? jsonDecode(response.data)
        : response.data;

    final infoList = (data['AcsEvent']?['InfoList'] ?? []) as List;

    return infoList
        .map(
          (e) => DeviceEvent(
            employeeNo: (e['employeeNoString'] ?? '').toString().trim(),
            timeIso: (e['time'] ?? '').toString(),
          ),
        )
        .where((e) => e.employeeNo.isNotEmpty)
        .toList();
  }

  // ============================================================
  // DIGEST AUTHENTICATION
  // ============================================================

  Future<Response> _authenticatedRequest({
    required String method,
    required String path,
    dynamic data,
  }) async {
    _debug('>>> _authenticatedRequest START: $method $path');

    // ----------------------------------------------------------
    // STEP 1 — unauthenticated request to obtain the challenge
    // ----------------------------------------------------------
    Response firstResponse;

    try {
      firstResponse = await _dio.request(
        path,
        data: data,
        options: Options(
          method: method,
          responseType: ResponseType.plain,
          validateStatus: (_) => true,
          contentType: method == 'POST' ? Headers.jsonContentType : null,
        ),
      );
      _debug('>>> first response status: ${firstResponse.statusCode}');
    } on DioException catch (e) {
      _debug(
        '>>> DioException in first request: '
        'type=${e.type}, msg=${e.message}, status=${e.response?.statusCode}',
      );
      if (e.response == null) rethrow;
      firstResponse = e.response!;
    }

    // Already authenticated (some devices cache session)
    if (firstResponse.statusCode == 200) {
      return firstResponse;
    }

    if (firstResponse.statusCode != 401) {
      throw Exception(
        'Hikvision returned HTTP ${firstResponse.statusCode}: '
        '${firstResponse.data}',
      );
    }

    // ----------------------------------------------------------
    // STEP 2 — read WWW-Authenticate challenge
    // ----------------------------------------------------------
    final challenge = firstResponse.headers.value('www-authenticate');

    if (challenge == null || challenge.isEmpty) {
      throw Exception(
        'Hikvision returned 401 but no WWW-Authenticate header.',
      );
    }

    _debug('HIKVISION DIGEST CHALLENGE: $challenge');
    _parseChallenge(challenge);

    // ----------------------------------------------------------
    // STEP 3 — build the Authorization header
    // ----------------------------------------------------------
    final authorization = _buildAuthorization(method: method, path: path);

    _debug('Sending Digest authorization...');

    // ----------------------------------------------------------
    // STEP 4 — send authenticated request
    // ----------------------------------------------------------
    final secondResponse = await _dio.request(
      path,
      data: data,
      options: Options(
        method: method,
        headers: {'Authorization': authorization},
        responseType: ResponseType.plain,
        validateStatus: (_) => true,
        contentType: method == 'POST' ? Headers.jsonContentType : null,
      ),
    );

    _debug('AUTHENTICATED STATUS: ${secondResponse.statusCode}');
    _debug('AUTHENTICATED BODY: ${secondResponse.data}');

    if (secondResponse.statusCode == 401) {
      _debug('AUTHENTICATION FAILED. Check username/password.');
    }

    return secondResponse;
  }

  // ============================================================
  // PARSE DIGEST CHALLENGE
  // ============================================================

  void _parseChallenge(String header) {
    final value =
        header.startsWith('Digest ') ? header.substring(7) : header;

    final values = <String, String>{};
    final regex = RegExp(r'''(\w+)\s*=\s*(?:"([^"]*)"|([^,\s]+))''');

    for (final match in regex.allMatches(value)) {
      final key = match.group(1)!;
      final parsed = match.group(2) ?? match.group(3) ?? '';
      values[key] = parsed;
    }

    _realm = values['realm'];
    _nonce = values['nonce'];
    _opaque = values['opaque'];

    // qop may come as `auth` or `auth,auth-int` — pick `auth`.
    final rawQop = values['qop'];
    _qop = rawQop?.split(',')
            .map((s) => s.trim())
            .firstWhere((s) => s == 'auth', orElse: () => 'auth');

    if (_realm == null || _nonce == null) {
      throw Exception('Invalid Hikvision Digest challenge: $header');
    }

    _nonceCount = 0;

    _debug('DIGEST REALM: $_realm');
    _debug('DIGEST QOP: $_qop');
  }

  // ============================================================
  // BUILD AUTHORIZATION
  // ============================================================

  String _buildAuthorization({required String method, required String path}) {
    final realm = _realm!;
    final nonce = _nonce!;
    final qop   = _qop ?? 'auth';

    _nonceCount++;
    final nc     = _nonceCount.toRadixString(16).padLeft(8, '0');
    final cnonce = _generateCnonce();

    // HA1 = MD5(username:realm:password)
    final ha1 = _md5('$user:$realm:$pass');

    // HA2 = MD5(method:uri)
    final ha2 = _md5('$method:$path');

    // response = MD5(HA1:nonce:nc:cnonce:qop:HA2)
    final response = _md5('$ha1:$nonce:$nc:$cnonce:$qop:$ha2');

    final buffer = StringBuffer();
    buffer.write('Digest ');
    buffer.write('username="$user"');
    buffer.write(', realm="$realm"');
    buffer.write(', nonce="$nonce"');
    buffer.write(', uri="$path"');
    buffer.write(', qop=$qop');
    buffer.write(', nc=$nc');
    buffer.write(', cnonce="$cnonce"');
    buffer.write(', response="$response"');

    if (_opaque != null && _opaque!.isNotEmpty) {
      buffer.write(', opaque="$_opaque"');
    }

    return buffer.toString();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _md5(String value) => md5.convert(utf8.encode(value)).toString();

  String _generateCnonce() {
    final random = Random.secure();
    final bytes  = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Hikvision-compatible ISO timestamp with a dynamic offset:
  ///   2026-09-17T05:03:31+03:00
  String _iso(DateTime d) {
    final off  = d.timeZoneOffset;
    final sign = off.isNegative ? '-' : '+';
    final h    = off.inHours.abs().toString().padLeft(2, '0');
    final m    = (off.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-'
           '${d.month.toString().padLeft(2, '0')}-'
           '${d.day.toString().padLeft(2, '0')}T'
           '${d.hour.toString().padLeft(2, '0')}:'
           '${d.minute.toString().padLeft(2, '0')}:'
           '${d.second.toString().padLeft(2, '0')}'
           '$sign$h:$m';
  }
}