import 'dart:async';

import 'package:banco_mobile/biometric/app_config.dart';
import 'package:banco_mobile/biometric/attendance_event.dart';
import 'package:banco_mobile/biometric/isapi_candidate.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'firebase_service.dart';

/// Outcome of handling a single device event.
enum _EventResult {
  saved,        // written to Firestore
  duplicate,    // already marked present today
  unregistered, // employeeNo is neither staff nor student
  failed,       // transient failure — will be retried next poll
}

class AttendanceEngine {
  final FirebaseService _fb = FirebaseService();

  /// Built in start() (not as a field initializer) so it always picks up the
  /// CURRENT AppConfig values (IP / user / password), even if the config was
  /// loaded or changed after this engine object was constructed.
  late IsapiClient _isapi;

  /// Hard cap on how long a single device request may take. Without this, a
  /// request to an unreachable device can hang forever, _isPolling stays
  /// true, and every later poll is skipped — so the engine never notices
  /// when the device comes back.
  static const Duration _requestTimeout = Duration(seconds: 8);

  Timer? _pollTimer;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  String _lastEventTime = _startOfToday();

  final _logController = StreamController<String>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  final _countController = StreamController<int>.broadcast();

  Stream<String> get logs   => _logController.stream;
  Stream<String> get status => _statusController.stream;
  Stream<int>    get count  => _countController.stream;

  int _seenToday = 0;
  String _currentDay = _dateKey(DateTime.now());

  bool _running = false;
  bool _isPolling = false; // re-entrancy guard: avoid overlapping polls
  bool _disposed = false;

  /// Tracks whether the last poll reached the device. Used to detect the
  /// offline → online transition so we can announce it and catch up.
  /// null = unknown (nothing polled yet).
  bool? _deviceOnline;

  // In-memory dedupe within the session; Firestore doc ID handles the rest.
  final Set<String> _sessionSeen = {};

  // -----------------------------------------------------------------
  // Time helpers
  // -----------------------------------------------------------------

  /// Hikvision-compatible ISO timestamp:
  ///   2026-09-17T05:03:31+03:00
  /// No milliseconds, no 'Z', explicit offset with colon.
  static String _hikIso(DateTime d) {
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

  static String _startOfToday() {
    final n = DateTime.now();
    return _hikIso(DateTime(n.year, n.month, n.day, 0, 0, 0));
  }

  static String _p(int x) => x.toString().padLeft(2, '0');

  static String _dateKey(DateTime d) =>
      '${d.year}-${_p(d.month)}-${_p(d.day)}';

  static String _timeKey(DateTime d) =>
      '${_p(d.hour)}:${_p(d.minute)}:${_p(d.second)}';

  /// Short "HH:mm" label for a Hikvision ISO string, for client messages.
  static String _friendlyTime(String iso) {
    final t = DateTime.tryParse(iso)?.toLocal();
    if (t == null) return iso;
    return '${_p(t.hour)}:${_p(t.minute)}';
  }

  // -----------------------------------------------------------------
  // Logging: two channels
  //   _log   → stream shown to the client (short, human-readable)
  //   _debug → console only (developer detail)
  // -----------------------------------------------------------------

  void _log(String m) {
    if (!_disposed) _logController.add(m);
  }

  /// Developer-only detail. Goes to console, never to the client stream.
  void _debug(String m) {
    // ignore: avoid_print
    print('[AttendanceEngine] $m');
  }

  void _status(String m) {
    if (!_disposed) _statusController.add(m);
  }

  void _count(int c) {
    if (!_disposed) _countController.add(c);
  }

  // -----------------------------------------------------------------
  // Device connection state
  // -----------------------------------------------------------------

  void _markDeviceOnline() {
    if (_deviceOnline == true) return;
    final wasOffline = _deviceOnline == false;
    _deviceOnline = true;
    if (wasOffline) {
      // Log once on reconnect instead of on every poll.
      _log('🔌 Device reconnected — catching up on events since '
          '${_friendlyTime(_lastEventTime)}');
    } else {
      _log('🔌 Device connected');
    }
  }

  void _markDeviceOffline(String reason) {
    if (_deviceOnline == false) return; // already reported; don't spam
    _deviceOnline = false;
    _status('Waiting for device…');
    _log('⚠ $reason — will keep retrying');
  }

  // -----------------------------------------------------------------
  // Lifecycle
  // -----------------------------------------------------------------

  Future<void> start() async {
    if (_running) return;
    _running = true;

    _isapi = IsapiClient(
      ip: AppConfig.instance.deviceIp,
      user: AppConfig.instance.username,
      pass: AppConfig.instance.password,
      verbose: kDebugMode,
    );

    _status('Connecting to device…');
    _log('🔍 Looking for attendance device…');

    _pollTimer = Timer.periodic(
      Duration(seconds: AppConfig.instance.pollSeconds),
      (_) => _pollDevice(),
    );

    // When the phone/tablet (re)joins a network — e.g. it connects to the
    // same Wi‑Fi as the scanner — poll immediately instead of waiting for
    // the next timer tick.
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      if (!_running) return;
      if (results.contains(ConnectivityResult.none)) return;
      _debug('Network changed ($results) — polling now');
      unawaited(_pollDevice());
    });

    unawaited(_pollDevice());
  }

  void stop() {
    _running = false;
    _pollTimer?.cancel();
    _pollTimer = null;
    _connSub?.cancel();
    _connSub = null;
    _status('Stopped');
  }

  void _maybeRollOverDay() {
    final today = _dateKey(DateTime.now());
    if (today != _currentDay) {
      _currentDay = today;
      _seenToday = 0;
      _sessionSeen.clear();
      _count(_seenToday);
      _log('🌅 New day — counters reset');
    }
  }

  // -----------------------------------------------------------------
  // Polling
  // -----------------------------------------------------------------

  String _keyFor(DeviceEvent e) {
    final t = DateTime.tryParse(e.timeIso)?.toLocal() ?? DateTime.now();
    return '${e.employeeNo}_${_dateKey(t)}';
  }

  Future<void> _pollDevice() async {
    if (!_running || _disposed) return;

    if (_isPolling) {
      // Previous poll hasn't finished — skip this tick rather than
      // race on _lastEventTime.
      return;
    }
    _isPolling = true;

    try {
      // Device is on the LAN, so we need *some* connectivity for the
      // HTTP call to work even though Firestore queues writes offline.
      final conn = await Connectivity().checkConnectivity();
      if (conn.contains(ConnectivityResult.none)) {
        _markDeviceOffline('No network');
        _debug('Connectivity: none — skipping poll');
        return;
      }

      _maybeRollOverDay();

      // Only announce "checking…" on the first poll and after a
      // reconnect; routine polls stay quiet in the log.
      if (_deviceOnline != true) {
        _status('Checking device for events…');
      }

      List<DeviceEvent> events;
      try {
        // Timeout so an unreachable device can't wedge the poll loop.
        // _lastEventTime only moves forward after a successful batch, so
        // everything that happened while the device was unreachable is
        // fetched on the first successful poll after it reconnects.
        events = await _isapi
            .fetchEvents(sinceIso: _lastEventTime)
            .timeout(_requestTimeout);
      } catch (err, stack) {
        _debug('❌ Device request failed: $err\n$stack');
        _markDeviceOffline('Could not reach attendance device');
        return;
      }

      // We got an answer from the device → it's online.
      _markDeviceOnline();

      // Newest event time in this batch. Do NOT assume ordering — some
      // devices return oldest-first.
      DateTime? newest;
      for (final e in events) {
        if (e.timeIso.isEmpty) continue;
        final t = DateTime.tryParse(e.timeIso);
        if (t != null && (newest == null || t.isAfter(newest))) {
          newest = t;
        }
      }

      // The device query is inclusive, so the last event we already
      // handled usually comes back again. Drop those so the client only
      // hears about genuinely new events.
      final fresh =
          events.where((e) => !_sessionSeen.contains(_keyFor(e))).toList();

      if (fresh.isEmpty) {
        _debug('Poll OK — no new events since $_lastEventTime');
        if (newest != null) _lastEventTime = _hikIso(newest.toLocal());
        _status('Running — last checked ${_timeKey(DateTime.now())}, '
            'no new events');
        return;
      }

      final total = fresh.length;
      _debug('Poll OK — ${events.length} event(s), $total new, '
          'since $_lastEventTime');

      if (total > 1) {
        _log('📥 Found $total new events — processing…');
      }

      // Handle every event, tallying outcomes for the summary.
      var saved = 0, duplicate = 0, unregistered = 0, failed = 0;
      for (var i = 0; i < total; i++) {
        if (total > 1) _status('Syncing ${i + 1} of $total…');

        final prefix = total > 1 ? '(${i + 1}/$total) ' : '';
        final result = await _handleEvent(fresh[i], prefix: prefix);

        switch (result) {
          case _EventResult.saved:        saved++;        break;
          case _EventResult.duplicate:    duplicate++;    break;
          case _EventResult.unregistered: unregistered++; break;
          case _EventResult.failed:       failed++;       break;
        }
      }

      // Summary line for batches (single events already got their own line).
      if (total > 1 || failed > 0) {
        final parts = <String>[
          if (saved > 0)        '$saved saved',
          if (duplicate > 0)    '$duplicate already present',
          if (unregistered > 0) '$unregistered not registered',
          if (failed > 0)       '$failed failed',
        ];
        final icon = failed > 0 ? '⚠' : '✅';
        _log('$icon Sync finished: ${parts.join(', ')}');
      }

      // Only advance the pointer when the whole batch was processed.
      // If something failed, we re-fetch the same window next poll;
      // already-saved events are skipped by _sessionSeen / Firestore's
      // "already present" check, so nothing gets duplicated or lost.
      if (failed == 0) {
        if (newest != null) {
          _lastEventTime = _hikIso(newest.toLocal());
          _debug('Advanced _lastEventTime → $_lastEventTime');
        }
        _status('Running — last synced ${_timeKey(DateTime.now())}');
      } else {
        _debug('$failed event(s) failed — keeping '
            '_lastEventTime=$_lastEventTime');
        _status('Running — $failed event(s) will be retried');
        _log('🔁 Will retry $failed event(s) on the next check');
      }
    } finally {
      _isPolling = false;
    }
  }

  // -----------------------------------------------------------------
  // Event handling
  // -----------------------------------------------------------------

  Future<_EventResult> _handleEvent(DeviceEvent e,
      {String prefix = ''}) async {
    // Use the event's own timestamp, not poll time — a poll can run
    // late and offline-queued device events can arrive well after they
    // happened.
    final eventTime = DateTime.tryParse(e.timeIso)?.toLocal() ?? DateTime.now();
    final date = _dateKey(eventTime);
    final time = _timeKey(eventTime);

    // Session-level dedupe (fast path)
    final key = '${e.employeeNo}_$date';
    if (_sessionSeen.contains(key)) return _EventResult.duplicate;

    // -----------------------------------------------------------------
    // Identify user type (Firestore read)
    // -----------------------------------------------------------------
    String type = 'unknown';
    try {
      final t = await _fb.identifyUserType(e.employeeNo);
      if (t != null) type = t;
    } catch (err, stack) {
      // NOTE: key is NOT in _sessionSeen yet, so this will be retried.
      _debug('⚠ Lookup failed for ${e.employeeNo}: $err\n$stack');
      _log('$prefix⚠ Could not identify ${e.employeeNo}');
      return _EventResult.failed;
    }

    // -----------------------------------------------------------------
    // Persist to Firestore (idempotent by doc ID)
    // -----------------------------------------------------------------
    String? error;
    if (type == 'staff') {
      error = await _fb.saveStaff(e.employeeNo, date, time);
    } else if (type == 'student') {
      error = await _fb.saveStudent(e.employeeNo, date, time);
    } else {
      error = 'unknown user type';
    }

    if (error == null) {
      _sessionSeen.add(key);
      _seenToday++;
      _count(_seenToday);
      _log('$prefix☁ ${e.employeeNo} ($type) → Firestore');
      _debug('Saved ${e.employeeNo} ($type) for $date $time');
      return _EventResult.saved;
    } else if (error == 'already present') {
      _sessionSeen.add(key);
      _log('$prefix⏭ ${e.employeeNo} already present today');
      return _EventResult.duplicate;
    } else if (error == 'unknown user type') {
      // Permanent outcome — retrying won't help.
      _sessionSeen.add(key);
      _log('$prefix✗ ${e.employeeNo} — not registered as staff or student');
      _debug('Unknown user type for ${e.employeeNo}');
      return _EventResult.unregistered;
    } else {
      // Transient save failure — leave out of _sessionSeen so it retries.
      _debug('✗ Save failed for ${e.employeeNo}: $error');
      _log('$prefix✗ ${e.employeeNo} — could not save record');
      return _EventResult.failed;
    }
  }

  // -----------------------------------------------------------------
  // Disposal
  // -----------------------------------------------------------------

  void dispose() {
    stop();
    _disposed = true;
    _logController.close();
    _statusController.close();
    _countController.close();
  }
}