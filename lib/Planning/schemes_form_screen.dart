// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:banco_mobile/Planning/scheme_of_work.dart';
import 'package:banco_mobile/Planning/schemes_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:banco_mobile/styles.dart';

class SchemeFormScreen extends StatefulWidget {
  final String schoolId;
  final String classId;
  final String className;
  final String teacherUid;
  final String teacherName;
  final SchemeOfWork? existing;

  const SchemeFormScreen({
    super.key,
    required this.schoolId,
    required this.classId,
    required this.className,
    required this.teacherUid,
    required this.teacherName,
    this.existing,
  });

  @override
  State<SchemeFormScreen> createState() => _SchemeFormScreenState();
}

class _SchemeFormScreenState extends State<SchemeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SchemesService _service = SchemesService();

  // Subject list — later swap with Firestore subjects collection
  static const List<String> _subjects = [
    'Mathematics', 'English', 'Biology', 'Chemistry', 'Physics',
    'History', 'Geography', 'Literature', 'Agriculture',
    'Commerce', 'Accounting', 'Computer Science',
    'CRE', 'IRE', 'Entrepreneurship',
  ];

  late String _subject;
  late String _term;
  late int _year;
  late List<SchemeWeek> _weeks;
  late TextEditingController _remarksCtrl;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _subject = e?.subject ?? _subjects.first;
    _term = e?.term ?? 'Term 1';
    _year = e?.year ?? DateTime.now().year;
    _weeks = (e?.weeks.isNotEmpty ?? false)
        ? List<SchemeWeek>.from(e!.weeks)
        : [_blankWeek(1)];
    _remarksCtrl = TextEditingController(text: e?.generalRemarks ?? '');
  }

  @override
  void dispose() {
    _remarksCtrl.dispose();
    for (final w in _weeks) {
      // dispose controllers created inside week cards (handled per-card)
    }
    super.dispose();
  }

  SchemeWeek _blankWeek(int n) => SchemeWeek(weekNumber: n);

  // ─── Build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildLockedClassBanner()),
            SliverToBoxAdapter(child: _buildHeaderFields()),
            SliverToBoxAdapter(child: _buildWeeklyHeader()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _WeekCard(
                      key: ValueKey(_weeks[i].id),
                      week: _weeks[i],
                      index: i,
                      onChanged: (w) => setState(() => _weeks[i] = w),
                      onRemove: _weeks.length > 1
                          ? () => setState(() => _weeks.removeAt(i))
                          : null,
                    ),
                  ),
                  childCount: _weeks.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildAddWeekButton()),
            SliverToBoxAdapter(child: _buildRemarksSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.2)!],
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        _isEdit ? 'Edit Scheme of Work' : 'New Scheme of Work',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _buildLockedClassBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mainColor, Color.lerp(mainColor, Colors.black, 0.25)!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: mainColor.withOpacity(0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.className,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$_subject · $_term · $_year',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderFields() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Details'),
          const SizedBox(height: 12),
          _dropdownField<String>(
            label: 'Subject',
            icon: Icons.menu_book_rounded,
            value: _subject,
            items: _subjects,
            onChanged: (v) => setState(() => _subject = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dropdownField<String>(
                  label: 'Term',
                  icon: Icons.calendar_today_rounded,
                  value: _term,
                  items: const ['Term 1', 'Term 2', 'Term 3'],
                  onChanged: (v) => setState(() => _term = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdownField<int>(
                  label: 'Year',
                  icon: Icons.event_rounded,
                  value: _year,
                  items: [
                    DateTime.now().year - 1,
                    DateTime.now().year,
                    DateTime.now().year + 1,
                  ],
                  onChanged: (v) => setState(() => _year = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _readOnlyField(
            label: 'Teacher',
            icon: Icons.person_rounded,
            value: widget.teacherName,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyHeader() {
    final totalPeriods = _weeks.fold<int>(0, (s, w) => s + w.periods);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          const Text(
            'Weekly Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A202C),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_weeks.length} weeks · $totalPeriods periods',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddWeekButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _weeks.add(_blankWeek(_weeks.length + 1));
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: mainColor.withOpacity(0.3),
              style: BorderStyle.solid,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  color: mainColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add Week',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: mainColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemarksSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('General Remarks'),
          const SizedBox(height: 10),
          TextField(
            controller: _remarksCtrl,
            maxLines: 3,
            decoration: _inputDecoration(
              hint: 'Any notes about this scheme…',
              icon: Icons.notes_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canSubmit = _weeks.every((w) => w.isComplete);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : () => _save(SchemeStatus.draft),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: mainColor.withOpacity(0.4)),
                ),
                child: Text(
                  'Save Draft',
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed:
                    (_saving || !canSubmit) ? null : () => _save(SchemeStatus.pending),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit for Approval',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Save / Submit ────────────────────────────────────────
  Future<void> _save(String targetStatus) async {
    if (!_formKey.currentState!.validate()) return;
    if (_weeks.any((w) => !w.isComplete)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Every week needs a topic and periods'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final scheme = SchemeOfWork(
        id: widget.existing?.id ?? '',
        schoolId: widget.schoolId,
        classId: widget.classId,
        className: widget.className,
        subject: _subject,
        term: _term,
        year: _year,
        teacherUid: widget.teacherUid,
        teacherName: widget.teacherName,
        status: targetStatus,
        weeks: _weeks,
        generalRemarks: _remarksCtrl.text.trim(),
        submittedAt: targetStatus == SchemeStatus.pending
            ? DateTime.now()
            : widget.existing?.submittedAt,
      );

      if (_isEdit) {
        await _service.update(scheme);
        if (targetStatus == SchemeStatus.pending) {
          await _service.submit(widget.schoolId, scheme.id);
        }
      } else {
        final id = await _service.create(scheme);
        if (targetStatus == SchemeStatus.pending) {
          await _service.submit(widget.schoolId, id);
        }
      }

      if (!mounted) return;
      Navigator.pop(context, scheme);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ─── Reusable field widgets ───────────────────────────────
  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A202C),
        ),
      );

  InputDecoration _inputDecoration({
    String? hint,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon:
          icon != null ? Icon(icon, color: mainColor, size: 18) : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mainColor, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required IconData icon,
    required T value,
    required List<T> items,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      decoration: _inputDecoration(hint: label, icon: icon),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF1A202C),
        fontWeight: FontWeight.w500,
      ),
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: Text('$e'),
              ))
          .toList(),
    );
  }

  Widget _readOnlyField({
    required String label,
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A202C),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(Icons.lock_rounded, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// WEEK CARD — collapsible editor per week
// ════════════════════════════════════════════════════════════
class _WeekCard extends StatefulWidget {
  final SchemeWeek week;
  final int index;
  final ValueChanged<SchemeWeek> onChanged;
  final VoidCallback? onRemove;

  const _WeekCard({
    super.key,
    required this.week,
    required this.index,
    required this.onChanged,
    this.onRemove,
  });

  @override
  State<_WeekCard> createState() => _WeekCardState();
}

class _WeekCardState extends State<_WeekCard> {
  late TextEditingController _topicCtrl;
  late TextEditingController _subTopicsCtrl;
  late TextEditingController _objectivesCtrl;
  late TextEditingController _periodsCtrl;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  late TextEditingController _remarksCtrl;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    final w = widget.week;
    _topicCtrl = TextEditingController(text: w.topic);
    _subTopicsCtrl = TextEditingController(text: w.subTopics);
    _objectivesCtrl = TextEditingController(text: w.objectives);
    _periodsCtrl =
        TextEditingController(text: w.periods == 0 ? '' : '${w.periods}');
    _startCtrl = TextEditingController(text: w.startDate);
    _endCtrl = TextEditingController(text: w.endDate);
    _remarksCtrl = TextEditingController(text: w.remarks);
    // Auto-expand if week is blank (new row)
    _expanded = !w.isComplete;
  }

  @override
  void dispose() {
    _topicCtrl.dispose();
    _subTopicsCtrl.dispose();
    _objectivesCtrl.dispose();
    _periodsCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      SchemeWeek(
        id: widget.week.id,
        weekNumber: widget.week.weekNumber,
        startDate: _startCtrl.text.trim(),
        endDate: _endCtrl.text.trim(),
        topic: _topicCtrl.text.trim(),
        subTopics: _subTopicsCtrl.text.trim(),
        objectives: _objectivesCtrl.text.trim(),
        periods: int.tryParse(_periodsCtrl.text.trim()) ?? 0,
        remarks: _remarksCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.week;
    final complete = w.isComplete;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: complete ? mainColor.withOpacity(0.25) : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: complete
                          ? mainColor.withOpacity(0.12)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'W${w.weekNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: complete ? mainColor : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.topic.isEmpty ? 'Untitled week' : w.topic,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: w.topic.isEmpty
                                ? Colors.grey.shade400
                                : const Color(0xFF1A202C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${w.periods} periods${w.startDate.isNotEmpty ? " · ${w.startDate} – ${w.endDate}" : ""}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onRemove != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: Colors.red.shade400, size: 20),
                      onPressed: widget.onRemove,
                      tooltip: 'Remove week',
                    ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(child: _dateField('Start', _startCtrl)),
                      const SizedBox(width: 10),
                      Expanded(child: _dateField('End', _endCtrl)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    controller: _topicCtrl,
                    label: 'Topic *',
                    hint: 'e.g. Cell Structure',
                    icon: Icons.title_rounded,
                    onChanged: (_) => _emit(),
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    controller: _subTopicsCtrl,
                    label: 'Sub-topics',
                    hint: 'One per line',
                    icon: Icons.list_alt_rounded,
                    maxLines: 2,
                    onChanged: (_) => _emit(),
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    controller: _objectivesCtrl,
                    label: 'Learning objectives',
                    hint: 'What learners should achieve',
                    icon: Icons.checklist_rounded,
                    maxLines: 2,
                    onChanged: (_) => _emit(),
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    controller: _periodsCtrl,
                    label: 'Periods *',
                    hint: 'e.g. 6',
                    icon: Icons.schedule_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _emit(),
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    controller: _remarksCtrl,
                    label: 'Remarks',
                    hint: 'Optional notes',
                    icon: Icons.notes_rounded,
                    onChanged: (_) => _emit(),
                  ),
                ],
              ),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A202C)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 12),
            prefixIcon: Icon(icon, size: 16, color: mainColor),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: mainColor, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          readOnly: true,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 2),
            );
            if (picked != null) {
              ctrl.text =
                  '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
              _emit();
            }
          },
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A202C)),
          decoration: InputDecoration(
            hintText: 'dd/mm/yyyy',
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 12),
            suffixIcon:
                Icon(Icons.calendar_today_rounded, size: 14, color: mainColor),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: mainColor, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }
}