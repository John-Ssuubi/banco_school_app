import 'package:flutter/material.dart';
import 'app_config.dart';
import 'attendance_engine.dart';
import 'isapi_candidate.dart';
import 'settings_page.dart';

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2C3E50),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final engine = AttendanceEngine();
  final logs = <String>[];
  String status = 'Idle';
  int count = 0;
  bool running = false;

  @override
  void initState() {
    super.initState();
    engine.logs.listen((m) => setState(() => logs.add(m)));
    engine.status.listen((s) => setState(() => status = s));
    engine.count.listen((c) => setState(() => count = c));
  }

  @override
  void dispose() {
    engine.dispose();
    super.dispose();
  }

  Future<void> _testDevice() async {
    final c = IsapiClient(ip: AppConfig.instance.deviceIp, user: AppConfig.instance.username, pass: AppConfig.instance.password);
    final ok = await c.testConnection();
    setState(() => logs.add(ok
        ? '✅ Device reachable at ${AppConfig.instance.deviceIp}'
        : '❌ Device unreachable (or CORS blocked) at ${AppConfig.instance.deviceIp}'));
  }

  Future<void> _openSettings() async {
    final wasRunning = running;
    if (wasRunning) {
      engine.stop();
      setState(() => running = false);
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );

    // Config may have changed; if it was running, restart with new values.
    if (wasRunning) {
      await engine.start();
      setState(() => running = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Monitor (Web)'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: Text('Captured: $count')),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey.shade50,
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _testDevice,
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Test Device'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (running) {
                      engine.stop();
                    } else {
                      await engine.start();
                    }
                    setState(() => running = !running);
                  },
                  icon: Icon(running ? Icons.stop : Icons.play_arrow),
                  label: Text(running ? 'Stop' : 'Start'),
                ),
                Chip(label: Text(status)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('No events yet.'))
                : ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (_, i) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.fiber_manual_record,
                          size: 10, color: Colors.green),
                      title: Text(
                        logs[logs.length - 1 - i],
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}