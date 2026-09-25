import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppConfig {
  // ---- Device ----
  String deviceIp;
  String username;
  String password;

  // ---- Firestore ----
  String schoolId;      // e.g. 'St.Savio Junior School Kisubi_Kisubi'
  String schoolName;    // read-only, pulled from the school doc

  // ---- Behaviour ----
  int pollSeconds;
  int lateHour;
  int lateMinute;

  AppConfig({
    this.deviceIp     = '192.168.100.151',
    this.username     = 'admin',
    this.password     = 'stsavio123456789',
    this.schoolId     = 'St.Savio Junior School Kisubi_Kisubi',
    this.schoolName   = '',
    this.pollSeconds  = 15,
    this.lateHour     = 8,
    this.lateMinute   = 30,
  });

  // ---------------- Singleton ----------------
  static AppConfig _instance = AppConfig();
  static AppConfig get instance => _instance;

  static final StreamController<AppConfig> _changes =
      StreamController<AppConfig>.broadcast();
  static Stream<AppConfig> get changes => _changes.stream;

  // ---------------- Firestore paths ----------------
  //
  // School doc:      Schools/{schoolId}
  // Biometric config: Schools/{schoolId}/biometric/config
  //
  static DocumentReference<Map<String, dynamic>> _schoolDoc(String schoolId) =>
      FirebaseFirestore.instance.collection('Schools').doc(schoolId);

  static DocumentReference<Map<String, dynamic>> _bioDoc(String schoolId) =>
      _schoolDoc(schoolId).collection('biometric').doc('config');

  // ---------------- Load ----------------
  /// Loads config for the given [schoolId] (or the currently-saved one).
  ///
  /// 1. Verifies the school doc exists.
  /// 2. Reads `Schools/{schoolId}/biometric/config`.
  /// 3. If missing, seeds it with defaults.
  static Future<AppConfig> load({String? schoolId}) async {
    final sid = (schoolId ?? _instance.schoolId).trim();
    if (sid.isEmpty) {
      throw Exception('schoolId is empty — set it in Settings');
    }

    try {
      // 1. Confirm school exists
      final schoolSnap = await _schoolDoc(sid).get();
      if (!schoolSnap.exists) {
        throw Exception('School not found: Schools/$sid');
      }
      final schoolData = schoolSnap.data() ?? {};
      final schoolName = (schoolData['school_name'] ?? sid).toString();

      // 2. Read biometric config
      final bioSnap = await _bioDoc(sid).get();

      if (!bioSnap.exists || bioSnap.data() == null) {
        // First run — seed with defaults, using the school's late threshold
        // if the school doc has one. (Your doc doesn't have a "lateHour"
        // field, so we just use the current defaults.)
        _instance = AppConfig(
          schoolId:   sid,
          schoolName: schoolName,
        );
        await _bioDoc(sid).set(_instance._toMap());
        _changes.add(_instance);
        return _instance;
      }

      _instance = AppConfig._fromMap(
        bioSnap.data()!,
        schoolId:   sid,
        schoolName: schoolName,
      );
      _changes.add(_instance);
      return _instance;
    } catch (e) {
      // Offline / rules denial / school missing — keep in-memory defaults.
      rethrow;
    }
  }

  /// Save the current in-memory config back to Firestore under the
  /// currently-set schoolId.
  Future<void> save() async {
    final sid = schoolId.trim();
    if (sid.isEmpty) throw Exception('schoolId is empty');
    await _bioDoc(sid).set(_toMap(), SetOptions(merge: true));
    _changes.add(_instance);
  }

  /// Live updates if another device edits the config.
  static Stream<AppConfig> watch() {
    // Re-watch whenever the schoolId changes.
    return _changes.stream
        .startWith(_instance)
        .asyncExpand((cfg) => _bioDoc(cfg.schoolId).snapshots().map((snap) {
              if (snap.exists && snap.data() != null) {
                _instance = AppConfig._fromMap(
                  snap.data()!,
                  schoolId:   cfg.schoolId,
                  schoolName: cfg.schoolName,
                );
              }
              return _instance;
            }));
  }

  // ---------------- Serialisation ----------------
  Map<String, dynamic> _toMap() => {
        'deviceIp':    deviceIp,
        'username':    username,
        'password':    password,
        'pollSeconds': pollSeconds,
        'lateHour':    lateHour,
        'lateMinute':  lateMinute,
        // schoolId and schoolName are NOT stored in the biometric subdoc —
        // they're implied by the path / read from the parent school doc.
      };

  factory AppConfig._fromMap(
    Map<String, dynamic> m, {
    required String schoolId,
    required String schoolName,
  }) =>
      AppConfig(
        deviceIp:    (m['deviceIp']    ?? '192.168.1.203').toString(),
        username:    (m['username']    ?? 'admin').toString(),
        password:    (m['password']    ?? '').toString(),
        schoolId:    schoolId,
        schoolName:  schoolName,
        pollSeconds: (m['pollSeconds'] as num?)?.toInt() ?? 15,
        lateHour:    (m['lateHour']    as num?)?.toInt() ?? 8,
        lateMinute:  (m['lateMinute']  as num?)?.toInt() ?? 30,
      );

}

extension _StartWith<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}