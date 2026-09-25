// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_config.dart';
import 'isapi_candidate.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.onSaved});
  final VoidCallback? onSaved;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _ip;
  late final TextEditingController _user;
  late final TextEditingController _pass;
  late final TextEditingController _school;
  late final TextEditingController _poll;
  late final TextEditingController _lateH;
  late final TextEditingController _lateM;

  bool _saving = false;
  bool _testing = false;
  bool _loadingSchool = false;

  String? _testResult;
  bool _testOk = false;

  String _resolvedSchoolName = '';

  @override
  void initState() {
    super.initState();
    final c = AppConfig.instance;
    _ip     = TextEditingController(text: c.deviceIp);
    _user   = TextEditingController(text: c.username);
    _pass   = TextEditingController(text: c.password);
    _school = TextEditingController(text: c.schoolId);
    _poll   = TextEditingController(text: c.pollSeconds.toString());
    _lateH  = TextEditingController(text: c.lateHour.toString());
    _lateM  = TextEditingController(text: c.lateMinute.toString());
    _resolvedSchoolName = c.schoolName;
  }

  @override
  void dispose() {
    for (final c in [_ip, _user, _pass, _school, _poll, _lateH, _lateM]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Loads the biometric config for the schoolId in the form. Fills the
  /// form with whatever Firestore has (or seeds defaults if empty).
  Future<void> _loadSchool() async {
    final sid = _school.text.trim();
    if (sid.isEmpty) {
      setState(() {
        _testOk = false;
        _testResult = '❌ Enter a School ID first';
      });
      return;
    }

    setState(() => _loadingSchool = true);
    try {
      final cfg = await AppConfig.load(schoolId: sid);
      if (!mounted) return;
      setState(() {
        _ip.text     = cfg.deviceIp;
        _user.text   = cfg.username;
        _pass.text   = cfg.password;
        _poll.text   = cfg.pollSeconds.toString();
        _lateH.text  = cfg.lateHour.toString();
        _lateM.text  = cfg.lateMinute.toString();
        _resolvedSchoolName = cfg.schoolName;
        _testOk = true;
        _testResult = '✅ Loaded school "${cfg.schoolName}"';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testOk = false;
        _resolvedSchoolName = '';
        _testResult = '❌ $e';
      });
    } finally {
      if (mounted) setState(() => _loadingSchool = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final c = AppConfig.instance
      ..deviceIp    = _ip.text.trim()
      ..username    = _user.text.trim()
      ..password    = _pass.text
      ..schoolId    = _school.text.trim()
      ..pollSeconds = int.parse(_poll.text.trim())
      ..lateHour    = int.parse(_lateH.text.trim())
      ..lateMinute  = int.parse(_lateM.text.trim());

    try {
      await c.save();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          'Saved to Schools/${c.schoolId}/biometric/config',
        )),
      );
      widget.onSaved?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _testDevice() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });

    final client = IsapiClient(
      ip:   _ip.text.trim(),
      user: _user.text.trim(),
      pass: _pass.text,
    );
    final ok = await client.testConnection();

    if (!mounted) return;
    setState(() {
      _testing = false;
      _testOk = ok;
      _testResult = ok
          ? '✅ Device reachable at ${_ip.text.trim()}'
          : '❌ Unreachable (or CORS blocked) at ${_ip.text.trim()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // -------------------- School --------------------
                _section('School'),
                Row(children: [
                  Expanded(
                    child: _text(_school, 'School ID',
                        hint: 'St.Savio Junior School Kisubi_Kisubi',
                        validator: _required),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: OutlinedButton.icon(
                      onPressed: _loadingSchool ? null : _loadSchool,
                      icon: _loadingSchool
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cloud_download),
                      label: const Text('Load'),
                    ),
                  ),
                ]),
                if (_resolvedSchoolName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text('School: $_resolvedSchoolName',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Config saved to:\nSchools/{schoolId}/biometric/config',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),

                const SizedBox(height: 24),

                // -------------------- Device --------------------
                _section('Device'),
                _text(_ip,   'Device IP',
                    hint: '192.168.1.203', validator: _required),
                _text(_user, 'Username', validator: _required),
                _text(_pass, 'Password', obscure: true, validator: _required),

                const SizedBox(height: 24),

                // -------------------- Behaviour --------------------
                _section('Behaviour'),
                _number(_poll, 'Poll interval (seconds)', min: 5, max: 600),
                Row(children: [
                  Expanded(child: _number(_lateH, 'Late hour (0-23)',
                      min: 0, max: 23)),
                  const SizedBox(width: 12),
                  Expanded(child: _number(_lateM, 'Late minute (0-59)',
                      min: 0, max: 59)),
                ]),

                const SizedBox(height: 32),

                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _testing ? null : _testDevice,
                      icon: _testing
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.wifi_tethering),
                      label: const Text('Test Device'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: const Text('Save to Firestore'),
                    ),
                  ),
                ]),

                if (_testResult != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _testOk
                          ? Colors.green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_testResult!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- helpers ----------

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _text(
    TextEditingController c,
    String label, {
    String? hint,
    bool obscure = false,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          controller: c,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          validator: validator,
        ),
      );

  Widget _number(
    TextEditingController c,
    String label, {
    required int min,
    required int max,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          controller: c,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: (v) {
            final n = int.tryParse((v ?? '').trim());
            if (n == null) return 'Enter a number';
            if (n < min || n > max) return 'Must be $min–$max';
            return null;
          },
        ),
      );

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}