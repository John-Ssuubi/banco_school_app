// ignore_for_file: deprecated_member_use, file_names, use_build_context_synchronously

import 'package:banco_mobile/DataBase/P4/p4_student_model.dart';
import 'package:banco_mobile/HeadTeacher/AssessmentTerm2/subject_analysis_term2.dart';
import 'package:banco_mobile/HeadTeacher/AssessmentTerm2/subject_contribution_term2.dart';
import 'package:banco_mobile/styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Design tokens
const _kRadius = 16.0;
const _kCardRadius = 20.0;

const _divColors = {
  'Division 1': Color(0xFF00C896),
  'Division 2': Color(0xFF3B9EFF),
  'Division 3': Color(0xFFFFB020),
  'Division 4': Color(0xFFFF6B35),
  'Ungraded': Color(0xFFEF4444),
};

Color _divColor(String div) => _divColors[div] ?? Colors.grey;

// Pure grade helpers
int _getAggregate(double score) {
  if (score == -1) return 9;
  if (score >= 80) return 1;
  if (score >= 75) return 2;
  if (score >= 70) return 3;
  if (score >= 65) return 4;
  if (score >= 60) return 5;
  if (score >= 55) return 6;
  if (score >= 50) return 7;
  if (score >= 45) return 8;
  return 9;
}

String _getDivision(int agg) {
  if (agg <= 12) return 'Division 1';
  if (agg <= 24) return 'Division 2';
  if (agg <= 32) return 'Division 3';
  if (agg <= 35) return 'Division 4';
  return 'Ungraded';
}

String _displayScore(double score) =>
    score == -1 ? '—' : score.toInt().toString();

// PDF export
Future<void> _downloadPdf({
  required BuildContext context,
  required String title,
  required List<StudentModelP4> students,
  required double Function(StudentModelP4) totalScore,
  required int Function(StudentModelP4) totalAgg,
  required double Function(StudentModelP4) avgScore,
  required double Function(dynamic) subjectScore,
}) async {
  final pdf = pw.Document();
  final sorted = List<StudentModelP4>.from(students)
    ..sort((a, b) => totalAgg(a).compareTo(totalAgg(b)));

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(24),
    build: (ctx) => [
      pw.Text(title,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 12),
      pw.Table.fromTextArray(
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        headers: ['#', 'Name', 'Total', 'Avg', 'Agg', 'Division'],
        data: sorted.asMap().entries.map((e) {
          final s = e.value;
          return [
            '${e.key + 1}',
            s.studentName ?? '—',
            totalScore(s) < 0 ? 'U' : totalScore(s).toInt().toString(),
            avgScore(s) < 0 ? 'U' : avgScore(s).toInt().toString(),
            '${totalAgg(s)}',
            _getDivision(totalAgg(s)),
          ];
        }).toList(),
      ),
      pw.SizedBox(height: 20),
      ...sorted.asMap().entries.map((e) {
        final s = e.value;
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('${e.key + 1}. ${s.studentName ?? "Student"}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              headers: ['Subject', 'Score', 'Agg'],
              data: s.subjectsScoreTerm2.map((sub) {
                final sc = subjectScore(sub);
                return [sub.subjectName, _displayScore(sc), '${_getAggregate(sc)}'];
              }).toList(),
            ),
            pw.SizedBox(height: 10),
          ],
        );
      }),
    ],
  ));

  await Printing.layoutPdf(
    onLayout: (_) async => pdf.save(),
    name: '$title.pdf',
  );
}

// Core view widget
class _TermView extends StatefulWidget {
  final String model;
  final String schoolId;
  final String examLabel;
  final double Function(dynamic subject) subjectScore;
  final Widget analyticsDest;
  final Widget contributionDest;

  const _TermView({
    required this.model,
    required this.schoolId,
    required this.examLabel,
    required this.subjectScore,
    required this.analyticsDest,
    required this.contributionDest,
  });

  @override
  State<_TermView> createState() => _TermViewState();
}

class _TermViewState extends State<_TermView> with SingleTickerProviderStateMixin {
  final String _year = DateTime.now().year.toString();
  final TextEditingController _search = TextEditingController();
  String _query = '';
  bool _fabOpen = false;
  late AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _search.addListener(() =>
        setState(() => _query = _search.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _search.dispose();
    _fabAnim.dispose();
    super.dispose();
  }

  // ── score helpers ──────────────────────────────────────────────────────────
  double _total(List subs) => subs.fold(0.0, (s, e) {
        final sc = widget.subjectScore(e);
        return s + (sc == -1 ? 0 : sc);
      });

  int _agg(List subs) =>
      subs.fold(0, (s, e) => s + _getAggregate(widget.subjectScore(e)));

  double _avg(List subs) {
    final marked = subs.where((e) => widget.subjectScore(e) != -1).toList();
    if (marked.isEmpty) return 0;
    return _total(marked) / marked.length;
  }

  // ── sort ───────────────────────────────────────────────────────────────────
  List<StudentModelP4> _sorted(List<StudentModelP4> src) {
    final f = src.where((s) {
      final name = (s.studentName ?? '').toLowerCase();
      final nin = (s.idNin ?? '').toLowerCase();
      return name.contains(_query) || nin.contains(_query);
    }).toList()
      ..sort((a, b) => _agg(a.subjectsScoreTerm2).compareTo(_agg(b.subjectsScoreTerm2)));
    return f;
  }

  // ── FAB toggle ─────────────────────────────────────────────────────────────
  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
    _fabOpen ? _fabAnim.forward() : _fabAnim.reverse();
  }

  // ── student dialog ─────────────────────────────────────────────────────────
  void _showDialog(BuildContext ctx, StudentModelP4 s, int pos) {
    final agg = _agg(s.subjectsScoreTerm2);
    final div = _getDivision(agg);
    final divClr = _divColor(div);

    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── header band ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [divClr.withOpacity(0.85), divClr.withOpacity(0.4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Text(
                    '$pos',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  s.studentName ?? 'Student',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(div,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),

            // ── stats row ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statChip('Total', _total(s.subjectsScoreTerm2).toInt().toString()),
                  _statChip('Avg', _avg(s.subjectsScoreTerm2).toStringAsFixed(1)),
                  _statChip('Agg', '$agg'),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── subject list ──
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.35),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: s.subjectsScoreTerm2.map((sub) {
                  final sc = widget.subjectScore(sub);
                  final agg = _getAggregate(sc);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(sub.subjectName,
                                style: const TextStyle(fontSize: 14))),
                        _aggBadge(agg),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 36,
                          child: Text(
                            _displayScore(sc),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: mainColor)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );

  Widget _aggBadge(int agg) {
    final colors = [
      null,
      const Color(0xFF00C896), // 1
      const Color(0xFF3B9EFF), // 2
      const Color(0xFF60D394), // 3
      const Color(0xFFAAD576), // 4
      const Color(0xFFFFB020), // 5
      const Color(0xFFFF9A3C), // 6
      const Color(0xFFFF6B35), // 7
      const Color(0xFFEF4444), // 8
      const Color(0xFF9B2335), // 9
    ];
    final clr = (agg >= 1 && agg <= 9) ? colors[agg]! : Colors.grey;
    return Container(
      width: 28,
      height: 22,
      decoration: BoxDecoration(
        color: clr.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: clr, width: 1),
      ),
      child: Center(
        child: Text('$agg',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: clr)),
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Schools')
          .doc(widget.schoolId)
          .collection('Years')
          .doc(_year)
          .collection(widget.model)
          .orderBy('studentName')
          .snapshots(),
      builder: (context, snapshot) {
        final allStudents = snapshot.hasData
            ? snapshot.data!.docs
                .map((d) => StudentModelP4.fromJson(d.data()))
                .toList()
            : <StudentModelP4>[];
        final students = _sorted(allStudents);

        return Scaffold(
          backgroundColor:
              isLight ? const Color(0xFFF5F7FA) : const Color(0xFF0F1117),
          body: Column(
            children: [
              // ── search bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: TextField(
                  controller: _search,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search student or NIN…',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _search.clear(),
                          )
                        : null,
                    filled: true,
                    fillColor: isLight ? Colors.white : const Color(0xFF1E2130),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_kRadius),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_kRadius),
                      borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.15), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_kRadius),
                      borderSide: BorderSide(color: mainColor, width: 1.5),
                    ),
                  ),
                ),
              ),

              // ── summary chips ──
              if (allStudents.isNotEmpty) _buildSummaryBar(allStudents),

              // ── student list ──
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasError
                        ? Center(child: Text('Error: ${snapshot.error}'))
                        : students.isEmpty
                            ? _emptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                                itemCount: students.length,
                                itemBuilder: (ctx, i) =>
                                    _studentCard(ctx, students[i], i),
                              ),
              ),
            ],
          ),
          floatingActionButton: _buildFab(allStudents),
        );
      },
    );
  }

  // ── summary bar ────────────────────────────────────────────────────────────
  Widget _buildSummaryBar(List<StudentModelP4> students) {
    final divCount = <String, int>{};
    for (final s in students) {
      final d = _getDivision(_agg(s.subjectsScoreTerm2));
      divCount[d] = (divCount[d] ?? 0) + 1;
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: [
          _chip('${students.length}', 'Total', Colors.grey),
          ...divCount.entries.map(
            (e) => _chip('${e.value}', e.key.replaceAll('Division ', 'Div '),
                _divColor(e.key)),
          ),
        ],
      ),
    );
  }

  Widget _chip(String count, String label, Color color) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(count,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13)),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
          ],
        ),
      );

  // ── student card ───────────────────────────────────────────────────────────
  Widget _studentCard(BuildContext ctx, StudentModelP4 s, int i) {
    final agg = _agg(s.subjectsScoreTerm2);
    final div = _getDivision(agg);
    final divClr = _divColor(div);
    final total = _total(s.subjectsScoreTerm2);
    final avg = _avg(s.subjectsScoreTerm2);
    final isLight = Theme.of(ctx).brightness == Brightness.light;

    return GestureDetector(
      onTap: () => _showDialog(ctx, s, i + 1),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : const Color(0xFF1E2130),
          borderRadius: BorderRadius.circular(_kCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_kCardRadius),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // left accent bar
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [divClr, divClr.withOpacity(0.4)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // rank badge
                Container(
                  width: 52,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${i + 1}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: divClr),
                      ),
                      Text('rank',
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.withOpacity(0.7))),
                    ],
                  ),
                ),

                // main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.studentName ?? 'No Name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: divClr.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                div.replaceAll('Division ', 'Div '),
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: divClr),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // subject pills
                        Wrap(
                          spacing: 5,
                          runSpacing: 4,
                          children: s.subjectsScoreTerm2.map((sub) {
                            final sc = widget.subjectScore(sub);
                            _getAggregate(sc);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isLight
                                    ? const Color(0xFFF0F2F5)
                                    : const Color(0xFF2A2D3E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${sub.subjectName.length > 3 ? sub.subjectName.substring(0, 3) : sub.subjectName} ${_displayScore(sc)}',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isLight
                                        ? Colors.black87
                                        : Colors.white70),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 8),

                        // stats row
                        Row(
                          children: [
                            _miniStat('Total',
                                total < 0 ? 'U' : total.toInt().toString()),
                            const SizedBox(width: 16),
                            _miniStat('Avg', avg.toStringAsFixed(1)),
                            const SizedBox(width: 16),
                            _miniStat('Agg', '$agg'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // chevron
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.chevron_right,
                      color: Colors.grey.withOpacity(0.4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      );

  // ── empty state ─────────────────────────────────────────────────────────────
  Widget _emptyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: Colors.grey.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              _query.isEmpty ? 'No students found.' : 'No results for "$_query"',
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );

  // ── expandable FAB ─────────────────────────────────────────────────────────
  Widget _buildFab(List<StudentModelP4> allStudents) {
    final items = [
      _FabItem(
        icon: Icons.analytics_rounded,
        label: 'Analytics',
        color: const Color(0xFF3B9EFF),
        onTap: () {
          _toggleFab();
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => widget.analyticsDest));
        },
      ),
      _FabItem(
        icon: Icons.insights_rounded,
        label: 'Insights',
        color: const Color(0xFF00C896),
        onTap: () {
          _toggleFab();
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => widget.contributionDest));
        },
      ),
      _FabItem(
        icon: Icons.picture_as_pdf_rounded,
        label: 'Export PDF',
        color: const Color(0xFFEF4444),
        onTap: allStudents.isEmpty
            ? null
            : () {
                _toggleFab();
                _downloadPdf(
                  context: context,
                  title: '${widget.model} — ${widget.examLabel} Assessment',
                  students: allStudents,
                  totalScore: (s) => _total(s.subjectsScoreTerm2),
                  totalAgg: (s) => _agg(s.subjectsScoreTerm2),
                  avgScore: (s) => _avg(s.subjectsScoreTerm2),
                  subjectScore: widget.subjectScore,
                );
              },
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // mini FABs
        ...items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final delay = (items.length - 1 - idx) * 0.12;

          return AnimatedBuilder(
            animation: _fabAnim,
            builder: (_, child) {
              final t = (_fabAnim.value - delay).clamp(0.0, 1.0);
              final curve = Curves.easeOutBack.transform(t);
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - curve) * 20),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // label
                  AnimatedBuilder(
                    animation: _fabAnim,
                    builder: (_, __) => Opacity(
                      opacity: (_fabAnim.value * 2).clamp(0.0, 1.0),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(item.label,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ),
                  FloatingActionButton.small(
                    heroTag: '${item.label}_${widget.examLabel}',
                    backgroundColor: item.color,
                    onPressed: item.onTap,
                    child: Icon(item.icon, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          );
        }),

        // main toggle FAB
        FloatingActionButton(
          heroTag: 'main_${widget.examLabel}',
          backgroundColor: mainColor,
          onPressed: _toggleFab,
          child: AnimatedBuilder(
            animation: _fabAnim,
            builder: (_, __) => Transform.rotate(
              angle: _fabAnim.value * 0.785, // 45°
              child: Icon(
                _fabOpen ? Icons.close : Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FabItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _FabItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}

// Public widgets for Term 2
class Term2Bot extends StatelessWidget {
  final String model;
  final String schoolId;
  const Term2Bot({super.key, required this.model, required this.schoolId});

  @override
  Widget build(BuildContext context) => _TermView(
        model: model,
        schoolId: schoolId,
        examLabel: 'BOT',
        subjectScore: (sub) => (sub.scoreBOT as num).toDouble(),
        analyticsDest: SubjectAnalysisBotTerm2(schoolId: schoolId, model: model),
        contributionDest: SubjectContributionBotTerm2(schoolId: schoolId, model: model),
      );
}

class Term2Mid extends StatelessWidget {
  final String model;
  final String schoolId;
  const Term2Mid({super.key, required this.model, required this.schoolId});

  @override
  Widget build(BuildContext context) => _TermView(
        model: model,
        schoolId: schoolId,
        examLabel: 'MID',
        subjectScore: (sub) => (sub.scoreMT as num).toDouble(),
        analyticsDest: SubjectAnalysisMidTerm2(schoolId: schoolId, model: model),
        contributionDest: SubjectContributionMidTerm2(schoolId: schoolId, model: model),
      );
}

class Term2End extends StatelessWidget {
  final String model;
  final String schoolId;
  const Term2End({super.key, required this.model, required this.schoolId});

  @override
  Widget build(BuildContext context) => _TermView(
        model: model,
        schoolId: schoolId,
        examLabel: 'END',
        subjectScore: (sub) => (sub.scoreEOT as num).toDouble(),
        analyticsDest: SubjectAnalysisEndTerm2(schoolId: schoolId, model: model),
        contributionDest: SubjectContributionEndTerm2(schoolId: schoolId, model: model),
      );
}